'use client';

import { useState, useEffect } from 'react';
import { useSession } from 'next-auth/react';
import { 
  CalendarDaysIcon, 
  UserGroupIcon, 
  PlusCircleIcon,
  ArrowRightIcon,
  GlobeAltIcon,
  UsersIcon
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
      icon: PlusCircleIcon,
      iconBg: 'bg-[#25004D]/10',
      iconColor: 'text-[#25004D]',
    },
    {
      name: 'Discover Events',
      description: 'Browse NYC tech events from Gary\'s Guide',
      href: '/dashboard/discover',
      icon: GlobeAltIcon,
      iconBg: 'bg-blue-100',
      iconColor: 'text-blue-600',
    },
    {
      name: 'View Calendar',
      description: 'See all your events in calendar view',
      href: '/dashboard/calendar',
      icon: CalendarDaysIcon,
      iconBg: 'bg-green-100',
      iconColor: 'text-green-600',
    },
    {
      name: 'LinkedIn Connections',
      description: 'Manage your networking contacts',
      href: '/dashboard/connections',
      icon: UsersIcon,
      iconBg: 'bg-pink-100',
      iconColor: 'text-pink-600',
    },
  ];

  return (
    <div className="space-y-6">
        {/* Welcome Header */}
        <div className="backdrop-blur-xl rounded-2xl p-8 text-white shadow-lg shadow-purple-500/20 border border-white/30" style={{ background: 'linear-gradient(to right, #25004D, #3d1a6d)' }}>
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold">
                Welcome back, {session?.user?.name?.split(' ')[0] || 'there'}!
              </h1>
              <p className="mt-2 text-purple-100">
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
                <p className="text-purple-200">
                  {new Date().toLocaleDateString('en-US', { year: 'numeric' })}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Stats */}
        <QuickStats events={events} />

        {/* Quick Actions */}
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {quickActions.map((action) => {
            const Icon = action.icon;
            return (
              <a
                key={action.name}
                href={action.href}
                className="group relative rounded-2xl border border-white/50 bg-white/40 backdrop-blur-xl p-6 shadow-lg shadow-[#25004D]/10 hover:shadow-xl hover:bg-white/50 transition-all duration-300"
              >
                <div>
                  <span className={`inline-flex rounded-xl p-3 ${action.iconBg} group-hover:scale-110 transition-transform duration-200`}>
                    <Icon className={`h-6 w-6 ${action.iconColor}`} aria-hidden="true" />
                  </span>
                </div>
                <div className="mt-4">
                  <h3 className="text-base font-semibold text-gray-900 group-hover:text-[#25004D] transition-colors">
                    {action.name}
                    <span className="absolute inset-0" aria-hidden="true" />
                  </h3>
                  <p className="mt-1 text-sm text-gray-500 leading-relaxed">
                    {action.description}
                  </p>
                </div>
                <div className="mt-4 flex items-center text-[#25004D] group-hover:text-[#3d1a6d]">
                  <span className="text-sm font-medium">Get started</span>
                  <ArrowRightIcon className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform duration-200" />
                </div>
              </a>
            );
          })}
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Upcoming Events */}
          <div className="lg:col-span-2">
            <div className="bg-white/40 backdrop-blur-xl rounded-2xl border border-white/50 p-6 shadow-lg shadow-[#25004D]/10">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-lg font-semibold text-gray-900">Upcoming Events</h2>
                <a
                  href="/dashboard/calendar"
                  className="text-sm font-medium text-[#25004D] hover:text-[#3d1a6d]"
                >
                  View all
                </a>
              </div>
              
              {isLoading ? (
                <div className="space-y-4">
                  {[...Array(3)].map((_, i) => (
                    <div key={i} className="animate-pulse">
                      <div className="h-20 bg-[#25004D]/10 rounded-xl"></div>
                    </div>
                  ))}
                </div>
              ) : upcomingEvents.length > 0 ? (
                <div className="space-y-3">
                  {upcomingEvents.map((event) => (
                    <div
                      key={event.id}
                      className="flex items-center justify-between p-4 border border-[#25004D]/20 rounded-xl hover:border-[#25004D]/30 hover:bg-[#25004D]/5 transition-all duration-200"
                    >
                      <div className="flex-1">
                        <h3 className="font-medium text-gray-900">{event.title}</h3>
                        <div className="flex items-center mt-1 text-sm text-gray-500">
                          <CalendarDaysIcon className="h-4 w-4 mr-1 text-[#25004D]/60" />
                          <span>
                            {formatDistanceToNow(new Date(event.startDate), { addSuffix: true })}
                          </span>
                          {event.location && (
                            <>
                              <span className="mx-2">-</span>
                              <span>{event.location}</span>
                            </>
                          )}
                        </div>
                      </div>
                      <a
                        href={`/dashboard/events/${event.id}`}
                        className="text-[#25004D] hover:text-[#3d1a6d] p-2 rounded-lg hover:bg-[#25004D]/10 transition-colors"
                      >
                        <ArrowRightIcon className="h-5 w-5" />
                      </a>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-12">
                  <div className="mx-auto w-16 h-16 bg-[#25004D]/10 rounded-2xl flex items-center justify-center mb-4">
                    <CalendarDaysIcon className="h-8 w-8 text-[#25004D]/60" />
                  </div>
                  <h3 className="text-sm font-medium text-gray-900">No upcoming events</h3>
                  <p className="mt-2 text-sm text-gray-500">
                    Get started by creating your first event or discovering events from Gary's Guide.
                  </p>
                  <div className="mt-6">
                    <a
                      href="/dashboard/events/create"
                      className="inline-flex items-center px-4 py-2 bg-[#25004D] text-white rounded-xl font-medium hover:bg-[#3d1a6d] transition-colors"
                    >
                      <PlusCircleIcon className="h-4 w-4 mr-2" />
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
              <div className="bg-white/40 backdrop-blur-xl rounded-2xl border border-white/50 p-6 shadow-lg shadow-[#25004D]/10">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Today's Events</h3>
                <div className="space-y-3">
                  {todayEvents.map((event) => (
                    <div key={event.id} className="flex items-center space-x-3 p-3 rounded-xl hover:bg-[#25004D]/10 transition-colors">
                      <div className="flex-shrink-0">
                        <div className="w-2 h-2 bg-[#25004D] rounded-full"></div>
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
