'use client';

import { CalendarEvent } from '@/types';
import { 
  CalendarDaysIcon, 
  UserGroupIcon, 
  ClockIcon,
  TrendingUpIcon
} from '@heroicons/react/24/outline';
import { format, isToday, isTomorrow, addDays, isWithinInterval } from 'date-fns';

interface QuickStatsProps {
  events: CalendarEvent[];
}

export default function QuickStats({ events }: QuickStatsProps) {
  const now = new Date();
  const nextWeek = addDays(now, 7);

  const stats = {
    total: events.length,
    today: events.filter(event => isToday(new Date(event.startDate))).length,
    tomorrow: events.filter(event => isTomorrow(new Date(event.startDate))).length,
    thisWeek: events.filter(event => 
      isWithinInterval(new Date(event.startDate), { start: now, end: nextWeek })
    ).length,
    upcoming: events.filter(event => new Date(event.startDate) > now).length,
    withLocation: events.filter(event => event.location).length,
  };

  const statCards = [
    {
      name: 'Total Events',
      value: stats.total,
      icon: CalendarDaysIcon,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
      description: 'All time',
    },
    {
      name: 'Today',
      value: stats.today,
      icon: ClockIcon,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
      description: format(now, 'MMM dd'),
    },
    {
      name: 'This Week',
      value: stats.thisWeek,
      icon: TrendingUpIcon,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
      description: 'Next 7 days',
    },
    {
      name: 'Upcoming',
      value: stats.upcoming,
      icon: CalendarDaysIcon,
      color: 'text-orange-600',
      bgColor: 'bg-orange-100',
      description: 'Future events',
    },
  ];

  return (
    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
      {statCards.map((stat) => {
        const Icon = stat.icon;
        return (
          <div key={stat.name} className="card p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className={`inline-flex p-3 rounded-lg ${stat.bgColor}`}>
                  <Icon className={`h-6 w-6 ${stat.color}`} />
                </div>
              </div>
              <div className="ml-4 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    {stat.name}
                  </dt>
                  <dd className="flex items-baseline">
                    <div className="text-2xl font-semibold text-gray-900">
                      {stat.value}
                    </div>
                    <div className="ml-2 text-sm text-gray-500">
                      {stat.description}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
