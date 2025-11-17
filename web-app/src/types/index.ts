// Core data models matching the iOS app

export interface CalendarEvent {
  id: string;
  title: string;
  startDate: Date;
  endDate: Date;
  location?: string;
  notes?: string;
  extractedInfo?: ExtractedEventInfo;
  eventIdentifier?: string; // Google Calendar ID
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface ExtractedEventInfo {
  rawText: string;
  title?: string;
  startDateTime?: Date;
  endDateTime?: Date;
  location?: string;
  description?: string;
  confidence: number;
}

export interface LinkedInProfile {
  id: string;
  profileURL: string;
  name: string;
  company?: string;
  title?: string;
  notes?: string;
  linkedDate: Date;
  linkedEventId?: string;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface GarysGuideEvent {
  id: string;
  title: string;
  date: string;
  time: string;
  price: string;
  venue: string;
  speakers: string;
  url: string;
  isGaryEvent: boolean;
  isPopularEvent: boolean;
  week: string;
  scrapedAt: Date;
  isActive: boolean;
}

export interface LocationCoordinate {
  latitude: number;
  longitude: number;
  address?: string;
}

export enum TransportationMode {
  WALKING = 'walking',
  SUBWAY = 'subway',
  BUS = 'bus',
  TAXI = 'taxi',
  RIDESHARE = 'rideshare',
  DRIVING = 'driving'
}

export interface RouteSegment {
  id: string;
  fromLocation: LocationCoordinate;
  toLocation: LocationCoordinate;
  transportationMode: TransportationMode;
  travelTime: number; // in seconds
  cost: number;
  instructions: string;
  departureTime: Date;
  arrivalTime: Date;
}

export interface RoutePlan {
  id: string;
  name: string;
  startLocation?: LocationCoordinate;
  segments: RouteSegment[];
  totalTime: number;
  totalCost: number;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface MessageTemplate {
  id: string;
  name: string;
  template: string;
  isDefault: boolean;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserPreferences {
  id: string;
  timezone: string;
  theme: 'light' | 'dark' | 'system';
  defaultEventDuration: number;
  weekStartsOn: number;
  userId: string;
}

export interface CalendarSettings {
  id: string;
  googleCalendarEnabled: boolean;
  googleCalendarId?: string;
  autoSync: boolean;
  syncInterval: number;
  userId: string;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface ImportResult {
  uniqueEvents: CalendarEvent[];
  duplicateEvents: CalendarEvent[];
  totalFound: number;
}

// UI State types
export interface AppState {
  events: CalendarEvent[];
  selectedDate: Date;
  selectedEvent?: CalendarEvent;
  isLoading: boolean;
  error?: string;
}

// Sharing types
export enum SharingMethod {
  ICS_FILE = 'ics_file',
  EMAIL = 'email',
  MESSAGE = 'message',
  LINK = 'link'
}

export interface SharingOptions {
  method: SharingMethod;
  events: CalendarEvent[];
  recipients?: string[];
}

// Filter types
export interface EventFilters {
  dateRange?: {
    start: Date;
    end: Date;
  };
  search?: string;
  location?: string;
  eventType?: 'all' | 'popular' | 'free' | 'paid';
}

// AI types
export interface AIExtractionRequest {
  imageData: string; // base64 encoded image
  prompt?: string;
}

export interface AIExtractionResponse {
  success: boolean;
  extractedInfo?: ExtractedEventInfo;
  error?: string;
}

// Route planning types
export interface RouteRequest {
  events: CalendarEvent[];
  startLocation?: LocationCoordinate;
  transportationPreferences?: TransportationMode[];
}

export interface RouteResponse {
  routePlan: RoutePlan;
  suggestions: AISuggestion[];
}

export interface AISuggestion {
  id: string;
  type: SuggestionType;
  title: string;
  description: string;
  confidence: number;
  action: string;
  costSavings?: number;
  timeSavings?: number; // in seconds
}

export enum SuggestionType {
  ROUTE_OPTIMIZATION = 'routeOptimization',
  TRANSPORTATION = 'transportation',
  TIME_MANAGEMENT = 'timeManagement',
  COST_OPTIMIZATION = 'costOptimization',
  SOCIAL_COORDINATION = 'socialCoordination'
}

// Form types
export interface EventFormData {
  title: string;
  startDate: Date;
  endDate: Date;
  location?: string;
  notes?: string;
}

export interface LinkedInProfileFormData {
  profileURL: string;
  name: string;
  company?: string;
  title?: string;
  notes?: string;
  linkedEventId?: string;
}

// Calendar integration types
export interface GoogleCalendarEvent {
  id: string;
  summary: string;
  start: {
    dateTime?: string;
    date?: string;
    timeZone?: string;
  };
  end: {
    dateTime?: string;
    date?: string;
    timeZone?: string;
  };
  location?: string;
  description?: string;
}

export interface CalendarIntegration {
  provider: 'google' | 'apple' | 'outlook';
  isConnected: boolean;
  lastSync?: Date;
  calendars: CalendarInfo[];
}

export interface CalendarInfo {
  id: string;
  name: string;
  primary: boolean;
  accessRole: string;
}

// Error types
export interface AppError {
  code: string;
  message: string;
  details?: any;
}

export enum ErrorCode {
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  EXTERNAL_API_ERROR = 'EXTERNAL_API_ERROR',
  INTERNAL_SERVER_ERROR = 'INTERNAL_SERVER_ERROR'
}

// Utility types
export type DeepPartial<T> = {
  [P in keyof T]?: DeepPartial<T[P]>;
};

export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

export type CreateEventData = Optional<CalendarEvent, 'id' | 'userId' | 'createdAt' | 'updatedAt'>;
export type UpdateEventData = Partial<Omit<CalendarEvent, 'id' | 'userId' | 'createdAt'>>;

export type CreateLinkedInProfileData = Optional<LinkedInProfile, 'id' | 'userId' | 'createdAt' | 'updatedAt' | 'linkedDate'>;
export type UpdateLinkedInProfileData = Partial<Omit<LinkedInProfile, 'id' | 'userId' | 'createdAt'>>;
