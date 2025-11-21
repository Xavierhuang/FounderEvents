import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const updateSettingsSchema = z.object({
  preferences: z.object({
    timezone: z.string().optional(),
    theme: z.enum(['light', 'dark', 'system']).optional(),
    defaultEventDuration: z.number().min(300).optional(),
    weekStartsOn: z.number().min(0).max(6).optional(),
  }).optional(),
  calendar: z.object({
    googleCalendarEnabled: z.boolean().optional(),
    googleCalendarId: z.string().optional(),
    autoSync: z.boolean().optional(),
    syncInterval: z.number().min(300).optional(),
  }).optional(),
});

// GET /api/settings - Get user settings
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const preferences = await prisma.userPreferences.findUnique({
      where: { userId: session.user.id },
    });

    const calendarSettings = await prisma.calendarSettings.findUnique({
      where: { userId: session.user.id },
    });

    return NextResponse.json({
      success: true,
      settings: {
        preferences,
        calendar: calendarSettings,
      },
    });
  } catch (error) {
    console.error('Error fetching settings:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// PUT /api/settings - Update user settings
export async function PUT(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const validatedData = updateSettingsSchema.parse(body);

    let preferences = null;
    let calendarSettings = null;

    // Update preferences
    if (validatedData.preferences) {
      preferences = await prisma.userPreferences.upsert({
        where: { userId: session.user.id },
        update: validatedData.preferences,
        create: {
          ...validatedData.preferences,
          userId: session.user.id,
        },
      });
    }

    // Update calendar settings
    if (validatedData.calendar) {
      calendarSettings = await prisma.calendarSettings.upsert({
        where: { userId: session.user.id },
        update: validatedData.calendar,
        create: {
          ...validatedData.calendar,
          userId: session.user.id,
        },
      });
    }

    return NextResponse.json({
      success: true,
      settings: {
        preferences,
        calendar: calendarSettings,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error updating settings:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

