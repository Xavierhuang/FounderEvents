import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import OpenAI from 'openai';
import { z } from 'zod';

const extractRequestSchema = z.object({
  imageData: z.string().min(1, 'Image data is required'),
  prompt: z.string().optional(),
});

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// POST /api/ai/extract - Extract event info from image using GPT-4 Vision
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
    const { imageData, prompt } = extractRequestSchema.parse(body);

    // Default prompt for event extraction
    const defaultPrompt = `
      Analyze this image and extract event information. Look for:
      - Event title/name
      - Date and time (convert to ISO 8601 format in New York timezone)
      - Location/venue
      - Description or additional details
      - Price information if available
      
      Return the information in this JSON format:
      {
        "event_name": "string",
        "event_time": "ISO 8601 datetime string",
        "event_location": "string",
        "event_description": "string",
        "confidence": number (0-1)
      }
      
      If you can't find certain information, use null for those fields.
      For dates without years, assume the current year (2024).
      For times without dates, try to infer from context or use null.
    `;

    const response = await openai.chat.completions.create({
      model: 'gpt-4-vision-preview',
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: prompt || defaultPrompt,
            },
            {
              type: 'image_url',
              image_url: {
                url: imageData,
                detail: 'high',
              },
            },
          ],
        },
      ],
      max_tokens: 1000,
      temperature: 0.1, // Low temperature for more consistent extraction
    });

    const content = response.choices[0]?.message?.content;
    if (!content) {
      throw new Error('No response from OpenAI');
    }

    // Try to parse JSON from the response
    let extractedData;
    try {
      // Find JSON in the response (GPT sometimes adds extra text)
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        extractedData = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('No JSON found in response');
      }
    } catch (parseError) {
      console.error('Error parsing OpenAI response:', parseError);
      return NextResponse.json(
        { error: 'Failed to parse AI response', details: content },
        { status: 500 }
      );
    }

    // Convert to our ExtractedEventInfo format
    const extractedInfo = {
      rawText: 'GPT-4 Vision Analysis',
      title: extractedData.event_name || undefined,
      startDateTime: extractedData.event_time ? new Date(extractedData.event_time) : undefined,
      endDateTime: extractedData.event_time 
        ? new Date(new Date(extractedData.event_time).getTime() + 60 * 60 * 1000) // +1 hour
        : undefined,
      location: extractedData.event_location || undefined,
      description: extractedData.event_description || undefined,
      confidence: extractedData.confidence || 0.8,
    };

    return NextResponse.json({
      success: true,
      extractedInfo,
      rawResponse: content,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error in AI extraction:', error);
    return NextResponse.json(
      { 
        error: 'AI extraction failed', 
        details: error instanceof Error ? error.message : 'Unknown error' 
      },
      { status: 500 }
    );
  }
}
