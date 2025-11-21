'use client';

import { useState, useEffect } from 'react';
import { CalendarEvent, RoutePlan } from '@/types';
import { MapIcon, ClockIcon, CurrencyDollarIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';

export default function RoutePlanningPage() {
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [selectedEventIds, setSelectedEventIds] = useState<string[]>([]);
  const [routePlans, setRoutePlans] = useState<RoutePlan[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isGenerating, setIsGenerating] = useState(false);

  useEffect(() => {
    fetchEvents();
    fetchRoutePlans();
  }, []);

  const fetchEvents = async () => {
    try {
      const response = await fetch('/api/events');
      if (response.ok) {
        const data = await response.json();
        const upcomingEvents = data.events.filter(
          (e: CalendarEvent) => new Date(e.startDate) > new Date()
        );
        setEvents(upcomingEvents);
      }
    } catch (error) {
      console.error('Failed to fetch events:', error);
      toast.error('Failed to load events');
    } finally {
      setIsLoading(false);
    }
  };

  const fetchRoutePlans = async () => {
    try {
      const response = await fetch('/api/route-planning');
      if (response.ok) {
        const data = await response.json();
        setRoutePlans(data.routePlans || []);
      }
    } catch (error) {
      console.error('Failed to fetch route plans:', error);
    }
  };

  const handleToggleEvent = (eventId: string) => {
    if (selectedEventIds.includes(eventId)) {
      setSelectedEventIds(selectedEventIds.filter(id => id !== eventId));
    } else {
      setSelectedEventIds([...selectedEventIds, eventId]);
    }
  };

  const handleGenerateRoute = async () => {
    if (selectedEventIds.length === 0) {
      toast.error('Please select at least one event');
      return;
    }

    setIsGenerating(true);
    try {
      const response = await fetch('/api/route-planning', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eventIds: selectedEventIds,
          startLocation: null,
          transportationPreferences: ['subway', 'walking', 'taxi'],
        }),
      });

      if (response.ok) {
        const data = await response.json();
        setRoutePlans([data.routePlan, ...routePlans]);
        setSelectedEventIds([]);
        toast.success('Route plan generated successfully!');
      } else {
        toast.error('Failed to generate route plan');
      }
    } catch (error) {
      console.error('Error generating route:', error);
      toast.error('Failed to generate route plan');
    } finally {
      setIsGenerating(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="spinner w-8 h-8"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Route Planning</h1>
        <p className="mt-2 text-gray-600">
          Plan optimal routes for your multi-event days with AI
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Event Selection */}
        <div className="card p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">
            Select Events
          </h2>
          {events.length > 0 ? (
            <div className="space-y-2 mb-6">
              {events.map((event) => (
                <label
                  key={event.id}
                  className="flex items-start p-3 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer"
                >
                  <input
                    type="checkbox"
                    checked={selectedEventIds.includes(event.id)}
                    onChange={() => handleToggleEvent(event.id)}
                    className="mt-1 h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  />
                  <div className="ml-3 flex-1">
                    <p className="font-medium text-gray-900">{event.title}</p>
                    <p className="text-sm text-gray-500">
                      {new Date(event.startDate).toLocaleString()}
                    </p>
                    {event.location && (
                      <p className="text-sm text-gray-500 flex items-center mt-1">
                        <MapIcon className="h-3 w-3 mr-1" />
                        {event.location}
                      </p>
                    )}
                  </div>
                </label>
              ))}
            </div>
          ) : (
            <p className="text-center py-8 text-gray-500">
              No upcoming events. Create some events first.
            </p>
          )}

          <button
            onClick={handleGenerateRoute}
            disabled={selectedEventIds.length === 0 || isGenerating}
            className="btn-primary w-full"
          >
            {isGenerating ? (
              <>
                <div className="spinner w-4 h-4 mr-2" />
                Generating Route...
              </>
            ) : (
              <>
                <MapIcon className="h-5 w-5 mr-2" />
                Generate Route ({selectedEventIds.length} events)
              </>
            )}
          </button>
        </div>

        {/* Route Plans */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">
            Your Route Plans
          </h2>
          {routePlans.length > 0 ? (
            <div className="space-y-4">
              {routePlans.map((plan) => (
                <div key={plan.id} className="card p-6">
                  <h3 className="font-semibold text-gray-900 mb-4">
                    {plan.name}
                  </h3>
                  <div className="space-y-3">
                    <div className="flex items-center text-sm">
                      <ClockIcon className="h-4 w-4 mr-2 text-gray-400" />
                      <span className="text-gray-600">
                        Total time: {Math.round(plan.totalTime / 60)} minutes
                      </span>
                    </div>
                    <div className="flex items-center text-sm">
                      <CurrencyDollarIcon className="h-4 w-4 mr-2 text-gray-400" />
                      <span className="text-gray-600">
                        Estimated cost: ${plan.totalCost.toFixed(2)}
                      </span>
                    </div>
                    {plan.segments && plan.segments.length > 0 && (
                      <div className="mt-4 pt-4 border-t border-gray-200">
                        <p className="text-sm font-medium text-gray-700 mb-2">
                          Route Segments:
                        </p>
                        <div className="space-y-2">
                          {plan.segments.map((segment, idx) => (
                            <div
                              key={segment.id}
                              className="text-sm text-gray-600 pl-4 border-l-2 border-primary-500"
                            >
                              <span className="font-medium">
                                {segment.transportMode}
                              </span>
                              {' - '}
                              {Math.round(segment.travelTime / 60)} min
                              {segment.cost > 0 && ` ($${segment.cost.toFixed(2)})`}
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="card p-12 text-center">
              <MapIcon className="mx-auto h-12 w-12 text-gray-400" />
              <p className="mt-4 text-gray-500">No route plans yet</p>
              <p className="mt-2 text-sm text-gray-400">
                Select events and generate your first route plan
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

