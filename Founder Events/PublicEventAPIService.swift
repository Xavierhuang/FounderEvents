//
//  PublicEventAPIService.swift
//  Founder Events
//
//  API Service for Public Events Platform
//

import Foundation

class PublicEventAPIService {
    static let shared = PublicEventAPIService()
    
    private let baseURL = "http://138.197.38.120/api"
    private let session = URLSession.shared
    
    // MARK: - Profile APIs
    
    func getProfile() async throws -> UserProfile? {
        let url = URL(string: "\(baseURL)/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 404 {
            return nil
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let profileResponse = try decoder.decode(ProfileResponse.self, from: data)
        
        return profileResponse.profile
    }
    
    func createProfile(_ request: CreateProfileRequest) async throws -> UserProfile {
        let url = URL(string: "\(baseURL)/profile")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let profileResponse = try decoder.decode(ProfileResponse.self, from: data)
        
        guard let profile = profileResponse.profile else {
            throw APIError.invalidResponse
        }
        
        return profile
    }
    
    func updateProfile(_ request: CreateProfileRequest) async throws -> UserProfile {
        let url = URL(string: "\(baseURL)/profile")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let profileResponse = try decoder.decode(ProfileResponse.self, from: data)
        
        guard let profile = profileResponse.profile else {
            throw APIError.invalidResponse
        }
        
        return profile
    }
    
    // MARK: - Public Events APIs
    
    func getPublicEvents(filter: PublicEventFilter? = nil, search: String? = nil) async throws -> [PublicEvent] {
        var components = URLComponents(string: "\(baseURL)/public-events")!
        var queryItems: [URLQueryItem] = []
        
        if let search = search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        if let filter = filter {
            switch filter {
            case .featured:
                queryItems.append(URLQueryItem(name: "isFeatured", value: "true"))
            case .popular:
                queryItems.append(URLQueryItem(name: "sortBy", value: "registrationCount"))
            default:
                break
            }
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        let url = components.url!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let eventsResponse = try decoder.decode(PublicEventsResponse.self, from: data)
        
        return eventsResponse.events
    }
    
    func getPublicEvent(slug: String) async throws -> PublicEvent {
        let url = URL(string: "\(baseURL)/public-events/\(slug)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let eventResponse = try decoder.decode(PublicEventDetailResponse.self, from: data)
        
        return eventResponse.event
    }
    
    func createPublicEvent(_ request: CreatePublicEventRequest) async throws -> PublicEvent {
        let url = URL(string: "\(baseURL)/public-events")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorData = try? JSONDecoder().decode([String: String].self, from: data)
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let eventResponse = try decoder.decode(CreateEventResponse.self, from: data)
        
        return eventResponse.event
    }
    
    func updatePublicEvent(slug: String, updates: [String: Any]) async throws -> PublicEvent {
        let url = URL(string: "\(baseURL)/public-events/\(slug)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: updates)
        urlRequest.httpBody = jsonData
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let eventResponse = try decoder.decode(UpdateEventResponse.self, from: data)
        
        return eventResponse.event
    }
    
    func publishEvent(slug: String) async throws -> PublicEvent {
        return try await updatePublicEvent(slug: slug, updates: ["status": "PUBLISHED"])
    }
    
    func unpublishEvent(slug: String) async throws -> PublicEvent {
        return try await updatePublicEvent(slug: slug, updates: ["status": "DRAFT"])
    }
    
    func toggleFeatured(slug: String, isFeatured: Bool) async throws -> PublicEvent {
        return try await updatePublicEvent(slug: slug, updates: ["isFeatured": isFeatured])
    }
    
    func deletePublicEvent(slug: String) async throws {
        let url = URL(string: "\(baseURL)/public-events/\(slug)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Registration APIs
    
    func registerForEvent(slug: String, request: RegisterForEventRequest) async throws -> EventRegistration {
        let url = URL(string: "\(baseURL)/public-events/\(slug)/register")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.registrationError(errorData?.error ?? "Failed to register")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let registrationResponse = try decoder.decode(RegistrationResponse.self, from: data)
        
        return registrationResponse.registration
    }
    
    func cancelRegistration(slug: String) async throws {
        let url = URL(string: "\(baseURL)/public-events/\(slug)/register")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    func getMyRegistrations() async throws -> [EventRegistration] {
        let url = URL(string: "\(baseURL)/profile/registrations")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        struct RegistrationsResponse: Codable {
            let registrations: [EventRegistration]
        }
        
        let registrationsResponse = try decoder.decode(RegistrationsResponse.self, from: data)
        return registrationsResponse.registrations
    }
    
    // MARK: - Discovery APIs
    
    func getDiscoverEvents(filter: PublicEventFilter? = nil) async throws -> [PublicEvent] {
        var components = URLComponents(string: "\(baseURL)/discover")!
        var queryItems: [URLQueryItem] = []
        
        if let filter = filter {
            switch filter {
            case .popular:
                queryItems.append(URLQueryItem(name: "eventType", value: "popular"))
            case .featured:
                queryItems.append(URLQueryItem(name: "eventType", value: "featured"))
            default:
                break
            }
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        let url = components.url!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        struct DiscoverResponse: Codable {
            let success: Bool
            let events: [PublicEvent]
        }
        
        let discoverResponse = try decoder.decode(DiscoverResponse.self, from: data)
        return discoverResponse.events
    }
}

// MARK: - Error Types

enum APIError: Error, LocalizedError {
    case invalidResponse
    case serverError(Int)
    case registrationError(String)
    case profileRequired
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .registrationError(let message):
            return message
        case .profileRequired:
            return "Please create a profile first"
        }
    }
}

struct ErrorResponse: Codable {
    let error: String
    let details: [String]?
}

