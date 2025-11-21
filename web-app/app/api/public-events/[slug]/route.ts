import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

// GET /api/public-events/[slug] - Get event details
export async function GET(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const session = await getServerSession(authOptions);

    const event = await prisma.publicEvent.findUnique({
      where: { slug: params.slug },
      include: {
        organizer: {
          select: {
            id: true,
            name: true,
            image: true,
            profile: {
              select: {
                username: true,
                displayName: true,
                avatar: true,
                bio: true,
              },
            },
          },
        },
        categories: true,
        registrations: {
          where: { status: 'CONFIRMED' },
          select: {
            id: true,
            firstName: true,
            lastName: true,
            user: {
              select: {
                profile: {
                  select: {
                    username: true,
                    avatar: true,
                  },
                },
              },
            },
          },
          take: 20,
        },
        _count: {
          select: {
            registrations: { where: { status: 'CONFIRMED' } },
            comments: true,
            likes: true,
          },
        },
      },
    });

    if (!event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 });
    }

    // Check if user is registered
    let isRegistered = false;
    let isLiked = false;
    let userRegistration = null;

    if (session?.user?.id) {
      userRegistration = await prisma.eventRegistration.findFirst({
        where: {
          eventId: event.id,
          userId: session.user.id,
          status: { in: ['CONFIRMED', 'PENDING'] },
        },
      });
      isRegistered = !!userRegistration;

      const like = await prisma.eventLike.findUnique({
        where: {
          userId_eventId: {
            userId: session.user.id,
            eventId: event.id,
          },
        },
      });
      isLiked = !!like;
    }

    // Increment view count
    await prisma.publicEvent.update({
      where: { id: event.id },
      data: { viewCount: { increment: 1 } },
    });

    return NextResponse.json({
      success: true,
      event,
      isRegistered,
      isLiked,
      userRegistration,
    });
  } catch (error) {
    console.error('Error fetching event:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// PUT /api/public-events/[slug] - Update event
export async function PUT(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const event = await prisma.publicEvent.findUnique({
      where: { slug: params.slug },
    });

    if (!event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 });
    }

    if (event.organizerId !== session.user.id) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const body = await request.json();

    // Handle publishedAt timestamp when publishing
    const updateData: any = {
      ...body,
      startDate: body.startDate ? new Date(body.startDate) : undefined,
      endDate: body.endDate ? new Date(body.endDate) : undefined,
      registrationDeadline: body.registrationDeadline
        ? new Date(body.registrationDeadline)
        : undefined,
    };

    // Set publishedAt when publishing for the first time
    if (body.status === 'PUBLISHED' && event.status !== 'PUBLISHED') {
      updateData.publishedAt = new Date();
    }

    // Clear publishedAt when unpublishing
    if (body.status === 'DRAFT' && event.status === 'PUBLISHED') {
      updateData.publishedAt = null;
    }

    const updatedEvent = await prisma.publicEvent.update({
      where: { slug: params.slug },
      data: updateData,
      include: {
        organizer: {
          select: {
            id: true,
            name: true,
            profile: true,
          },
        },
        categories: true,
      },
    });

    return NextResponse.json({
      success: true,
      event: updatedEvent,
    });
  } catch (error) {
    console.error('Error updating event:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// DELETE /api/public-events/[slug] - Delete event
export async function DELETE(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const event = await prisma.publicEvent.findUnique({
      where: { slug: params.slug },
    });

    if (!event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 });
    }

    if (event.organizerId !== session.user.id) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    await prisma.publicEvent.delete({
      where: { slug: params.slug },
    });

    // Update profile stats
    await prisma.userProfile.update({
      where: { userId: session.user.id },
      data: {
        totalEvents: { decrement: 1 },
      },
    });

    return NextResponse.json({
      success: true,
      message: 'Event deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting event:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

