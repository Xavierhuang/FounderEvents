'use client';

import { useState } from 'react';
import { useSession, signOut } from 'next-auth/react';
import { usePathname } from 'next/navigation';
import { isAdmin } from '@/lib/admin';
import { 
  CalendarDaysIcon, 
  UserGroupIcon, 
  PlusIcon,
  Cog6ToothIcon,
  UserCircleIcon,
  Bars3Icon,
  XMarkIcon,
  ArrowRightOnRectangleIcon,
  LinkIcon,
  ServerIcon,
  HomeIcon,
  RectangleStackIcon,
  MagnifyingGlassIcon,
  PlusCircleIcon
} from '@heroicons/react/24/outline';
import { motion, AnimatePresence } from 'framer-motion';
import Link from 'next/link';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: HomeIcon },
  { name: 'My Events', href: '/dashboard/my-events', icon: RectangleStackIcon },
  { name: 'Calendar', href: '/dashboard/calendar', icon: CalendarDaysIcon },
  { name: 'Discover', href: '/dashboard/discover', icon: MagnifyingGlassIcon },
  { name: 'Create Event', href: '/dashboard/events/create-manual', icon: PlusCircleIcon },
  { name: 'Import Event', href: '/dashboard/events/import', icon: LinkIcon },
  { name: 'Connections', href: '/dashboard/connections', icon: UserGroupIcon },
  { name: 'Admin', href: '/dashboard/admin', icon: ServerIcon },
];

const userNavigation = [
  { name: 'Settings', href: '/dashboard/settings', icon: Cog6ToothIcon },
  { name: 'Profile', href: '/dashboard/profile', icon: UserCircleIcon },
];

interface AppLayoutProps {
  children: React.ReactNode;
}

export default function AppLayout({ children }: AppLayoutProps) {
  const { data: session } = useSession();
  const pathname = usePathname();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  
  // Filter navigation based on admin status
  const userIsAdmin = isAdmin(session?.user?.email);
  const filteredNavigation = navigation.filter(item => {
    // Hide Admin link for non-admins
    if (item.name === 'Admin' && !userIsAdmin) {
      return false;
    }
    return true;
  });

  const handleSignOut = () => {
    signOut({ callbackUrl: '/' });
  };

  return (
    <div className="h-full">
      {/* Mobile sidebar */}
      <AnimatePresence>
        {sidebarOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-50 lg:hidden"
            >
              <div className="fixed inset-0 bg-gray-900/80" onClick={() => setSidebarOpen(false)} />
              <motion.div
                initial={{ x: -300 }}
                animate={{ x: 0 }}
                exit={{ x: -300 }}
                transition={{ type: "spring", bounce: 0, duration: 0.4 }}
                className="fixed left-0 top-0 z-40 h-full w-72 shadow-xl"
                style={{ background: '#250040' }}
              >
                <div className="flex h-16 items-center justify-between px-6" style={{ borderBottom: '1px solid rgba(255,255,255,0.15)' }}>
                  <div className="flex items-center">
                    <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background: 'linear-gradient(to bottom right, #5a1ad6, #25004D)' }}>
                      <CalendarDaysIcon className="h-5 w-5 text-white" />
                    </div>
                    <span className="ml-2 text-xl font-bold text-white">FoundersEvents</span>
                  </div>
                  <button
                    onClick={() => setSidebarOpen(false)}
                    className="hover:text-white"
                    style={{ color: 'rgba(255,255,255,0.7)' }}
                  >
                    <XMarkIcon className="h-6 w-6" />
                  </button>
                </div>
                <nav className="px-6 py-6">
                  <ul className="space-y-2">
                    {filteredNavigation.map((item) => {
                      const Icon = item.icon;
                      // For Dashboard, only match exact path; for others, match path or children
                      const isActive = item.href === '/dashboard' 
                        ? pathname === '/dashboard'
                        : pathname === item.href || pathname.startsWith(item.href + '/');
                      return (
                        <li key={item.name}>
                          <Link
                            href={item.href}
                            onClick={() => setSidebarOpen(false)}
                            className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                              isActive
                                ? 'bg-white'
                                : 'hover:bg-white/5 hover:text-white'
                            }`}
                            style={{ color: isActive ? '#25004D' : 'rgba(255,255,255,0.7)' }}
                          >
                            <Icon className="mr-3 h-5 w-5" style={{ color: isActive ? '#25004D' : undefined }} />
                            {item.name}
                          </Link>
                        </li>
                      );
                    })}
                  </ul>
                </nav>
              </motion.div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Desktop sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col">
        <div className="flex grow flex-col gap-y-5 overflow-y-auto px-6 py-6" style={{ background: '#25004D' }}>
          <div className="flex h-16 shrink-0 items-center">
            <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background: 'linear-gradient(to bottom right, #5a1ad6, #25004D)' }}>
              <CalendarDaysIcon className="h-5 w-5 text-white" />
            </div>
            <span className="ml-2 text-xl font-bold text-white">FoundersEvents</span>
          </div>
          <nav className="flex flex-1 flex-col">
            <ul role="list" className="flex flex-1 flex-col gap-y-7">
              <li>
                <ul role="list" className="-mx-2 space-y-1">
                  {filteredNavigation.map((item) => {
                    const Icon = item.icon;
                    // For Dashboard, only match exact path; for others, match path or children
                    const isActive = item.href === '/dashboard' 
                      ? pathname === '/dashboard'
                      : pathname === item.href || pathname.startsWith(item.href + '/');
                    return (
                      <li key={item.name}>
                        <Link
                          href={item.href}
                          className={`group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold transition-colors ${
                            isActive
                              ? 'bg-white'
                              : 'hover:text-white hover:bg-white/5'
                          }`}
                          style={{ color: isActive ? '#25004D' : 'rgba(255,255,255,0.7)' }}
                        >
                          <Icon
                            className="h-6 w-6 shrink-0 group-hover:text-white"
                            style={{ color: isActive ? '#25004D' : 'rgba(255,255,255,0.6)' }}
                          />
                          {item.name}
                        </Link>
                      </li>
                    );
                  })}
                </ul>
              </li>
              <li className="mt-auto">
                <div className="pt-6" style={{ borderTop: '1px solid rgba(255,255,255,0.15)' }}>
                  <ul role="list" className="-mx-2 space-y-1">
                    {userNavigation.map((item) => {
                      const Icon = item.icon;
                      const isActive = pathname === item.href;
                      return (
                        <li key={item.name}>
                          <Link
                            href={item.href}
                            className={`group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold transition-colors ${
                              isActive
                                ? 'bg-white'
                                : 'hover:text-white hover:bg-white/5'
                            }`}
                            style={{ color: isActive ? '#25004D' : 'rgba(255,255,255,0.7)' }}
                          >
                            <Icon
                              className="h-6 w-6 shrink-0 group-hover:text-white"
                              style={{ color: isActive ? '#25004D' : 'rgba(255,255,255,0.6)' }}
                            />
                            {item.name}
                          </Link>
                        </li>
                      );
                    })}
                  </ul>
                </div>
              </li>
            </ul>
          </nav>
        </div>
      </div>

      {/* Main content */}
      <div className="lg:pl-72 min-h-screen" style={{ backgroundImage: 'url(/purple-gradient-bg.png)', backgroundSize: 'cover', backgroundPosition: 'center', backgroundAttachment: 'fixed' }}>
        {/* Top bar */}
        <div className="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 border-b border-white/20 bg-white/70 backdrop-blur-xl px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:px-8">
          <button
            type="button"
            className="-m-2.5 p-2.5 text-gray-700 lg:hidden"
            onClick={() => setSidebarOpen(true)}
          >
            <span className="sr-only">Open sidebar</span>
            <Bars3Icon className="h-6 w-6" aria-hidden="true" />
          </button>

          {/* Separator */}
          <div className="h-6 w-px bg-gray-200 lg:hidden" aria-hidden="true" />

          <div className="flex flex-1 gap-x-4 self-stretch lg:gap-x-6">
            <div className="flex flex-1 items-center">
              {/* Breadcrumb or page title could go here */}
            </div>
            <div className="flex items-center gap-x-4 lg:gap-x-6">
              {/* User menu */}
              <div className="relative">
                <button
                  type="button"
                  className="-m-1.5 flex items-center p-1.5 hover:bg-gray-50 rounded-lg transition-colors"
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                >
                  <span className="sr-only">Open user menu</span>
                  {session?.user?.image ? (
                    <img
                      className="h-8 w-8 rounded-full bg-gray-50 object-cover"
                      src={session.user.image}
                      alt={session.user.name || 'User avatar'}
                    />
                  ) : (
                    <div className="h-8 w-8 rounded-full flex items-center justify-center text-white font-semibold text-sm" style={{ background: 'linear-gradient(to bottom right, #3d1a6d, #25004D)' }}>
                      {session?.user?.name?.charAt(0).toUpperCase() || 'U'}
                    </div>
                  )}
                  <span className="hidden lg:flex lg:items-center">
                    <span className="ml-4 text-sm font-semibold leading-6 text-gray-900">
                      {session?.user?.name}
                    </span>
                  </span>
                </button>

                <AnimatePresence>
                  {userMenuOpen && (
                    <motion.div
                      initial={{ opacity: 0, scale: 0.95 }}
                      animate={{ opacity: 1, scale: 1 }}
                      exit={{ opacity: 0, scale: 0.95 }}
                      transition={{ duration: 0.1 }}
                      className="absolute right-0 z-10 mt-2.5 w-48 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5"
                    >
                      <div className="px-3 py-2 border-b border-gray-100">
                        <p className="text-sm font-medium text-gray-900">{session?.user?.name}</p>
                        <p className="text-xs text-gray-500 truncate">{session?.user?.email}</p>
                      </div>
                      {userNavigation.map((item) => {
                        const Icon = item.icon;
                        return (
                          <Link
                            key={item.name}
                            href={item.href}
                            className="flex items-center px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900 transition-colors"
                            onClick={() => setUserMenuOpen(false)}
                          >
                            <Icon className="mr-3 h-4 w-4" />
                            {item.name}
                          </Link>
                        );
                      })}
                      <div className="border-t border-gray-100 mt-2 pt-2">
                        <button
                          onClick={handleSignOut}
                          className="flex w-full items-center px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900 transition-colors"
                        >
                          <ArrowRightOnRectangleIcon className="mr-3 h-4 w-4" />
                          Sign out
                        </button>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </div>
          </div>
        </div>

        {/* Page content */}
        <main className="py-8">
          <div className="px-4 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>

      {/* Click outside to close user menu */}
      {userMenuOpen && (
        <div
          className="fixed inset-0 z-30"
          onClick={() => setUserMenuOpen(false)}
        />
      )}
    </div>
  );
}
