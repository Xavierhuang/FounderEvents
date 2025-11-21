import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { Providers } from './providers';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'FoundersEvents - Event Platform for Founders',
  description: 'Discover, create, and join events for founders and entrepreneurs. AI-powered event management and networking.',
  keywords: ['calendar', 'events', 'AI', 'networking', 'scheduling', 'productivity', 'founders', 'entrepreneurs'],
  authors: [{ name: 'FoundersEvents Team' }],
  metadataBase: new URL('https://foundersevents.app'),
  icons: {
    icon: '/favicon.ico',
    apple: '/apple-touch-icon.png',
  },
  openGraph: {
    title: 'FoundersEvents - Event Platform for Founders',
    description: 'Discover, create, and join events for founders and entrepreneurs',
    url: 'https://foundersevents.app',
    siteName: 'FoundersEvents',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'FoundersEvents - Event Platform for Founders',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'FoundersEvents - Event Platform for Founders',
    description: 'Discover, create, and join events for founders and entrepreneurs',
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
        <Providers>
          <div className="min-h-full">
            {children}
          </div>
        </Providers>
      </body>
    </html>
  );
}
