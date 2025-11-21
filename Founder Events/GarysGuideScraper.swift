import Foundation
import SwiftUI
import EventKit // Added for calendar functionality

// MARK: - Gary's Guide Web Scraper
class GarysGuideScraper: ObservableObject {
    @Published var events: [GarysGuideEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func fetchEvents(limit: Int? = nil, completion: (([GarysGuideEvent]) -> Void)? = nil) {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Fetching events from Gary's Guide...")
        print("🌐 URL: \(garysGuideURL)")
        
        // First, let's test if we can reach the website at all
        testConnection { [weak self] canReach in
            if !canReach {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Cannot reach Gary's Guide. Please check your internet connection."
                    self?.events = []
                }
                completion?([])
                return
            }
            
            // If we can reach it, proceed with the actual request
            self?.performActualRequest(limit: limit, completion: completion)
        }
    }
    
    private func testConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.garysguide.com") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.httpMethod = "HEAD" // Just check if we can reach the site
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Connection test failed: \(error.localizedDescription)")
                completion(false)
            } else if let httpResponse = response as? HTTPURLResponse {
                print("✅ Connection test successful: \(httpResponse.statusCode)")
                completion(true)
            } else {
                print("❌ Connection test failed: No response")
                completion(false)
            }
        }
        
        task.resume()
    }
    
    private func performActualRequest(limit: Int?, completion: (([GarysGuideEvent]) -> Void)?) {
        
        guard let url = URL(string: garysGuideURL) else {
            print("❌ Invalid URL")
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        // Create a URL request with timeout and proper headers
        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0 // 15 second timeout
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self?.isLoading = false
                    
                    // Provide more specific error messages for different network issues
                    let specificErrorMessage: String
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            specificErrorMessage = "No internet connection. Please check your WiFi or cellular data."
                        case .timedOut:
                            specificErrorMessage = "Connection timed out. Please try again."
                        case .cannotFindHost:
                            specificErrorMessage = "Cannot reach Gary's Guide. Please check your connection."
                        case .networkConnectionLost:
                            specificErrorMessage = "Network connection lost. Please try again."
                        default:
                            specificErrorMessage = "Network error: \(error.localizedDescription)"
                        }
                    } else {
                        specificErrorMessage = "Network error: \(error.localizedDescription)"
                    }
                    
                    self?.errorMessage = specificErrorMessage
                    self?.events = []
                    return
                }
                
                // Check HTTP response status
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Response Status: \(httpResponse.statusCode)")
                    print("📡 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    if httpResponse.statusCode != 200 {
                        print("❌ HTTP error: \(httpResponse.statusCode)")
                        self?.isLoading = false
                        
                        let statusMessage: String
                        switch httpResponse.statusCode {
                        case 403:
                            statusMessage = "Access denied by Gary's Guide. Please try again later."
                        case 404:
                            statusMessage = "Gary's Guide events page not found."
                        case 500...599:
                            statusMessage = "Gary's Guide server error. Please try again later."
                        default:
                            statusMessage = "Server error: \(httpResponse.statusCode)"
                        }
                        
                        self?.errorMessage = statusMessage
                        self?.events = []
                        return
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self?.isLoading = false
                    self?.errorMessage = "No data received"
                    self?.events = []
                    return
                }
                
                guard let htmlString = String(data: data, encoding: .utf8) else {
                    print("❌ Failed to decode HTML")
                    self?.isLoading = false
                    self?.errorMessage = "Failed to decode HTML"
                    self?.events = []
                    return
                }
                
                print("✅ Successfully fetched HTML from Gary's Guide")
                self?.parseEventsFromHTML(htmlString, limit: limit, completion: completion)
            }
        }
        
        task.resume()
    }
    
    private func parseEventsFromHTML(_ html: String, limit: Int?, completion: (([GarysGuideEvent]) -> Void)?) {
        print("🔍 Parsing events from HTML...")
        
        // Debug: Print a sample of the HTML to see the structure
        let sampleHTML = String(html.prefix(2000))
        print("📄 Sample HTML structure:")
        print(sampleHTML)
        print("📄 End of sample HTML")
        
        var parsedEvents: [GarysGuideEvent] = []
        
        // Detect popular event URLs from dedicated section
        let popularEventURLs = extractPopularEventURLs(from: html)
        print("🔥 Identified \(popularEventURLs.count) events inside Popular/Featured sections")
        
        // Extract event titles from the URL path
        let titlePattern = #"alt='([^']+)' href='https://www\.garysguide\.com/events/[^']*"#
        let titleRegex = try? NSRegularExpression(pattern: titlePattern)
        let titleMatches = titleRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        // Extract event URLs
        let urlPattern = #"href='(https://www\.garysguide\.com/events/[^']*)'"#
        let urlRegex = try? NSRegularExpression(pattern: urlPattern)
        let urlMatches = urlRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        // Extract dates - look for dates in <b> tags (try multiple patterns)
        var dateMatches: [NSTextCheckingResult] = []
        
        // Pattern 1: Standard date in <b> tags
        let datePattern1 = #"<b>(\w{3}\s+\d{1,2})</b>"#
        if let dateRegex1 = try? NSRegularExpression(pattern: datePattern1) {
            dateMatches = dateRegex1.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        }
        
        // Pattern 2: Date with possible extra spaces
        if dateMatches.isEmpty {
            let datePattern2 = #"<b>\s*(\w{3}\s+\d{1,2})\s*</b>"#
            if let dateRegex2 = try? NSRegularExpression(pattern: datePattern2) {
                dateMatches = dateRegex2.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        // Pattern 3: Date in different HTML structure
        if dateMatches.isEmpty {
            let datePattern3 = #"(\w{3}\s+\d{1,2})"#
            if let dateRegex3 = try? NSRegularExpression(pattern: datePattern3) {
                dateMatches = dateRegex3.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        print("📅 Date extraction - Found \(dateMatches.count) date matches")
        for (index, match) in dateMatches.enumerated() {
            let dateString = extractString(from: html, range: match.range(at: 1))
            print("📅 Date \(index + 1): '\(dateString)'")
        }
        
        // Extract times - look for times after <br/> (try multiple patterns)
        var timeMatches: [NSTextCheckingResult] = []
        
        // Pattern 1: Standard time after <br/>
        let timePattern1 = #"<br/>(\d{1,2}:\d{2}[ap]m)"#
        if let timeRegex1 = try? NSRegularExpression(pattern: timePattern1) {
            timeMatches = timeRegex1.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        }
        
        // Pattern 2: Time with possible extra spaces
        if timeMatches.isEmpty {
            let timePattern2 = #"<br/>\s*(\d{1,2}:\d{2}[ap]m)\s*"#
            if let timeRegex2 = try? NSRegularExpression(pattern: timePattern2) {
                timeMatches = timeRegex2.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        // Pattern 3: Time in different format (24-hour)
        if timeMatches.isEmpty {
            let timePattern3 = #"<br/>(\d{1,2}:\d{2})"#
            if let timeRegex3 = try? NSRegularExpression(pattern: timePattern3) {
                timeMatches = timeRegex3.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        print("⏰ Time extraction - Found \(timeMatches.count) time matches")
        for (index, match) in timeMatches.enumerated() {
            let timeString = extractString(from: html, range: match.range(at: 1))
            print("⏰ Time \(index + 1): '\(timeString)'")
        }
        
        // Extract venues (try multiple patterns for different HTML structures)
        var venueMatches: [NSTextCheckingResult] = []
        
        // Pattern 1: Standard fdescription pattern
        let venuePattern1 = #"<font class='fdescription'>\s*<br/><b>([^<]+)</b>([^<]*)</font>"#
        if let venueRegex1 = try? NSRegularExpression(pattern: venuePattern1) {
            venueMatches = venueRegex1.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        }
        
        // Pattern 2: Alternative venue pattern
        if venueMatches.isEmpty {
            let venuePattern2 = #"<font[^>]*class='fdescription'[^>]*>\s*<br/><b>([^<]+)</b>([^<]*)</font>"#
            if let venueRegex2 = try? NSRegularExpression(pattern: venuePattern2) {
                venueMatches = venueRegex2.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        // Pattern 3: Generic venue pattern
        if venueMatches.isEmpty {
            let venuePattern3 = #"<b>([^<]+)</b>,\s*([^<]+)</font>"#
            if let venueRegex3 = try? NSRegularExpression(pattern: venuePattern3) {
                venueMatches = venueRegex3.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        // Pattern 4: Look for any bold text followed by comma and address
        if venueMatches.isEmpty {
            let venuePattern4 = #"<b>([^<]+)</b>,\s*([^<]+?)(?:</font>|<br/>)"#
            if let venueRegex4 = try? NSRegularExpression(pattern: venuePattern4) {
                venueMatches = venueRegex4.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
            }
        }
        
        print("🏢 Venue extraction - Total matches: \(venueMatches.count)")
        if venueMatches.isEmpty {
            print("🏢 No venue patterns matched - will use 'Venue TBD'")
        }
        
        // Extract speakers (look for "With" text)
        let speakerPattern = #"With\s+([^<]+)</font>"#
        let speakerRegex = try? NSRegularExpression(pattern: speakerPattern)
        let speakerMatches = speakerRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        // Extract prices (look for "Free" or "$" amounts)
        let pricePattern = #"(Free|\$\d+)"#
        let priceRegex = try? NSRegularExpression(pattern: pricePattern)
        let priceMatches = priceRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        // Create events by combining extracted data
        let minCount = min(titleMatches.count, dateMatches.count, timeMatches.count, urlMatches.count)
        
        print("📊 Found \(minCount) events to process")
        print("🏢 Found \(venueMatches.count) venue matches")
        print("🎤 Found \(speakerMatches.count) speaker matches")
        print("💰 Found \(priceMatches.count) price matches")
        
        // Process all events at once with a single DispatchGroup
        let group = DispatchGroup()
        var allEvents: [GarysGuideEvent] = []
        
        print("🔄 Processing \(minCount) events...")
        
        let cappedCount = limit.map { min($0, minCount) } ?? minCount
        
        for i in 0..<cappedCount {
            group.enter()
            
            let urlTitle = extractString(from: html, range: titleMatches[i].range(at: 1))
            let title = formatTitle(from: urlTitle)
            let date = extractString(from: html, range: dateMatches[i].range(at: 1))
            let time = extractString(from: html, range: timeMatches[i].range(at: 1))
            let eventUrl = extractString(from: html, range: urlMatches[i].range(at: 1))
            let normalizedEventUrl = GarysGuideScraper.normalizeEventURL(eventUrl)
            
            // Debug: Print extracted date and time
            print("🔍 Extracted - Date: '\(date)', Time: '\(time)' for event: \(title)")
            
            // Get venue if available
            var venue = "Venue TBD"
            if i < venueMatches.count {
                let venueName = extractString(from: html, range: venueMatches[i].range(at: 1))
                let venueAddress = extractString(from: html, range: venueMatches[i].range(at: 2))
                venue = venueName + venueAddress
                print("🏢 Extracted venue: '\(venue)' for event: \(title)")
            } else {
                print("⚠️ No venue found for event: \(title)")
            }
            
            // Get speakers if available
            var speakers = ""
            if i < speakerMatches.count {
                speakers = "With " + extractString(from: html, range: speakerMatches[i].range(at: 1))
            }
            
            // Get price if available
            var price = "Free"
            if i < priceMatches.count {
                price = extractString(from: html, range: priceMatches[i].range(at: 1))
            }
            
            // Determine week based on date
            let week = determineWeek(from: date)
            
            // Check if this event lives inside the Popular Events section or has badges
            var isPopularEvent = popularEventURLs.contains(normalizedEventUrl)
            
            if !isPopularEvent {
                isPopularEvent = checkIfPopularEvent(title: title, html: html, eventIndex: i)
            }
            
            // Create event with original URL first, then try to get redirect
                let event = GarysGuideEvent(
                title: title,
                date: date,
                time: time,
                price: price,
                venue: venue,
                speakers: speakers,
                url: eventUrl, // Use original Gary's Guide URL as fallback
                isGaryEvent: false,
                    isPopularEvent: isPopularEvent,
                week: week
            )
            
            allEvents.append(event)
            
            // Try to fetch redirect URL and update the event if found
            fetchRedirectURL(from: eventUrl) { [weak self] redirectUrl in
                if let redirectUrl = redirectUrl,
                   let eventIndex = allEvents.firstIndex(where: { $0.title == title && $0.date == date }) {
                    
                    // Update the specific event with the redirect URL
                    let updatedEvent = GarysGuideEvent(
                        title: allEvents[eventIndex].title,
                        date: allEvents[eventIndex].date,
                        time: allEvents[eventIndex].time,
                        price: allEvents[eventIndex].price,
                        venue: allEvents[eventIndex].venue,
                        speakers: allEvents[eventIndex].speakers,
                        url: redirectUrl, // Use the redirect URL
                        isGaryEvent: allEvents[eventIndex].isGaryEvent,
                        isPopularEvent: allEvents[eventIndex].isPopularEvent,
                        week: allEvents[eventIndex].week
                    )
                    
                    allEvents[eventIndex] = updatedEvent
                    print("✅ Updated '\(title)' with redirect URL: \(redirectUrl)")
                } else {
                    print("⚠️ No redirect found for '\(title)', using original URL")
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            // All events processed, sort chronologically and update the UI
            if allEvents.isEmpty {
                print("❌ Failed to parse events from Gary's Guide")
                self?.events = []
            } else {
                // Sort events chronologically
                let sortedEvents = allEvents.sorted { event1, event2 in
                    // Parse dates for comparison
                    let date1 = self?.parseDateForSorting(event1.date) ?? Date()
                    let date2 = self?.parseDateForSorting(event2.date) ?? Date()
                    
                    if date1 == date2 {
                        // If same date, sort by time - convert times to comparable values
                        let time1 = self?.parseTimeForSorting(event1.time) ?? Date()
                        let time2 = self?.parseTimeForSorting(event2.time) ?? Date()
                        return time1 < time2
                    }
                    return date1 < date2
                }
                
                // Filter out events with invalid dates or past dates
                let currentDate = Date()
                let calendar = Calendar.current
                let startOfToday = calendar.startOfDay(for: currentDate)
                
                let validEvents = sortedEvents.filter { event in
                    let eventDate = self?.parseDateForSorting(event.date) ?? Date()
                    return eventDate >= startOfToday
                }
                
                print("✅ Successfully parsed \(validEvents.count) real events from Gary's Guide")
                self?.events = validEvents
                completion?(validEvents)
            }
            self?.isLoading = false
        }
    }
    
    func fetchPopularEventURLs(completion: @escaping (Set<String>) -> Void) {
        guard let url = URL(string: garysGuideURL) else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard error == nil,
                  let data = data,
                  let html = String(data: data, encoding: .utf8),
                  let self = self else {
                completion([])
                return
            }
            
            let urls = self.extractPopularEventURLs(from: html)
            completion(urls)
        }
        
        task.resume()
    }
    
    private func fetchRedirectURL(from eventUrl: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: eventUrl) else {
            completion(nil)
            return
        }
        
        // Create a URL request with timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0 // 10 second timeout for redirect URLs
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                // Look for redirect URLs (gary.to links)
                let redirectPattern = #"href="(http://gary\.to/[^"]*)"#
                let redirectRegex = try? NSRegularExpression(pattern: redirectPattern, options: [.caseInsensitive])
                let redirectMatches = redirectRegex?.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) ?? []
                
                if let firstMatch = redirectMatches.first {
                    let redirectUrl = self?.extractString(from: htmlString, range: firstMatch.range(at: 1)) ?? ""
                    print("  ✅ Found redirect: \(redirectUrl) for event: \(eventUrl)")
                    completion(redirectUrl)
                } else {
                    // Look for external registration links
                    let registrationPattern = #"href="(https://[^"]*(eventbrite|meetup|ticketmaster|brownpapertickets|eventful|calendly|zoom|teams|register|rsvp)[^"]*)"#
                    let registrationRegex = try? NSRegularExpression(pattern: registrationPattern, options: [.caseInsensitive])
                    let registrationMatches = registrationRegex?.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) ?? []
                    
                    if let firstMatch = registrationMatches.first {
                        let registrationUrl = self?.extractString(from: htmlString, range: firstMatch.range(at: 1)) ?? ""
                        print("  ✅ Found registration: \(registrationUrl) for event: \(eventUrl)")
                        completion(registrationUrl)
                    } else {
                        print("  ⚠️ No redirect/registration found for event: \(eventUrl)")
                        completion(nil)
                    }
                }
            } else {
                print("  ❌ Failed to fetch detail page: \(eventUrl)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    private func validateEventURL(_ url: String, title: String) -> String {
        // Validate that the URL makes sense for this event
        print("🔍 Validating URL '\(url)' for event '\(title)'")
        
        // If it's a gary.to redirect, it should be valid
        if url.contains("gary.to/") {
            print("✅ Valid gary.to redirect URL")
            return url
        }
        
        // If it's a Gary's Guide event page, check if it matches the title
        if url.contains("garysguide.com/events/") {
            // Extract the event slug from the URL
            if let urlComponents = URLComponents(string: url) {
                let pathComponents = urlComponents.path.components(separatedBy: "/")
                if pathComponents.count >= 3 {
                    let eventSlug = pathComponents[2]
                    let titleSlug = title.lowercased()
                        .replacingOccurrences(of: " ", with: "-")
                        .replacingOccurrences(of: "&", with: "")
                        .replacingOccurrences(of: ":", with: "")
                        .replacingOccurrences(of: "'", with: "")
                        .replacingOccurrences(of: ".", with: "")
                    
                    // Check if the URL slug is related to the title
                    if eventSlug.contains(titleSlug.prefix(10)) || titleSlug.contains(eventSlug.prefix(10)) {
                        print("✅ URL matches event title")
                        return url
                    } else {
                        print("⚠️ URL slug '\(eventSlug)' doesn't match title '\(titleSlug)'")
                    }
                }
            }
        }
        
        // For other URLs (eventbrite, meetup, etc.), trust them
        if url.contains("eventbrite.com") || url.contains("meetup.com") || url.contains("calendly.com") {
            print("✅ Valid external registration URL")
            return url
        }
        
        print("⚠️ Using URL as-is: \(url)")
        return url
    }
    
    private func extractString(from html: String, range: NSRange) -> String {
        guard range.location != NSNotFound,
              let swiftRange = Range(range, in: html) else {
            return ""
        }
        return String(html[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func formatTitle(from urlTitle: String) -> String {
        // Convert URL title like "Startup-Luncheon" to "Startup Luncheon"
        return urlTitle.replacingOccurrences(of: "-", with: " ")
    }
    
    private func determineWeek(from date: String) -> String {
        // Simple logic to determine week based on date
        if date.contains("Aug 07") || date.contains("Aug 08") || date.contains("Aug 09") || date.contains("Aug 10") {
            return "AUG 04"
        } else if date.contains("Aug 11") || date.contains("Aug 12") || date.contains("Aug 13") || date.contains("Aug 14") {
            return "AUG 11"
        } else {
            return "AUG 04" // Default
        }
    }
    
    private func parseDateForSorting(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())
        let fullDateString = "\(dateString) \(currentYear)"
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM dd yyyy"
        fullDateFormatter.locale = Locale(identifier: "en_US")
        
        return fullDateFormatter.date(from: fullDateString) ?? Date()
    }
    
    private func parseTimeForSorting(_ timeString: String) -> Date {
        // Try different time formats
        let timeFormats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        
        for format in timeFormats {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = format
            timeFormatter.locale = Locale(identifier: "en_US")
            
            if let parsedTime = timeFormatter.date(from: timeString) {
                return parsedTime
            }
        }
        
        // If all parsing fails, return a default date
        return Date()
    }
    
    // MARK: - Event Registration Helper
    class EventRegistrationHelper {
        static func openEventRegistration(for event: GarysGuideEvent) {
            // Try to open the registration URL
            if let url = URL(string: event.url) {
                // Open in Safari
                UIApplication.shared.open(url)
            } else {
                // Fallback to Gary's Guide if URL is invalid
                if let fallbackUrl = URL(string: "https://www.garysguide.com") {
                    UIApplication.shared.open(fallbackUrl)
                }
            }
        }
        
        static func openEventInWebView(for event: GarysGuideEvent) -> URL {
            // Return the registration URL for web view
            return URL(string: event.url) ?? URL(string: "https://www.garysguide.com")!
        }
        
        // Helper to check if URL is a registration link
        static func isRegistrationURL(_ url: String) -> Bool {
            let registrationKeywords = [
                "eventbrite", "meetup", "ticketmaster", "brownpapertickets",
                "eventful", "calendly", "zoom", "teams", "register", "rsvp",
                "signup", "join", "attend", "book", "buy", "ticket", "gary.to"
            ]
            
            let lowercasedURL = url.lowercased()
            return registrationKeywords.contains { keyword in
                lowercasedURL.contains(keyword)
            }
        }
        
        // Helper to get the appropriate button text for a URL
        static func getButtonText(for url: String) -> String {
            if isRegistrationURL(url) {
                return "Register"
            } else if url.contains("garysguide.com/events") {
                return "View Details"
            } else {
                return "View Details"
            }
        }
        
        // MARK: - App Calendar Functions
        
        static func addEventToAppCalendar(event: GarysGuideEvent, appState: AppState, completion: @escaping (Bool, String?) -> Void) {
            print("🎯 addEventToAppCalendar called for event: \(event.title)")
            print("📅 Original date: '\(event.date)', time: '\(event.time)'")
            
            // Parse the date and time
            let eventDate = parseEventDateTime(date: event.date, time: event.time)
            
            guard let startDate = eventDate else {
                print("❌ Failed to parse event date and time")
                completion(false, "Could not parse event date and time")
                return
            }
            
            print("✅ Parsed start date: \(startDate)")
            
            // Create end date (1 hour duration)
            let endDate = startDate.addingTimeInterval(3600)
            print("✅ End date: \(endDate)")
            
            // Create calendar event for the app
            let calendarEvent = CalendarEvent(
                title: event.title,
                startDate: startDate,
                endDate: endDate,
                location: event.venue,
                notes: "Event URL: \(event.url)\nSpeakers: \(event.speakers)\nPrice: \(event.price)"
            )
            
            print("📝 Created calendar event:")
            print("   Title: \(calendarEvent.title)")
            print("   Start: \(calendarEvent.startDate)")
            print("   End: \(calendarEvent.endDate)")
            print("   Location: \(calendarEvent.location ?? "No location")")
            
            // Check if event already exists
            let existingEvent = appState.events.first { existing in
                existing.title == event.title &&
                Calendar.current.isDate(existing.startDate, inSameDayAs: startDate)
            }
            
            if existingEvent != nil {
                completion(false, "Event already exists in your calendar")
            } else {
                // Add to app's calendar
                appState.addEvent(calendarEvent)
                completion(true, "Event added to your calendar successfully!")
            }
        }
        
        private static func parseEventDateTime(date: String, time: String) -> Date? {
            let normalizedTime = GarysGuideEvent.normalizeTime(time)
            print("🔍 parseEventDateTime called with date: '\(date)', time: '\(normalizedTime)'")
            
            // Get current year
            let currentYear = Calendar.current.component(.year, from: Date())
            let currentMonth = Calendar.current.component(.month, from: Date())
            
            // Create full date string with current year
            let fullDateString = "\(date) \(currentYear)"
            print("📅 Full date string: '\(fullDateString)'")
            
            // Parse the date with year
            let fullDateFormatter = DateFormatter()
            fullDateFormatter.dateFormat = "MMM dd yyyy"
            fullDateFormatter.locale = Locale(identifier: "en_US")
            
            guard let eventDate = fullDateFormatter.date(from: fullDateString) else {
                print("❌ Failed to parse date: \(fullDateString)")
                return nil
            }
            
            print("📅 Parsed event date: \(eventDate)")
            
            // Check if the event date is in the past (before today)
            let calendar = Calendar.current
            let today = Date()
            let eventMonth = calendar.component(.month, from: eventDate)
            let eventDay = calendar.component(.day, from: eventDate)
            
        // Always use current year - no events should be moved to next year
        let adjustedYear = currentYear
        print("✅ Using current year for event: \(currentYear)")
            
            // Recreate the date with the adjusted year
            let adjustedDateString = "\(date) \(adjustedYear)"
            print("📅 Adjusted date string: '\(adjustedDateString)'")
            
            guard let adjustedEventDate = fullDateFormatter.date(from: adjustedDateString) else {
                print("❌ Failed to parse adjusted date: \(adjustedDateString)")
                return nil
            }
            
            print("📅 Final event date: \(adjustedEventDate)")
            
            // Parse the time - try different formats
            let timeFormats = ["h:mm a", "HH:mm"]
            var parsedTimeComponents: DateComponents?
            
            for format in timeFormats {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = format
                timeFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                if let parsedTime = timeFormatter.date(from: normalizedTime) {
                    parsedTimeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                    print("⏰ Parsed time with format '\(format)': \(normalizedTime)")
                    break
                }
            }
            
            if parsedTimeComponents == nil {
                let upper = normalizedTime.uppercased()
                if upper == "TBD" || upper == "ALL DAY" || upper.isEmpty {
                    parsedTimeComponents = DateComponents(hour: 12, minute: 0)
                    print("⏰ Time unspecified, defaulting to 12:00 PM")
                } else if let match = normalizedTime.range(of: #"(\d{1,2}):(\d{2})\s*([AP]M)"#, options: .regularExpression) {
                    let matched = String(normalizedTime[match])
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h:mm a"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    if let parsedTime = formatter.date(from: matched) {
                        parsedTimeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                        print("⏰ Parsed time via regex fallback: \(matched)")
                    }
                }
            }
            
            guard let timeComponents = parsedTimeComponents else {
                print("❌ Failed to parse time: \(normalizedTime)")
                return nil
            }
            
            // Combine date and time
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: adjustedEventDate)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            
            // Set timezone to Eastern Time (Gary's Guide events are typically in NYC)
            combinedComponents.timeZone = TimeZone(identifier: "America/New_York")
            
            let finalDate = calendar.date(from: combinedComponents)
            print("🎯 Final combined date: \(finalDate?.description ?? "nil")")
            
            return finalDate
        }
    }
    
    // MARK: - Popular Event Detection
    private func checkIfPopularEvent(title: String, html: String, eventIndex: Int) -> Bool {
        // Look for specific popular event indicators around this event
        // Common indicators: "Popular Event", "Featured", "Trending", "Hot", etc.
        
        // Create a search pattern around the event title
        let titlePattern = title.replacingOccurrences(of: " ", with: "\\s+")
        let searchPattern = "\(titlePattern).*?(Popular Event|Featured|Trending|Hot|🔥|⭐)"
        
        do {
            let regex = try NSRegularExpression(pattern: searchPattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSRange(location: 0, length: html.utf16.count)
            let matches = regex.matches(in: html, options: [], range: range)
            
            if !matches.isEmpty {
                print("🔥 Found popular event indicator for: \(title)")
                return true
            }
        } catch {
            print("⚠️ Error checking popular event status for \(title): \(error)")
        }
        
        // Also check for specific HTML patterns that indicate popular events
        let popularPatterns = [
            "Popular Event",
            "Featured Event", 
            "Trending",
            "Hot Event",
            "🔥",
            "⭐",
            "class=\"popular\"",
            "class=\"featured\""
        ]
        
        // Look for these patterns in a reasonable range around the event title
        if let titleRange = html.range(of: title) {
            let startIndex = html.index(titleRange.lowerBound, offsetBy: -500, limitedBy: html.startIndex) ?? html.startIndex
            let endIndex = html.index(titleRange.upperBound, offsetBy: 500, limitedBy: html.endIndex) ?? html.endIndex
            let searchRange = html[startIndex..<endIndex]
            
            for pattern in popularPatterns {
                if searchRange.contains(pattern) {
                    print("🔥 Found popular event pattern '\(pattern)' for: \(title)")
                    return true
                }
            }
        }
        
        // Default: not a popular event
        return false
    }
    
    private func extractPopularEventURLs(from html: String) -> Set<String> {
        var urls = Set<String>()
        
        let pattern = #"<font[^>]*class=['"]fboxtitle['"][^>]*>(?:POPULAR|FEATURED|HOT)\s+EVENTS?</font>(.*?)<font[^>]*class=['"]fboxtitle"# // capture block between section headers
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) {
            let range = NSRange(location: 0, length: html.utf16.count)
            if let match = regex.firstMatch(in: html, options: [], range: range), match.numberOfRanges > 1 {
                let block = self.extractString(from: html, range: match.range(at: 1))
                let eventPattern = #"href=['"](https://www\.garysguide\.com/events/[^'"]+)['"]"#
                if let eventRegex = try? NSRegularExpression(pattern: eventPattern, options: []) {
                    let blockRange = NSRange(location: 0, length: block.utf16.count)
                    let matches = eventRegex.matches(in: block, options: [], range: blockRange)
                    for m in matches {
                        let url = self.extractString(from: block, range: m.range(at: 1))
                        urls.insert(GarysGuideScraper.normalizeEventURL(url))
                    }
                }
            }
        }
        
        return urls
    }
    
    static func normalizeEventURL(_ url: String) -> String {
        guard var components = URLComponents(string: url) else { return url }
        components.query = nil
        components.fragment = nil
        return components.string ?? url
    }
}
