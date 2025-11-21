import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const registerSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  email: z.string().email(),
  quantity: z.number().int().positive().default(1),
});

// POST /api/public-events/[slug]/register - Register for event
export async function POST(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const session = await getServerSession(authOptions);
    const body = await request.json();
    const validatedData = registerSchema.parse(body);

    // Get event
    const event = await prisma.publicEvent.findUnique({
      where: { slug: params.slug },
      include: {
        registrations: {
          where: { status: 'CONFIRMED' },
        },
      },
    });

    if (!event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 });
    }

    if (event.status !== 'PUBLISHED') {
      return NextResponse.json({ error: 'Event is not available for registration' }, { status: 400 });
    }

    // Check if registration deadline has passed
    if (event.registrationDeadline && new Date() > event.registrationDeadline) {
      return NextResponse.json({ error: 'Registration deadline has passed' }, { status: 400 });
    }

    // Check capacity
    const confirmedCount = event.registrations.length;
    if (event.capacity && confirmedCount + validatedData.quantity > event.capacity) {
      return NextResponse.json({ error: 'Event is at capacity' }, { status: 400 });
    }

    // Check if already registered
    const existingRegistration = await prisma.eventRegistration.findFirst({
      where: {
        eventId: event.id,
        email: validatedData.email,
        status: { in: ['CONFIRMED', 'PENDING'] },
      },
    });

    if (existingRegistration) {
      return NextResponse.json({ error: 'Already registered for this event' }, { status: 400 });
    }

    // Create registration
    const status = event.requiresApproval ? 'PENDING' : 'CONFIRMED';
    const totalAmount = event.price * validatedData.quantity;

    const registration = await prisma.eventRegistration.create({
      data: {
        ...validatedData,
        status,
        totalAmount,
        eventId: event.id,
        userId: session?.user?.id,
        paymentStatus: totalAmount > 0 ? 'PENDING' : undefined,
      },
      include: {
        event: {
          select: {
            id: true,
            title: true,
            slug: true,
            startDate: true,
          },
        },
      },
    });

    // Update event registration count
    await prisma.publicEvent.update({
      where: { id: event.id },
      data: {
        registrationCount: { increment: validatedData.quantity },
      },
    });

    // Update organizer's total attendees (if profile exists)
    try {
      await prisma.userProfile.update({
        where: { userId: event.organizerId },
        data: {
          totalAttendees: { increment: validatedData.quantity },
        },
      });
    } catch (err) {
      // Profile might not exist, continue anyway
      console.log('Could not update organizer profile:', err);
    }

    return NextResponse.json({
      success: true,
      registration,
      message: status === 'PENDING' 
        ? 'Registration submitted for approval' 
        : 'Successfully registered for event',
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error registering for event:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// DELETE /api/public-events/[slug]/register - Cancel registration
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

    const registration = await prisma.eventRegistration.findFirst({
      where: {
        eventId: event.id,
        userId: session.user.id,
        status: { in: ['CONFIRMED', 'PENDING'] },
      },
    });

    if (!registration) {
      return NextResponse.json({ error: 'Registration not found' }, { status: 404 });
    }

    // Update registration status
    await prisma.eventRegistration.update({
      where: { id: registration.id },
      data: { status: 'CANCELLED' },
    });

    // Update event registration count
    await prisma.publicEvent.update({
      where: { id: event.id },
      data: {
        registrationCount: { decrement: registration.quantity },
      },
    });

    // Update organizer's total attendees (if profile exists)
    try {
      await prisma.userProfile.update({
        where: { userId: event.organizerId },
        data: {
          totalAttendees: { decrement: registration.quantity },
        },
      });
    } catch (err) {
      // Profile might not exist, continue anyway
      console.log('Could not update organizer profile:', err);
    }

    return NextResponse.json({
      success: true,
      message: 'Registration cancelled successfully',
    });
  } catch (error) {
    console.error('Error cancelling registration:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

