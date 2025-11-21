import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { z } from 'zod';

const updateProfileSchema = z.object({
  profileURL: z.string().url().optional(),
  name: z.string().min(1).optional(),
  company: z.string().optional(),
  title: z.string().optional(),
  notes: z.string().optional(),
  linkedEventId: z.string().optional(),
});

// GET /api/linkedin/[id] - Get specific profile
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const profile = await prisma.linkedInProfile.findFirst({
      where: {
        id: params.id,
        userId: session.user.id,
      },
      include: {
        linkedEvent: true,
      },
    });

    if (!profile) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 });
    }

    return NextResponse.json({
      success: true,
      profile,
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// PUT /api/linkedin/[id] - Update profile
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const body = await request.json();
    const validatedData = updateProfileSchema.parse(body);

    const existingProfile = await prisma.linkedInProfile.findFirst({
      where: {
        id: params.id,
        userId: session.user.id,
      },
    });

    if (!existingProfile) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 });
    }

    const updateData: any = {};
    if (validatedData.profileURL) updateData.profileURL = validatedData.profileURL;
    if (validatedData.name) updateData.name = validatedData.name;
    if (validatedData.company !== undefined) updateData.company = validatedData.company;
    if (validatedData.title !== undefined) updateData.title = validatedData.title;
    if (validatedData.notes !== undefined) updateData.notes = validatedData.notes;
    if (validatedData.linkedEventId !== undefined) updateData.linkedEventId = validatedData.linkedEventId;

    const profile = await prisma.linkedInProfile.update({
      where: { id: params.id },
      data: updateData,
      include: {
        linkedEvent: true,
      },
    });

    return NextResponse.json({
      success: true,
      profile,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation error', details: error.errors },
        { status: 400 }
      );
    }

    console.error('Error updating profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// DELETE /api/linkedin/[id] - Delete profile
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const existingProfile = await prisma.linkedInProfile.findFirst({
      where: {
        id: params.id,
        userId: session.user.id,
      },
    });

    if (!existingProfile) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 });
    }

    await prisma.linkedInProfile.delete({
      where: { id: params.id },
    });

    return NextResponse.json({
      success: true,
      message: 'Profile deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting profile:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

