'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useSession } from 'next-auth/react';
import { UserIcon, GlobeAltIcon, LinkIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';

export default function ProfilePage() {
  const router = useRouter();
  const { data: session } = useSession();
  const [profile, setProfile] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const response = await fetch('/api/profile');
      if (response.ok) {
        const data = await response.json();
        setProfile(data.profile);
      } else if (response.status === 404) {
        router.push('/dashboard/profile/setup');
      }
    } catch (error) {
      console.error('Error fetching profile:', error);
      toast.error('Failed to load profile');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="max-w-4xl mx-auto space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="card p-8 space-y-4">
            <div className="h-6 bg-gray-200 rounded w-3/4"></div>
            <div className="h-4 bg-gray-200 rounded w-full"></div>
            <div className="h-4 bg-gray-200 rounded w-5/6"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!profile) {
    return null;
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-gray-900">Your Profile</h1>
        <button
          onClick={() => router.push('/dashboard/profile/edit')}
          className="btn-secondary"
        >
          Edit Profile
        </button>
      </div>

      <div className="card overflow-hidden">
        {profile.coverImage && (
          <div className="h-48 w-full">
            <img
              src={profile.coverImage}
              alt="Cover"
              className="w-full h-full object-cover"
            />
          </div>
        )}
        {!profile.coverImage && (
          <div className="h-48 w-full bg-gradient-to-r from-primary-400 to-primary-600" />
        )}

        <div className="p-8 space-y-6">
          <div className="flex items-start space-x-6 -mt-20">
            <div className="flex-shrink-0">
              {profile.avatar ? (
                <img
                  src={profile.avatar}
                  alt={profile.username}
                  className="w-32 h-32 rounded-full object-cover border-4 border-white shadow-lg"
                />
              ) : (
                <div className="w-32 h-32 rounded-full bg-primary-100 flex items-center justify-center border-4 border-white shadow-lg">
                  <UserIcon className="h-16 w-16 text-primary-600" />
                </div>
              )}
            </div>
            <div className="flex-1 mt-16">
              <h2 className="text-2xl font-bold text-gray-900">{profile.displayName || profile.username}</h2>
              <p className="text-gray-500">@{profile.username}</p>
            </div>
          </div>

          {profile.bio && (
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-2">About</h3>
              <p className="text-gray-900 whitespace-pre-wrap">{profile.bio}</p>
            </div>
          )}

          {profile.website && (
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-2">Website</h3>
              <a
                href={profile.website}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center text-primary-600 hover:text-primary-700"
              >
                <GlobeAltIcon className="h-5 w-5 mr-2" />
                {profile.website}
              </a>
            </div>
          )}

          {(profile.twitter || profile.linkedin || profile.instagram) && (
            <div>
              <h3 className="text-sm font-medium text-gray-700 mb-2">Social Links</h3>
              <div className="flex flex-wrap gap-4">
                {profile.twitter && (
                  <a
                    href={`https://twitter.com/${profile.twitter}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center text-gray-600 hover:text-gray-900"
                  >
                    <LinkIcon className="h-5 w-5 mr-1" />
                    Twitter
                  </a>
                )}
                {profile.linkedin && (
                  <a
                    href={profile.linkedin}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center text-gray-600 hover:text-gray-900"
                  >
                    <LinkIcon className="h-5 w-5 mr-1" />
                    LinkedIn
                  </a>
                )}
                {profile.instagram && (
                  <a
                    href={`https://instagram.com/${profile.instagram}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center text-gray-600 hover:text-gray-900"
                  >
                    <LinkIcon className="h-5 w-5 mr-1" />
                    Instagram
                  </a>
                )}
              </div>
            </div>
          )}

          <div className="border-t border-gray-200 pt-6">
            <h3 className="text-sm font-medium text-gray-700 mb-2">Your Public Profile</h3>
            <div className="flex items-center space-x-2">
              <code className="flex-1 px-4 py-2 bg-gray-100 rounded-lg text-sm text-gray-900">
                {`https://foundersevents.app/@${profile.username}`}
              </code>
              <button
                onClick={() => {
                  navigator.clipboard.writeText(`https://foundersevents.app/@${profile.username}`);
                  toast.success('Profile link copied!');
                }}
                className="btn-secondary"
              >
                Copy
              </button>
            </div>
          </div>

          <div className="border-t border-gray-200 pt-6">
            <div className="grid grid-cols-3 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-gray-900">{profile.publicEvents?.length || 0}</div>
                <div className="text-sm text-gray-500">Events Created</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-gray-900">
                  {profile.publicEvents?.reduce((acc: number, e: any) => acc + (e.registrationCount || 0), 0) || 0}
                </div>
                <div className="text-sm text-gray-500">Total Registrations</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-gray-900">
                  {profile.publicEvents?.reduce((acc: number, e: any) => acc + (e.viewCount || 0), 0) || 0}
                </div>
                <div className="text-sm text-gray-500">Profile Views</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {profile.publicEvents && profile.publicEvents.length > 0 && (
        <div className="card p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Your Events</h2>
          <div className="space-y-4">
            {profile.publicEvents.slice(0, 5).map((event: any) => (
              <div key={event.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-gray-300 transition-colors">
                <div>
                  <h3 className="font-medium text-gray-900">{event.title}</h3>
                  <p className="text-sm text-gray-500">
                    {new Date(event.startDate).toLocaleDateString()} • {event.registrationCount || 0} registered
                  </p>
                </div>
                <a
                  href={`/events/${event.slug}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-secondary"
                >
                  View
                </a>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
