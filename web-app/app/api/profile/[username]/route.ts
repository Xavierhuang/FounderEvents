import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// GET /api/profile/[username] - Get public profile by username
export async function GET(
  request: NextRequest,
  { params }: { params: { username: string } }
) {
  try {
    const profile = await prisma.userProfile.findUnique({
      where: { username: params.username },
      include: {
        user: {
          select: {
            name: true,
            image: true,
            createdAt: true,
          },
        },
      },
    });

    if (!profile) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 });
    }

    // Get user's public events
    const events = await prisma.publicEvent.findMany({
      where: {
        organizerId: profile.userId,
        status: 'PUBLISHED',
        visibility: 'PUBLIC',
      },
      orderBy: { startDate: 'desc' },
      take: 10,
      select: {
        id: true,
        slug: true,
        title: true,
        shortDescription: true,
        startDate: true,
        coverImage: true,
        registrationCount: true,
        likeCount: true,
      },
    });

    return NextResponse.json({
      success: true,
      profile,
      events,
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

