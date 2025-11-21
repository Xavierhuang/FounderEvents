'use client';

import { useState, useEffect } from 'react';
import { GarysGuideEvent } from '@/types';
import { MagnifyingGlassIcon, SparklesIcon, CalendarIcon, MapPinIcon, CurrencyDollarIcon, StarIcon } from '@heroicons/react/24/outline';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';

export default function DiscoverPage() {
  const router = useRouter();
  const [events, setEvents] = useState<GarysGuideEvent[]>([]);
  const [filteredEvents, setFilteredEvents] = useState<GarysGuideEvent[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [eventTypeFilter, setEventTypeFilter] = useState<'all' | 'popular' | 'featured'>('all');

  useEffect(() => {
    fetchEvents();
  }, [eventTypeFilter]);

  useEffect(() => {
    filterEvents();
  }, [events, searchQuery]);

  const fetchEvents = async () => {
    setIsLoading(true);
    try {
      const params = new URLSearchParams();
      if (eventTypeFilter !== 'all') {
        params.append('eventType', eventTypeFilter);
      }

      const response = await fetch(`/api/discover?${params}`);
      if (response.ok) {
        const data = await response.json();
        setEvents(data.events || []);
      } else {
        toast.error('Failed to load events');
      }
    } catch (error) {
      console.error('Failed to fetch events:', error);
      toast.error('Failed to load events');
    } finally {
      setIsLoading(false);
    }
  };

  const filterEvents = () => {
    if (!searchQuery) {
      setFilteredEvents(events);
      return;
    }

    const query = searchQuery.toLowerCase();
    const filtered = events.filter(event =>
      event.title.toLowerCase().includes(query) ||
      event.venue.toLowerCase().includes(query) ||
      event.speakers.toLowerCase().includes(query)
    );
    setFilteredEvents(filtered);
  };

  const handleAddToCalendar = async (event: GarysGuideEvent) => {
    try {
      // Parse the date and time (this is a simplified version)
      const startDate = new Date();
      const endDate = new Date(startDate.getTime() + 2 * 60 * 60 * 1000); // +2 hours

      const response = await fetch('/api/events', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: event.title,
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString(),
          location: event.venue,
          notes: `${event.speakers}\n\nPrice: ${event.price}\n\nMore info: ${event.url}`,
        }),
      });

      if (response.ok) {
        toast.success('Event added to your calendar!');
      } else {
        toast.error('Failed to add event');
      }
    } catch (error) {
      console.error('Error adding event:', error);
      toast.error('Failed to add event');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Discover Events</h1>
          <p className="mt-2 text-gray-600">Browse events from Gary's Guide and featured community events</p>
        </div>
      </div>

      {/* Filters */}
      <div className="card p-6">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Search events..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="input pl-10"
              />
            </div>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setEventTypeFilter('all')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                eventTypeFilter === 'all'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              All Events
            </button>
            <button
              onClick={() => setEventTypeFilter('popular')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center ${
                eventTypeFilter === 'popular'
                  ? 'bg-primary-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <SparklesIcon className="h-4 w-4 inline mr-1" />
              Popular Events
            </button>
            <button
              onClick={() => setEventTypeFilter('featured')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center ${
                eventTypeFilter === 'featured'
                  ? 'bg-yellow-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <StarIcon className="h-4 w-4 inline mr-1" />
              Featured Events
            </button>
          </div>
        </div>
      </div>

      {/* Events Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="card p-6 animate-pulse">
              <div className="h-6 bg-gray-200 rounded w-3/4 mb-4"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-2/3"></div>
            </div>
          ))}
        </div>
      ) : filteredEvents.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredEvents.map((event) => (
            <div key={event.id} className="card p-6 hover:shadow-lg transition-all duration-200 group">
              <div className="flex items-start justify-between mb-3">
                <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                  {event.title}
                </h3>
                <div className="flex gap-1 ml-2">
                  {(event as any).isFeatured && (
                    <StarIcon className="h-5 w-5 text-yellow-500 flex-shrink-0" />
                  )}
                  {event.isPopularEvent && (
                    <SparklesIcon className="h-5 w-5 text-purple-500 flex-shrink-0" />
                  )}
                </div>
              </div>

              <div className="space-y-2 mb-4">
                <div className="flex items-center text-sm text-gray-600">
                  <CalendarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span>{event.date} at {event.time}</span>
                </div>
                
                <div className="flex items-center text-sm text-gray-600">
                  <MapPinIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span className="truncate">{event.venue}</span>
                </div>

                <div className="flex items-center text-sm text-gray-600">
                  <CurrencyDollarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span className={event.price === 'Free' ? 'text-green-600 font-medium' : ''}>
                    {event.price}
                  </span>
                </div>
              </div>

              {event.speakers && (
                <p className="text-sm text-gray-500 mb-4 line-clamp-2">
                  Speakers: {event.speakers}
                </p>
              )}

              <div className="flex gap-2">
                <button
                  onClick={() => handleAddToCalendar(event)}
                  className="btn-primary flex-1 text-sm"
                >
                  Add to Calendar
                </button>
                <a
                  href={event.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-secondary flex-1 text-sm text-center"
                >
                  View Details
                </a>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <SparklesIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-4 text-sm font-medium text-gray-900">No events found</h3>
          <p className="mt-2 text-sm text-gray-500">
            Try adjusting your search or filters
          </p>
        </div>
      )}
    </div>
  );
}

