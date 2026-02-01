'use client';

import { CalendarEvent } from '@/types';
import { 
  Square3Stack3DIcon,
  SunIcon,
  ChartBarIcon,
  RocketLaunchIcon
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
      icon: Square3Stack3DIcon,
      iconBg: 'bg-[#25004D]/10',
      iconColor: 'text-[#25004D]',
      borderColor: 'border-[#25004D]/20',
      description: 'All time',
    },
    {
      name: 'Today',
      value: stats.today,
      icon: SunIcon,
      iconBg: 'bg-green-100',
      iconColor: 'text-green-600',
      borderColor: 'border-green-200',
      description: format(now, 'MMM dd'),
    },
    {
      name: 'This Week',
      value: stats.thisWeek,
      icon: ChartBarIcon,
      iconBg: 'bg-orange-100',
      iconColor: 'text-orange-500',
      borderColor: 'border-orange-200',
      description: 'Next 7 days',
    },
    {
      name: 'Upcoming',
      value: stats.upcoming,
      icon: RocketLaunchIcon,
      iconBg: 'bg-amber-100',
      iconColor: 'text-amber-600',
      borderColor: 'border-amber-200',
      description: 'Future events',
    },
  ];

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {statCards.map((stat) => {
        const Icon = stat.icon;
        return (
          <div 
            key={stat.name} 
            className="bg-white/40 backdrop-blur-xl rounded-2xl border border-white/50 p-5 shadow-lg shadow-[#25004D]/10 hover:bg-white/50 hover:shadow-xl transition-all duration-200"
          >
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className={`inline-flex p-3 rounded-xl ${stat.iconBg}`}>
                  <Icon className={`h-6 w-6 ${stat.iconColor}`} />
                </div>
              </div>
              <div className="ml-4 flex-1">
                <p className="text-sm font-medium text-gray-500 truncate">
                  {stat.name}
                </p>
                <div className="flex items-baseline mt-1">
                  <span className="text-2xl font-bold text-gray-900">
                    {stat.value}
                  </span>
                  <span className="ml-2 text-sm text-gray-400">
                    {stat.description}
                  </span>
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
