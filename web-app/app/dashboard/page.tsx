'use client';

import { useState, useEffect } from 'react';
import { useSession } from 'next-auth/react';
import { 
  CalendarDaysIcon, 
  UserGroupIcon, 
  SparklesIcon,
  PlusIcon,
  ArrowRightIcon
} from '@heroicons/react/24/outline';
import { CalendarEvent } from '@/types';
import EventCard from '@/components/events/EventCard';
import QuickStats from '@/components/dashboard/QuickStats';
import RecentActivity from '@/components/dashboard/RecentActivity';
import UpcomingEvents from '@/components/dashboard/UpcomingEvents';
import { formatDistanceToNow } from 'date-fns';

export default function DashboardPage() {
  const { data: session } = useSession();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
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
    } finally {
      setIsLoading(false);
    }
  };

  const upcomingEvents = events
    .filter(event => new Date(event.startDate) > new Date())
    .sort((a, b) => new Date(a.startDate).getTime() - new Date(b.startDate).getTime())
    .slice(0, 5);

  const todayEvents = events.filter(event => {
    const today = new Date();
    const eventDate = new Date(event.startDate);
    return eventDate.toDateString() === today.toDateString();
  });

  const quickActions = [
    {
      name: 'Add Event',
      description: 'Create a new event from screenshot or manually',
      href: '/dashboard/events/create',
      icon: PlusIcon,
      color: 'bg-primary-500 hover:bg-primary-600',
    },
    {
      name: 'Discover Events',
      description: 'Browse NYC tech events from Gary\'s Guide',
      href: '/dashboard/discover',
      icon: SparklesIcon,
      color: 'bg-blue-500 hover:bg-blue-600',
    },
    {
      name: 'View Calendar',
      description: 'See all your events in calendar view',
      href: '/dashboard/calendar',
      icon: CalendarDaysIcon,
      color: 'bg-green-500 hover:bg-green-600',
    },
    {
      name: 'LinkedIn Connections',
      description: 'Manage your networking contacts',
      href: '/dashboard/connections',
      icon: UserGroupIcon,
      color: 'bg-purple-500 hover:bg-purple-600',
    },
  ];

  return (
    <div className="space-y-8">
      {/* Welcome Header */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-400 rounded-2xl p-8 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">
              Welcome back, {session?.user?.name?.split(' ')[0] || 'there'}! 👋
            </h1>
            <p className="mt-2 text-primary-100">
              {todayEvents.length > 0 
                ? `You have ${todayEvents.length} event${todayEvents.length === 1 ? '' : 's'} today`
                : 'No events scheduled for today'
              }
            </p>
          </div>
          <div className="hidden md:block">
            <div className="text-right">
              <p className="text-lg font-semibold">
                {new Date().toLocaleDateString('en-US', { 
                  weekday: 'long', 
                  month: 'long', 
                  day: 'numeric' 
                })}
              </p>
              <p className="text-primary-100">
                {new Date().toLocaleDateString('en-US', { year: 'numeric' })}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <QuickStats events={events} />

      {/* Quick Actions */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {quickActions.map((action) => {
          const Icon = action.icon;
          return (
            <a
              key={action.name}
              href={action.href}
              className="group relative rounded-xl border border-gray-200 bg-white p-6 shadow-sm hover:shadow-md transition-all duration-200 hover:border-gray-300"
            >
              <div>
                <span className={`inline-flex rounded-lg p-3 ${action.color} text-white group-hover:scale-110 transition-transform duration-200`}>
                  <Icon className="h-6 w-6" aria-hidden="true" />
                </span>
              </div>
              <div className="mt-4">
                <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                  {action.name}
                  <span className="absolute inset-0" aria-hidden="true" />
                </h3>
                <p className="mt-1 text-sm text-gray-500">
                  {action.description}
                </p>
              </div>
              <div className="mt-4 flex items-center text-primary-600 group-hover:text-primary-500">
                <span className="text-sm font-medium">Get started</span>
                <ArrowRightIcon className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform duration-200" />
              </div>
            </a>
          );
        })}
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Upcoming Events */}
        <div className="lg:col-span-2">
          <div className="card p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Upcoming Events</h2>
              <a
                href="/dashboard/calendar"
                className="text-sm font-medium text-primary-600 hover:text-primary-500"
              >
                View all
              </a>
            </div>
            
            {isLoading ? (
              <div className="space-y-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="animate-pulse">
                    <div className="h-20 bg-gray-200 rounded-lg"></div>
                  </div>
                ))}
              </div>
            ) : upcomingEvents.length > 0 ? (
              <div className="space-y-4">
                {upcomingEvents.map((event) => (
                  <div
                    key={event.id}
                    className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-gray-300 transition-colors"
                  >
                    <div className="flex-1">
                      <h3 className="font-medium text-gray-900">{event.title}</h3>
                      <div className="flex items-center mt-1 text-sm text-gray-500">
                        <CalendarDaysIcon className="h-4 w-4 mr-1" />
                        <span>
                          {formatDistanceToNow(new Date(event.startDate), { addSuffix: true })}
                        </span>
                        {event.location && (
                          <>
                            <span className="mx-2">•</span>
                            <span>{event.location}</span>
                          </>
                        )}
                      </div>
                    </div>
                    <a
                      href={`/dashboard/events/${event.id}`}
                      className="text-primary-600 hover:text-primary-500"
                    >
                      <ArrowRightIcon className="h-5 w-5" />
                    </a>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <CalendarDaysIcon className="mx-auto h-12 w-12 text-gray-400" />
                <h3 className="mt-4 text-sm font-medium text-gray-900">No upcoming events</h3>
                <p className="mt-2 text-sm text-gray-500">
                  Get started by creating your first event or discovering events from Gary's Guide.
                </p>
                <div className="mt-6">
                  <a
                    href="/dashboard/events/create"
                    className="btn-primary"
                  >
                    <PlusIcon className="h-4 w-4 mr-2" />
                    Create Event
                  </a>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Recent Activity Sidebar */}
        <div className="space-y-6">
          <RecentActivity />
          
          {/* Today's Events */}
          {todayEvents.length > 0 && (
            <div className="card p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Today's Events</h3>
              <div className="space-y-3">
                {todayEvents.map((event) => (
                  <div key={event.id} className="flex items-center space-x-3">
                    <div className="flex-shrink-0">
                      <div className="w-2 h-2 bg-primary-600 rounded-full"></div>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {event.title}
                      </p>
                      <p className="text-xs text-gray-500">
                        {new Date(event.startDate).toLocaleTimeString('en-US', {
                          hour: 'numeric',
                          minute: '2-digit',
                          hour12: true,
                        })}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
