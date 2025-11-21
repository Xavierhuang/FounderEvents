import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const createProfileSchema = z.object({
  username: z.string().min(3).max(30).regex(/^[a-zA-Z0-9_-]+$/, 'Username can only contain letters, numbers, hyphens, and underscores'),
  displayName: z.string().min(1).max(100),
  bio: z.string().max(500).optional(),
  avatar: z.string().url().optional(),
  website: z.string().url().optional(),
  twitter: z.string().optional(),
  linkedin: z.string().optional(),
  instagram: z.string().optional(),
});

// GET /api/profile - Get user's profile
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const profile = await prisma.userProfile.findUnique({
      where: { userId: session.user.id },
    });

    // Also fetch user's organized events
    let organizedEvents = [];
    if (profile) {
      organizedEvents = await prisma.publicEvent.findMany({
        where: { organizerId: session.user.id },
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: {
              registrations: { where: { status: 'CONFIRMED' } },
              comments: true,
              likes: true,
            },
          },
        },
      });
    }

    return NextResponse.json({
      success: true,
      profile: profile ? {
        ...profile,
        organizedEvents,
        publicEvents: organizedEvents, // Alias for backward compatibility
      } : null,
      hasProfile: !!profile,
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST /api/profile - Create user profile
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const validatedData = createProfileSchema.parse(body);

    // Check if profile already exists
    const existingProfile = await prisma.userProfile.findUnique({
      where: { userId: session.user.id },
    });

    if (existingProfile) {
      return NextResponse.json(
        { error: 'Profile already exists' },
        { status: 400 }
      );
    }

    // Check if username is taken
    const usernameExists = await prisma.userProfile.findUnique({
      where: { username: validatedData.username },
    });

    if (usernameExists) {
      return NextResponse.json(
        { error: 'Username is already taken' },
        { status: 400 }
      );
    }

    const profile = await prisma.userProfile.create({
      data: {
        ...validatedData,
        userId: session.user.id,
      },
    });

    return NextResponse.json({
      success: true,
      profile,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error creating profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// PUT /api/profile - Update user profile
export async function PUT(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const validatedData = createProfileSchema.partial().parse(body);

    // If updating username, check if it's taken
    if (validatedData.username) {
      const usernameExists = await prisma.userProfile.findFirst({
        where: {
          username: validatedData.username,
          userId: { not: session.user.id },
        },
      });

      if (usernameExists) {
        return NextResponse.json(
          { error: 'Username is already taken' },
          { status: 400 }
        );
      }
    }

    const profile = await prisma.userProfile.update({
      where: { userId: session.user.id },
      data: validatedData,
    });

    return NextResponse.json({
      success: true,
      profile,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error updating profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

