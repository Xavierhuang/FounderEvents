// Public Event Platform Types

export interface UserProfile {
  id: string;
  username: string;
  displayName: string;
  bio?: string;
  avatar?: string;
  coverImage?: string;
  website?: string;
  twitter?: string;
  linkedin?: string;
  instagram?: string;
  totalEvents: number;
  totalAttendees: number;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface PublicEvent {
  id: string;
  slug: string;
  title: string;
  description: string;
  shortDescription?: string;
  startDate: Date;
  endDate: Date;
  timezone: string;
  locationType: 'PHYSICAL' | 'VIRTUAL' | 'HYBRID';
  venueName?: string;
  venueAddress?: string;
  venueCity?: string;
  venueState?: string;
  venueZipCode?: string;
  virtualLink?: string;
  coverImage?: string;
  images?: string[];
  isPublic: boolean;
  requiresApproval: boolean;
  capacity?: number;
  registrationDeadline?: Date;
  price: number;
  currency: string;
  status: 'DRAFT' | 'PUBLISHED' | 'CANCELLED' | 'COMPLETED';
  visibility: 'PUBLIC' | 'PRIVATE' | 'UNLISTED';
  isFeatured: boolean;
  metaTitle?: string;
  metaDescription?: string;
  tags: string[];
  viewCount: number;
  registrationCount: number;
  likeCount: number;
  shareCount: number;
  organizerId: string;
  organizer?: UserProfile;
  categories?: EventCategory[];
  registrations?: EventRegistration[];
  comments?: EventComment[];
  likes?: EventLike[];
  createdAt: Date;
  updatedAt: Date;
  publishedAt?: Date;
}

export interface EventCategory {
  id: string;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  color?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface EventRegistration {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  status: 'PENDING' | 'CONFIRMED' | 'CANCELLED' | 'WAITLIST';
  ticketType?: string;
  quantity: number;
  totalAmount: number;
  paymentStatus?: 'PENDING' | 'PAID' | 'REFUNDED';
  paymentId?: string;
  checkedIn: boolean;
  checkedInAt?: Date;
  userId?: string;
  eventId: string;
  event?: PublicEvent;
  createdAt: Date;
  updatedAt: Date;
}

export interface EventComment {
  id: string;
  content: string;
  userId: string;
  user?: {
    name: string;
    image?: string;
    profile?: UserProfile;
  };
  eventId: string;
  parentId?: string;
  replies?: EventComment[];
  createdAt: Date;
  updatedAt: Date;
}

export interface EventLike {
  id: string;
  userId: string;
  eventId: string;
  createdAt: Date;
}

// Form types
export interface PublicEventFormData {
  title: string;
  description: string;
  shortDescription?: string;
  startDate: string;
  endDate: string;
  timezone: string;
  locationType: 'PHYSICAL' | 'VIRTUAL' | 'HYBRID';
  venueName?: string;
  venueAddress?: string;
  venueCity?: string;
  venueState?: string;
  venueZipCode?: string;
  virtualLink?: string;
  coverImage?: string;
  isPublic: boolean;
  requiresApproval: boolean;
  capacity?: number;
  registrationDeadline?: string;
  price: number;
  currency: string;
  tags: string[];
  categoryIds: string[];
}

export interface RegistrationFormData {
  firstName: string;
  lastName: string;
  email: string;
  quantity: number;
}

export interface UserProfileFormData {
  username: string;
  displayName: string;
  bio?: string;
  avatar?: string;
  website?: string;
  twitter?: string;
  linkedin?: string;
  instagram?: string;
}

// API Response types
export interface PublicEventsResponse {
  success: boolean;
  events: PublicEvent[];
  total: number;
  page: number;
  pageSize: number;
}

export interface PublicEventResponse {
  success: boolean;
  event: PublicEvent;
  isRegistered?: boolean;
  isLiked?: boolean;
}

export interface RegistrationResponse {
  success: boolean;
  registration: EventRegistration;
  message?: string;
}

// Filter types
export interface PublicEventFilters {
  search?: string;
  categoryId?: string;
  locationType?: 'PHYSICAL' | 'VIRTUAL' | 'HYBRID';
  startDate?: string;
  endDate?: string;
  priceMin?: number;
  priceMax?: number;
  isFree?: boolean;
  tags?: string[];
  city?: string;
  organizerId?: string;
  page?: number;
  pageSize?: number;
  sortBy?: 'startDate' | 'createdAt' | 'registrationCount' | 'viewCount';
  sortOrder?: 'asc' | 'desc';
}

