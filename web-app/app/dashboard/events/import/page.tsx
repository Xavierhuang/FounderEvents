'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { LinkIcon, SparklesIcon, ArrowRightIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';

export default function ImportEventPage() {
  const router = useRouter();
  const [url, setUrl] = useState('');
  const [isExtracting, setIsExtracting] = useState(false);
  const [extractedData, setExtractedData] = useState<any>(null);
  const [platform, setPlatform] = useState<'luma' | 'eventbrite' | 'auto'>('auto');
  const [hasProfile, setHasProfile] = useState<boolean | null>(null);

  // Check if user has a profile
  useEffect(() => {
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

  const handleExtract = async () => {
    if (!url.trim()) {
      toast.error('Please enter a URL');
      return;
    }

    setIsExtracting(true);
    try {
      const response = await fetch('/api/events/extract-from-url', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ url: url.trim(), platform }),
      });

      if (response.ok) {
        const data = await response.json();
        setExtractedData(data.extractedData);
        if (data.warning) {
          toast.success('Event data extracted (with limitations)', { duration: 5000 });
        } else {
          toast.success('Event data extracted successfully!');
        }
      } else {
        const error = await response.json();
        const errorMessage = error.error || 'Failed to extract event data';
        const suggestion = error.suggestion || '';
        toast.error(
          <div>
            <div className="font-semibold">{errorMessage}</div>
            {suggestion && <div className="text-sm mt-1">{suggestion}</div>}
            {error.details && <div className="text-xs mt-1 text-gray-400">{error.details}</div>}
          </div>,
          { duration: 8000 }
        );
      }
    } catch (error) {
      console.error('Extraction error:', error);
      toast.error('Failed to extract event data');
    } finally {
      setIsExtracting(false);
    }
  };

  const handleCreateEvent = async () => {
    if (!extractedData) return;

    // Helper function to validate and clean URL
    const cleanUrl = (url: string | null | undefined): string | undefined => {
      if (!url || url.trim() === '') return undefined;
      try {
        new URL(url);
        return url;
      } catch {
        return undefined;
      }
    };

    // Helper function to ensure proper ISO datetime format
    const cleanDatetime = (dateStr: string | null | undefined): string => {
      if (!dateStr) {
        return new Date().toISOString();
      }
      try {
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) {
          return new Date().toISOString();
        }
        return date.toISOString();
      } catch {
        return new Date().toISOString();
      }
    };

    // Map extracted data to match the API schema
    const eventData = {
      title: extractedData.title || 'Untitled Event',
      description: extractedData.description || 'No description',
      shortDescription: extractedData.shortDescription || extractedData.description?.substring(0, 300),
      startDate: cleanDatetime(extractedData.startDate),
      endDate: cleanDatetime(extractedData.endDate),
      timezone: 'America/New_York',
      locationType: extractedData.locationType || 'PHYSICAL',
      venueName: extractedData.venueName || undefined,
      venueAddress: extractedData.venueAddress || undefined,
      venueCity: extractedData.venueCity || undefined,
      venueState: extractedData.venueState || undefined,
      venueZipCode: extractedData.venueZipCode || undefined,
      virtualLink: cleanUrl(extractedData.virtualLink),
      coverImage: cleanUrl(extractedData.coverImage),
      isPublic: true,
      requiresApproval: false,
      capacity: extractedData.capacity || undefined,
      registrationDeadline: extractedData.registrationDeadline ? cleanDatetime(extractedData.registrationDeadline) : undefined,
      price: extractedData.price || 0,
      currency: extractedData.currency || 'USD',
      tags: Array.isArray(extractedData.tags) ? extractedData.tags : [],
      categoryIds: [],
    };

    console.log('Extracted data:', extractedData);
    console.log('Creating event with data:', eventData);
    console.log('StartDate:', eventData.startDate);
    console.log('EndDate:', eventData.endDate);

    try {
      const response = await fetch('/api/public-events', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });

      if (response.ok) {
        const data = await response.json();
        toast.success('Event created successfully!');
        router.push(`/events/${data.event.slug}`);
      } else {
        const error = await response.json();
        console.error('Event creation error:', error);
        
        if (error.error?.includes('create a profile')) {
          toast.error(
            <div>
              <div className="font-semibold">Profile Required</div>
              <div className="text-sm mt-1">You need to create a profile before creating events</div>
            </div>,
            { duration: 5000 }
          );
          setTimeout(() => router.push('/dashboard/profile/setup'), 2000);
        } else if (error.details) {
          // Show validation errors
          const validationErrors = Array.isArray(error.details) 
            ? error.details.map((e: any) => `${e.path?.join('.')}: ${e.message}`).join(', ')
            : JSON.stringify(error.details);
          
          toast.error(
            <div>
              <div className="font-semibold">Validation Error</div>
              <div className="text-xs mt-1">{validationErrors}</div>
            </div>,
            { duration: 8000 }
          );
        } else {
          toast.error(error.error || 'Failed to create event');
        }
      }
    } catch (error) {
      console.error('Error creating event:', error);
      toast.error('Failed to create event');
    }
  };

  // Show profile setup prompt if no profile
  if (hasProfile === false) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="card p-8 text-center space-y-4">
          <div className="mx-auto w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center">
            <LinkIcon className="h-8 w-8 text-primary-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900">Profile Required</h2>
          <p className="text-gray-600">
            You need to create an event organizer profile before you can import and create events.
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
        <h1 className="text-3xl font-bold text-gray-900">Import Event from URL</h1>
        <p className="mt-2 text-gray-600">
          Extract event details from Luma or Eventbrite and create your own FoundersEvents link
        </p>
      </div>

      <div className="card p-6 space-y-6">
        {/* URL Input */}
        <div>
          <label htmlFor="url" className="block text-sm font-medium text-gray-700 mb-2">
            Event URL
          </label>
          <div className="flex gap-4">
            <div className="flex-1">
              <div className="relative">
                <LinkIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="url"
                  id="url"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  placeholder="https://lu.ma/event/... or https://www.eventbrite.com/e/..."
                  className="input pl-10"
                />
              </div>
            </div>
            <button
              onClick={handleExtract}
              disabled={isExtracting || !url.trim()}
              className="btn-primary"
            >
              {isExtracting ? (
                <>
                  <div className="spinner w-4 h-4 mr-2" />
                  Extracting...
                </>
              ) : (
                <>
                  <SparklesIcon className="h-5 w-5 mr-2" />
                  Extract Event
                </>
              )}
            </button>
          </div>

          {/* Platform Selection */}
          <div className="mt-4 flex gap-4">
            <label className="flex items-center">
              <input
                type="radio"
                value="auto"
                checked={platform === 'auto'}
                onChange={(e) => setPlatform(e.target.value as any)}
                className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300"
              />
              <span className="ml-2 text-sm text-gray-700">Auto-detect</span>
            </label>
            <label className="flex items-center">
              <input
                type="radio"
                value="luma"
                checked={platform === 'luma'}
                onChange={(e) => setPlatform(e.target.value as any)}
                className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300"
              />
              <span className="ml-2 text-sm text-gray-700">Luma</span>
            </label>
            <label className="flex items-center">
              <input
                type="radio"
                value="eventbrite"
                checked={platform === 'eventbrite'}
                onChange={(e) => setPlatform(e.target.value as any)}
                className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300"
              />
              <span className="ml-2 text-sm text-gray-700">Eventbrite</span>
            </label>
          </div>
        </div>

        {/* Extracted Data Preview */}
        {extractedData && (
          <div className="border-t border-gray-200 pt-6 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-gray-900">Extracted Event Data</h2>
              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setExtractedData(null);
                    setUrl('');
                  }}
                  className="btn-secondary"
                >
                  Clear
                </button>
                <button
                  onClick={handleCreateEvent}
                  className="btn-primary"
                >
                  Create Event
                  <ArrowRightIcon className="h-4 w-4 ml-2" />
                </button>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-6 space-y-4">
              <div>
                <h3 className="font-semibold text-gray-900 mb-2">Title</h3>
                <p className="text-gray-700">{extractedData.title}</p>
              </div>

              {extractedData.shortDescription && (
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">Short Description</h3>
                  <p className="text-gray-700">{extractedData.shortDescription}</p>
                </div>
              )}

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">Start Date</h3>
                  <p className="text-gray-700">
                    {new Date(extractedData.startDate).toLocaleString()}
                  </p>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">End Date</h3>
                  <p className="text-gray-700">
                    {new Date(extractedData.endDate).toLocaleString()}
                  </p>
                </div>
              </div>

              <div>
                <h3 className="font-semibold text-gray-900 mb-2">Location</h3>
                <p className="text-gray-700">
                  {extractedData.locationType === 'VIRTUAL' 
                    ? 'Virtual Event' 
                    : extractedData.locationType === 'HYBRID'
                    ? 'Hybrid Event'
                    : extractedData.venueName || extractedData.venueAddress || 'TBD'}
                </p>
                {extractedData.venueAddress && (
                  <p className="text-sm text-gray-500 mt-1">{extractedData.venueAddress}</p>
                )}
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">Price</h3>
                  <p className="text-gray-700">
                    {extractedData.price === 0 
                      ? 'Free' 
                      : `${extractedData.currency || 'USD'} ${extractedData.price}`}
                  </p>
                </div>
                {extractedData.capacity && (
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">Capacity</h3>
                    <p className="text-gray-700">{extractedData.capacity} attendees</p>
                  </div>
                )}
              </div>

              {extractedData.tags && extractedData.tags.length > 0 && (
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">Tags</h3>
                  <div className="flex flex-wrap gap-2">
                    {extractedData.tags.map((tag: string, idx: number) => (
                      <span
                        key={idx}
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {extractedData.coverImage && (
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">Cover Image</h3>
                  <img
                    src={extractedData.coverImage}
                    alt="Event cover"
                    className="w-full h-48 object-cover rounded-lg"
                  />
                </div>
              )}

              <div className="pt-4 border-t border-gray-200">
                <p className="text-sm text-gray-500">
                  Source: {extractedData.platform} • 
                  <a 
                    href={extractedData.originalUrl} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="text-primary-600 hover:text-primary-700 ml-1"
                  >
                    View original
                  </a>
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Instructions */}
        {!extractedData && (
          <div className="border-t border-gray-200 pt-6">
            <h3 className="font-semibold text-gray-900 mb-3">How it works:</h3>
            <ol className="list-decimal list-inside space-y-2 text-sm text-gray-600">
              <li>Paste a Luma or Eventbrite event URL</li>
              <li>Click "Extract Event" to automatically extract all event details</li>
              <li>Review the extracted data</li>
              <li>Click "Create Event" to create your own FoundersEvents link</li>
            </ol>
            <div className="mt-4 p-4 bg-blue-50 rounded-lg">
              <p className="text-sm text-blue-800">
                <strong>Tip:</strong> After creating, you'll get your own FoundersEvents URL that you can share!
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

