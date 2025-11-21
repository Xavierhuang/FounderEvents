'use client';

import { LinkedInProfile } from '@/types';
import { BuildingOfficeIcon, BriefcaseIcon, TrashIcon, PencilIcon, LinkIcon } from '@heroicons/react/24/outline';
import { format } from 'date-fns';

interface ProfileCardProps {
  profile: LinkedInProfile & { linkedEvent?: any };
  onDelete?: (profileId: string) => void;
  onEdit?: (profile: LinkedInProfile) => void;
  showActions?: boolean;
}

export default function ProfileCard({ profile, onDelete, onEdit, showActions = true }: ProfileCardProps) {
  const handleDelete = () => {
    if (onDelete && confirm('Are you sure you want to delete this profile?')) {
      onDelete(profile.id);
    }
  };

  const handleEdit = () => {
    if (onEdit) {
      onEdit(profile);
    }
  };

  return (
    <div className="card p-6 hover:shadow-lg transition-all duration-200">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3">
            <div className="profile-avatar text-lg">
              {profile.name.split(' ').map(n => n[0]).join('')}
            </div>
            <div>
              <h3 className="text-lg font-semibold text-gray-900">
                {profile.name}
              </h3>
              {profile.title && (
                <div className="flex items-center text-sm text-gray-600 mt-1">
                  <BriefcaseIcon className="h-4 w-4 mr-1 flex-shrink-0" />
                  <span>{profile.title}</span>
                </div>
              )}
            </div>
          </div>

          {profile.company && (
            <div className="flex items-center text-sm text-gray-600 mt-3">
              <BuildingOfficeIcon className="h-4 w-4 mr-2 flex-shrink-0" />
              <span>{profile.company}</span>
            </div>
          )}

          {profile.linkedEvent && (
            <div className="mt-3">
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                Met at: {profile.linkedEvent.title}
              </span>
            </div>
          )}

          {profile.notes && (
            <p className="mt-3 text-sm text-gray-500 line-clamp-2">
              {profile.notes}
            </p>
          )}

          <div className="mt-4 flex items-center space-x-4">
            <a
              href={profile.profileURL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center text-sm text-primary-600 hover:text-primary-700"
            >
              <LinkIcon className="h-4 w-4 mr-1" />
              View Profile
            </a>
            <span className="text-xs text-gray-400">
              Added {format(new Date(profile.linkedDate), 'MMM d, yyyy')}
            </span>
          </div>
        </div>

        {showActions && (
          <div className="ml-4 flex space-x-2">
            <button
              onClick={handleEdit}
              className="p-2 text-gray-400 hover:text-primary-600 transition-colors"
            >
              <PencilIcon className="h-5 w-5" />
            </button>
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
  );
}

