'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import toast from 'react-hot-toast';
import { ArrowLeftIcon, CameraIcon, UserIcon } from '@heroicons/react/24/outline';

export default function EditProfilePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [profile, setProfile] = useState<any>(null);
  const [avatarPreview, setAvatarPreview] = useState<string | null>(null);
  const [coverPreview, setCoverPreview] = useState<string | null>(null);
  
  const { register, handleSubmit, setValue, formState: { errors } } = useForm({
    defaultValues: {
      username: '',
      displayName: '',
      bio: '',
      avatar: '',
      coverImage: '',
      website: '',
      twitter: '',
      linkedin: '',
      instagram: '',
    }
  });

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const response = await fetch('/api/profile');
      if (response.ok) {
        const data = await response.json();
        if (data.profile) {
          setProfile(data.profile);
          
          // Pre-fill form
          setValue('username', data.profile.username);
          setValue('displayName', data.profile.displayName);
          setValue('bio', data.profile.bio || '');
          setValue('avatar', data.profile.avatar || '');
          setValue('coverImage', data.profile.coverImage || '');
          setValue('website', data.profile.website || '');
          setValue('twitter', data.profile.twitter || '');
          setValue('linkedin', data.profile.linkedin || '');
          setValue('instagram', data.profile.instagram || '');
          
          setAvatarPreview(data.profile.avatar);
          setCoverPreview(data.profile.coverImage);
        } else {
          router.push('/dashboard/profile/setup');
        }
      } else {
        router.push('/dashboard/profile/setup');
      }
    } catch (error) {
      console.error('Error fetching profile:', error);
      toast.error('Failed to load profile');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Validate file size (max 5MB)
      if (file.size > 5 * 1024 * 1024) {
        toast.error('Image size must be less than 5MB');
        return;
      }

      // Validate file type
      if (!file.type.startsWith('image/')) {
        toast.error('Please upload an image file');
        return;
      }

      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        const base64String = reader.result as string;
        setAvatarPreview(base64String);
        setValue('avatar', base64String);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleCoverChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Validate file size (max 10MB)
      if (file.size > 10 * 1024 * 1024) {
        toast.error('Image size must be less than 10MB');
        return;
      }

      // Validate file type
      if (!file.type.startsWith('image/')) {
        toast.error('Please upload an image file');
        return;
      }

      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        const base64String = reader.result as string;
        setCoverPreview(base64String);
        setValue('coverImage', base64String);
      };
      reader.readAsDataURL(file);
    }
  };

  const onSubmit = async (data: any) => {
    setIsSubmitting(true);

    try {
      const response = await fetch('/api/profile', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (response.ok) {
        toast.success('Profile updated successfully!');
        router.push('/dashboard/profile');
      } else {
        const error = await response.json();
        if (error.details) {
          // Show validation errors
          const validationErrors = Array.isArray(error.details) 
            ? error.details.map((e: any) => `${e.path?.join('.')}: ${e.message}`).join(', ')
            : JSON.stringify(error.details);
          toast.error(validationErrors);
        } else {
          toast.error(error.error || 'Failed to update profile');
        }
      }
    } catch (error) {
      console.error('Error updating profile:', error);
      toast.error('Failed to update profile');
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

  if (!profile) return null;

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
          <h1 className="text-3xl font-bold text-gray-900">Edit Profile</h1>
          <p className="mt-1 text-gray-600">Update your public profile information</p>
        </div>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Cover Image */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Cover Image</h2>
          
          <div className="relative">
            <div className="w-full h-48 rounded-lg overflow-hidden bg-gradient-to-r from-primary-400 to-primary-600">
              {coverPreview ? (
                <img
                  src={coverPreview}
                  alt="Cover"
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <p className="text-white text-sm">No cover image</p>
                </div>
              )}
            </div>
            
            <label className="absolute bottom-4 right-4 cursor-pointer">
              <div className="bg-white rounded-lg px-4 py-2 shadow-lg hover:bg-gray-50 transition-colors flex items-center space-x-2">
                <CameraIcon className="h-5 w-5 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Change Cover</span>
              </div>
              <input
                type="file"
                accept="image/*"
                onChange={handleCoverChange}
                className="hidden"
              />
            </label>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Or paste image URL
            </label>
            <input
              type="url"
              {...register('coverImage')}
              className="input"
              placeholder="https://example.com/cover.jpg"
              onChange={(e) => {
                setCoverPreview(e.target.value);
              }}
            />
          </div>
        </div>

        {/* Avatar */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Profile Picture</h2>
          
          <div className="flex items-center space-x-6">
            <div className="relative">
              {avatarPreview ? (
                <img
                  src={avatarPreview}
                  alt="Avatar"
                  className="w-32 h-32 rounded-full object-cover border-4 border-white shadow-lg"
                />
              ) : (
                <div className="w-32 h-32 rounded-full bg-primary-100 flex items-center justify-center border-4 border-white shadow-lg">
                  <UserIcon className="h-16 w-16 text-primary-600" />
                </div>
              )}
              
              <label className="absolute bottom-0 right-0 cursor-pointer">
                <div className="bg-primary-600 rounded-full p-2 shadow-lg hover:bg-primary-700 transition-colors">
                  <CameraIcon className="h-5 w-5 text-white" />
                </div>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleAvatarChange}
                  className="hidden"
                />
              </label>
            </div>

            <div className="flex-1">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Or paste image URL
              </label>
              <input
                type="url"
                {...register('avatar')}
                className="input"
                placeholder="https://example.com/avatar.jpg"
                onChange={(e) => {
                  setAvatarPreview(e.target.value);
                }}
              />
              <p className="mt-1 text-xs text-gray-500">
                JPG, PNG or GIF. Max size 5MB.
              </p>
            </div>
          </div>
        </div>

        {/* Basic Information */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Basic Information</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Username *
            </label>
            <input
              type="text"
              {...register('username', { 
                required: 'Username is required',
                minLength: { value: 3, message: 'Username must be at least 3 characters' },
                maxLength: { value: 30, message: 'Username must be less than 30 characters' },
                pattern: { 
                  value: /^[a-zA-Z0-9_-]+$/, 
                  message: 'Username can only contain letters, numbers, hyphens, and underscores' 
                }
              })}
              className="input"
              placeholder="johndoe"
            />
            {errors.username && (
              <p className="mt-1 text-sm text-red-600">{errors.username.message}</p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              Your profile will be at: foundersevents.app/@{profile.username}
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Display Name *
            </label>
            <input
              type="text"
              {...register('displayName', { 
                required: 'Display name is required',
                maxLength: { value: 100, message: 'Display name must be less than 100 characters' }
              })}
              className="input"
              placeholder="John Doe"
            />
            {errors.displayName && (
              <p className="mt-1 text-sm text-red-600">{errors.displayName.message}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Bio
            </label>
            <textarea
              {...register('bio', {
                maxLength: { value: 500, message: 'Bio must be less than 500 characters' }
              })}
              rows={4}
              className="input"
              placeholder="Tell us about yourself..."
            />
            {errors.bio && (
              <p className="mt-1 text-sm text-red-600">{errors.bio.message}</p>
            )}
          </div>
        </div>

        {/* Social Links */}
        <div className="card p-6 space-y-4">
          <h2 className="text-xl font-semibold text-gray-900">Social Links</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Website
            </label>
            <input
              type="url"
              {...register('website')}
              className="input"
              placeholder="https://yourwebsite.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Twitter
            </label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">@</span>
              <input
                type="text"
                {...register('twitter')}
                className="input pl-8"
                placeholder="username"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              LinkedIn
            </label>
            <input
              type="text"
              {...register('linkedin')}
              className="input"
              placeholder="https://linkedin.com/in/username"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Instagram
            </label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">@</span>
              <input
                type="text"
                {...register('instagram')}
                className="input pl-8"
                placeholder="username"
              />
            </div>
          </div>
        </div>

        {/* Form Actions */}
        <div className="flex items-center justify-between pt-6">
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

