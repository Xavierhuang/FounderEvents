import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import Anthropic from '@anthropic-ai/sdk';
import { z } from 'zod';

const extractRequestSchema = z.object({
  url: z.string().url('Invalid URL'),
  platform: z.enum(['luma', 'eventbrite', 'auto']).optional().default('auto'),
});

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Helper function to detect platform from URL
function detectPlatform(url: string): 'luma' | 'eventbrite' {
  if (url.includes('lu.ma') || url.includes('luma.com')) {
    return 'luma';
  }
  if (url.includes('eventbrite.com') || url.includes('eventbrite.co')) {
    return 'eventbrite';
  }
  return 'luma'; // default
}

// POST /api/events/extract-from-url - Extract event data from Luma/Eventbrite URL
export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    if (!process.env.ANTHROPIC_API_KEY) {
      return NextResponse.json(
        { error: 'Anthropic API key not configured' },
        { status: 500 }
      );
    }

    const body = await request.json();
    const { url, platform } = extractRequestSchema.parse(body);

    const detectedPlatform = platform === 'auto' ? detectPlatform(url) : platform;

    // Fetch the webpage content
    let htmlContent = '';
    let fetchError = null;
    
    try {
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
        },
        redirect: 'follow',
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      htmlContent = await response.text();
      
      if (!htmlContent || htmlContent.length < 100) {
        throw new Error('Received empty or invalid HTML content');
      }
    } catch (error) {
      fetchError = error;
      console.error('Error fetching URL:', error);
      
      // If fetch fails, try using GPT-4 to extract from URL metadata instead
      // This is a fallback for sites that block direct access
    }

    // Use GPT-4 to extract structured event data from HTML or URL
    const extractionPrompt = `
      Extract event information from this ${detectedPlatform} event ${htmlContent ? 'page HTML' : 'URL: ' + url}.
      
      ${htmlContent 
        ? 'Extract the following information from the HTML:'
        : 'Based on the URL structure and common ' + detectedPlatform + ' event patterns, extract or infer:'}
      
      - Event title
      - Event description (full description)
      - Short description (1-2 sentences)
      - Start date and time (convert to ISO 8601 format, assume America/New_York timezone if not specified)
      - End date and time (convert to ISO 8601 format)
      - Location type (PHYSICAL, VIRTUAL, or HYBRID)
      - Venue name (if physical event)
      - Venue address (full address if available)
      - City, State, ZIP code (if available)
      - Virtual link (if virtual/hybrid event)
      - Cover image URL
      - Price (extract as number, 0 if free)
      - Currency (default to USD)
      - Capacity (if mentioned)
      - Registration deadline (if mentioned)
      - Tags/categories (extract relevant keywords)
      
      Return the information in this JSON format:
      {
        "title": "string",
        "description": "string",
        "shortDescription": "string (optional)",
        "startDate": "ISO 8601 datetime string",
        "endDate": "ISO 8601 datetime string",
        "locationType": "PHYSICAL | VIRTUAL | HYBRID",
        "venueName": "string (optional)",
        "venueAddress": "string (optional)",
        "venueCity": "string (optional)",
        "venueState": "string (optional)",
        "venueZipCode": "string (optional)",
        "virtualLink": "URL string (optional)",
        "coverImage": "URL string (optional)",
        "price": number,
        "currency": "string (default: USD)",
        "capacity": number (optional),
        "registrationDeadline": "ISO 8601 datetime string (optional)",
        "tags": ["string", "string"],
        "originalUrl": "${url}",
        "platform": "${detectedPlatform}"
      }
      
      Important:
      - If date/time is missing, use null
      - Extract as much information as possible
      - For location, determine if it's physical, virtual, or hybrid
      - Extract price as a number (0 for free events)
      - Extract relevant tags/categories from the content
      
      ${htmlContent 
        ? `HTML Content:\n${htmlContent.substring(0, 50000)}` 
        : `Note: Could not fetch HTML content. Please extract what you can from the URL structure and ${detectedPlatform} platform patterns.`}
    `;

    let response;
    try {
      const systemPrompt = htmlContent 
        ? 'You are an expert at extracting structured event data from HTML. Extract all available event information accurately.'
        : 'You are an expert at extracting event information from URLs and platform patterns. Use your knowledge of Luma and Eventbrite event structures to infer event details.';
      
      response = await anthropic.messages.create({
        model: 'claude-sonnet-4-5',
        max_tokens: 2000,
        temperature: 0.1,
        system: systemPrompt,
        messages: [
          {
            role: 'user',
            content: extractionPrompt,
          },
        ],
      });
    } catch (anthropicError) {
      console.error('Anthropic API error:', anthropicError);
      return NextResponse.json(
        { 
          error: 'Failed to extract event data', 
          details: anthropicError instanceof Error ? anthropicError.message : 'Anthropic API error',
          suggestion: fetchError 
            ? 'The event page may be blocking automated access. Try copying the event details manually or check if the URL is publicly accessible.'
            : 'Please check your Anthropic API key and try again.'
        },
        { status: 500 }
      );
    }

    const content = response.content[0]?.type === 'text' ? response.content[0].text : null;
    if (!content) {
      throw new Error('No response from Claude');
    }

    // Parse the JSON response
    let extractedData;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        extractedData = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('No JSON found in response');
      }
    } catch (parseError) {
      console.error('Error parsing OpenAI response:', parseError);
      console.error('Raw response:', content);
      return NextResponse.json(
        { 
          error: 'Failed to parse extracted data', 
          details: content.substring(0, 500),
          suggestion: 'The AI response format was unexpected. Please try again or enter the event details manually.'
        },
        { status: 500 }
      );
    }

    // Validate and format the extracted data
    const formattedData = {
      title: extractedData.title || 'Untitled Event',
      description: extractedData.description || extractedData.shortDescription || 'No description available',
      shortDescription: extractedData.shortDescription || extractedData.description?.substring(0, 300),
      startDate: extractedData.startDate || new Date().toISOString(),
      endDate: extractedData.endDate || new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(), // +2 hours default
      locationType: extractedData.locationType || 'PHYSICAL',
      venueName: extractedData.venueName,
      venueAddress: extractedData.venueAddress,
      venueCity: extractedData.venueCity,
      venueState: extractedData.venueState,
      venueZipCode: extractedData.venueZipCode,
      virtualLink: extractedData.virtualLink,
      coverImage: extractedData.coverImage,
      price: extractedData.price || 0,
      currency: extractedData.currency || 'USD',
      capacity: extractedData.capacity,
      registrationDeadline: extractedData.registrationDeadline,
      tags: extractedData.tags || [],
      originalUrl: url,
      platform: detectedPlatform,
    };

    return NextResponse.json({
      success: true,
      extractedData: formattedData,
      rawResponse: content,
      warning: fetchError ? 'Could not fetch HTML content, extracted from URL patterns' : undefined,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error extracting event from URL:', error);
    console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
    
    return NextResponse.json(
      { 
        error: 'Failed to extract event data', 
        details: error instanceof Error ? error.message : 'Unknown error',
        suggestion: 'Please check the URL is correct and publicly accessible. You can also try entering the event details manually.'
      },
      { status: 500 }
    );
  }
}

