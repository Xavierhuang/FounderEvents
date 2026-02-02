'use client';

import { useState, useEffect } from 'react';
import { CalendarEvent } from '@/types';
import EventCard from '@/components/events/EventCard';
import { ChevronLeftIcon, ChevronRightIcon, MagnifyingGlassIcon, CalendarIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { 
  format, 
  startOfMonth, 
  endOfMonth, 
  startOfWeek, 
  endOfWeek, 
  addDays, 
  addMonths,
  subMonths,
  addWeeks,
  subWeeks,
  isSameMonth,
  isSameDay,
  isToday,
  startOfDay,
  eachDayOfInterval,
  eachHourOfInterval,
  startOfHour,
  setHours
} from 'date-fns';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';

type ViewType = 'Day' | 'Week' | 'Month';

export default function CalendarPage() {
  const router = useRouter();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [showDayModal, setShowDayModal] = useState(false);
  const [currentDate, setCurrentDate] = useState(new Date());
  const [weekStart, setWeekStart] = useState(() => startOfWeek(new Date(), { weekStartsOn: 1 }));
  const [view, setView] = useState<ViewType>('Month');
  const [searchQuery, setSearchQuery] = useState('');
  const [platformFilter, setPlatformFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');

  useEffect(() => {
    fetchEvents();
  }, []);

  const fetchEvents = async () => {
    try {
      const response = await fetch('/api/events');
      if (response.ok) {
        const data = await response.json();
        setEvents(data.events || []);
      }
    } catch (error) {
      console.error('Failed to fetch events:', error);
      toast.error('Failed to load events');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDateSelect = (date: Date) => {
    setSelectedDate(date);
    setSelectedEvent(null);
    setShowDayModal(true);
  };

  const handleEventClick = (event: CalendarEvent) => {
    setSelectedEvent(event);
    setSelectedDate(new Date(event.startDate));
    setShowDayModal(true);
  };

  const handleCloseModal = () => {
    setShowDayModal(false);
    setSelectedEvent(null);
  };

  const handleDeleteEvent = async (eventId: string) => {
    try {
      const response = await fetch(`/api/events/${eventId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setEvents(events.filter(e => e.id !== eventId));
        setSelectedEvent(null);
        toast.success('Event deleted successfully');
      } else {
        toast.error('Failed to delete event');
      }
    } catch (error) {
      console.error('Error deleting event:', error);
      toast.error('Failed to delete event');
    }
  };

  const selectedDayEvents = selectedDate ? events.filter(event => {
    const eventDate = startOfDay(new Date(event.startDate));
    const selected = startOfDay(selectedDate);
    return eventDate.getTime() === selected.getTime();
  }) : [];

  const handlePrevious = () => {
    if (view === 'Month') {
      setCurrentDate(subMonths(currentDate, 1));
    } else if (view === 'Week') {
      const newWeekStart = subWeeks(weekStart, 1);
      setWeekStart(newWeekStart);
      setCurrentDate(newWeekStart);
    } else {
      const newDate = new Date(currentDate);
      newDate.setDate(newDate.getDate() - 1);
      setCurrentDate(newDate);
    }
  };

  const handleNext = () => {
    if (view === 'Month') {
      setCurrentDate(addMonths(currentDate, 1));
    } else if (view === 'Week') {
      const newWeekStart = addWeeks(weekStart, 1);
      setWeekStart(newWeekStart);
      setCurrentDate(newWeekStart);
    } else {
      const newDate = new Date(currentDate);
      newDate.setDate(newDate.getDate() + 1);
      setCurrentDate(newDate);
    }
  };

  const getDateRangeDisplay = () => {
    if (view === 'Week') {
      const weekEnd = endOfWeek(weekStart, { weekStartsOn: 1 });
      return `${format(weekStart, 'MM/dd/yy')} - ${format(weekEnd, 'MM/dd/yy')}`;
    } else if (view === 'Month') {
      const monthStart = startOfMonth(currentDate);
      const monthEnd = endOfMonth(currentDate);
      return `${format(monthStart, 'MM/dd/yy')} - ${format(monthEnd, 'MM/dd/yy')}`;
    } else {
      return format(currentDate, 'MM/dd/yy');
    }
  };

  const getNavigationTitle = () => {
    if (view === 'Month') {
      return format(currentDate, 'MMM yyyy');
    } else if (view === 'Week') {
      return format(weekStart, 'MMM yyyy');
    } else {
      return format(currentDate, 'MMM d, yyyy');
    }
  };

  const monthStart = startOfMonth(currentDate);
  const monthEnd = endOfMonth(monthStart);
  const calendarStart = startOfWeek(monthStart, { weekStartsOn: 1 });
  const calendarEnd = endOfWeek(monthEnd, { weekStartsOn: 1 });

  const getEventsForDay = (day: Date) => {
    return events.filter(event => 
      isSameDay(new Date(event.startDate), day)
    );
  };

  // Frosted glass styles
  const frostedContainerStyle: React.CSSProperties = {
    backgroundColor: 'rgba(255, 255, 255, 0.25)',
    backdropFilter: 'blur(30px) saturate(140%)',
    WebkitBackdropFilter: 'blur(30px) saturate(140%)',
    border: '1px solid rgba(255, 255, 255, 0.6)',
  };

  const frostedPillStyle: React.CSSProperties = {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    backdropFilter: 'blur(20px) saturate(140%)',
    WebkitBackdropFilter: 'blur(20px) saturate(140%)',
    border: '1px solid rgba(255, 255, 255, 0.6)',
    borderRadius: '8px',
  };

  const frostedSelectedTabStyle: React.CSSProperties = {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    backdropFilter: 'blur(20px) saturate(140%)',
    WebkitBackdropFilter: 'blur(20px) saturate(140%)',
    border: '1px solid rgba(255, 255, 255, 0.6)',
  };

  // Subtle purple/gray grid line color for internal lines
  const gridLineColor = 'rgba(200, 180, 220, 0.3)';

  // Cell styles
  const frostedCellStyle: React.CSSProperties = {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    border: `1px solid ${gridLineColor}`,
  };

  const frostedCellMutedStyle: React.CSSProperties = {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    border: `1px solid ${gridLineColor}`,
  };

  // Get week days for week view
  const weekDays = eachDayOfInterval({
    start: weekStart,
    end: endOfWeek(weekStart, { weekStartsOn: 1 }),
  });

  // Hours for time slots (6 AM to 10 PM)
  const hours = Array.from({ length: 17 }, (_, i) => i + 6);

  // Render calendar days header
  const renderCalendarDays = () => {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (
      <div className="grid grid-cols-7 gap-1 mb-2">
        {days.map(day => (
          <div
            key={day}
            className="text-center text-xs font-medium text-gray-600 p-2"
          >
            {day}
          </div>
        ))}
      </div>
    );
  };

  // Render Week View
  const renderWeekView = () => {
    return (
      <div className="flex flex-col h-full">
        {/* Week Header with Days */}
        <div className="grid grid-cols-8 gap-1 mb-2">
          {/* Empty cell for time column */}
          <div className="text-center text-xs font-medium text-gray-600 p-2"></div>
          {weekDays.map((day) => {
            const isTodayDate = isToday(day);
            return (
              <div
                key={day.toString()}
                className={`text-center p-2 rounded-lg ${isTodayDate ? 'bg-[#25004D]/10' : ''}`}
              >
                <div className="text-xs font-medium text-gray-600">
                  {format(day, 'EEE')}
                </div>
                <div className={`text-lg font-semibold ${isTodayDate ? 'text-[#25004D]' : 'text-gray-800'}`}>
                  {format(day, 'd')}
                </div>
              </div>
            );
          })}
        </div>

        {/* Time Grid */}
        <div className="flex-1 overflow-y-auto" style={{ maxHeight: '500px' }}>
          {hours.map((hour) => (
            <div key={hour} className="grid grid-cols-8 gap-1">
              {/* Time label */}
              <div className="text-xs text-gray-500 text-right pr-2 py-2">
                {format(setHours(new Date(), hour), 'h a')}
              </div>
              {/* Day cells */}
              {weekDays.map((day) => {
                const cellDate = setHours(day, hour);
                const dayEvents = events.filter(event => {
                  const eventDate = new Date(event.startDate);
                  return isSameDay(eventDate, day) && eventDate.getHours() === hour;
                });

                return (
                  <div
                    key={`${day.toString()}-${hour}`}
                    className="min-h-[50px] rounded-lg p-1 cursor-pointer transition-colors hover:bg-white/30"
                    style={frostedCellStyle}
                    onClick={() => handleDateSelect(cellDate)}
                  >
                    {dayEvents.map((event) => (
                      <div
                        key={event.id}
                        className="text-xs px-1 py-0.5 rounded truncate cursor-pointer transition-colors mb-1"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleEventClick(event);
                        }}
                        style={{
                          backgroundColor: 'rgba(37, 0, 77, 0.15)',
                          color: '#25004D',
                        }}
                        onMouseEnter={(e) => {
                          e.currentTarget.style.backgroundColor = 'rgba(37, 0, 77, 0.25)';
                        }}
                        onMouseLeave={(e) => {
                          e.currentTarget.style.backgroundColor = 'rgba(37, 0, 77, 0.15)';
                        }}
                      >
                        {event.title}
                      </div>
                    ))}
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      </div>
    );
  };

  // Render Day View
  const renderDayView = () => {
    const dayEvents = events.filter(event => 
      isSameDay(new Date(event.startDate), currentDate)
    );

    return (
      <div className="flex flex-col h-full">
        {/* Day Header */}
        <div className="text-center p-4 mb-2">
          <div className="text-xs font-medium text-gray-600">
            {format(currentDate, 'EEEE')}
          </div>
          <div className={`text-2xl font-semibold ${isToday(currentDate) ? 'text-[#25004D]' : 'text-gray-800'}`}>
            {format(currentDate, 'd')}
          </div>
        </div>

        {/* Time Grid */}
        <div className="flex-1 overflow-y-auto" style={{ maxHeight: '500px' }}>
          {hours.map((hour) => {
            const cellDate = setHours(currentDate, hour);
            const hourEvents = dayEvents.filter(event => {
              const eventDate = new Date(event.startDate);
              return eventDate.getHours() === hour;
            });

            return (
              <div key={hour} className="grid grid-cols-12 gap-1">
                {/* Time label */}
                <div className="col-span-1 text-xs text-gray-500 text-right pr-2 py-2">
                  {format(setHours(new Date(), hour), 'h a')}
                </div>
                {/* Event cell */}
                <div
                  className="col-span-11 min-h-[50px] rounded-lg p-2 cursor-pointer transition-colors hover:bg-white/30"
                  style={frostedCellStyle}
                  onClick={() => handleDateSelect(cellDate)}
                >
                  {hourEvents.map((event) => (
                    <div
                      key={event.id}
                      className="text-sm px-2 py-1 rounded cursor-pointer transition-colors mb-1"
                      onClick={(e) => {
                        e.stopPropagation();
                        handleEventClick(event);
                      }}
                      style={{
                        backgroundColor: 'rgba(37, 0, 77, 0.15)',
                        color: '#25004D',
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = 'rgba(37, 0, 77, 0.25)';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = 'rgba(37, 0, 77, 0.15)';
                      }}
                    >
                      <div className="font-medium">{event.title}</div>
                      {event.location && (
                        <div className="text-xs opacity-75">{event.location}</div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  // Render calendar cells for month view
  const renderCalendarCells = () => {
    const allDays: Date[] = [];
    let day = calendarStart;
    
    while (day <= calendarEnd) {
      allDays.push(day);
      day = addDays(day, 1);
    }

    return (
      <div className="grid grid-cols-7 gap-1">
        {allDays.map((currentDay) => {
          const dayEvents = getEventsForDay(currentDay);
          const isCurrentMonth = isSameMonth(currentDay, monthStart);
          const isSelected = selectedDate && isSameDay(currentDay, selectedDate);
          const isTodayDate = isToday(currentDay);

          return (
            <div
              key={currentDay.toString()}
              className="min-h-[100px] rounded-lg p-1 cursor-pointer transition-colors hover:bg-white/30"
              onClick={() => handleDateSelect(currentDay)}
              style={{
                ...(isCurrentMonth ? frostedCellStyle : frostedCellMutedStyle),
                borderColor: isSelected ? '#25004D' : (isTodayDate ? '#25004D' : undefined),
                borderWidth: isSelected || isTodayDate ? '2px' : undefined,
              }}
            >
              <div
                className={`text-sm mb-1 ${
                  isCurrentMonth ? 'text-gray-800' : 'text-gray-500'
                } ${isTodayDate ? 'font-bold text-[#25004D]' : ''}`}
              >
                {format(currentDay, 'd')}
              </div>
              {dayEvents.length > 0 && (
                <div className="space-y-1">
                  {dayEvents.slice(0, 2).map((event) => (
                    <div
                      key={event.id}
                      className="text-xs px-1 py-0.5 rounded truncate cursor-pointer transition-colors"
                      title={event.title}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleEventClick(event);
                      }}
                      style={{
                        backgroundColor: 'rgba(37, 0, 77, 0.15)',
                        color: '#25004D',
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = 'rgba(37, 0, 77, 0.25)';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = 'rgba(37, 0, 77, 0.15)';
                      }}
                    >
                      {event.title}
                    </div>
                  ))}
                  {dayEvents.length > 2 && (
                    <div className="text-xs text-gray-600">
                      +{dayEvents.length - 2} more
                    </div>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>
    );
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="spinner w-8 h-8"></div>
      </div>
    );
  }

  return (
    <div className="space-y-0">
      {/* Main Calendar Card */}
      <div 
        className="flex flex-col rounded-xl overflow-hidden"
        style={frostedContainerStyle}
      >
        {/* Calendar Header */}
        <div className="flex items-center justify-between px-4 py-3">
          {/* Month Navigation */}
          <div className="flex items-center gap-1">
            <button
              onClick={handlePrevious}
              className="p-1.5 rounded-md transition-colors hover:bg-white/40"
            >
              <ChevronLeftIcon className="h-5 w-5 text-gray-600" />
            </button>
            <span className="text-lg font-semibold text-[#25004D] min-w-[110px] text-center">
              {getNavigationTitle()}
            </span>
            <button
              onClick={handleNext}
              className="p-1.5 rounded-md transition-colors hover:bg-white/40"
            >
              <ChevronRightIcon className="h-5 w-5 text-gray-600" />
            </button>
          </div>

          {/* Date Range Display & View Switcher */}
          <div className="flex items-center gap-3">
            {/* Date Range */}
            <div 
              className="flex items-center gap-2 px-3 py-2 rounded-lg"
              style={frostedPillStyle}
            >
              <CalendarIcon className="h-4 w-4 text-[#25004D]" />
              <span className="text-sm text-[#25004D]">{getDateRangeDisplay()}</span>
            </div>

            {/* View Tabs */}
            <div 
              className="flex items-center rounded-lg p-1"
              style={frostedPillStyle}
            >
              {(['Day', 'Week', 'Month'] as ViewType[]).map((mode) => (
                <button
                  key={mode}
                  onClick={() => setView(mode)}
                  className={`px-4 py-1.5 text-sm font-medium rounded-md transition-colors ${
                    view === mode
                      ? 'text-[#25004D] shadow-sm'
                      : 'text-gray-500 hover:text-gray-700'
                  }`}
                  style={view === mode ? frostedSelectedTabStyle : undefined}
                >
                  {mode}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Filters Row */}
        <div className="flex items-center justify-between px-4 pb-3">
          {/* Search on the left */}
          <div className="w-64">
            <div className="relative">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500 z-10" />
              <input
                type="text"
                placeholder="Search"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#25004D]/30 rounded-lg"
                style={frostedPillStyle}
              />
            </div>
          </div>
          
          {/* Platform and Status filters on the right */}
          <div className="flex items-center gap-3">
            <select
              value={platformFilter}
              onChange={(e) => setPlatformFilter(e.target.value)}
              className="px-4 py-2 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#25004D]/30 cursor-pointer appearance-none pr-8"
              style={frostedPillStyle}
            >
              <option value="all">All Platforms</option>
              <option value="luma">Luma</option>
              <option value="eventbrite">Eventbrite</option>
              <option value="manual">Manual</option>
            </select>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#25004D]/30 cursor-pointer appearance-none pr-8"
              style={frostedPillStyle}
            >
              <option value="all">All Status</option>
              <option value="upcoming">Upcoming</option>
              <option value="past">Past</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
        </div>

        {/* Inner Month Navigation for Month View */}
        {view === 'Month' && (
          <div 
            className="flex items-center justify-between px-4 py-3"
            style={{ borderBottom: `1px solid ${gridLineColor}` }}
          >
            <button
              onClick={handlePrevious}
              className="p-1 hover:bg-white/30 rounded transition-colors"
            >
              <ChevronLeftIcon className="h-4 w-4 text-gray-700" />
            </button>
            <h2 className="text-lg font-semibold text-gray-800">
              {format(currentDate, 'MMMM yyyy')}
            </h2>
            <button
              onClick={handleNext}
              className="p-1 hover:bg-white/30 rounded transition-colors"
            >
              <ChevronRightIcon className="h-4 w-4 text-gray-700" />
            </button>
          </div>
        )}

        {/* Calendar Content */}
        <div className="flex-1 overflow-hidden px-4 pb-4">
          {view === 'Month' && (
            <>
              {renderCalendarDays()}
              {renderCalendarCells()}
            </>
          )}
          {view === 'Week' && renderWeekView()}
          {view === 'Day' && renderDayView()}
        </div>
      </div>

      {/* Day Details Modal */}
      {showDayModal && selectedDate && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          {/* Backdrop */}
          <div 
            className="fixed inset-0 bg-black/50 backdrop-blur-sm transition-opacity"
            onClick={handleCloseModal}
          />
          
          {/* Modal */}
          <div className="flex min-h-full items-center justify-center p-4">
            <div className="relative bg-white/90 backdrop-blur-xl rounded-2xl border border-white/50 shadow-2xl w-full max-w-md p-6 transform transition-all">
              {/* Close button */}
              <button
                onClick={handleCloseModal}
                className="absolute top-4 right-4 p-2 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <XMarkIcon className="h-5 w-5 text-gray-500" />
              </button>

              <h2 className="text-xl font-semibold text-gray-900 mb-6">
                {format(selectedDate, 'EEEE, MMMM d')}
              </h2>
              
              {selectedDayEvents.length > 0 ? (
                <div className="space-y-4 max-h-[60vh] overflow-y-auto">
                  {selectedDayEvents.map(event => (
                    <EventCard
                      key={event.id}
                      event={event}
                      onDelete={handleDeleteEvent}
                    />
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <p className="text-gray-500 text-sm">No events on this day</p>
                  <button
                    onClick={() => {
                      handleCloseModal();
                      router.push('/dashboard/events/create');
                    }}
                    className="mt-4 text-[#25004D] hover:text-[#3d1a6d] text-sm font-medium"
                  >
                    Create an event
                  </button>
                </div>
              )}

              {selectedEvent && (
                <div className="mt-6 pt-6 border-t border-gray-200">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">
                    Selected Event
                  </h3>
                  <EventCard
                    event={selectedEvent}
                    onDelete={handleDeleteEvent}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
