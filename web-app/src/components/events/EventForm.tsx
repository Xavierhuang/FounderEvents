'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { CalendarEvent } from '@/types';

interface EventFormProps {
  event?: CalendarEvent;
  onSubmit: (data: any) => Promise<void>;
  onCancel: () => void;
}

interface FormData {
  title: string;
  startDate: string;
  startTime: string;
  endDate: string;
  endTime: string;
  location: string;
  notes: string;
}

export default function EventForm({ event, onSubmit, onCancel }: EventFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    defaultValues: event ? {
      title: event.title,
      startDate: new Date(event.startDate).toISOString().split('T')[0],
      startTime: new Date(event.startDate).toTimeString().slice(0, 5),
      endDate: new Date(event.endDate).toISOString().split('T')[0],
      endTime: new Date(event.endDate).toTimeString().slice(0, 5),
      location: event.location || '',
      notes: event.notes || '',
    } : undefined,
  });

  const onFormSubmit = async (data: FormData) => {
    setIsSubmitting(true);
    try {
      const startDateTime = new Date(`${data.startDate}T${data.startTime}`).toISOString();
      const endDateTime = new Date(`${data.endDate}T${data.endTime}`).toISOString();

      await onSubmit({
        title: data.title,
        startDate: startDateTime,
        endDate: endDateTime,
        location: data.location || undefined,
        notes: data.notes || undefined,
      });
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-6">
      <div>
        <label htmlFor="title" className="block text-sm font-medium text-gray-700">
          Event Title *
        </label>
        <input
          type="text"
          id="title"
          {...register('title', { required: 'Title is required' })}
          className="mt-1 input"
          placeholder="Tech Meetup, Conference, etc."
        />
        {errors.title && (
          <p className="mt-1 text-sm text-red-600">{errors.title.message}</p>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label htmlFor="startDate" className="block text-sm font-medium text-gray-700">
            Start Date *
          </label>
          <input
            type="date"
            id="startDate"
            {...register('startDate', { required: 'Start date is required' })}
            className="mt-1 input"
          />
          {errors.startDate && (
            <p className="mt-1 text-sm text-red-600">{errors.startDate.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="startTime" className="block text-sm font-medium text-gray-700">
            Start Time *
          </label>
          <input
            type="time"
            id="startTime"
            {...register('startTime', { required: 'Start time is required' })}
            className="mt-1 input"
          />
          {errors.startTime && (
            <p className="mt-1 text-sm text-red-600">{errors.startTime.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="endDate" className="block text-sm font-medium text-gray-700">
            End Date *
          </label>
          <input
            type="date"
            id="endDate"
            {...register('endDate', { required: 'End date is required' })}
            className="mt-1 input"
          />
          {errors.endDate && (
            <p className="mt-1 text-sm text-red-600">{errors.endDate.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="endTime" className="block text-sm font-medium text-gray-700">
            End Time *
          </label>
          <input
            type="time"
            id="endTime"
            {...register('endTime', { required: 'End time is required' })}
            className="mt-1 input"
          />
          {errors.endTime && (
            <p className="mt-1 text-sm text-red-600">{errors.endTime.message}</p>
          )}
        </div>
      </div>

      <div>
        <label htmlFor="location" className="block text-sm font-medium text-gray-700">
          Location
        </label>
        <input
          type="text"
          id="location"
          {...register('location')}
          className="mt-1 input"
          placeholder="WeWork Union Square, NYC"
        />
      </div>

      <div>
        <label htmlFor="notes" className="block text-sm font-medium text-gray-700">
          Notes
        </label>
        <textarea
          id="notes"
          {...register('notes')}
          rows={4}
          className="mt-1 input"
          placeholder="Add any additional details about the event..."
        />
      </div>

      <div className="flex justify-end space-x-4">
        <button
          type="button"
          onClick={onCancel}
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
              <div className="spinner w-4 h-4 mr-2" />
              Saving...
            </>
          ) : (
            event ? 'Update Event' : 'Create Event'
          )}
        </button>
      </div>
    </form>
  );
}

