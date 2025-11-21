'use client';

import { useRouter, useSearchParams } from 'next/navigation';
import { CalendarDaysIcon } from '@heroicons/react/24/outline';

export default function AuthErrorPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const error = searchParams.get('error');

  const getErrorMessage = (error: string | null) => {
    switch (error) {
      case 'Configuration':
        return 'There is a problem with the server configuration.';
      case 'AccessDenied':
        return 'You do not have permission to sign in.';
      case 'Verification':
        return 'The verification token has expired or has already been used.';
      default:
        return 'An error occurred during authentication.';
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-blue-50 flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-red-600 to-red-400 rounded-2xl mb-4">
            <CalendarDaysIcon className="h-10 w-10 text-white" />
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Authentication Error
          </h1>
          <p className="text-gray-600">
            Something went wrong
          </p>
        </div>

        <div className="card p-8">
          <div className="p-4 rounded-lg bg-red-50 border border-red-200 mb-6">
            <p className="text-sm text-red-600">
              {getErrorMessage(error)}
            </p>
          </div>

          <div className="space-y-4">
            <button
              onClick={() => router.push('/auth/signin')}
              className="w-full btn-primary"
            >
              Try Again
            </button>
            <button
              onClick={() => router.push('/')}
              className="w-full btn-secondary"
            >
              Back to Home
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

