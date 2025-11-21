import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// POST /api/route-planning - Generate AI-optimized route plan
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    if (!process.env.OPENAI_API_KEY) {
      return NextResponse.json(
        { error: 'OpenAI API key not configured' },
        { status: 500 }
      );
    }

    const body = await request.json();
    const { eventIds, startLocation, transportationPreferences } = body;

    if (!eventIds || eventIds.length === 0) {
      return NextResponse.json(
        { error: 'Event IDs are required' },
        { status: 400 }
      );
    }

    // Fetch events
    const events = await prisma.calendarEvent.findMany({
      where: {
        id: { in: eventIds },
        userId: session.user.id,
      },
      orderBy: { startDate: 'asc' },
    });

    if (events.length === 0) {
      return NextResponse.json(
        { error: 'No events found' },
        { status: 404 }
      );
    }

    // Create prompt for AI route optimization
    const eventsInfo = events.map((e, i) => 
      `${i + 1}. ${e.title} at ${e.location || 'Unknown location'} - ${new Date(e.startDate).toLocaleString()}`
    ).join('\n');

    const prompt = `
      You are a route planning assistant for NYC. Given the following events, create an optimized route plan.
      
      Events:
      ${eventsInfo}
      
      Starting location: ${startLocation || 'User\'s current location'}
      Transportation preferences: ${transportationPreferences?.join(', ') || 'Any'}
      
      Provide a JSON response with:
      1. Optimal order of events (if reordering makes sense)
      2. Recommended transportation modes between locations
      3. Estimated travel times
      4. Total estimated cost
      5. Suggestions for time optimization
      
      Format:
      {
        "optimizedOrder": [event indices in optimal order],
        "routes": [
          {
            "from": "location",
            "to": "location",
            "mode": "subway|walking|taxi|uber",
            "duration": minutes,
            "cost": dollars,
            "instructions": "detailed directions"
          }
        ],
        "totalTime": minutes,
        "totalCost": dollars,
        "suggestions": ["optimization suggestion 1", "suggestion 2"]
      }
    `;

    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: 'You are an expert NYC route planner with deep knowledge of the city\'s transportation system.'
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
      max_tokens: 2000,
      temperature: 0.3,
    });

    const content = response.choices[0]?.message?.content;
    if (!content) {
      throw new Error('No response from OpenAI');
    }

    // Parse the AI response
    let routePlan;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        routePlan = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('No JSON found in response');
      }
    } catch (parseError) {
      console.error('Error parsing AI response:', parseError);
      return NextResponse.json(
        { error: 'Failed to parse AI response', details: content },
        { status: 500 }
      );
    }

    // Save route plan to database
    const savedRoutePlan = await prisma.routePlan.create({
      data: {
        name: `Route for ${events[0].title}${events.length > 1 ? ` + ${events.length - 1} more` : ''}`,
        startLocation: startLocation ? JSON.parse(JSON.stringify(startLocation)) : null,
        totalTime: routePlan.totalTime * 60, // Convert to seconds
        totalCost: routePlan.totalCost,
        userId: session.user.id,
        segments: {
          create: routePlan.routes.map((route: any, index: number) => ({
            fromLocation: JSON.parse(JSON.stringify({ address: route.from })),
            toLocation: JSON.parse(JSON.stringify({ address: route.to })),
            transportMode: route.mode.toUpperCase(),
            travelTime: route.duration * 60, // Convert to seconds
            cost: route.cost,
            instructions: route.instructions,
            departureTime: index === 0 
              ? events[0].startDate 
              : new Date(events[0].startDate.getTime() + (index * 60 * 60 * 1000)),
            arrivalTime: new Date(events[0].startDate.getTime() + ((index + 1) * 60 * 60 * 1000)),
          })),
        },
      },
      include: {
        segments: true,
      },
    });

    return NextResponse.json({
      success: true,
      routePlan: savedRoutePlan,
      suggestions: routePlan.suggestions,
      aiResponse: content,
    });
  } catch (error) {
    console.error('Error in route planning:', error);
    return NextResponse.json(
      { 
        error: 'Route planning failed', 
        details: error instanceof Error ? error.message : 'Unknown error' 
      },
      { status: 500 }
    );
  }
}

// GET /api/route-planning - Get user's route plans
export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const routePlans = await prisma.routePlan.findMany({
      where: { userId: session.user.id },
      include: {
        segments: {
          include: {
            event: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return NextResponse.json({
      success: true,
      routePlans,
    });
  } catch (error) {
    console.error('Error fetching route plans:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

