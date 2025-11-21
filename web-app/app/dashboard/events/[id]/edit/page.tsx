'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { useForm } from 'react-hook-form';
import toast from 'react-hot-toast';
import { ArrowLeftIcon } from '@heroicons/react/24/outline';

export default function EditEventPage() {
  const router = useRouter();
  const params = useParams();
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [event, setEvent] = useState<any>(null);
  
  const { register, handleSubmit, watch, setValue, formState: { errors } } = useForm({
    defaultValues: {
      title: '',
      description: '',
      shortDescription: '',
      startDate: '',
      startTime: '',
      endDate: '',
      endTime: '',
      locationType: 'PHYSICAL' as 'PHYSICAL' | 'VIRTUAL' | 'HYBRID',
      venueName: '',
      venueAddress: '',
      venueCity: '',
      venueState: '',
      venueZipCode: '',
      virtualLink: '',
      coverImage: '',
      price: 0,
      capacity: '',
      tags: '',
      isFeatured: false,
    }
  });

  const locationType = watch('locationType');

  useEffect(() => {
    fetchEvent();
  }, [params.id]);

  const fetchEvent = async () => {
    try {
      // First, get the user's profile to find their events
      const profileResponse = await fetch('/api/profile');
      if (!profileResponse.ok) {
        throw new Error('Failed to fetch profile');
      }

      const profileData = await profileResponse.json();
      const userEvent = profileData.profile?.organizedEvents?.find((e: any) => e.id === params.id) 
                     || profileData.profile?.publicEvents?.find((e: any) => e.id === params.id);

      if (!userEvent) {
        toast.error('Event not found or you do not have permission to edit it');
        router.push('/dashboard/my-events');
        return;
      }

      setEvent(userEvent);

      // Pre-fill form with event data
      const startDate = new Date(userEvent.startDate);
      const endDate = new Date(userEvent.endDate);

      setValue('title', userEvent.title);
      setValue('description', userEvent.description);
      setValue('shortDescription', userEvent.shortDescription || '');
      setValue('startDate', startDate.toISOString().split('T')[0]);
      setValue('startTime', startDate.toTimeString().slice(0, 5));
      setValue('endDate', endDate.toISOString().split('T')[0]);
      setValue('endTime', endDate.toTimeString().slice(0, 5));
      setValue('locationType', userEvent.locationType);
      setValue('venueName', userEvent.venueName || '');
      setValue('venueAddress', userEvent.venueAddress || '');
      setValue('venueCity', userEvent.venueCity || '');
      setValue('venueState', userEvent.venueState || '');
      setValue('venueZipCode', userEvent.venueZipCode || '');
      setValue('virtualLink', userEvent.virtualLink || '');
      setValue('coverImage', userEvent.coverImage || '');
      setValue('price', userEvent.price || 0);
      setValue('capacity', userEvent.capacity?.toString() || '');
      setValue('tags', userEvent.tags?.join(', ') || '');
      setValue('isFeatured', userEvent.isFeatured || false);

      setIsLoading(false);
    } catch (error) {
      console.error('Error fetching event:', error);
      toast.error('Failed to load event');
      router.push('/dashboard/my-events');
    }
  };

  const onSubmit = async (data: any) => {
    if (!event) return;

    setIsSubmitting(true);

    try {
      // Combine date and time
      const startDateTime = new Date(`${data.startDate}T${data.startTime}`).toISOString();
      const endDateTime = new Date(`${data.endDate}T${data.endTime}`).toISOString();

      // Format tags
      const tags = data.tags ? data.tags.split(',').map((t: string) => t.trim()).filter(Boolean) : [];

      const eventData = {
        title: data.title,
        description: data.description,
        shortDescription: data.shortDescription || data.description.substring(0, 300),
        startDate: startDateTime,
        endDate: endDateTime,
        timezone: 'America/New_York',
        locationType: data.locationType,
        venueName: data.venueName || undefined,
        venueAddress: data.venueAddress || undefined,
        venueCity: data.venueCity || undefined,
        venueState: data.venueState || undefined,
        venueZipCode: data.venueZipCode || undefined,
        virtualLink: data.virtualLink || undefined,
        coverImage: data.coverImage || undefined,
        capacity: data.capacity ? parseInt(data.capacity) : undefined,
        price: parseFloat(data.price) || 0,
        currency: 'USD',
        tags: tags,
        isFeatured: data.isFeatured,
      };

      const response = await fetch(`/api/public-events/${event.slug}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });

      if (response.ok) {
        toast.success('Event updated successfully!');
        router.push('/dashboard/my-events');
      } else {
        const error = await response.json();
        toast.error(error.error || 'Failed to update event');
      }
    } catch (error) {
      console.error('Error updating event:', error);
      toast.error('Failed to update event');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="max-w-4xl mx-auto">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="card p-6 space-y-4">
            <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!event) return null;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <button
          onClick={() => router.back()}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeftIcon className="h-5 w-5 text-gray-600" />
        </button>
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Edit Event</h1>
          <p className="mt-1 text-gray-600">Update your event details</p>
        </div>
      </div>

      {/* Event Status Badge */}
      <div className="flex items-center space-x-2">
        <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
          event.status === 'PUBLISHED' 
            ? 'bg-green-100 text-green-800'
            : event.status === 'DRAFT'
            ? 'bg-gray-100 text-gray-800'
            : 'bg-red-100 text-red-800'
        }`}>
          {event.status}
        </span>
        {event.isFeatured && (
          <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-800">
            Featured
          </span>
        )}
      </div>

      {/* Edit Form */}
      <form onSubmit={handleSubmit(onSubmit)} className="card p-6 space-y-6">
        {/* Basic Information */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Basic Information</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Event Title *
            </label>
            <input
              type="text"
              {...register('title', { required: 'Title is required' })}
              className="input"
              placeholder="NYC Tech Meetup"
            />
            {errors.title && (
              <p className="mt-1 text-sm text-red-600">{errors.title.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description *
            </label>
            <textarea
              {...register('description', { required: 'Description is required' })}
              rows={6}
              className="input"
              placeholder="Describe your event in detail..."
            />
            {errors.description && (
              <p className="mt-1 text-sm text-red-600">{errors.description.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Short Description
            </label>
            <textarea
              {...register('shortDescription')}
              rows={2}
              className="input"
              placeholder="Brief summary for cards and previews (optional)"
            />
          </div>
        </div>

        {/* Date and Time */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Date & Time</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Date *
              </label>
              <input
                type="date"
                {...register('startDate', { required: 'Start date is required' })}
                className="input"
              />
              {errors.startDate && (
                <p className="mt-1 text-sm text-red-600">{errors.startDate.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Time *
              </label>
              <input
                type="time"
                {...register('startTime', { required: 'Start time is required' })}
                className="input"
              />
              {errors.startTime && (
                <p className="mt-1 text-sm text-red-600">{errors.startTime.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Date *
              </label>
              <input
                type="date"
                {...register('endDate', { required: 'End date is required' })}
                className="input"
              />
              {errors.endDate && (
                <p className="mt-1 text-sm text-red-600">{errors.endDate.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Time *
              </label>
              <input
                type="time"
                {...register('endTime', { required: 'End time is required' })}
                className="input"
              />
              {errors.endTime && (
                <p className="mt-1 text-sm text-red-600">{errors.endTime.message}</p>
              )}
            </div>
          </div>
        </div>

        {/* Location */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Location</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Location Type *
            </label>
            <div className="flex space-x-4">
              <label className="flex items-center">
                <input
                  type="radio"
                  value="PHYSICAL"
                  {...register('locationType')}
                  className="mr-2"
                />
                <span>Physical</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="VIRTUAL"
                  {...register('locationType')}
                  className="mr-2"
                />
                <span>Virtual</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="HYBRID"
                  {...register('locationType')}
                  className="mr-2"
                />
                <span>Hybrid</span>
              </label>
            </div>
          </div>

          {(locationType === 'PHYSICAL' || locationType === 'HYBRID') && (
            <>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Venue Name
                </label>
                <input
                  type="text"
                  {...register('venueName')}
                  className="input"
                  placeholder="WeWork Union Square"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Street Address
                </label>
                <input
                  type="text"
                  {...register('venueAddress')}
                  className="input"
                  placeholder="123 Main St"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    City
                  </label>
                  <input
                    type="text"
                    {...register('venueCity')}
                    className="input"
                    placeholder="New York"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    State
                  </label>
                  <input
                    type="text"
                    {...register('venueState')}
                    className="input"
                    placeholder="NY"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Zip Code
                  </label>
                  <input
                    type="text"
                    {...register('venueZipCode')}
                    className="input"
                    placeholder="10001"
                  />
                </div>
              </div>
            </>
          )}

          {(locationType === 'VIRTUAL' || locationType === 'HYBRID') && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Virtual Link (Zoom, Google Meet, etc.)
              </label>
              <input
                type="url"
                {...register('virtualLink')}
                className="input"
                placeholder="https://zoom.us/j/123456789"
              />
            </div>
          )}
        </div>

        {/* Additional Details */}
        <div className="space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Additional Details</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cover Image URL
            </label>
            <input
              type="url"
              {...register('coverImage')}
              className="input"
              placeholder="https://example.com/image.jpg"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Price (USD)
              </label>
              <input
                type="number"
                step="0.01"
                {...register('price')}
                className="input"
                placeholder="0.00"
              />
              <p className="mt-1 text-xs text-gray-500">Set to 0 for free events</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Capacity
              </label>
              <input
                type="number"
                {...register('capacity')}
                className="input"
                placeholder="Leave empty for unlimited"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tags (comma-separated)
            </label>
            <input
              type="text"
              {...register('tags')}
              className="input"
              placeholder="tech, networking, ai, startup"
            />
          </div>

          <div className="flex items-center">
            <input
              type="checkbox"
              {...register('isFeatured')}
              className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
            />
            <label className="ml-2 block text-sm text-gray-700">
              Feature this event (appears in Featured Events filter)
            </label>
          </div>
        </div>

        {/* Form Actions */}
        <div className="flex items-center justify-between pt-6 border-t border-gray-200">
          <button
            type="button"
            onClick={() => router.back()}
            className="btn-secondary"
            disabled={isSubmitting}
          >
            Cancel
          </button>
          <button
            type="submit"
            className="btn-primary"
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <>
                <div className="spinner w-4 h-4 mr-2"></div>
                Saving Changes...
              </>
            ) : (
              'Save Changes'
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
