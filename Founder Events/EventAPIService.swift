import Foundation

// URLSessionDelegate to handle self-signed SSL certificates
class SelfSignedCertDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Accept self-signed certificates for your server
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Check if the host matches our API server
        let host = challenge.protectionSpace.host
        if host == "167.172.135.1" {
            // Accept the self-signed certificate for our API server
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // For other hosts, use default handling
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

class EventAPIService {
    static let shared = EventAPIService()
    
    // HTTPS endpoint with self-signed certificate
    private let baseURL = "https://167.172.135.1:5443/api"
    
    // Keep a strong reference to the delegate to prevent deallocation
    private let certDelegate = SelfSignedCertDelegate()
    
    // Custom URLSession that accepts self-signed certificates
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: certDelegate, delegateQueue: nil)
    }()
    
    func fetchEvents() async throws -> [EventDTO] {
        guard let url = URL(string: "\(baseURL)/events") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let apiResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
        return apiResponse.events
    }
    
    func fetchTodayEvents() async throws -> [EventDTO] {
        guard let url = URL(string: "\(baseURL)/events/today") else {
            print("❌ Invalid URL: \(baseURL)/events/today")
            throw APIError.invalidURL
        }
        
        print("🌐 Fetching events from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw APIError.invalidResponse
            }
            
            print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: Status code \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("📄 Error response: \(errorString)")
                }
                throw APIError.invalidResponse
            }
            
            // Debug: Print raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 API Response (first 1000 chars): \(String(jsonString.prefix(1000)))")
            } else {
                print("❌ Failed to convert response data to string")
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
                print("✅ Successfully decoded \(apiResponse.events.count) events from wrapped response")
                return apiResponse.events
            } catch let decodeError {
                print("❌ Decoding error: \(decodeError)")
                print("   Error details: \(decodeError.localizedDescription)")
                
                // Try to decode as direct array if wrapped response fails
                if let events = try? JSONDecoder().decode([EventDTO].self, from: data) {
                    print("✅ Decoded as direct array, found \(events.count) events")
                    return events
                }
                
                // Print the actual JSON structure for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Full JSON response: \(jsonString)")
                }
                
                throw APIError.decodingError
            }
        } catch let urlError {
            print("❌ Network error: \(urlError)")
            print("   Error details: \(urlError.localizedDescription)")
            if let nsError = urlError as NSError? {
                print("   Error domain: \(nsError.domain)")
                print("   Error code: \(nsError.code)")
                print("   Error userInfo: \(nsError.userInfo)")
            }
            throw urlError
        }
    }
    
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case decodingError
    }
}

struct EventsResponse: Decodable {
    let success: Bool?
    let count: Int?
    let lastUpdated: String?
    let events: [EventDTO]
    
    // Handle cases where API might return events directly as an array
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode optional fields
        success = try? container.decode(Bool.self, forKey: .success)
        count = try? container.decode(Int.self, forKey: .count)
        
        // Handle both snake_case and camelCase for lastUpdated
        if let lastUpdatedSnake = try? container.decode(String.self, forKey: .lastUpdatedSnake) {
            lastUpdated = lastUpdatedSnake
        } else {
            lastUpdated = try? container.decode(String.self, forKey: .lastUpdated)
        }
        
        // Events are required
        events = try container.decode([EventDTO].self, forKey: .events)
    }
    
    enum CodingKeys: String, CodingKey {
        case success
        case count
        case lastUpdated
        case lastUpdatedSnake = "last_updated"
        case events
    }
}

struct EventDTO: Codable {
    let id: String
    let link: String
    let title: String
    let time: String
    let address: String
    let notes: String
    let date: String
    let source: String
    
    // Handle empty fields and provide defaults
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        link = try container.decode(String.self, forKey: .link)
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        time = (try? container.decode(String.self, forKey: .time)) ?? ""
        address = (try? container.decode(String.self, forKey: .address)) ?? ""
        notes = (try? container.decode(String.self, forKey: .notes)) ?? ""
        date = try container.decode(String.self, forKey: .date)
        source = (try? container.decode(String.self, forKey: .source)) ?? "scraper"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, link, title, time, address, notes, date, source
    }
}

