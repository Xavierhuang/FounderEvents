import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const createProfileSchema = z.object({
  profileURL: z.string().url('Invalid LinkedIn URL'),
  name: z.string().min(1, 'Name is required'),
  company: z.string().optional(),
  title: z.string().optional(),
  notes: z.string().optional(),
  linkedEventId: z.string().optional(),
});

// GET /api/linkedin - Fetch user's LinkedIn profiles
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const eventId = searchParams.get('eventId');
    const search = searchParams.get('search');

    const where: any = { userId: session.user.id };

    if (eventId) {
      where.linkedEventId = eventId;
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { company: { contains: search, mode: 'insensitive' } },
        { title: { contains: search, mode: 'insensitive' } },
      ];
    }

    const profiles = await prisma.linkedInProfile.findMany({
      where,
      include: {
        linkedEvent: {
          select: {
            id: true,
            title: true,
            startDate: true,
          },
        },
      },
      orderBy: { linkedDate: 'desc' },
    });

    return NextResponse.json({
      success: true,
      profiles,
    });
  } catch (error) {
    console.error('Error fetching LinkedIn profiles:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST /api/linkedin - Create new LinkedIn profile
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const validatedData = createProfileSchema.parse(body);

    const profile = await prisma.linkedInProfile.create({
      data: {
        profileURL: validatedData.profileURL,
        name: validatedData.name,
        company: validatedData.company,
        title: validatedData.title,
        notes: validatedData.notes,
        linkedEventId: validatedData.linkedEventId,
        userId: session.user.id,
      },
      include: {
        linkedEvent: {
          select: {
            id: true,
            title: true,
            startDate: true,
          },
        },
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

    console.error('Error creating LinkedIn profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

