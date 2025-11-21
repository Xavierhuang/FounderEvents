//
//  PublicEventModels.swift
//  Founder Events
//
//  Public Event Platform Models
//

import Foundation

// MARK: - User Profile

struct UserProfile: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let bio: String?
    let avatar: String?
    let coverImage: String?
    
    // Social links
    let website: String?
    let twitter: String?
    let linkedin: String?
    let instagram: String?
    
    // Stats
    let totalEvents: Int
    let totalAttendees: Int
    
    let userId: String
    let createdAt: Date
    let updatedAt: Date
}

struct CreateProfileRequest: Codable {
    let username: String
    let displayName: String
    let bio: String?
    let avatar: String?
    let coverImage: String?
    let website: String?
    let twitter: String?
    let linkedin: String?
    let instagram: String?
}

// MARK: - Public Event

struct PublicEvent: Codable, Identifiable {
    let id: String
    let slug: String
    let title: String
    let description: String
    let shortDescription: String?
    
    // Event details
    let startDate: Date
    let endDate: Date
    let timezone: String
    
    // Location
    let locationType: LocationType
    let venueName: String?
    let venueAddress: String?
    let venueCity: String?
    let venueState: String?
    let venueZipCode: String?
    let virtualLink: String?
    
    // Media
    let coverImage: String?
    let images: [String]?
    
    // Registration
    let isPublic: Bool
    let requiresApproval: Bool
    let capacity: Int?
    let registrationDeadline: Date?
    let price: Double
    let currency: String
    
    // Status
    let status: EventStatus
    let visibility: EventVisibility
    let isFeatured: Bool
    
    // SEO
    let metaTitle: String?
    let metaDescription: String?
    let tags: [String]
    
    // Stats
    let viewCount: Int
    let registrationCount: Int
    let likeCount: Int
    let shareCount: Int
    
    // Relationships
    let organizerId: String
    let organizer: EventOrganizer?
    
    let createdAt: Date
    let updatedAt: Date
    let publishedAt: Date?
    
    enum LocationType: String, Codable {
        case PHYSICAL
        case VIRTUAL
        case HYBRID
    }
    
    enum EventStatus: String, Codable {
        case DRAFT
        case PUBLISHED
        case CANCELLED
        case COMPLETED
    }
    
    enum EventVisibility: String, Codable {
        case PUBLIC
        case PRIVATE
        case UNLISTED
    }
}

struct EventOrganizer: Codable {
    let id: String
    let name: String?
    let image: String?
    let profile: UserProfile?
}

// MARK: - Create/Update Public Event

struct CreatePublicEventRequest: Codable {
    let title: String
    let description: String
    let shortDescription: String?
    let startDate: String
    let endDate: String
    let timezone: String
    let locationType: String
    let venueName: String?
    let venueAddress: String?
    let venueCity: String?
    let venueState: String?
    let venueZipCode: String?
    let virtualLink: String?
    let coverImage: String?
    let isPublic: Bool
    let requiresApproval: Bool
    let capacity: Int?
    let price: Double
    let currency: String
    let tags: [String]
    let categoryIds: [String]
}

// MARK: - Event Registration

struct EventRegistration: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let status: RegistrationStatus
    let ticketType: String?
    let quantity: Int
    let totalAmount: Double
    let paymentStatus: String?
    let paymentId: String?
    let checkedIn: Bool
    let checkedInAt: Date?
    let userId: String?
    let eventId: String
    let createdAt: Date
    let updatedAt: Date
    
    enum RegistrationStatus: String, Codable {
        case PENDING
        case CONFIRMED
        case CANCELLED
        case WAITLIST
    }
}

struct RegisterForEventRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let quantity: Int?
}

// MARK: - Event Comment

struct EventComment: Codable, Identifiable {
    let id: String
    let content: String
    let userId: String
    let eventId: String
    let parentId: String?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Event Like

struct EventLike: Codable, Identifiable {
    let id: String
    let userId: String
    let eventId: String
    let createdAt: Date
}

// MARK: - API Responses

struct ProfileResponse: Codable {
    let success: Bool
    let profile: UserProfile?
    let hasProfile: Bool
}

struct PublicEventsResponse: Codable {
    let success: Bool
    let events: [PublicEvent]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct PublicEventDetailResponse: Codable {
    let success: Bool
    let event: PublicEvent
    let isRegistered: Bool
    let isLiked: Bool
    let userRegistration: EventRegistration?
}

struct CreateEventResponse: Codable {
    let success: Bool
    let event: PublicEvent
}

struct RegistrationResponse: Codable {
    let success: Bool
    let registration: EventRegistration
    let message: String?
}

struct UpdateEventResponse: Codable {
    let success: Bool
    let event: PublicEvent
}

// MARK: - Filters

enum PublicEventFilter {
    case all
    case popular
    case featured
    case upcoming
    case past
    
    var displayName: String {
        switch self {
        case .all: return "All Events"
        case .popular: return "Popular Events"
        case .featured: return "Featured Events"
        case .upcoming: return "Upcoming"
        case .past: return "Past Events"
        }
    }
}

