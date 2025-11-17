import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { SessionProvider } from 'next-auth/react';
import { Toaster } from 'react-hot-toast';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'ScheduleShare - Smart Calendar Manager',
  description: 'AI-powered event creation, discovery, and networking for busy professionals',
  keywords: ['calendar', 'events', 'AI', 'networking', 'scheduling', 'productivity'],
  authors: [{ name: 'ScheduleShare Team' }],
  viewport: 'width=device-width, initial-scale=1',
  themeColor: '#7c1aff',
  icons: {
    icon: '/favicon.ico',
    apple: '/apple-touch-icon.png',
  },
  openGraph: {
    title: 'ScheduleShare - Smart Calendar Manager',
    description: 'AI-powered event creation, discovery, and networking for busy professionals',
    url: 'https://scheduleshare.app',
    siteName: 'ScheduleShare',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'ScheduleShare - Smart Calendar Manager',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ScheduleShare - Smart Calendar Manager',
    description: 'AI-powered event creation, discovery, and networking for busy professionals',
    images: ['/og-image.png'],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="h-full">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
      </head>
      <body className={`${inter.className} h-full bg-gray-50 antialiased`}>
        <SessionProvider>
          <div className="min-h-full">
            {children}
          </div>
          <Toaster
            position="top-center"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#1f2937',
                color: '#f9fafb',
                borderRadius: '12px',
                padding: '16px',
                boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
              },
              success: {
                iconTheme: {
                  primary: '#10b981',
                  secondary: '#f9fafb',
                },
              },
              error: {
                iconTheme: {
                  primary: '#ef4444',
                  secondary: '#f9fafb',
                },
              },
            }}
          />
        </SessionProvider>
      </body>
    </html>
  );
}
