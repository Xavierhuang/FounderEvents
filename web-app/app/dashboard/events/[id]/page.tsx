'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { CalendarEvent } from '@/types';
import { CalendarIcon, MapPinIcon, ClockIcon, TrashIcon, PencilIcon, ArrowDownTrayIcon } from '@heroicons/react/24/outline';
import { format } from 'date-fns';
import toast from 'react-hot-toast';

export default function EventDetailPage() {
  const router = useRouter();
  const params = useParams();
  const [event, setEvent] = useState<CalendarEvent | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (params.id) {
      fetchEvent(params.id as string);
    }
  }, [params.id]);

  const fetchEvent = async (id: string) => {
    try {
      const response = await fetch(`/api/events/${id}`);
      if (response.ok) {
        const data = await response.json();
        setEvent(data.event);
      } else {
        toast.error('Event not found');
        router.push('/dashboard/calendar');
      }
    } catch (error) {
      console.error('Failed to fetch event:', error);
      toast.error('Failed to load event');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!event || !confirm('Are you sure you want to delete this event?')) return;

    try {
      const response = await fetch(`/api/events/${event.id}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        toast.success('Event deleted successfully');
        router.push('/dashboard/calendar');
      } else {
        toast.error('Failed to delete event');
      }
    } catch (error) {
      console.error('Error deleting event:', error);
      toast.error('Failed to delete event');
    }
  };

  const handleExport = async () => {
    if (!event) return;

    try {
      const response = await fetch(`/api/events/export?eventIds=${event.id}`);
      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `${event.title.replace(/\s+/g, '-')}.ics`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
        toast.success('Event exported successfully');
      } else {
        toast.error('Failed to export event');
      }
    } catch (error) {
      console.error('Error exporting event:', error);
      toast.error('Failed to export event');
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="spinner w-8 h-8"></div>
      </div>
    );
  }

  if (!event) {
    return null;
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">{event.title}</h1>
          <p className="mt-2 text-gray-600">Event Details</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={handleExport}
            className="btn-secondary"
          >
            <ArrowDownTrayIcon className="h-5 w-5 mr-2" />
            Export
          </button>
          <button
            onClick={() => router.push(`/dashboard/events/${event.id}/edit`)}
            className="btn-secondary"
          >
            <PencilIcon className="h-5 w-5 mr-2" />
            Edit
          </button>
          <button
            onClick={handleDelete}
            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            <TrashIcon className="h-5 w-5 mr-2 inline" />
            Delete
          </button>
        </div>
      </div>

      <div className="card p-8">
        <div className="space-y-6">
          <div>
            <div className="flex items-center text-gray-600 mb-2">
              <CalendarIcon className="h-5 w-5 mr-2" />
              <span className="font-medium">Date</span>
            </div>
            <p className="text-lg text-gray-900 ml-7">
              {format(new Date(event.startDate), 'EEEE, MMMM d, yyyy')}
            </p>
          </div>

          <div>
            <div className="flex items-center text-gray-600 mb-2">
              <ClockIcon className="h-5 w-5 mr-2" />
              <span className="font-medium">Time</span>
            </div>
            <p className="text-lg text-gray-900 ml-7">
              {format(new Date(event.startDate), 'h:mm a')} - {format(new Date(event.endDate), 'h:mm a')}
            </p>
          </div>

          {event.location && (
            <div>
              <div className="flex items-center text-gray-600 mb-2">
                <MapPinIcon className="h-5 w-5 mr-2" />
                <span className="font-medium">Location</span>
              </div>
              <p className="text-lg text-gray-900 ml-7">{event.location}</p>
            </div>
          )}

          {event.notes && (
            <div>
              <h3 className="font-medium text-gray-700 mb-2">Notes</h3>
              <p className="text-gray-900 whitespace-pre-wrap">{event.notes}</p>
            </div>
          )}

          {event.extractedInfo && event.extractedInfo.confidence && (
            <div className="pt-6 border-t border-gray-200">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-600">
                  This event was extracted using AI
                </span>
                <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-purple-100 text-purple-800">
                  {Math.round(event.extractedInfo.confidence * 100)}% confidence
                </span>
              </div>
            </div>
          )}
        </div>
      </div>

      <div className="flex justify-center">
        <button
          onClick={() => router.back()}
          className="btn-secondary"
        >
          Back to Calendar
        </button>
      </div>
    </div>
  );
}

