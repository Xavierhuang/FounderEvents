import { notFound } from 'next/navigation';
import EventPageClient from './EventPageClient';

async function getEvent(slug: string) {
  try {
    const res = await fetch(`${process.env.NEXTAUTH_URL}/api/public-events/${slug}`, {
      cache: 'no-store',
    });
    
    if (!res.ok) {
      return null;
    }
    
    const data = await res.json();
    return data.event;
  } catch (error) {
    console.error('Error fetching event:', error);
    return null;
  }
}

export default async function EventPage({ params }: { params: { slug: string } }) {
  const event = await getEvent(params.slug);

  if (!event) {
    notFound();
  }

  return <EventPageClient event={event} />;
}

