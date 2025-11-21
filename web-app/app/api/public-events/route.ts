import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const createEventSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().min(1),
  shortDescription: z.string().max(300).optional(),
  startDate: z.string().datetime(),
  endDate: z.string().datetime(),
  timezone: z.string().default('America/New_York'),
  locationType: z.enum(['PHYSICAL', 'VIRTUAL', 'HYBRID']),
  venueName: z.string().optional(),
  venueAddress: z.string().optional(),
  venueCity: z.string().optional(),
  venueState: z.string().optional(),
  venueZipCode: z.string().optional(),
  virtualLink: z.preprocess(
    (val) => (val === '' || !val ? undefined : val),
    z.string().url().optional()
  ),
  coverImage: z.preprocess(
    (val) => (val === '' || !val ? undefined : val),
    z.string().url().optional()
  ),
  isPublic: z.boolean().default(true),
  requiresApproval: z.boolean().default(false),
  capacity: z.number().int().positive().optional(),
  registrationDeadline: z.string().datetime().optional(),
  price: z.number().min(0).default(0),
  currency: z.string().default('USD'),
  tags: z.array(z.string()).default([]),
  categoryIds: z.array(z.string()).default([]),
});

// GET /api/public-events - List public events with filters
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const search = searchParams.get('search');
    const categoryId = searchParams.get('categoryId');
    const locationType = searchParams.get('locationType');
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');
    const isFree = searchParams.get('isFree') === 'true';
    const isFeatured = searchParams.get('isFeatured') === 'true';
    const city = searchParams.get('city');
    const organizerId = searchParams.get('organizerId');
    const page = parseInt(searchParams.get('page') || '1');
    const pageSize = parseInt(searchParams.get('pageSize') || '20');
    const sortBy = searchParams.get('sortBy') || 'startDate';
    const sortOrder = searchParams.get('sortOrder') || 'asc';

    const where: any = {
      status: 'PUBLISHED',
      visibility: 'PUBLIC',
      startDate: { gte: new Date() }, // Only upcoming events
    };

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
        { tags: { has: search } },
      ];
    }

    if (locationType) {
      where.locationType = locationType;
    }

    if (startDate) {
      where.startDate = { ...where.startDate, gte: new Date(startDate) };
    }

    if (endDate) {
      where.endDate = { lte: new Date(endDate) };
    }

    if (isFree) {
      where.price = 0;
    }

    if (isFeatured) {
      where.isFeatured = true;
    }

    if (city) {
      where.venueCity = { contains: city, mode: 'insensitive' };
    }

    if (organizerId) {
      where.organizerId = organizerId;
    }

    const [events, total] = await Promise.all([
      prisma.publicEvent.findMany({
        where,
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
                },
              },
            },
          },
          categories: true,
          _count: {
            select: {
              registrations: { where: { status: 'CONFIRMED' } },
              comments: true,
              likes: true,
            },
          },
        },
        orderBy: { [sortBy]: sortOrder },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      prisma.publicEvent.count({ where }),
    ]);

    return NextResponse.json({
      success: true,
      events,
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize),
    });
  } catch (error) {
    console.error('Error fetching public events:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST /api/public-events - Create new public event
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Check if user has a profile
    const profile = await prisma.userProfile.findUnique({
      where: { userId: session.user.id },
    });

    if (!profile) {
      return NextResponse.json(
        { error: 'You must create a profile before creating events' },
        { status: 400 }
      );
    }

    const body = await request.json();
    console.log('Received event data:', JSON.stringify(body, null, 2));
    const validatedData = createEventSchema.parse(body);
    console.log('Validated data:', JSON.stringify(validatedData, null, 2));

    // Generate slug from title
    const baseSlug = validatedData.title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
    
    // Ensure slug is unique
    let slug = baseSlug;
    let counter = 1;
    while (await prisma.publicEvent.findUnique({ where: { slug } })) {
      slug = `${baseSlug}-${counter}`;
      counter++;
    }

    // Create the event
    const event = await prisma.publicEvent.create({
      data: {
        title: validatedData.title,
        description: validatedData.description,
        shortDescription: validatedData.shortDescription,
        slug,
        startDate: new Date(validatedData.startDate),
        endDate: new Date(validatedData.endDate),
        timezone: validatedData.timezone,
        locationType: validatedData.locationType,
        venueName: validatedData.venueName,
        venueAddress: validatedData.venueAddress,
        venueCity: validatedData.venueCity,
        venueState: validatedData.venueState,
        venueZipCode: validatedData.venueZipCode,
        virtualLink: validatedData.virtualLink,
        coverImage: validatedData.coverImage,
        isPublic: validatedData.isPublic,
        requiresApproval: validatedData.requiresApproval,
        capacity: validatedData.capacity,
        registrationDeadline: validatedData.registrationDeadline
          ? new Date(validatedData.registrationDeadline)
          : undefined,
        price: validatedData.price,
        currency: validatedData.currency,
        status: 'PUBLISHED',
        visibility: 'PUBLIC',
        tags: JSON.stringify(validatedData.tags),
        organizerId: session.user.id,
        categories: validatedData.categoryIds.length > 0 ? {
          connect: validatedData.categoryIds.map(id => ({ id })),
        } : undefined,
      },
    });

    // Fetch the event with relations
    const eventWithRelations = await prisma.publicEvent.findUnique({
      where: { id: event.id },
      include: {
        organizer: {
          select: {
            id: true,
            name: true,
            email: true,
            image: true,
          },
        },
        categories: true,
      },
    });

    return NextResponse.json({
      success: true,
      event: eventWithRelations,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error creating event:', error);
    console.error('Error stack:', error instanceof Error ? error.stack : 'No stack');
    return NextResponse.json(
      { 
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

