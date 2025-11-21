'use client';

import { useState, useEffect } from 'react';
import { UserPreferences, CalendarSettings, MessageTemplate } from '@/types';
import { PlusIcon, TrashIcon, PencilIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';

export default function SettingsPage() {
  const [preferences, setPreferences] = useState<UserPreferences | null>(null);
  const [calendarSettings, setCalendarSettings] = useState<CalendarSettings | null>(null);
  const [templates, setTemplates] = useState<MessageTemplate[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    fetchSettings();
    fetchTemplates();
  }, []);

  const fetchSettings = async () => {
    try {
      const response = await fetch('/api/settings');
      if (response.ok) {
        const data = await response.json();
        setPreferences(data.settings.preferences);
        setCalendarSettings(data.settings.calendar);
      }
    } catch (error) {
      console.error('Failed to fetch settings:', error);
      toast.error('Failed to load settings');
    } finally {
      setIsLoading(false);
    }
  };

  const fetchTemplates = async () => {
    try {
      const response = await fetch('/api/templates');
      if (response.ok) {
        const data = await response.json();
        setTemplates(data.templates || []);
      }
    } catch (error) {
      console.error('Failed to fetch templates:', error);
    }
  };

  const handleSavePreferences = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);

    try {
      const response = await fetch('/api/settings', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          preferences,
          calendar: calendarSettings,
        }),
      });

      if (response.ok) {
        toast.success('Settings saved successfully!');
      } else {
        toast.error('Failed to save settings');
      }
    } catch (error) {
      console.error('Error saving settings:', error);
      toast.error('Failed to save settings');
    } finally {
      setIsSaving(false);
    }
  };

  const handleAddTemplate = async () => {
    const name = prompt('Template name:');
    const template = prompt('Template content:');
    
    if (!name || !template) return;

    try {
      const response = await fetch('/api/templates', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, template }),
      });

      if (response.ok) {
        const data = await response.json();
        setTemplates([...templates, data.template]);
        toast.success('Template added successfully!');
      } else {
        toast.error('Failed to add template');
      }
    } catch (error) {
      console.error('Error adding template:', error);
      toast.error('Failed to add template');
    }
  };

  const handleDeleteTemplate = async (templateId: string) => {
    if (!confirm('Are you sure you want to delete this template?')) return;

    try {
      const response = await fetch(`/api/templates/${templateId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setTemplates(templates.filter(t => t.id !== templateId));
        toast.success('Template deleted successfully');
      } else {
        toast.error('Failed to delete template');
      }
    } catch (error) {
      console.error('Error deleting template:', error);
      toast.error('Failed to delete template');
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="spinner w-8 h-8"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Settings</h1>
        <p className="mt-2 text-gray-600">Manage your preferences and integrations</p>
      </div>

      <form onSubmit={handleSavePreferences} className="space-y-6">
        {/* User Preferences */}
        <div className="card p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">User Preferences</h2>
          <div className="space-y-4">
            <div>
              <label htmlFor="timezone" className="block text-sm font-medium text-gray-700">
                Timezone
              </label>
              <select
                id="timezone"
                value={preferences?.timezone || 'America/New_York'}
                onChange={(e) => setPreferences({ ...preferences!, timezone: e.target.value })}
                className="mt-1 input"
              >
                <option value="America/New_York">Eastern Time (ET)</option>
                <option value="America/Chicago">Central Time (CT)</option>
                <option value="America/Denver">Mountain Time (MT)</option>
                <option value="America/Los_Angeles">Pacific Time (PT)</option>
                <option value="Europe/London">London (GMT)</option>
                <option value="Europe/Paris">Paris (CET)</option>
                <option value="Asia/Tokyo">Tokyo (JST)</option>
              </select>
            </div>

            <div>
              <label htmlFor="theme" className="block text-sm font-medium text-gray-700">
                Theme
              </label>
              <select
                id="theme"
                value={preferences?.theme || 'light'}
                onChange={(e) => setPreferences({ ...preferences!, theme: e.target.value as any })}
                className="mt-1 input"
              >
                <option value="light">Light</option>
                <option value="dark">Dark</option>
                <option value="system">System</option>
              </select>
            </div>

            <div>
              <label htmlFor="defaultEventDuration" className="block text-sm font-medium text-gray-700">
                Default Event Duration (hours)
              </label>
              <input
                type="number"
                id="defaultEventDuration"
                min="0.5"
                max="24"
                step="0.5"
                value={(preferences?.defaultEventDuration || 3600) / 3600}
                onChange={(e) => setPreferences({ ...preferences!, defaultEventDuration: parseFloat(e.target.value) * 3600 })}
                className="mt-1 input"
              />
            </div>

            <div>
              <label htmlFor="weekStartsOn" className="block text-sm font-medium text-gray-700">
                Week Starts On
              </label>
              <select
                id="weekStartsOn"
                value={preferences?.weekStartsOn || 1}
                onChange={(e) => setPreferences({ ...preferences!, weekStartsOn: parseInt(e.target.value) })}
                className="mt-1 input"
              >
                <option value="0">Sunday</option>
                <option value="1">Monday</option>
              </select>
            </div>
          </div>
        </div>

        {/* Calendar Integration */}
        <div className="card p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Calendar Integration</h2>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <label htmlFor="googleCalendarEnabled" className="text-sm font-medium text-gray-700">
                  Google Calendar Sync
                </label>
                <p className="text-sm text-gray-500">
                  Automatically sync events with Google Calendar
                </p>
              </div>
              <input
                type="checkbox"
                id="googleCalendarEnabled"
                checked={calendarSettings?.googleCalendarEnabled || false}
                onChange={(e) => setCalendarSettings({ ...calendarSettings!, googleCalendarEnabled: e.target.checked })}
                className="h-5 w-5 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
              />
            </div>

            {calendarSettings?.googleCalendarEnabled && (
              <>
                <div>
                  <label htmlFor="googleCalendarId" className="block text-sm font-medium text-gray-700">
                    Primary Calendar ID
                  </label>
                  <input
                    type="text"
                    id="googleCalendarId"
                    value={calendarSettings.googleCalendarId || ''}
                    onChange={(e) => setCalendarSettings({ ...calendarSettings, googleCalendarId: e.target.value })}
                    className="mt-1 input"
                    placeholder="primary"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label htmlFor="autoSync" className="text-sm font-medium text-gray-700">
                      Auto Sync
                    </label>
                    <p className="text-sm text-gray-500">
                      Automatically sync changes
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    id="autoSync"
                    checked={calendarSettings.autoSync || false}
                    onChange={(e) => setCalendarSettings({ ...calendarSettings, autoSync: e.target.checked })}
                    className="h-5 w-5 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  />
                </div>

                <div>
                  <label htmlFor="syncInterval" className="block text-sm font-medium text-gray-700">
                    Sync Interval (minutes)
                  </label>
                  <input
                    type="number"
                    id="syncInterval"
                    min="5"
                    max="1440"
                    value={(calendarSettings.syncInterval || 3600) / 60}
                    onChange={(e) => setCalendarSettings({ ...calendarSettings, syncInterval: parseInt(e.target.value) * 60 })}
                    className="mt-1 input"
                  />
                </div>
              </>
            )}
          </div>
        </div>

        <div className="flex justify-end">
          <button
            type="submit"
            disabled={isSaving}
            className="btn-primary"
          >
            {isSaving ? (
              <>
                <div className="spinner w-4 h-4 mr-2" />
                Saving...
              </>
            ) : (
              'Save Settings'
            )}
          </button>
        </div>
      </form>

      {/* Message Templates */}
      <div className="card p-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Message Templates</h2>
            <p className="text-sm text-gray-500 mt-1">
              Create templates for LinkedIn messages
            </p>
          </div>
          <button
            onClick={handleAddTemplate}
            className="btn-secondary"
          >
            <PlusIcon className="h-5 w-5 mr-2" />
            Add Template
          </button>
        </div>

        {templates.length > 0 ? (
          <div className="space-y-3">
            {templates.map((template) => (
              <div
                key={template.id}
                className="flex items-start justify-between p-4 border border-gray-200 rounded-lg"
              >
                <div className="flex-1">
                  <div className="flex items-center">
                    <h3 className="font-medium text-gray-900">{template.name}</h3>
                    {template.isDefault && (
                      <span className="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-primary-100 text-primary-800">
                        Default
                      </span>
                    )}
                  </div>
                  <p className="mt-1 text-sm text-gray-500 line-clamp-2">
                    {template.template}
                  </p>
                </div>
                <button
                  onClick={() => handleDeleteTemplate(template.id)}
                  className="ml-4 p-2 text-gray-400 hover:text-red-600 transition-colors"
                >
                  <TrashIcon className="h-5 w-5" />
                </button>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-8">
            <p className="text-gray-500 text-sm">No templates yet</p>
            <button
              onClick={handleAddTemplate}
              className="mt-4 text-primary-600 hover:text-primary-700 text-sm font-medium"
            >
              Create your first template
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

