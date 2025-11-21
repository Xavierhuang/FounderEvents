'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { UserProfileFormData } from '@/types/public-events';
import toast from 'react-hot-toast';

export default function ProfileSetupPage() {
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const { register, handleSubmit, formState: { errors } } = useForm<UserProfileFormData>();

  const onSubmit = async (data: UserProfileFormData) => {
    setIsSubmitting(true);
    try {
      const response = await fetch('/api/profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (response.ok) {
        toast.success('Profile created successfully!');
        router.push('/dashboard/my-events');
      } else {
        const error = await response.json();
        toast.error(error.error || 'Failed to create profile');
      }
    } catch (error) {
      console.error('Error creating profile:', error);
      toast.error('Failed to create profile');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900">Create Your Event Organizer Profile</h1>
        <p className="mt-2 text-gray-600">
          Set up your public profile to start creating and managing events
        </p>
      </div>

      <div className="card p-8">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div>
            <label htmlFor="username" className="block text-sm font-medium text-gray-700">
              Username * <span className="text-gray-500">(yourname.foundersevents.app)</span>
            </label>
            <input
              type="text"
              id="username"
              {...register('username', {
                required: 'Username is required',
                minLength: { value: 3, message: 'Username must be at least 3 characters' },
                maxLength: { value: 30, message: 'Username must be less than 30 characters' },
                pattern: {
                  value: /^[a-zA-Z0-9_-]+$/,
                  message: 'Username can only contain letters, numbers, hyphens, and underscores'
                }
              })}
              className="mt-1 input"
              placeholder="john-doe"
            />
            {errors.username && (
              <p className="mt-1 text-sm text-red-600">{errors.username.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="displayName" className="block text-sm font-medium text-gray-700">
              Display Name *
            </label>
            <input
              type="text"
              id="displayName"
              {...register('displayName', {
                required: 'Display name is required',
                maxLength: { value: 100, message: 'Display name must be less than 100 characters' }
              })}
              className="mt-1 input"
              placeholder="John Doe"
            />
            {errors.displayName && (
              <p className="mt-1 text-sm text-red-600">{errors.displayName.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="bio" className="block text-sm font-medium text-gray-700">
              Bio
            </label>
            <textarea
              id="bio"
              {...register('bio', {
                maxLength: { value: 500, message: 'Bio must be less than 500 characters' }
              })}
              rows={4}
              className="mt-1 input"
              placeholder="Tell people about yourself and what events you organize..."
            />
            {errors.bio && (
              <p className="mt-1 text-sm text-red-600">{errors.bio.message}</p>
            )}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="website" className="block text-sm font-medium text-gray-700">
                Website
              </label>
              <input
                type="url"
                id="website"
                {...register('website')}
                className="mt-1 input"
                placeholder="https://example.com"
              />
            </div>

            <div>
              <label htmlFor="twitter" className="block text-sm font-medium text-gray-700">
                Twitter
              </label>
              <input
                type="text"
                id="twitter"
                {...register('twitter')}
                className="mt-1 input"
                placeholder="@username"
              />
            </div>

            <div>
              <label htmlFor="linkedin" className="block text-sm font-medium text-gray-700">
                LinkedIn
              </label>
              <input
                type="text"
                id="linkedin"
                {...register('linkedin')}
                className="mt-1 input"
                placeholder="linkedin.com/in/username"
              />
            </div>

            <div>
              <label htmlFor="instagram" className="block text-sm font-medium text-gray-700">
                Instagram
              </label>
              <input
                type="text"
                id="instagram"
                {...register('instagram')}
                className="mt-1 input"
                placeholder="@username"
              />
            </div>
          </div>

          <div className="flex justify-end space-x-4 pt-4 border-t border-gray-200">
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
                  <div className="spinner w-4 h-4 mr-2" />
                  Creating Profile...
                </>
              ) : (
                'Create Profile'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

