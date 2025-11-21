'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import toast from 'react-hot-toast';

export default function CreateManualEventPage() {
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [hasProfile, setHasProfile] = useState<boolean | null>(null);
  
  const { register, handleSubmit, watch, formState: { errors } } = useForm({
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
    }
  });

  const locationType = watch('locationType');

  useEffect(() => {
    // Check if user has a profile
    fetch('/api/profile')
      .then(res => {
        if (res.ok) {
          setHasProfile(true);
        } else if (res.status === 404) {
          setHasProfile(false);
        }
      })
      .catch(() => setHasProfile(false));
  }, []);

  const onSubmit = async (data: any) => {
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
        isPublic: true,
        requiresApproval: false,
        capacity: data.capacity ? parseInt(data.capacity) : undefined,
        price: parseFloat(data.price) || 0,
        currency: 'USD',
        tags: tags,
        categoryIds: [],
      };

      const response = await fetch('/api/public-events', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });

      if (response.ok) {
        const result = await response.json();
        toast.success('Event created successfully!');
        router.push(`/events/${result.event.slug}`);
      } else {
        const error = await response.json();
        if (error.details) {
          const validationErrors = Array.isArray(error.details) 
            ? error.details.map((e: any) => `${e.path?.join('.')}: ${e.message}`).join(', ')
            : JSON.stringify(error.details);
          toast.error(`Validation Error: ${validationErrors}`);
        } else {
          toast.error(error.error || 'Failed to create event');
        }
      }
    } catch (error) {
      console.error('Error creating event:', error);
      toast.error('Failed to create event');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Show profile setup prompt if no profile
  if (hasProfile === false) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="card p-8 text-center space-y-4">
          <h2 className="text-2xl font-bold text-gray-900">Profile Required</h2>
          <p className="text-gray-600">
            You need to create an event organizer profile before you can create events.
          </p>
          <div className="pt-4">
            <button
              onClick={() => router.push('/dashboard/profile/setup')}
              className="btn-primary"
            >
              Create Profile
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Create Event</h1>
        <p className="mt-2 text-gray-600">
          Manually create a new public event
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Basic Info */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Basic Information</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Event Title *
            </label>
            <input
              {...register('title', { required: 'Title is required' })}
              className="input"
              placeholder="My Amazing Event"
            />
            {errors.title && <p className="mt-1 text-sm text-red-600">{errors.title.message}</p>}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Short Description
            </label>
            <input
              {...register('shortDescription')}
              className="input"
              placeholder="A brief one-liner about your event"
              maxLength={300}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Full Description *
            </label>
            <textarea
              {...register('description', { required: 'Description is required' })}
              className="input"
              rows={6}
              placeholder="Tell people all about your event..."
            />
            {errors.description && <p className="mt-1 text-sm text-red-600">{errors.description.message}</p>}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cover Image URL
            </label>
            <input
              {...register('coverImage')}
              type="url"
              className="input"
              placeholder="https://example.com/image.jpg"
            />
          </div>
        </div>

        {/* Date & Time */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Date & Time</h2>
          
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Date *
              </label>
              <input
                {...register('startDate', { required: 'Start date is required' })}
                type="date"
                className="input"
              />
              {errors.startDate && <p className="mt-1 text-sm text-red-600">{errors.startDate.message}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Time *
              </label>
              <input
                {...register('startTime', { required: 'Start time is required' })}
                type="time"
                className="input"
              />
              {errors.startTime && <p className="mt-1 text-sm text-red-600">{errors.startTime.message}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Date *
              </label>
              <input
                {...register('endDate', { required: 'End date is required' })}
                type="date"
                className="input"
              />
              {errors.endDate && <p className="mt-1 text-sm text-red-600">{errors.endDate.message}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Time *
              </label>
              <input
                {...register('endTime', { required: 'End time is required' })}
                type="time"
                className="input"
              />
              {errors.endTime && <p className="mt-1 text-sm text-red-600">{errors.endTime.message}</p>}
            </div>
          </div>
        </div>

        {/* Location */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Location</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Location Type *
            </label>
            <select {...register('locationType')} className="input">
              <option value="PHYSICAL">In-Person</option>
              <option value="VIRTUAL">Virtual</option>
              <option value="HYBRID">Hybrid</option>
            </select>
          </div>

          {(locationType === 'PHYSICAL' || locationType === 'HYBRID') && (
            <>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Venue Name
                </label>
                <input
                  {...register('venueName')}
                  className="input"
                  placeholder="The Event Space"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Address
                </label>
                <input
                  {...register('venueAddress')}
                  className="input"
                  placeholder="123 Main St"
                />
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    City
                  </label>
                  <input
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
                    {...register('venueState')}
                    className="input"
                    placeholder="NY"
                  />
                </div>
              </div>

              <div className="w-1/3">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  ZIP Code
                </label>
                <input
                  {...register('venueZipCode')}
                  className="input"
                  placeholder="10001"
                />
              </div>
            </>
          )}

          {(locationType === 'VIRTUAL' || locationType === 'HYBRID') && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Virtual Event Link
              </label>
              <input
                {...register('virtualLink')}
                type="url"
                className="input"
                placeholder="https://zoom.us/j/..."
              />
            </div>
          )}
        </div>

        {/* Additional Details */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Additional Details</h2>
          
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Price (USD)
              </label>
              <input
                {...register('price')}
                type="number"
                step="0.01"
                min="0"
                className="input"
                placeholder="0.00"
              />
              <p className="mt-1 text-sm text-gray-500">Enter 0 for free events</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Capacity
              </label>
              <input
                {...register('capacity')}
                type="number"
                min="1"
                className="input"
                placeholder="Leave empty for unlimited"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tags
            </label>
            <input
              {...register('tags')}
              className="input"
              placeholder="tech, networking, startup (comma-separated)"
            />
          </div>
        </div>

        {/* Submit */}
        <div className="flex space-x-3">
          <button
            type="button"
            onClick={() => router.back()}
            className="flex-1 btn-secondary"
            disabled={isSubmitting}
          >
            Cancel
          </button>
          <button
            type="submit"
            className="flex-1 btn-primary"
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Creating...' : 'Create Event'}
          </button>
        </div>
      </form>
    </div>
  );
}

