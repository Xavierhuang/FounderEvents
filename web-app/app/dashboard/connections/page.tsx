'use client';

import { useState, useEffect } from 'react';
import { LinkedInProfile, CalendarEvent } from '@/types';
import ProfileCard from '@/components/linkedin/ProfileCard';
import ProfileForm from '@/components/linkedin/ProfileForm';
import { PlusIcon, MagnifyingGlassIcon, XMarkIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';

export default function ConnectionsPage() {
  const [profiles, setProfiles] = useState<LinkedInProfile[]>([]);
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [editingProfile, setEditingProfile] = useState<LinkedInProfile | null>(null);

  useEffect(() => {
    fetchProfiles();
    fetchEvents();
  }, []);

  const fetchProfiles = async () => {
    try {
      const response = await fetch('/api/linkedin');
      if (response.ok) {
        const data = await response.json();
        setProfiles(data.profiles || []);
      }
    } catch (error) {
      console.error('Failed to fetch profiles:', error);
      toast.error('Failed to load profiles');
    } finally {
      setIsLoading(false);
    }
  };

  const fetchEvents = async () => {
    try {
      const response = await fetch('/api/events');
      if (response.ok) {
        const data = await response.json();
        setEvents(data.events || []);
      }
    } catch (error) {
      console.error('Failed to fetch events:', error);
    }
  };

  const handleCreateProfile = async (data: any) => {
    try {
      const response = await fetch('/api/linkedin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (response.ok) {
        const result = await response.json();
        setProfiles([result.profile, ...profiles]);
        setShowForm(false);
        toast.success('Profile added successfully!');
      } else {
        toast.error('Failed to add profile');
      }
    } catch (error) {
      console.error('Error creating profile:', error);
      toast.error('Failed to add profile');
    }
  };

  const handleUpdateProfile = async (data: any) => {
    if (!editingProfile) return;

    try {
      const response = await fetch(`/api/linkedin/${editingProfile.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (response.ok) {
        const result = await response.json();
        setProfiles(profiles.map(p => p.id === editingProfile.id ? result.profile : p));
        setEditingProfile(null);
        setShowForm(false);
        toast.success('Profile updated successfully!');
      } else {
        toast.error('Failed to update profile');
      }
    } catch (error) {
      console.error('Error updating profile:', error);
      toast.error('Failed to update profile');
    }
  };

  const handleDeleteProfile = async (profileId: string) => {
    try {
      const response = await fetch(`/api/linkedin/${profileId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setProfiles(profiles.filter(p => p.id !== profileId));
        toast.success('Profile deleted successfully');
      } else {
        toast.error('Failed to delete profile');
      }
    } catch (error) {
      console.error('Error deleting profile:', error);
      toast.error('Failed to delete profile');
    }
  };

  const handleEditProfile = (profile: LinkedInProfile) => {
    setEditingProfile(profile);
    setShowForm(true);
  };

  const filteredProfiles = profiles.filter(profile =>
    searchQuery === '' ||
    profile.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    profile.company?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    profile.title?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">LinkedIn Connections</h1>
          <p className="mt-2 text-gray-600">Manage your networking contacts</p>
        </div>
        <button
          onClick={() => {
            setEditingProfile(null);
            setShowForm(true);
          }}
          className="btn-primary"
        >
          <PlusIcon className="h-5 w-5 mr-2" />
          Add Connection
        </button>
      </div>

      {/* Search */}
      <div className="card p-6">
        <div className="relative">
          <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search connections..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="input pl-10"
          />
        </div>
      </div>

      {/* Form Modal */}
      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-gray-900">
                  {editingProfile ? 'Edit Connection' : 'Add New Connection'}
                </h2>
                <button
                  onClick={() => {
                    setShowForm(false);
                    setEditingProfile(null);
                  }}
                  className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  <XMarkIcon className="h-6 w-6 text-gray-500" />
                </button>
              </div>
              <ProfileForm
                profile={editingProfile || undefined}
                events={events.map(e => ({ id: e.id, title: e.title }))}
                onSubmit={editingProfile ? handleUpdateProfile : handleCreateProfile}
                onCancel={() => {
                  setShowForm(false);
                  setEditingProfile(null);
                }}
              />
            </div>
          </div>
        </div>
      )}

      {/* Profiles Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="card p-6 animate-pulse">
              <div className="h-6 bg-gray-200 rounded w-3/4 mb-4"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-2/3"></div>
            </div>
          ))}
        </div>
      ) : filteredProfiles.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredProfiles.map((profile) => (
            <ProfileCard
              key={profile.id}
              profile={profile}
              onDelete={handleDeleteProfile}
              onEdit={handleEditProfile}
            />
          ))}
        </div>
      ) : (
        <div className="text-center py-12 card">
          <h3 className="mt-4 text-sm font-medium text-gray-900">No connections found</h3>
          <p className="mt-2 text-sm text-gray-500">
            {searchQuery ? 'Try adjusting your search' : 'Get started by adding your first connection'}
          </p>
          {!searchQuery && (
            <div className="mt-6">
              <button
                onClick={() => setShowForm(true)}
                className="btn-primary"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Add Connection
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

