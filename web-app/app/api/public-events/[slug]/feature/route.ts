import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

// POST /api/public-events/[slug]/feature - Feature/unfeature an event (admin only)
export async function POST(
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

    // Check if user is the organizer (for now, only organizers can feature their events)
    // In production, you might want to have admin-only featuring
    if (event.organizerId !== session.user.id) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    const { isFeatured } = await request.json();

    const updatedEvent = await prisma.publicEvent.update({
      where: { slug: params.slug },
      data: { isFeatured: isFeatured },
    });

    return NextResponse.json({
      success: true,
      event: updatedEvent,
      message: isFeatured ? 'Event featured successfully' : 'Event unfeatured successfully',
    });
  } catch (error) {
    console.error('Error featuring event:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

