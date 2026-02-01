'use client';

import { useState, useEffect, useCallback } from 'react';
import { GarysGuideEvent } from '@/types';
import { MagnifyingGlassIcon, SparklesIcon, CalendarIcon, MapPinIcon, CurrencyDollarIcon, StarIcon, ArrowPathIcon, ShareIcon } from '@heroicons/react/24/outline';
import toast, { Toaster } from 'react-hot-toast';

type DateFilter = 'all' | 'today' | 'tomorrow' | 'custom';

// Helper function to format date for display
const formatEventDate = (dateStr: string): string => {
  if (!dateStr) return '';
  try {
    const date = new Date(dateStr + 'T00:00:00');
    return date.toLocaleDateString('en-US', { 
      weekday: 'long',
      month: 'long', 
      day: 'numeric',
      year: 'numeric'
    });
  } catch {
    return dateStr;
  }
};

export default function DiscoverPage() {
  const [events, setEvents] = useState<GarysGuideEvent[]>([]);
  const [filteredEvents, setFilteredEvents] = useState<GarysGuideEvent[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [eventTypeFilter, setEventTypeFilter] = useState<'all' | 'featured'>('all');
  const [dateFilter, setDateFilter] = useState<DateFilter>('all');
  const [customDate, setCustomDate] = useState<string>('');

  const fetchEvents = useCallback(async () => {
    setIsLoading(true);
    console.log('🔄 Fetching events with filters:', { eventTypeFilter, dateFilter, customDate });
    try {
      let allEvents: GarysGuideEvent[] = [];

      // Handle "Featured Events" - these are user-created events
      if (eventTypeFilter === 'featured') {
        try {
          const timestamp = Date.now();
          const response = await fetch(`/api/public-events?isFeatured=true&t=${timestamp}`, {
            cache: 'no-store',
            headers: {
              'Cache-Control': 'no-cache',
            },
          });
          if (response.ok) {
            const data = await response.json();
            // Convert PublicEvent to GarysGuideEvent format
            const featuredEvents = (data.events || []).map((event: any) => {
              const eventDate = new Date(event.startDate);
              const dateStr = eventDate.toISOString().split('T')[0]; // YYYY-MM-DD format
              return {
                id: event.id,
                title: event.title,
                date: dateStr,
                time: new Date(event.startDate).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }),
                price: event.price === 0 ? 'Free' : `$${event.price.toFixed(2)}`,
                venue: event.venueName || event.venueCity || 'Location TBD',
                speakers: event.shortDescription || '',
                url: `/events/${event.slug}`,
                isGaryEvent: false,
                isPopularEvent: false,
                week: new Date(event.startDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                eventDate: new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate()), // Store parsed date for filtering
              };
            });
            allEvents = [...allEvents, ...featuredEvents];
          }
        } catch (error) {
          console.error('Failed to fetch featured events:', error);
        }
      } else {
        // For "All Events", always fetch all events and filter client-side for better timezone handling
        try {
          const timestamp = Date.now();
          let apiEndpoint = '/api/events/all';
          
          // Only use specific date endpoint for custom dates
          if (dateFilter === 'custom' && customDate) {
            apiEndpoint = `/api/events/date/${customDate}`;
          }
          
          console.log('📡 Fetching from endpoint:', apiEndpoint);
          const response = await fetch(`${apiEndpoint}?t=${timestamp}`, {
            cache: 'no-store',
            headers: {
              'Cache-Control': 'no-cache',
            },
          });
          if (response.ok) {
            const data = await response.json();
            console.log('✅ Received events:', data.events?.length || 0);
            
            // Convert EventDTO format to GarysGuideEvent format
            const apiEvents = (data.events || [])
              .map((event: any) => {
                // Parse event date - API returns "MMM dd" format (e.g., "Jan 23")
                let eventDate: Date | null = null;
                
                if (event.date) {
                  // Try to parse as ISO date first (YYYY-MM-DD)
                  if (event.date.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    eventDate = new Date(event.date + 'T00:00:00');
                  } else {
                    // Parse as "MMM dd" format
                    const currentYear = new Date().getFullYear();
                    const fullDateString = `${event.date} ${currentYear}`;
                    const dateFormatter = new Date(fullDateString);
                    if (!isNaN(dateFormatter.getTime())) {
                      eventDate = dateFormatter;
                    }
                  }
                }
                
                if (!eventDate) return null;
                
                return {
                  id: event.id,
                  title: event.title,
                  date: event.date, // Keep original format for display
                  time: event.time,
                  price: 'Free',
                  venue: event.address || 'Location TBD',
                  speakers: event.notes || '',
                  url: event.link,
                  isGaryEvent: false,
                  isPopularEvent: event.isPopularEvent || false,
                  week: event.date,
                  eventDate: eventDate, // Store parsed date for filtering and sorting
                };
              })
              .filter((event: any) => {
                if (!event || !event.eventDate) return false;
                
                // Client-side filtering for "today" - use local date
                if (dateFilter === 'today') {
                  const today = new Date();
                  today.setHours(0, 0, 0, 0); // Reset to start of day
                  const eventDate = new Date(event.eventDate);
                  eventDate.setHours(0, 0, 0, 0); // Reset to start of day
                  // Compare dates (ignore time)
                  return eventDate.getTime() === today.getTime();
                }
                
                // Client-side filtering for "tomorrow" - use local date
                if (dateFilter === 'tomorrow') {
                  const tomorrow = new Date();
                  tomorrow.setDate(tomorrow.getDate() + 1);
                  tomorrow.setHours(0, 0, 0, 0); // Reset to start of day
                  const eventDate = new Date(event.eventDate);
                  eventDate.setHours(0, 0, 0, 0); // Reset to start of day
                  // Compare dates (ignore time)
                  return eventDate.getTime() === tomorrow.getTime();
                }
                
                // For "all" dates, only show today and future events
                if (dateFilter === 'all') {
                  const today = new Date();
                  today.setHours(0, 0, 0, 0);
                  const eventDate = new Date(event.eventDate);
                  eventDate.setHours(0, 0, 0, 0);
                  return eventDate.getTime() >= today.getTime();
                }
                
                return true;
              })
              .sort((a: any, b: any) => {
                // Sort by date, then by time
                if (a.eventDate.getTime() !== b.eventDate.getTime()) {
                  return a.eventDate.getTime() - b.eventDate.getTime();
                }
                return (a.time || '').localeCompare(b.time || '');
              });
            
            allEvents = [...allEvents, ...apiEvents];
          }
        } catch (error) {
          console.error('Failed to fetch events from API:', error);
        }
      }

      console.log('📦 Setting events:', allEvents.length);
      console.log('📋 Sample events:', allEvents.slice(0, 3).map(e => ({ title: e.title, date: e.date })));
      
      // Deduplicate events by link/URL to prevent redundant entries
      const uniqueEventsMap = new Map<string, typeof allEvents[0]>();
      for (const event of allEvents) {
        const key = event.url || event.id || `${event.title}-${event.date}`;
        if (!uniqueEventsMap.has(key)) {
          uniqueEventsMap.set(key, event);
        }
      }
      const uniqueEvents = Array.from(uniqueEventsMap.values());
      
      console.log('📦 Deduplicated events:', uniqueEvents.length, '(from', allEvents.length, 'total)');
      
      // Update both states - use functional updates to ensure React sees the change
      setEvents(() => uniqueEvents);
      // Immediately update filtered events since we're fetching pre-filtered data
      // Apply search filter if there's a search query
      let filtered = uniqueEvents;
      if (searchQuery) {
        const query = searchQuery.toLowerCase();
        filtered = allEvents.filter(event =>
          event.title.toLowerCase().includes(query) ||
          event.venue.toLowerCase().includes(query) ||
          event.speakers.toLowerCase().includes(query)
        );
      }
      console.log('🔍 Setting filtered events:', filtered.length);
      setFilteredEvents(() => filtered);
    } catch (error) {
      console.error('❌ Failed to fetch events:', error);
      toast.error('Failed to load events');
    } finally {
      setIsLoading(false);
    }
  }, [eventTypeFilter, dateFilter, customDate, searchQuery]);

  useEffect(() => {
    console.log('🔄 useEffect triggered - filters changed:', { eventTypeFilter, dateFilter, customDate });
    fetchEvents();
  }, [fetchEvents]);

  useEffect(() => {
    // Only filter by search query since date filtering is done by the API
    let filtered = [...events];
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(event =>
        event.title.toLowerCase().includes(query) ||
        event.venue.toLowerCase().includes(query) ||
        event.speakers.toLowerCase().includes(query)
      );
    }
    console.log('🔍 Filtered events by search:', filtered.length);
    setFilteredEvents(filtered);
  }, [events, searchQuery]);

  const handleRefreshEvents = async () => {
    setIsRefreshing(true);
    try {
      toast.loading('Refreshing events...', { id: 'refreshing' });
      await fetchEvents();
      toast.success('Events refreshed successfully!', { id: 'refreshing' });
    } catch (error) {
      console.error('Failed to refresh events:', error);
      toast.error('Failed to refresh events', { id: 'refreshing' });
    } finally {
      setIsRefreshing(false);
    }
  };

  const filterEvents = () => {
    // Since we're now fetching filtered events from the API, we only need to filter by search query
    let filtered = [...events];

    // Apply search query filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(event =>
        event.title.toLowerCase().includes(query) ||
        event.venue.toLowerCase().includes(query) ||
        event.speakers.toLowerCase().includes(query)
      );
    }

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

  const handleShareAllEvents = () => {
    if (filteredEvents.length === 0) {
      toast.error('No events to share');
      return;
    }

    const filterName = eventTypeFilter === 'all' ? 'All Events' 
      : eventTypeFilter === 'featured' ? 'Featured Events'
      : 'All Events';

    const appStoreLink = 'https://apps.apple.com/us/app/founder-events/id6755369462';
    const header = `Founder Events – ${filterName} (${filteredEvents.length} events)\n\n`;
    const body = filteredEvents.map(event => {
      const lines = [
        `• ${event.title}`,
        `  ${event.date} at ${event.time}`,
      ];
      
      if (event.venue && event.venue !== 'Location TBD') {
        lines.push(`  ${event.venue}`);
      }
      
      if (event.price) {
        lines.push(`  Price: ${event.price}`);
      }
      
      lines.push(`  ${event.url}`);
      
      return lines.join('\n');
    }).join('\n\n');

    const footer = `\n\n---\nDownload Founder Events to discover more events:\n${appStoreLink}`;
    const shareText = header + body + footer;

    // Use Web Share API if available, otherwise fallback to clipboard
    if (navigator.share) {
      navigator.share({
        title: `Founder Events – ${filterName}`,
        text: shareText,
      }).catch((error) => {
        console.error('Error sharing:', error);
        // Fallback to clipboard
        copyToClipboard(shareText);
      });
    } else {
      // Fallback to clipboard
      copyToClipboard(shareText);
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text).then(() => {
      toast.success('Events copied to clipboard!');
    }).catch((error) => {
      console.error('Failed to copy to clipboard:', error);
      toast.error('Failed to copy events');
    });
  };

  return (
    <>
      <Toaster position="top-right" />
      <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Discover Events</h1>
          <p className="mt-2 text-gray-600">Browse all events and featured community events</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={handleShareAllEvents}
            disabled={filteredEvents.length === 0 || isLoading}
            className="btn-secondary flex items-center gap-2"
            title="Share all events"
          >
            <ShareIcon className="h-5 w-5" />
            Share Events
          </button>
          <button
            onClick={handleRefreshEvents}
            disabled={isRefreshing}
            className="btn-secondary flex items-center gap-2"
          >
            <ArrowPathIcon className={`h-5 w-5 ${isRefreshing ? 'animate-spin' : ''}`} />
            {isRefreshing ? 'Refreshing...' : 'Refresh Events'}
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="card p-6 space-y-4">
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
          <div className="flex gap-2 flex-wrap">
            <button
              onClick={() => setEventTypeFilter('all')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                eventTypeFilter === 'all'
                  ? 'bg-[#25004D] text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              All Events
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

        {/* Date Filters */}
        <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center">
          <span className="text-sm font-medium text-gray-700 whitespace-nowrap">Filter by date:</span>
          <div className="flex gap-2 flex-wrap items-center">
            <button
              onClick={() => {
                setDateFilter('all');
                setCustomDate('');
              }}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                dateFilter === 'all'
                  ? 'bg-[#25004D] text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              All Dates
            </button>
            <button
              onClick={() => {
                setDateFilter('today');
                setCustomDate('');
              }}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center ${
                dateFilter === 'today'
                  ? 'bg-[#25004D] text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <CalendarIcon className="h-4 w-4 inline mr-1" />
              Today
            </button>
            <button
              onClick={() => {
                setDateFilter('tomorrow');
                setCustomDate('');
              }}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center ${
                dateFilter === 'tomorrow'
                  ? 'bg-[#25004D] text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <CalendarIcon className="h-4 w-4 inline mr-1" />
              Tomorrow
            </button>
            <div className="flex items-center gap-2">
              <input
                type="date"
                value={customDate}
                onChange={(e) => {
                  setCustomDate(e.target.value);
                  if (e.target.value) {
                    setDateFilter('custom');
                  }
                }}
                min={new Date().toISOString().split('T')[0]}
                className="px-4 py-2 rounded-lg text-sm border border-gray-300 focus:outline-none focus:ring-2 focus:ring-[#25004D] focus:border-transparent"
                placeholder="Choose date"
              />
              {customDate && (
                <button
                  onClick={() => {
                    setCustomDate('');
                    setDateFilter('all');
                  }}
                  className="px-3 py-2 text-sm text-gray-600 hover:text-gray-800"
                  title="Clear date filter"
                >
                  ×
                </button>
              )}
            </div>
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
        <div key={`grid-${dateFilter}-${filteredEvents.length}`} className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredEvents.map((event, index) => (
            <div key={`${event.id}-${index}-${dateFilter}`} className="card p-6 hover:shadow-lg transition-all duration-200 group">
              <div className="flex items-start justify-between mb-3">
                <h3 className="text-lg font-semibold text-gray-900 group-hover:text-[#25004D] transition-colors">
                  {event.title}
                </h3>
                <div className="flex gap-1 ml-2">
                  {(event as any).source === 'external' && (
                    <span className="px-2 py-1 text-xs font-semibold text-blue-700 bg-blue-100 rounded">
                      API
                    </span>
                  )}
                  {(event as any).isFeatured && (
                    <StarIcon className="h-5 w-5 text-yellow-500 flex-shrink-0" />
                  )}
                  {event.isPopularEvent && (
                    <SparklesIcon className="h-5 w-5 text-[#25004D] flex-shrink-0" />
                  )}
                </div>
              </div>

              <div className="space-y-2 mb-4">
                <div className="flex items-center text-sm text-gray-600">
                  <CalendarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span>{formatEventDate(event.date)} at {event.time}</span>
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
    </>
  );
}

