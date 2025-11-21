'use client';

import { CalendarEvent } from '@/types';
import EventCard from '@/components/events/EventCard';

interface UpcomingEventsProps {
  events: CalendarEvent[];
  onDeleteEvent?: (eventId: string) => void;
}

export default function UpcomingEvents({ events, onDeleteEvent }: UpcomingEventsProps) {
  const upcomingEvents = events
    .filter(event => new Date(event.startDate) > new Date())
    .sort((a, b) => new Date(a.startDate).getTime() - new Date(b.startDate).getTime())
    .slice(0, 5);

  if (upcomingEvents.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">No upcoming events</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {upcomingEvents.map(event => (
        <EventCard
          key={event.id}
          event={event}
          onDelete={onDeleteEvent}
        />
      ))}
    </div>
  );
}

