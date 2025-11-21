'use client';

import { useState, useEffect } from 'react';
import { PublicEvent } from '@/types/public-events';
import { MagnifyingGlassIcon, MapPinIcon, CalendarIcon, UsersIcon, SparklesIcon, StarIcon } from '@heroicons/react/24/outline';
import Link from 'next/link';
import { format } from 'date-fns';
import toast from 'react-hot-toast';

type EventFilter = 'all' | 'featured' | 'popular';

export default function PublicEventsPage() {
  const [events, setEvents] = useState<PublicEvent[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [locationType, setLocationType] = useState('');
  const [isFree, setIsFree] = useState(false);
  const [activeFilter, setActiveFilter] = useState<EventFilter>('all');

  useEffect(() => {
    fetchEvents();
  }, [locationType, isFree, activeFilter]);

  const fetchEvents = async () => {
    setIsLoading(true);
    try {
      const params = new URLSearchParams();
      if (searchQuery) params.append('search', searchQuery);
      if (locationType) params.append('locationType', locationType);
      if (isFree) params.append('isFree', 'true');
      if (activeFilter === 'featured') params.append('isFeatured', 'true');
      if (activeFilter === 'popular') params.append('sortBy', 'registrationCount');

      const response = await fetch(`/api/public-events?${params}`);
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

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    fetchEvents();
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-400 text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="text-4xl sm:text-5xl font-bold mb-4">
              Discover Amazing Events
            </h1>
            <p className="text-xl text-primary-100 mb-8">
              Find and join events created by our community
            </p>
            
            {/* Search Bar */}
            <form onSubmit={handleSearch} className="max-w-2xl mx-auto">
              <div className="relative">
                <MagnifyingGlassIcon className="absolute left-4 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search events..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-12 pr-4 py-4 rounded-xl text-gray-900 focus:ring-2 focus:ring-white"
                />
              </div>
            </form>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Event Type Filters */}
        <div className="flex gap-3 mb-6 overflow-x-auto pb-2">
          <button
            onClick={() => setActiveFilter('all')}
            className={`px-6 py-3 rounded-full font-medium transition-all whitespace-nowrap ${
              activeFilter === 'all'
                ? 'bg-primary-600 text-white shadow-lg'
                : 'bg-white text-gray-700 hover:bg-gray-100'
            }`}
          >
            All Events
          </button>
          <button
            onClick={() => setActiveFilter('featured')}
            className={`px-6 py-3 rounded-full font-medium transition-all whitespace-nowrap flex items-center ${
              activeFilter === 'featured'
                ? 'bg-yellow-500 text-white shadow-lg'
                : 'bg-white text-gray-700 hover:bg-gray-100'
            }`}
          >
            <StarIcon className="h-5 w-5 mr-2" />
            Featured Events
          </button>
          <button
            onClick={() => setActiveFilter('popular')}
            className={`px-6 py-3 rounded-full font-medium transition-all whitespace-nowrap flex items-center ${
              activeFilter === 'popular'
                ? 'bg-purple-600 text-white shadow-lg'
                : 'bg-white text-gray-700 hover:bg-gray-100'
            }`}
          >
            <SparklesIcon className="h-5 w-5 mr-2" />
            Popular Events
          </button>
        </div>

        {/* Additional Filters */}
        <div className="card p-6 mb-8">
          <div className="flex flex-wrap gap-4">
            <select
              value={locationType}
              onChange={(e) => setLocationType(e.target.value)}
              className="input"
            >
              <option value="">All Locations</option>
              <option value="PHYSICAL">In-Person</option>
              <option value="VIRTUAL">Virtual</option>
              <option value="HYBRID">Hybrid</option>
            </select>

            <label className="flex items-center">
              <input
                type="checkbox"
                checked={isFree}
                onChange={(e) => setIsFree(e.target.checked)}
                className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded mr-2"
              />
              <span className="text-sm font-medium text-gray-700">Free Events Only</span>
            </label>
          </div>
        </div>

        {/* Events Grid */}
        {isLoading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="card p-6 animate-pulse">
                <div className="h-48 bg-gray-200 rounded-lg mb-4"></div>
                <div className="h-6 bg-gray-200 rounded w-3/4 mb-2"></div>
                <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        ) : events.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {events.map((event) => (
              <Link
                key={event.id}
                href={`/events/${event.slug}`}
                className="card hover:shadow-lg transition-all duration-200 overflow-hidden group relative"
              >
                {event.isFeatured && (
                  <div className="absolute top-4 right-4 z-10">
                    <div className="bg-yellow-500 text-white px-3 py-1 rounded-full text-xs font-bold flex items-center shadow-lg">
                      <StarIcon className="h-4 w-4 mr-1" />
                      FEATURED
                    </div>
                  </div>
                )}
                
                {event.coverImage ? (
                  <img
                    src={event.coverImage}
                    alt={event.title}
                    className="w-full h-48 object-cover group-hover:scale-105 transition-transform duration-200"
                  />
                ) : (
                  <div className="w-full h-48 bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center">
                    <SparklesIcon className="h-16 w-16 text-white opacity-50" />
                  </div>
                )}
                
                <div className="p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2 group-hover:text-primary-600 transition-colors">
                    {event.title}
                  </h3>
                  
                  {event.shortDescription && (
                    <p className="text-sm text-gray-600 mb-4 line-clamp-2">
                      {event.shortDescription}
                    </p>
                  )}

                  <div className="space-y-2">
                    <div className="flex items-center text-sm text-gray-600">
                      <CalendarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                      <span>{format(new Date(event.startDate), 'MMM d, yyyy • h:mm a')}</span>
                    </div>

                    <div className="flex items-center text-sm text-gray-600">
                      <MapPinIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                      <span className="truncate">
                        {event.locationType === 'VIRTUAL' ? 'Virtual Event' : 
                         event.locationType === 'HYBRID' ? 'Hybrid Event' :
                         event.venueCity || 'TBD'}
                      </span>
                    </div>

                    <div className="flex items-center text-sm text-gray-600">
                      <UsersIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                      <span>{event.registrationCount} registered</span>
                    </div>
                  </div>

                  <div className="mt-4 pt-4 border-t border-gray-200 flex items-center justify-between">
                    <div className="flex items-center">
                      {event.organizer?.profile?.avatar ? (
                        <img
                          src={event.organizer.profile.avatar}
                          alt={event.organizer.profile.displayName}
                          className="w-8 h-8 rounded-full"
                        />
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center">
                          <span className="text-primary-600 font-medium text-sm">
                            {event.organizer?.profile?.displayName?.charAt(0)}
                          </span>
                        </div>
                      )}
                      <span className="ml-2 text-sm text-gray-600">
                        {event.organizer?.profile?.displayName}
                      </span>
                    </div>
                    
                    <div className={`px-3 py-1 rounded-full text-xs font-medium ${
                      event.price === 0 
                        ? 'bg-green-100 text-green-800'
                        : 'bg-blue-100 text-blue-800'
                    }`}>
                      {event.price === 0 ? 'Free' : `$${event.price}`}
                    </div>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        ) : (
          <div className="text-center py-12 card">
            <SparklesIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-4 text-sm font-medium text-gray-900">No events found</h3>
            <p className="mt-2 text-sm text-gray-500">
              {activeFilter === 'featured' 
                ? 'No featured events at the moment. Check back soon!'
                : 'Try adjusting your search or filters'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
