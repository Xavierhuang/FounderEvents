'use client';

import { useState } from 'react';
import { signIn } from 'next-auth/react';
import { 
  SparklesIcon, 
  CalendarDaysIcon, 
  UserGroupIcon,
  CameraIcon,
  ShareIcon,
  MapIcon,
  ArrowRightIcon,
  CheckIcon
} from '@heroicons/react/24/outline';
import { motion } from 'framer-motion';

const features = [
  {
    name: 'AI Event Extraction',
    description: 'Take a screenshot of any event and let AI extract all the details automatically.',
    icon: CameraIcon,
    color: 'text-blue-600',
    bgColor: 'bg-blue-100',
  },
  {
    name: 'Event Discovery',
    description: 'Discover NYC tech events from Gary\'s Guide and add them to your calendar.',
    icon: SparklesIcon,
    color: 'text-purple-600',
    bgColor: 'bg-purple-100',
  },
  {
    name: 'Smart Networking',
    description: 'Connect with LinkedIn profiles from events and send personalized messages.',
    icon: UserGroupIcon,
    color: 'text-green-600',
    bgColor: 'bg-green-100',
  },
  {
    name: 'Calendar Integration',
    description: 'Seamlessly sync with Google Calendar and import/export your events.',
    icon: CalendarDaysIcon,
    color: 'text-orange-600',
    bgColor: 'bg-orange-100',
  },
  {
    name: 'Easy Sharing',
    description: 'Share events with colleagues via email, message, or ICS file.',
    icon: ShareIcon,
    color: 'text-pink-600',
    bgColor: 'bg-pink-100',
  },
  {
    name: 'Route Planning',
    description: 'AI-powered route optimization for multi-event days in NYC.',
    icon: MapIcon,
    color: 'text-indigo-600',
    bgColor: 'bg-indigo-100',
  },
];

const testimonials = [
  {
    content: "ScheduleShare has transformed how I manage events. The AI extraction saves me hours every week!",
    author: "Sarah Chen",
    role: "Product Manager",
    company: "TechCorp",
  },
  {
    content: "The networking features are incredible. I've made so many valuable connections through this app.",
    author: "Mike Rodriguez",
    role: "Startup Founder",
    company: "InnovateLab",
  },
  {
    content: "Finally, a calendar app that understands the NYC tech scene. Gary's Guide integration is perfect.",
    author: "Emily Johnson",
    role: "Software Engineer",
    company: "DataFlow",
  },
];

const pricingPlans = [
  {
    name: 'Free',
    price: '$0',
    description: 'Perfect for getting started',
    features: [
      'Up to 10 events per month',
      'AI event extraction',
      'Basic calendar integration',
      'Event discovery',
      'Email support',
    ],
    cta: 'Get Started Free',
    popular: false,
  },
  {
    name: 'Pro',
    price: '$12',
    description: 'For power users and professionals',
    features: [
      'Unlimited events',
      'Advanced AI features',
      'LinkedIn integration',
      'Route planning',
      'Priority support',
      'Calendar import/export',
      'Team collaboration',
    ],
    cta: 'Start Free Trial',
    popular: true,
  },
  {
    name: 'Enterprise',
    price: 'Custom',
    description: 'For teams and organizations',
    features: [
      'Everything in Pro',
      'Custom integrations',
      'Advanced analytics',
      'Dedicated support',
      'SSO integration',
      'Custom branding',
    ],
    cta: 'Contact Sales',
    popular: false,
  },
];

export default function LandingPage() {
  const [isSigningIn, setIsSigningIn] = useState(false);

  const handleSignIn = async () => {
    setIsSigningIn(true);
    try {
      await signIn('google', { callbackUrl: '/dashboard' });
    } catch (error) {
      console.error('Sign in error:', error);
      setIsSigningIn(false);
    }
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="flex items-center">
                  <div className="w-8 h-8 bg-gradient-to-br from-primary-600 to-primary-400 rounded-lg flex items-center justify-center">
                    <CalendarDaysIcon className="h-5 w-5 text-white" />
                  </div>
                  <span className="ml-2 text-xl font-bold text-gray-900">FoundersEvents</span>
                </div>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <button
                onClick={handleSignIn}
                disabled={isSigningIn}
                className="btn-primary"
              >
                {isSigningIn ? (
                  <>
                    <div className="spinner w-4 h-4 mr-2" />
                    Signing in...
                  </>
                ) : (
                  <>
                    Sign in with Google
                    <ArrowRightIcon className="ml-2 h-4 w-4" />
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-primary-50 to-blue-50 py-20 sm:py-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <motion.h1 
              className="text-4xl sm:text-6xl font-bold text-gray-900 mb-6"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              Smart Calendar Management
              <span className="text-gradient-primary block">Powered by AI</span>
            </motion.h1>
            <motion.p 
              className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
            >
              Extract events from screenshots, discover NYC tech events, network with LinkedIn contacts, 
              and optimize your schedule with AI-powered route planning.
            </motion.p>
            <motion.div 
              className="flex flex-col sm:flex-row justify-center items-center space-y-4 sm:space-y-0 sm:space-x-4"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
            >
              <button
                onClick={handleSignIn}
                disabled={isSigningIn}
                className="btn-primary text-lg px-8 py-3"
              >
                {isSigningIn ? (
                  <>
                    <div className="spinner w-5 h-5 mr-3" />
                    Getting Started...
                  </>
                ) : (
                  <>
                    Get Started Free
                    <ArrowRightIcon className="ml-2 h-5 w-5" />
                  </>
                )}
              </button>
              <a href="#features" className="btn-secondary text-lg px-8 py-3">
                Learn More
              </a>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              Everything you need to manage events
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              From AI-powered extraction to smart networking, ScheduleShare has all the tools 
              you need to stay organized and connected.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <motion.div
                  key={feature.name}
                  className="card p-8 hover:shadow-lg transition-all duration-300"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: index * 0.1 }}
                >
                  <div className={`inline-flex p-3 rounded-lg ${feature.bgColor} mb-4`}>
                    <Icon className={`h-6 w-6 ${feature.color}`} />
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">
                    {feature.name}
                  </h3>
                  <p className="text-gray-600">
                    {feature.description}
                  </p>
                </motion.div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              Loved by professionals everywhere
            </h2>
            <p className="text-xl text-gray-600">
              See what our users have to say about ScheduleShare
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <motion.div
                key={index}
                className="card p-8"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
              >
                <p className="text-gray-600 mb-6 italic">
                  "{testimonial.content}"
                </p>
                <div className="flex items-center">
                  <div className="profile-avatar">
                    {testimonial.author.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="ml-3">
                    <p className="font-semibold text-gray-900">{testimonial.author}</p>
                    <p className="text-sm text-gray-500">
                      {testimonial.role} at {testimonial.company}
                    </p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              Simple, transparent pricing
            </h2>
            <p className="text-xl text-gray-600">
              Choose the plan that's right for you
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {pricingPlans.map((plan, index) => (
              <motion.div
                key={plan.name}
                className={`card p-8 relative ${
                  plan.popular 
                    ? 'ring-2 ring-primary-500 shadow-lg scale-105' 
                    : 'hover:shadow-lg'
                } transition-all duration-300`}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
              >
                {plan.popular && (
                  <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                    <span className="badge-primary px-4 py-2 font-semibold">
                      Most Popular
                    </span>
                  </div>
                )}
                <div className="text-center mb-8">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">
                    {plan.name}
                  </h3>
                  <div className="mb-4">
                    <span className="text-4xl font-bold text-gray-900">
                      {plan.price}
                    </span>
                    {plan.price !== 'Custom' && (
                      <span className="text-gray-600">/month</span>
                    )}
                  </div>
                  <p className="text-gray-600">{plan.description}</p>
                </div>
                <ul className="space-y-3 mb-8">
                  {plan.features.map((feature, featureIndex) => (
                    <li key={featureIndex} className="flex items-center">
                      <CheckIcon className="h-5 w-5 text-green-500 mr-3 flex-shrink-0" />
                      <span className="text-gray-600">{feature}</span>
                    </li>
                  ))}
                </ul>
                <button
                  onClick={plan.name === 'Enterprise' ? undefined : handleSignIn}
                  disabled={isSigningIn}
                  className={`w-full ${
                    plan.popular 
                      ? 'btn-primary' 
                      : 'btn-secondary'
                  }`}
                >
                  {plan.cta}
                </button>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-primary-600 to-primary-400">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
            Ready to revolutionize your calendar?
          </h2>
          <p className="text-xl text-primary-100 mb-8">
            Join thousands of professionals who trust ScheduleShare to manage their events and networking.
          </p>
          <button
            onClick={handleSignIn}
            disabled={isSigningIn}
            className="btn-secondary bg-white text-primary-600 hover:bg-gray-50 text-lg px-8 py-3"
          >
            {isSigningIn ? (
              <>
                <div className="spinner w-5 h-5 mr-3" />
                Starting Your Journey...
              </>
            ) : (
              <>
                Start Your Free Trial
                <ArrowRightIcon className="ml-2 h-5 w-5" />
              </>
            )}
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center mb-4">
                <div className="w-8 h-8 bg-gradient-to-br from-primary-600 to-primary-400 rounded-lg flex items-center justify-center">
                  <CalendarDaysIcon className="h-5 w-5 text-white" />
                </div>
                <span className="ml-2 text-xl font-bold text-white">FoundersEvents</span>
              </div>
              <p className="text-gray-400 mb-4">
                Smart calendar management powered by AI. Extract events, discover networking opportunities, 
                and optimize your schedule like never before.
              </p>
            </div>
            <div>
              <h3 className="font-semibold text-white mb-4">Product</h3>
              <ul className="space-y-2">
                <li><a href="#features" className="hover:text-white transition-colors">Features</a></li>
                <li><a href="#pricing" className="hover:text-white transition-colors">Pricing</a></li>
                <li><a href="/docs" className="hover:text-white transition-colors">Documentation</a></li>
                <li><a href="/api" className="hover:text-white transition-colors">API</a></li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold text-white mb-4">Support</h3>
              <ul className="space-y-2">
                <li><a href="/help" className="hover:text-white transition-colors">Help Center</a></li>
                <li><a href="/contact" className="hover:text-white transition-colors">Contact Us</a></li>
                <li><a href="/status" className="hover:text-white transition-colors">Status</a></li>
                <li><a href="/privacy" className="hover:text-white transition-colors">Privacy Policy</a></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-12 pt-8 text-center">
            <p className="text-gray-400">
              © 2024 ScheduleShare. All rights reserved. Built with ❤️ for the NYC tech community.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
