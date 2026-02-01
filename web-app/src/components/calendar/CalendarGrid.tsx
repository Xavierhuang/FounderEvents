'use client';

import { useState } from 'react';
import { CalendarEvent } from '@/types';
import { ChevronLeftIcon, ChevronRightIcon } from '@heroicons/react/24/outline';
import { 
  format, 
  startOfMonth, 
  endOfMonth, 
  startOfWeek, 
  endOfWeek, 
  addDays, 
  addMonths,
  subMonths,
  isSameMonth,
  isSameDay,
  isToday
} from 'date-fns';

interface CalendarGridProps {
  events: CalendarEvent[];
  selectedDate?: Date;
  onDateSelect?: (date: Date) => void;
  onEventClick?: (event: CalendarEvent) => void;
}

export default function CalendarGrid({ 
  events, 
  selectedDate = new Date(), 
  onDateSelect,
  onEventClick 
}: CalendarGridProps) {
  const [currentMonth, setCurrentMonth] = useState(selectedDate);

  const monthStart = startOfMonth(currentMonth);
  const monthEnd = endOfMonth(monthStart);
  const startDate = startOfWeek(monthStart);
  const endDate = endOfWeek(monthEnd);

  const handlePrevMonth = () => {
    setCurrentMonth(subMonths(currentMonth, 1));
  };

  const handleNextMonth = () => {
    setCurrentMonth(addMonths(currentMonth, 1));
  };

  const handleToday = () => {
    setCurrentMonth(new Date());
  };

  const getEventsForDay = (day: Date) => {
    return events.filter(event => 
      isSameDay(new Date(event.startDate), day)
    );
  };

  const renderHeader = () => {
    return (
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">
          {format(currentMonth, 'MMMM yyyy')}
        </h2>
        <div className="flex items-center space-x-4">
          <button
            onClick={handleToday}
            className="btn-secondary text-sm"
          >
            Today
          </button>
          <div className="flex space-x-2">
            <button
              onClick={handlePrevMonth}
              className="p-2 hover:bg-white/50 rounded-lg transition-colors"
            >
              <ChevronLeftIcon className="h-5 w-5" />
            </button>
            <button
              onClick={handleNextMonth}
              className="p-2 hover:bg-white/50 rounded-lg transition-colors"
            >
              <ChevronRightIcon className="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    );
  };

  const renderDays = () => {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return (
      <div className="grid grid-cols-7 gap-px bg-[#25004D]/10 rounded-t-xl overflow-hidden">
        {days.map(day => (
          <div
            key={day}
            className="bg-white/30 backdrop-blur-sm py-3 text-center text-sm font-semibold text-gray-700"
          >
            {day}
          </div>
        ))}
      </div>
    );
  };

  const renderCells = () => {
    const rows = [];
    let days = [];
    let day = startDate;

    while (day <= endDate) {
      for (let i = 0; i < 7; i++) {
        const currentDay = day;
        const dayEvents = getEventsForDay(currentDay);
        const isCurrentMonth = isSameMonth(currentDay, monthStart);
        const isSelected = selectedDate && isSameDay(currentDay, selectedDate);
        const isTodayDate = isToday(currentDay);

        days.push(
          <div
            key={currentDay.toString()}
            className={`
              min-h-[120px] bg-white/40 backdrop-blur-sm p-2 border-r border-b border-white/30 cursor-pointer
              ${!isCurrentMonth ? 'bg-white/20' : ''}
              ${isSelected ? 'ring-2 ring-[#25004D]' : ''}
              hover:bg-white/60 transition-colors
            `}
            onClick={() => onDateSelect && onDateSelect(currentDay)}
          >
            <div className="flex items-center justify-between mb-1">
              <span
                className={`
                  text-sm font-medium
                  ${!isCurrentMonth ? 'text-gray-400' : 'text-gray-900'}
                  ${isTodayDate ? 'bg-[#25004D] text-white rounded-full w-7 h-7 flex items-center justify-center' : ''}
                `}
              >
                {format(currentDay, 'd')}
              </span>
              {dayEvents.length > 0 && (
                <span className="text-xs text-gray-500">
                  {dayEvents.length}
                </span>
              )}
            </div>
            <div className="space-y-1">
              {dayEvents.slice(0, 3).map(event => (
                <div
                  key={event.id}
                  onClick={(e) => {
                    e.stopPropagation();
                    onEventClick && onEventClick(event);
                  }}
                  className="text-xs p-1 bg-[#25004D]/10 text-[#25004D] rounded truncate hover:bg-[#25004D]/20 transition-colors"
                >
                  {format(new Date(event.startDate), 'h:mm a')} - {event.title}
                </div>
              ))}
              {dayEvents.length > 3 && (
                <div className="text-xs text-gray-500 pl-1">
                  +{dayEvents.length - 3} more
                </div>
              )}
            </div>
          </div>
        );
        day = addDays(day, 1);
      }
      rows.push(
        <div key={day.toString()} className="grid grid-cols-7 gap-px bg-[#25004D]/10">
          {days}
        </div>
      );
      days = [];
    }

    return <div className="border-l border-white/30 rounded-b-xl overflow-hidden">{rows}</div>;
  };

  return (
    <div className="bg-white/40 backdrop-blur-xl rounded-2xl border border-white/50 p-6 shadow-lg">
      {renderHeader()}
      {renderDays()}
      {renderCells()}
    </div>
  );
}

