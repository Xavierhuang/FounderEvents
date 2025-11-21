import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { google } from 'googleapis';

// POST /api/calendar/google/sync - Sync events with Google Calendar
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Get user's calendar settings
    const calendarSettings = await prisma.calendarSettings.findUnique({
      where: { userId: session.user.id },
    });

    if (!calendarSettings?.googleCalendarEnabled) {
      return NextResponse.json(
        { error: 'Google Calendar sync is not enabled' },
        { status: 400 }
      );
    }

    // Get user's access token from session
    // Note: In production, you'd need to handle token refresh
    const accessToken = (session as any).accessToken;
    if (!accessToken) {
      return NextResponse.json(
        { error: 'Google Calendar access token not found' },
        { status: 401 }
      );
    }

    // Initialize Google Calendar API
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET
    );
    oauth2Client.setCredentials({ access_token: accessToken });

    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    // Get events from our database
    const events = await prisma.calendarEvent.findMany({
      where: { 
        userId: session.user.id,
        eventIdentifier: null, // Only sync events not already synced
      },
    });

    const syncedEvents = [];
    const errors = [];

    // Sync each event to Google Calendar
    for (const event of events) {
      try {
        const googleEvent = await calendar.events.insert({
          calendarId: calendarSettings.googleCalendarId || 'primary',
          requestBody: {
            summary: event.title,
            description: event.notes || undefined,
            location: event.location || undefined,
            start: {
              dateTime: event.startDate.toISOString(),
              timeZone: 'America/New_York',
            },
            end: {
              dateTime: event.endDate.toISOString(),
              timeZone: 'America/New_York',
            },
          },
        });

        // Update our database with the Google Calendar event ID
        await prisma.calendarEvent.update({
          where: { id: event.id },
          data: { eventIdentifier: googleEvent.data.id || undefined },
        });

        syncedEvents.push(event.id);
      } catch (error) {
        console.error(`Error syncing event ${event.id}:`, error);
        errors.push({ eventId: event.id, error: (error as Error).message });
      }
    }

    return NextResponse.json({
      success: true,
      syncedCount: syncedEvents.length,
      errors,
    });
  } catch (error) {
    console.error('Error syncing with Google Calendar:', error);
    return NextResponse.json(
      { 
        error: 'Calendar sync failed', 
        details: error instanceof Error ? error.message : 'Unknown error' 
      },
      { status: 500 }
    );
  }
}

// GET /api/calendar/google/sync - Check sync status
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const calendarSettings = await prisma.calendarSettings.findUnique({
      where: { userId: session.user.id },
    });

    const totalEvents = await prisma.calendarEvent.count({
      where: { userId: session.user.id },
    });

    const syncedEvents = await prisma.calendarEvent.count({
      where: { 
        userId: session.user.id,
        eventIdentifier: { not: null },
      },
    });

    return NextResponse.json({
      success: true,
      isEnabled: calendarSettings?.googleCalendarEnabled || false,
      totalEvents,
      syncedEvents,
      unsyncedEvents: totalEvents - syncedEvents,
    });
  } catch (error) {
    console.error('Error checking sync status:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

