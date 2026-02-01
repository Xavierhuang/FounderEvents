'use client';

import { useState, useEffect } from 'react';
import { 
  CalendarDaysIcon, 
  UserGroupIcon, 
  SparklesIcon,
  ShareIcon
} from '@heroicons/react/24/outline';
import { formatDistanceToNow } from 'date-fns';

interface Activity {
  id: string;
  type: 'event_created' | 'event_shared' | 'profile_added' | 'event_discovered';
  title: string;
  description: string;
  timestamp: Date;
  icon: any;
  color: string;
}

export default function RecentActivity() {
  const [activities, setActivities] = useState<Activity[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchRecentActivity();
  }, []);

  const fetchRecentActivity = async () => {
    try {
      const response = await fetch('/api/activity/recent');
      if (response.ok) {
        const data = await response.json();
        setActivities(data.activities || []);
      }
    } catch (error) {
      console.error('Failed to fetch recent activity:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Mock data for demonstration
  const mockActivities: Activity[] = [
    {
      id: '1',
      type: 'event_created',
      title: 'Created "Tech Meetup"',
      description: 'AI extracted event from screenshot',
      timestamp: new Date(Date.now() - 1000 * 60 * 30), // 30 minutes ago
      icon: CalendarDaysIcon,
      color: 'text-blue-600',
    },
    {
      id: '2',
      type: 'profile_added',
      title: 'Added LinkedIn profile',
      description: 'Connected with Sarah Chen from TechCorp',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
      icon: UserGroupIcon,
      color: 'text-green-600',
    },
    {
      id: '3',
      type: 'event_discovered',
      title: 'Discovered 5 new events',
      description: 'From Gary\'s Guide NYC tech events',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 4), // 4 hours ago
      icon: SparklesIcon,
      color: 'text-[#25004D]',
    },
    {
      id: '4',
      type: 'event_shared',
      title: 'Shared calendar',
      description: 'Sent 3 events via email to team',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
      icon: ShareIcon,
      color: 'text-orange-600',
    },
  ];

  const displayActivities = activities.length > 0 ? activities : mockActivities;

  return (
    <div className="bg-white/40 backdrop-blur-xl rounded-2xl border border-white/50 p-6 shadow-lg shadow-[#25004D]/10">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900">Recent Activity</h3>
        <a
          href="/dashboard/activity"
          className="text-sm font-medium text-[#25004D] hover:text-[#3d1a6d]"
        >
          View all
        </a>
      </div>

      {isLoading ? (
        <div className="space-y-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="animate-pulse flex items-start space-x-3">
              <div className="w-8 h-8 bg-[#25004D]/10 rounded-xl"></div>
              <div className="flex-1 space-y-2">
                <div className="h-4 bg-[#25004D]/10 rounded w-3/4"></div>
                <div className="h-3 bg-[#25004D]/10 rounded w-1/2"></div>
              </div>
            </div>
          ))}
        </div>
      ) : displayActivities.length > 0 ? (
        <div className="flow-root">
          <ul className="-mb-8">
            {displayActivities.map((activity, activityIdx) => {
              const Icon = activity.icon;
              return (
                <li key={activity.id}>
                  <div className="relative pb-8">
                    {activityIdx !== displayActivities.length - 1 ? (
                      <span
                        className="absolute left-4 top-4 -ml-px h-full w-0.5 bg-[#25004D]/10"
                        aria-hidden="true"
                      />
                    ) : null}
                    <div className="relative flex items-start space-x-3">
                      <div>
                        <div className={`relative px-1`}>
                          <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#25004D]/10 ring-4 ring-white">
                            <Icon className={`h-4 w-4 ${activity.color}`} aria-hidden="true" />
                          </div>
                        </div>
                      </div>
                      <div className="min-w-0 flex-1">
                        <div>
                          <div className="text-sm">
                            <span className="font-medium text-gray-900">
                              {activity.title}
                            </span>
                          </div>
                          <p className="mt-0.5 text-sm text-gray-500">
                            {formatDistanceToNow(activity.timestamp, { addSuffix: true })}
                          </p>
                        </div>
                        <div className="mt-2 text-sm text-gray-600">
                          <p>{activity.description}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </li>
              );
            })}
          </ul>
        </div>
      ) : (
        <div className="text-center py-6">
          <div className="text-gray-400 text-sm">
            No recent activity to show
          </div>
        </div>
      )}
    </div>
  );
}
