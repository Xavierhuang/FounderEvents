'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { PlusIcon, PencilIcon, TrashIcon, EyeIcon, StarIcon, RocketLaunchIcon, ArchiveBoxIcon } from '@heroicons/react/24/outline';
import { format, parseISO } from 'date-fns';
import toast from 'react-hot-toast';

export default function MyEventsPage() {
  const router = useRouter();
  const [events, setEvents] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'upcoming' | 'past'>('all');

  useEffect(() => {
    fetchMyEvents();
  }, []);

  const fetchMyEvents = async () => {
    try {
      const response = await fetch('/api/profile');
      if (response.ok) {
        const data = await response.json();
        setEvents(data.profile?.publicEvents || []);
      } else if (response.status === 404) {
        // No profile, redirect to setup
        router.push('/dashboard/profile/setup');
      }
    } catch (error) {
      console.error('Error fetching events:', error);
      toast.error('Failed to load your events');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async (eventId: string, eventSlug: string) => {
    if (!confirm('Are you sure you want to delete this event? This action cannot be undone.')) {
      return;
    }

    try {
      const response = await fetch(`/api/public-events/${eventSlug}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        toast.success('Event deleted successfully');
        setEvents(events.filter(e => e.id !== eventId));
      } else {
        const error = await response.json();
        toast.error(error.error || 'Failed to delete event');
      }
    } catch (error) {
      console.error('Error deleting event:', error);
      toast.error('Failed to delete event');
    }
  };

  const handleToggleFeatured = async (event: any) => {
    try {
      const response = await fetch(`/api/public-events/${event.slug}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isFeatured: !event.isFeatured }),
      });

      if (response.ok) {
        toast.success(event.isFeatured ? 'Event unfeatured' : 'Event featured');
        setEvents(events.map(e => 
          e.id === event.id ? { ...e, isFeatured: !e.isFeatured } : e
        ));
      } else {
        const error = await response.json();
        toast.error(error.error || 'Failed to update event');
      }
    } catch (error) {
      console.error('Error updating event:', error);
      toast.error('Failed to update event');
    }
  };

  const handleTogglePublish = async (event: any) => {
    const newStatus = event.status === 'PUBLISHED' ? 'DRAFT' : 'PUBLISHED';
    
    try {
      const response = await fetch(`/api/public-events/${event.slug}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus }),
      });

      if (response.ok) {
        toast.success(newStatus === 'PUBLISHED' ? 'Event published!' : 'Event unpublished');
        setEvents(events.map(e => 
          e.id === event.id ? { ...e, status: newStatus, publishedAt: newStatus === 'PUBLISHED' ? new Date().toISOString() : null } : e
        ));
      } else {
        const error = await response.json();
        toast.error(error.error || 'Failed to update event');
      }
    } catch (error) {
      console.error('Error updating event:', error);
      toast.error('Failed to update event');
    }
  };

  const filteredEvents = events.filter(event => {
    const eventDate = new Date(event.startDate);
    const now = new Date();
    
    if (filter === 'upcoming') {
      return eventDate >= now;
    } else if (filter === 'past') {
      return eventDate < now;
    }
    return true;
  });

  if (isLoading) {
    return (
      <div className="max-w-6xl mx-auto space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="card p-6">
                <div className="h-6 bg-gray-200 rounded w-3/4 mb-3"></div>
                <div className="h-4 bg-gray-200 rounded w-full mb-2"></div>
                <div className="h-4 bg-gray-200 rounded w-2/3"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">My Events</h1>
          <p className="mt-1 text-gray-600">
            Manage your public events ({filteredEvents.length} {filter === 'all' ? 'total' : filter})
          </p>
        </div>
        <button
          onClick={() => router.push('/dashboard/events/import')}
          className="btn-primary"
        >
          <PlusIcon className="h-5 w-5 mr-2" />
          Import Event
        </button>
      </div>

      {/* Filters */}
      <div className="flex space-x-2">
        <button
          onClick={() => setFilter('all')}
          className={filter === 'all' ? 'tab-button-active' : 'tab-button'}
        >
          All Events
        </button>
        <button
          onClick={() => setFilter('upcoming')}
          className={filter === 'upcoming' ? 'tab-button-active' : 'tab-button'}
        >
          Upcoming
        </button>
        <button
          onClick={() => setFilter('past')}
          className={filter === 'past' ? 'tab-button-active' : 'tab-button'}
        >
          Past
        </button>
      </div>

      {/* Events Grid */}
      {filteredEvents.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredEvents.map((event) => (
            <div key={event.id} className="card p-6 space-y-4">
              {/* Event Header */}
              <div>
                <div className="flex items-start justify-between mb-2">
                  <h3 className="font-semibold text-lg text-gray-900 line-clamp-2">
                    {event.title}
                  </h3>
                  {event.isFeatured && (
                    <StarIcon className="h-5 w-5 text-yellow-500 flex-shrink-0 ml-2" />
                  )}
                </div>
                <p className="text-sm text-gray-600 line-clamp-2">
                  {event.shortDescription || event.description}
                </p>
              </div>

              {/* Event Details */}
              <div className="space-y-2 text-sm text-gray-500">
                <div>
                  📅 {format(parseISO(event.startDate), 'MMM dd, yyyy')} at {format(parseISO(event.startDate), 'h:mm a')}
                </div>
                <div>
                  📍 {event.locationType === 'VIRTUAL' 
                    ? 'Virtual Event' 
                    : event.venueName || event.venueCity || 'TBD'}
                </div>
                <div>
                  👥 {event.registrationCount || 0} registered
                  {event.capacity && ` / ${event.capacity}`}
                </div>
                <div>
                  👁️ {event.viewCount || 0} views
                </div>
              </div>

              {/* Status Badge */}
              <div className="flex items-center space-x-2">
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  event.status === 'PUBLISHED' 
                    ? 'bg-green-100 text-green-800'
                    : event.status === 'DRAFT'
                    ? 'bg-gray-100 text-gray-800'
                    : 'bg-red-100 text-red-800'
                }`}>
                  {event.status}
                </span>
                {event.price === 0 && (
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    FREE
                  </span>
                )}
              </div>

              {/* Actions */}
              <div className="space-y-2 pt-4 border-t border-gray-200">
                {/* Publish Toggle Button */}
                <button
                  onClick={() => handleTogglePublish(event)}
                  className={`w-full flex items-center justify-center px-4 py-2 rounded-lg font-medium transition-colors ${
                    event.status === 'PUBLISHED'
                      ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      : 'bg-green-600 text-white hover:bg-green-700'
                  }`}
                >
                  {event.status === 'PUBLISHED' ? (
                    <>
                      <ArchiveBoxIcon className="h-4 w-4 mr-2" />
                      Unpublish
                    </>
                  ) : (
                    <>
                      <RocketLaunchIcon className="h-4 w-4 mr-2" />
                      Publish Event
                    </>
                  )}
                </button>

                {/* Action Buttons */}
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => window.open(`/events/${event.slug}`, '_blank')}
                    className="flex-1 btn-secondary text-sm"
                    title="View event"
                  >
                    <EyeIcon className="h-4 w-4 mr-1" />
                    View
                  </button>
                  <button
                    onClick={() => handleToggleFeatured(event)}
                    className={`p-2 rounded-lg transition-colors ${
                      event.isFeatured 
                        ? 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200' 
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                    title={event.isFeatured ? 'Unfeature' : 'Feature'}
                  >
                    <StarIcon className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => router.push(`/dashboard/events/${event.id}/edit`)}
                    className="p-2 bg-gray-100 text-gray-600 hover:bg-gray-200 rounded-lg transition-colors"
                    title="Edit event"
                  >
                    <PencilIcon className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(event.id, event.slug)}
                    className="p-2 bg-red-100 text-red-600 hover:bg-red-200 rounded-lg transition-colors"
                    title="Delete event"
                  >
                    <TrashIcon className="h-4 w-4" />
                  </button>
                </div>
              </div>

              {/* Public Link */}
              <div className="pt-2 border-t border-gray-200 mt-2">
                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    value={`foundersevents.app/events/${event.slug}`}
                    readOnly
                    className="flex-1 text-xs px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg min-w-0 truncate"
                  />
                  <button
                    onClick={() => {
                      navigator.clipboard.writeText(`https://foundersevents.app/events/${event.slug}`);
                      toast.success('Link copied!');
                    }}
                    className="flex-shrink-0 px-3 py-2 text-xs font-medium bg-gray-100 text-gray-700 hover:bg-gray-200 rounded-lg transition-colors"
                  >
                    Copy
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-16 card">
          <PlusIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-4 text-lg font-medium text-gray-900">
            {filter === 'all' ? 'No events yet' : `No ${filter} events`}
          </h3>
          <p className="mt-2 text-gray-500">
            {filter === 'all' 
              ? 'Get started by importing an event from Luma or Eventbrite'
              : `You don't have any ${filter} events`}
          </p>
          {filter === 'all' && (
            <div className="mt-6">
              <button
                onClick={() => router.push('/dashboard/events/import')}
                className="btn-primary"
              >
                <PlusIcon className="h-5 w-5 mr-2" />
                Import Your First Event
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

