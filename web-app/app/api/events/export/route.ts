import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import ical from 'ical-generator';

// GET /api/events/export - Export events as ICS file
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const eventIds = searchParams.get('eventIds')?.split(',') || [];
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');

    const where: any = { userId: session.user.id };

    if (eventIds.length > 0) {
      where.id = { in: eventIds };
    }

    if (startDate && endDate) {
      where.startDate = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      };
    }

    const events = await prisma.calendarEvent.findMany({
      where,
      orderBy: { startDate: 'asc' },
    });

    // Create ICS calendar
    const calendar = ical({
      name: 'ScheduleShare Events',
      prodId: '//ScheduleShare//EN',
    });

    events.forEach(event => {
      calendar.createEvent({
        id: event.id,
        start: event.startDate,
        end: event.endDate,
        summary: event.title,
        description: event.notes || undefined,
        location: event.location || undefined,
      });
    });

    const icsContent = calendar.toString();

    return new NextResponse(icsContent, {
      status: 200,
      headers: {
        'Content-Type': 'text/calendar',
        'Content-Disposition': 'attachment; filename="events.ics"',
      },
    });
  } catch (error) {
    console.error('Error exporting events:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

