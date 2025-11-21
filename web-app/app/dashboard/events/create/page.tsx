'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import EventForm from '@/components/events/EventForm';
import ImageUpload from '@/components/upload/ImageUpload';
import { SparklesIcon, PencilSquareIcon } from '@heroicons/react/24/outline';
import toast from 'react-hot-toast';

type CreationMode = 'ai' | 'manual';

export default function CreateEventPage() {
  const router = useRouter();
  const [mode, setMode] = useState<CreationMode>('ai');
  const [imageData, setImageData] = useState<string | null>(null);
  const [isExtracting, setIsExtracting] = useState(false);
  const [extractedData, setExtractedData] = useState<any>(null);

  const handleImageSelect = async (data: string) => {
    setImageData(data);
    setIsExtracting(true);

    try {
      const response = await fetch('/api/ai/extract', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ imageData: data }),
      });

      if (response.ok) {
        const result = await response.json();
        setExtractedData(result.extractedInfo);
        toast.success('Event details extracted successfully!');
      } else {
        toast.error('Failed to extract event details');
      }
    } catch (error) {
      console.error('Extraction error:', error);
      toast.error('Failed to extract event details');
    } finally {
      setIsExtracting(false);
    }
  };

  const handleCreateEvent = async (data: any) => {
    try {
      const response = await fetch('/api/events', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...data,
          extractedInfo: extractedData || undefined,
        }),
      });

      if (response.ok) {
        toast.success('Event created successfully!');
        router.push('/dashboard/calendar');
      } else {
        toast.error('Failed to create event');
      }
    } catch (error) {
      console.error('Error creating event:', error);
      toast.error('Failed to create event');
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Create New Event</h1>
        <p className="mt-2 text-gray-600">
          Extract event details from a screenshot or create manually
        </p>
      </div>

      {/* Mode Selection */}
      <div className="card p-6">
        <div className="flex gap-4">
          <button
            onClick={() => setMode('ai')}
            className={`flex-1 p-4 rounded-lg border-2 transition-all ${
              mode === 'ai'
                ? 'border-primary-500 bg-primary-50'
                : 'border-gray-200 hover:border-gray-300'
            }`}
          >
            <SparklesIcon className={`h-6 w-6 mx-auto mb-2 ${mode === 'ai' ? 'text-primary-600' : 'text-gray-400'}`} />
            <h3 className="font-semibold text-gray-900">AI Extraction</h3>
            <p className="text-sm text-gray-600 mt-1">Upload a screenshot</p>
          </button>
          <button
            onClick={() => setMode('manual')}
            className={`flex-1 p-4 rounded-lg border-2 transition-all ${
              mode === 'manual'
                ? 'border-primary-500 bg-primary-50'
                : 'border-gray-200 hover:border-gray-300'
            }`}
          >
            <PencilSquareIcon className={`h-6 w-6 mx-auto mb-2 ${mode === 'manual' ? 'text-primary-600' : 'text-gray-400'}`} />
            <h3 className="font-semibold text-gray-900">Manual Entry</h3>
            <p className="text-sm text-gray-600 mt-1">Fill in the form</p>
          </button>
        </div>
      </div>

      {/* AI Extraction Mode */}
      {mode === 'ai' && (
        <div className="card p-6 space-y-6">
          <div>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Upload Event Screenshot
            </h2>
            <ImageUpload
              onImageSelect={handleImageSelect}
              onClear={() => {
                setImageData(null);
                setExtractedData(null);
              }}
            />
          </div>

          {isExtracting && (
            <div className="text-center py-8">
              <div className="spinner w-8 h-8 mx-auto mb-4"></div>
              <p className="text-gray-600">Extracting event details...</p>
            </div>
          )}

          {extractedData && !isExtracting && (
            <div>
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Review and Edit Details
              </h2>
              <EventForm
                event={{
                  id: '',
                  title: extractedData.title || '',
                  startDate: extractedData.startDateTime || new Date(),
                  endDate: extractedData.endDateTime || new Date(),
                  location: extractedData.location || '',
                  notes: extractedData.description || '',
                  userId: '',
                  createdAt: new Date(),
                  updatedAt: new Date(),
                }}
                onSubmit={handleCreateEvent}
                onCancel={() => router.back()}
              />
            </div>
          )}
        </div>
      )}

      {/* Manual Entry Mode */}
      {mode === 'manual' && (
        <div className="card p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Event Details
          </h2>
          <EventForm
            onSubmit={handleCreateEvent}
            onCancel={() => router.back()}
          />
        </div>
      )}
    </div>
  );
}

