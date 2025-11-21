'use client';

import { CalendarEvent } from '@/types';
import { CalendarIcon, MapPinIcon, ClockIcon, TrashIcon, PencilIcon } from '@heroicons/react/24/outline';
import { format } from 'date-fns';
import Link from 'next/link';

interface EventCardProps {
  event: CalendarEvent;
  onDelete?: (eventId: string) => void;
  showActions?: boolean;
}

export default function EventCard({ event, onDelete, showActions = true }: EventCardProps) {
  const handleDelete = (e: React.MouseEvent) => {
    e.preventDefault();
    if (onDelete && confirm('Are you sure you want to delete this event?')) {
      onDelete(event.id);
    }
  };

  return (
    <Link href={`/dashboard/events/${event.id}`}>
      <div className="card p-6 hover:shadow-lg transition-all duration-200 group">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
              {event.title}
            </h3>
            
            <div className="mt-3 space-y-2">
              <div className="flex items-center text-sm text-gray-600">
                <CalendarIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                <span>
                  {format(new Date(event.startDate), 'EEEE, MMMM d, yyyy')}
                </span>
              </div>
              
              <div className="flex items-center text-sm text-gray-600">
                <ClockIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                <span>
                  {format(new Date(event.startDate), 'h:mm a')} - {format(new Date(event.endDate), 'h:mm a')}
                </span>
              </div>
              
              {event.location && (
                <div className="flex items-center text-sm text-gray-600">
                  <MapPinIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span className="truncate">{event.location}</span>
                </div>
              )}
            </div>

            {event.notes && (
              <p className="mt-3 text-sm text-gray-500 line-clamp-2">
                {event.notes}
              </p>
            )}

            {event.extractedInfo && event.extractedInfo.confidence && (
              <div className="mt-3">
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                  AI Extracted ({Math.round(event.extractedInfo.confidence * 100)}% confidence)
                </span>
              </div>
            )}
          </div>

          {showActions && (
            <div className="ml-4 flex space-x-2">
              <Link
                href={`/dashboard/events/${event.id}/edit`}
                className="p-2 text-gray-400 hover:text-primary-600 transition-colors"
                onClick={(e) => e.stopPropagation()}
              >
                <PencilIcon className="h-5 w-5" />
              </Link>
              <button
                onClick={handleDelete}
                className="p-2 text-gray-400 hover:text-red-600 transition-colors"
              >
                <TrashIcon className="h-5 w-5" />
              </button>
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}

