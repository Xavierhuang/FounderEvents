'use client';

import { useState, useEffect } from 'react';
import { CalendarEvent } from '@/types';
import CalendarGrid from '@/components/calendar/CalendarGrid';
import EventCard from '@/components/events/EventCard';
import { PlusIcon } from '@heroicons/react/24/outline';
import { format, startOfDay, endOfDay } from 'date-fns';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';

export default function CalendarPage() {
  const router = useRouter();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchEvents();
  }, []);

  const fetchEvents = async () => {
    try {
      const response = await fetch('/api/events');
      if (response.ok) {
        const data = await response.json();
        setEvents(data.events || []);
      }
    } catch (error) {
      console.error('Failed to fetch events:', error);
      toast.error('Failed to load events');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDateSelect = (date: Date) => {
    setSelectedDate(date);
    setSelectedEvent(null);
  };

  const handleEventClick = (event: CalendarEvent) => {
    setSelectedEvent(event);
    setSelectedDate(new Date(event.startDate));
  };

  const handleDeleteEvent = async (eventId: string) => {
    try {
      const response = await fetch(`/api/events/${eventId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setEvents(events.filter(e => e.id !== eventId));
        setSelectedEvent(null);
        toast.success('Event deleted successfully');
      } else {
        toast.error('Failed to delete event');
      }
    } catch (error) {
      console.error('Error deleting event:', error);
      toast.error('Failed to delete event');
    }
  };

  const selectedDayEvents = events.filter(event => {
    const eventDate = startOfDay(new Date(event.startDate));
    const selected = startOfDay(selectedDate);
    return eventDate.getTime() === selected.getTime();
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="spinner w-8 h-8"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Calendar</h1>
          <p className="mt-2 text-gray-600">View and manage your events</p>
        </div>
        <button
          onClick={() => router.push('/dashboard/events/create')}
          className="btn-primary"
        >
          <PlusIcon className="h-5 w-5 mr-2" />
          Add Event
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <CalendarGrid
            events={events}
            selectedDate={selectedDate}
            onDateSelect={handleDateSelect}
            onEventClick={handleEventClick}
          />
        </div>

        <div className="space-y-6">
          <div className="card p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              {format(selectedDate, 'EEEE, MMMM d')}
            </h2>
            
            {selectedDayEvents.length > 0 ? (
              <div className="space-y-4">
                {selectedDayEvents.map(event => (
                  <EventCard
                    key={event.id}
                    event={event}
                    onDelete={handleDeleteEvent}
                  />
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <p className="text-gray-500 text-sm">No events on this day</p>
                <button
                  onClick={() => router.push('/dashboard/events/create')}
                  className="mt-4 text-primary-600 hover:text-primary-700 text-sm font-medium"
                >
                  Create an event
                </button>
              </div>
            )}
          </div>

          {selectedEvent && (
            <div className="card p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Selected Event
              </h3>
              <EventCard
                event={selectedEvent}
                onDelete={handleDeleteEvent}
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

