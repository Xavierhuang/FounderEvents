'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { LinkedInProfile } from '@/types';

interface ProfileFormProps {
  profile?: LinkedInProfile;
  events?: Array<{ id: string; title: string }>;
  onSubmit: (data: any) => Promise<void>;
  onCancel: () => void;
}

interface FormData {
  profileURL: string;
  name: string;
  company: string;
  title: string;
  notes: string;
  linkedEventId: string;
}

export default function ProfileForm({ profile, events = [], onSubmit, onCancel }: ProfileFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    defaultValues: profile ? {
      profileURL: profile.profileURL,
      name: profile.name,
      company: profile.company || '',
      title: profile.title || '',
      notes: profile.notes || '',
      linkedEventId: profile.linkedEventId || '',
    } : undefined,
  });

  const onFormSubmit = async (data: FormData) => {
    setIsSubmitting(true);
    try {
      await onSubmit({
        profileURL: data.profileURL,
        name: data.name,
        company: data.company || undefined,
        title: data.title || undefined,
        notes: data.notes || undefined,
        linkedEventId: data.linkedEventId || undefined,
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
        <label htmlFor="profileURL" className="block text-sm font-medium text-gray-700">
          LinkedIn Profile URL *
        </label>
        <input
          type="url"
          id="profileURL"
          {...register('profileURL', { 
            required: 'LinkedIn URL is required',
            pattern: {
              value: /^https?:\/\/(www\.)?linkedin\.com\/.*/,
              message: 'Please enter a valid LinkedIn URL'
            }
          })}
          className="mt-1 input"
          placeholder="https://www.linkedin.com/in/username"
        />
        {errors.profileURL && (
          <p className="mt-1 text-sm text-red-600">{errors.profileURL.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-700">
          Name *
        </label>
        <input
          type="text"
          id="name"
          {...register('name', { required: 'Name is required' })}
          className="mt-1 input"
          placeholder="John Doe"
        />
        {errors.name && (
          <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label htmlFor="title" className="block text-sm font-medium text-gray-700">
            Job Title
          </label>
          <input
            type="text"
            id="title"
            {...register('title')}
            className="mt-1 input"
            placeholder="Software Engineer"
          />
        </div>

        <div>
          <label htmlFor="company" className="block text-sm font-medium text-gray-700">
            Company
          </label>
          <input
            type="text"
            id="company"
            {...register('company')}
            className="mt-1 input"
            placeholder="Tech Corp"
          />
        </div>
      </div>

      {events.length > 0 && (
        <div>
          <label htmlFor="linkedEventId" className="block text-sm font-medium text-gray-700">
            Link to Event
          </label>
          <select
            id="linkedEventId"
            {...register('linkedEventId')}
            className="mt-1 input"
          >
            <option value="">No event linked</option>
            {events.map(event => (
              <option key={event.id} value={event.id}>
                {event.title}
              </option>
            ))}
          </select>
        </div>
      )}

      <div>
        <label htmlFor="notes" className="block text-sm font-medium text-gray-700">
          Notes
        </label>
        <textarea
          id="notes"
          {...register('notes')}
          rows={4}
          className="mt-1 input"
          placeholder="Add any notes about this connection..."
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
            profile ? 'Update Profile' : 'Add Profile'
          )}
        </button>
      </div>
    </form>
  );
}

