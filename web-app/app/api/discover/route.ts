import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

// GET /api/discover - Fetch both Gary's Guide events and user-created featured events
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const eventType = searchParams.get('eventType') || 'all';
    const search = searchParams.get('search');

    let events: any[] = [];

    // If featured filter, get user-created featured events
    if (eventType === 'featured') {
      const publicEvents = await prisma.publicEvent.findMany({
        where: {
          isFeatured: true,
          status: 'PUBLISHED',
          visibility: 'PUBLIC',
        },
        include: {
          organizer: {
            select: {
              name: true,
              email: true,
            },
          },
        },
        orderBy: {
          startDate: 'asc',
        },
        take: 50,
      });

      // Transform PublicEvent to match GarysGuideEvent structure for UI consistency
      events = publicEvents.map(event => ({
        id: event.id,
        title: event.title,
        date: new Date(event.startDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        time: new Date(event.startDate).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }),
        price: event.price > 0 ? `$${event.price}` : 'Free',
        venue: event.venueName || event.locationType,
        speakers: event.shortDescription || '',
        url: `/events/${event.slug}`,
        isGaryEvent: false,
        isPopularEvent: false,
        isFeatured: true,
        week: new Date(event.startDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }).toUpperCase(),
      }));
    } else {
      // Get Gary's Guide events
      const where: any = { isActive: true };

      // Event type filter for Gary's Guide events
      if (eventType === 'popular') {
        where.isPopularEvent = true;
      }

      // Search filter
      if (search) {
        where.OR = [
          { title: { contains: search, mode: 'insensitive' } },
          { venue: { contains: search, mode: 'insensitive' } },
          { speakers: { contains: search, mode: 'insensitive' } },
        ];
      }

      events = await prisma.garysGuideEvent.findMany({
        where,
        orderBy: [
          { isPopularEvent: 'desc' },
          { scrapedAt: 'desc' },
        ],
        take: 50,
      });
    }

    return NextResponse.json({
      success: true,
      events,
    });
  } catch (error) {
    console.error('Error fetching discover events:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST /api/discover/refresh - Refresh Gary's Guide events (admin/cron job)
export async function POST(request: NextRequest) {
  try {
    // This would typically be called by a cron job or admin endpoint
    // For now, we'll create some sample data
    
    const sampleEvents = [
      {
        title: 'NYC Tech Meetup: AI & Machine Learning',
        date: 'Dec 15',
        time: '6:00 PM',
        price: 'Free',
        venue: 'WeWork Union Square',
        speakers: 'Dr. Sarah Chen (Google AI), Mike Rodriguez (OpenAI)',
        url: 'https://www.garysguide.com/events/nyc-tech-meetup-ai-ml',
        isGaryEvent: false,
        isPopularEvent: true,
        week: 'DEC 15',
      },
      {
        title: 'Startup Pitch Night',
        date: 'Dec 18',
        time: '7:00 PM',
        price: '$25',
        venue: 'TechHub NYC',
        speakers: 'Various startup founders and VCs',
        url: 'https://www.garysguide.com/events/startup-pitch-night',
        isGaryEvent: false,
        isPopularEvent: false,
        week: 'DEC 18',
      },
      {
        title: 'Women in Tech Networking',
        date: 'Dec 20',
        time: '6:30 PM',
        price: 'Free',
        venue: 'Flatiron Building',
        speakers: 'Emily Johnson (CTO, DataFlow), Lisa Wang (Founder, TechWomen)',
        url: 'https://www.garysguide.com/events/women-in-tech-networking',
        isGaryEvent: false,
        isPopularEvent: true,
        week: 'DEC 20',
      },
      {
        title: 'Blockchain & Web3 Summit',
        date: 'Dec 22',
        time: '5:00 PM',
        price: '$50',
        venue: 'Blockchain Center NYC',
        speakers: 'Alex Thompson (Ethereum Foundation), Nina Patel (Coinbase)',
        url: 'https://www.garysguide.com/events/blockchain-web3-summit',
        isGaryEvent: false,
        isPopularEvent: false,
        week: 'DEC 22',
      },
    ];

    // Upsert sample events
    for (const eventData of sampleEvents) {
      await prisma.garysGuideEvent.upsert({
        where: { url: eventData.url },
        update: { ...eventData, scrapedAt: new Date() },
        create: { ...eventData, scrapedAt: new Date() },
      });
    }

    return NextResponse.json({
      success: true,
      message: `Refreshed ${sampleEvents.length} events`,
    });
  } catch (error) {
    console.error('Error refreshing discover events:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
