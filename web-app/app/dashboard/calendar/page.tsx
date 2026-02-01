'use client';

import { useState, useEffect } from 'react';
import { CalendarEvent } from '@/types';
import CalendarGrid from '@/components/calendar/CalendarGrid';
import EventCard from '@/components/events/EventCard';
import { PlusIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { format, startOfDay, endOfDay } from 'date-fns';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';

export default function CalendarPage() {
  const router = useRouter();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [showDayModal, setShowDayModal] = useState(false);

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
    setShowDayModal(true);
  };

  const handleEventClick = (event: CalendarEvent) => {
    setSelectedEvent(event);
    setSelectedDate(new Date(event.startDate));
    setShowDayModal(true);
  };

  const handleCloseModal = () => {
    setShowDayModal(false);
    setSelectedEvent(null);
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

  const selectedDayEvents = selectedDate ? events.filter(event => {
    const eventDate = startOfDay(new Date(event.startDate));
    const selected = startOfDay(selectedDate);
    return eventDate.getTime() === selected.getTime();
  }) : [];

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

      <CalendarGrid
        events={events}
        selectedDate={selectedDate || new Date()}
        onDateSelect={handleDateSelect}
        onEventClick={handleEventClick}
      />

      {/* Day Details Modal */}
      {showDayModal && selectedDate && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/50 backdrop-blur-sm transition-opacity"
            onClick={handleCloseModal}
          />
          
          {/* Modal */}
          <div className="flex min-h-full items-center justify-center p-4">
            <div className="relative bg-white/80 backdrop-blur-xl rounded-2xl border border-white/50 shadow-2xl w-full max-w-md p-6 transform transition-all">
              {/* Close button */}
              <button
                onClick={handleCloseModal}
                className="absolute top-4 right-4 p-2 rounded-lg hover:bg-white/50 transition-colors"
              >
                <XMarkIcon className="h-5 w-5 text-gray-500" />
              </button>

              <h2 className="text-xl font-semibold text-gray-900 mb-6">
                {format(selectedDate, 'EEEE, MMMM d')}
              </h2>
              
              {selectedDayEvents.length > 0 ? (
                <div className="space-y-4 max-h-[60vh] overflow-y-auto">
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
                    onClick={() => {
                      handleCloseModal();
                      router.push('/dashboard/events/create');
                    }}
                    className="mt-4 text-[#25004D] hover:text-[#3d1a6d] text-sm font-medium"
                  >
                    Create an event
                  </button>
                </div>
              )}

              {selectedEvent && (
                <div className="mt-6 pt-6 border-t border-gray-200">
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
      )}
    </div>
  );
}

