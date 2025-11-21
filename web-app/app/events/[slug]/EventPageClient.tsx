'use client';

import { useState } from 'react';
import { format, parseISO } from 'date-fns';
import { CalendarDaysIcon, MapPinIcon, UsersIcon, CurrencyDollarIcon, ClockIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';
import RegistrationModal from './RegistrationModal';

interface EventPageClientProps {
  event: any;
}

export default function EventPageClient({ event: initialEvent }: EventPageClientProps) {
  const [event, setEvent] = useState(initialEvent);
  const [showRegistrationModal, setShowRegistrationModal] = useState(false);

  const handleShare = () => {
    navigator.clipboard.writeText(window.location.href);
    toast.success('Link copied to clipboard!');
  };

  const handleRegister = () => {
    setShowRegistrationModal(true);
  };

  const handleRegistrationSuccess = () => {
    // Refresh event data to get updated registration count
    fetch(`/api/public-events/${event.slug}`)
      .then(res => res.json())
      .then(data => setEvent(data.event))
      .catch(err => console.error('Failed to refresh event:', err));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="relative">
        {event.coverImage ? (
          <div className="w-full">
            <img
              src={event.coverImage}
              alt={event.title}
              className="w-full h-auto max-h-[600px] object-contain bg-black"
            />
          </div>
        ) : (
          <div className="h-96 w-full bg-gradient-to-r from-primary-600 to-primary-400"></div>
        )}
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Title */}
            <div>
              <h1 className="text-4xl font-bold text-gray-900 mb-2">{event.title}</h1>
              {event.shortDescription && (
                <p className="text-xl text-gray-600">{event.shortDescription}</p>
              )}
            </div>

            {/* Description */}
            <div className="card p-6">
              <h2 className="text-2xl font-semibold text-gray-900 mb-4">About This Event</h2>
              <div className="prose max-w-none text-gray-700 whitespace-pre-wrap">
                {event.description}
              </div>
            </div>

            {/* Organizer */}
            {event.organizer && (
              <div className="card p-6">
                <h2 className="text-2xl font-semibold text-gray-900 mb-4">Organized By</h2>
                <div className="flex items-center space-x-4">
                  {event.organizer.image ? (
                    <img
                      src={event.organizer.image}
                      alt={event.organizer.name}
                      className="w-16 h-16 rounded-full"
                    />
                  ) : (
                    <div className="w-16 h-16 rounded-full bg-primary-100 flex items-center justify-center text-primary-600 text-2xl font-bold">
                      {event.organizer.name?.[0]?.toUpperCase()}
                    </div>
                  )}
                  <div>
                    <p className="font-semibold text-gray-900">{event.organizer.name}</p>
                    <p className="text-sm text-gray-500">{event.organizer.email}</p>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Event Details Card */}
            <div className="card p-6 sticky top-6">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Event Details</h3>
              
              <div className="space-y-4">
                {/* Date & Time */}
                <div className="flex items-start space-x-3">
                  <CalendarDaysIcon className="h-6 w-6 text-gray-400 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="font-medium text-gray-900">
                      {format(parseISO(event.startDate), 'EEEE, MMMM d, yyyy')}
                    </p>
                    <p className="text-sm text-gray-500">
                      {format(parseISO(event.startDate), 'h:mm a')} - {format(parseISO(event.endDate), 'h:mm a')} {event.timezone}
                    </p>
                  </div>
                </div>

                {/* Location */}
                <div className="flex items-start space-x-3">
                  <MapPinIcon className="h-6 w-6 text-gray-400 flex-shrink-0 mt-0.5" />
                  <div>
                    {event.locationType === 'VIRTUAL' ? (
                      <>
                        <p className="font-medium text-gray-900">Virtual Event</p>
                        {event.virtualLink && (
                          <a
                            href={event.virtualLink}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-sm text-primary-600 hover:text-primary-700"
                          >
                            Join online
                          </a>
                        )}
                      </>
                    ) : (
                      <>
                        <p className="font-medium text-gray-900">
                          {event.venueName || 'In-Person Event'}
                        </p>
                        {event.venueAddress && (
                          <p className="text-sm text-gray-500">
                            {event.venueAddress}
                            {event.venueCity && `, ${event.venueCity}`}
                            {event.venueState && `, ${event.venueState}`}
                          </p>
                        )}
                      </>
                    )}
                  </div>
                </div>

                {/* Price */}
                <div className="flex items-start space-x-3">
                  <CurrencyDollarIcon className="h-6 w-6 text-gray-400 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="font-medium text-gray-900">
                      {event.price === 0 ? 'Free' : `${event.currency} ${event.price}`}
                    </p>
                  </div>
                </div>

                {/* Capacity */}
                {event.capacity && (
                  <div className="flex items-start space-x-3">
                    <UsersIcon className="h-6 w-6 text-gray-400 flex-shrink-0 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900">
                        {event.registrationCount || 0} / {event.capacity} registered
                      </p>
                    </div>
                  </div>
                )}

                {/* Registration Deadline */}
                {event.registrationDeadline && (
                  <div className="flex items-start space-x-3">
                    <ClockIcon className="h-6 w-6 text-gray-400 flex-shrink-0 mt-0.5" />
                    <div>
                      <p className="text-sm text-gray-500">Registration closes</p>
                      <p className="font-medium text-gray-900">
                        {format(parseISO(event.registrationDeadline), 'MMM d, yyyy h:mm a')}
                      </p>
                    </div>
                  </div>
                )}
              </div>

              {/* Register Button */}
              <div className="mt-6">
                <button onClick={handleRegister} className="w-full btn-primary">
                  Register for Event
                </button>
              </div>

              {/* Share */}
              <div className="mt-4 pt-4 border-t border-gray-200">
                <button onClick={handleShare} className="w-full btn-secondary text-sm">
                  Share Event
                </button>
              </div>
            </div>

            {/* Tags */}
            {event.tags && JSON.parse(event.tags).length > 0 && (
              <div className="card p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Tags</h3>
                <div className="flex flex-wrap gap-2">
                  {JSON.parse(event.tags).map((tag: string, idx: number) => (
                    <span
                      key={idx}
                      className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-800"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Registration Modal */}
      <RegistrationModal
        event={event}
        isOpen={showRegistrationModal}
        onClose={() => setShowRegistrationModal(false)}
        onSuccess={handleRegistrationSuccess}
      />
    </div>
  );
}

