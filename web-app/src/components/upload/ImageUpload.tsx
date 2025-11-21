'use client';

import { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { PhotoIcon, XMarkIcon } from '@heroicons/react/24/outline';

interface ImageUploadProps {
  onImageSelect: (imageData: string) => void;
  onClear?: () => void;
}

export default function ImageUpload({ onImageSelect, onClear }: ImageUploadProps) {
  const [preview, setPreview] = useState<string | null>(null);

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const result = e.target?.result as string;
        setPreview(result);
        onImageSelect(result);
      };
      reader.readAsDataURL(file);
    }
  }, [onImageSelect]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.gif', '.webp']
    },
    multiple: false,
    maxSize: 10485760, // 10MB
  });

  const handleClear = () => {
    setPreview(null);
    if (onClear) {
      onClear();
    }
  };

  if (preview) {
    return (
      <div className="relative">
        <img
          src={preview}
          alt="Preview"
          className="w-full h-auto rounded-lg border-2 border-gray-300"
        />
        <button
          onClick={handleClear}
          className="absolute top-2 right-2 p-2 bg-white rounded-full shadow-lg hover:bg-gray-100 transition-colors"
        >
          <XMarkIcon className="h-5 w-5 text-gray-600" />
        </button>
      </div>
    );
  }

  return (
    <div
      {...getRootProps()}
      className={`
        border-2 border-dashed rounded-lg p-12 text-center cursor-pointer
        transition-colors duration-200
        ${isDragActive 
          ? 'border-primary-500 bg-primary-50' 
          : 'border-gray-300 hover:border-gray-400'
        }
      `}
    >
      <input {...getInputProps()} />
      <PhotoIcon className="mx-auto h-12 w-12 text-gray-400" />
      <p className="mt-4 text-sm text-gray-600">
        {isDragActive ? (
          <span className="text-primary-600 font-medium">Drop the image here</span>
        ) : (
          <>
            <span className="text-primary-600 font-medium">Click to upload</span> or drag and drop
          </>
        )}
      </p>
      <p className="mt-2 text-xs text-gray-500">
        PNG, JPG, GIF up to 10MB
      </p>
    </div>
  );
}

