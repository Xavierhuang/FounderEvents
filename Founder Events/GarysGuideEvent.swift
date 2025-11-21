import Foundation
import SwiftUI
import Combine

// MARK: - Founder Events Event Model
struct GarysGuideEvent: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let date: String
    let time: String
    let price: String
    let venue: String
    let speakers: String
    let url: String
    let isGaryEvent: Bool
    let isPopularEvent: Bool
    let week: String
    
    // Initialize from EventDTO
    init(from dto: EventDTO) {
        self.id = dto.id
        
        // Generate title from URL if empty
        if dto.title.isEmpty {
            self.title = Self.extractTitleFromURL(dto.link)
        } else {
            self.title = dto.title
        }
        
        // Format date from ISO format (2025-11-17) to readable format (Nov 17)
        self.date = Self.formatDate(dto.date)
        
        self.time = Self.normalizeTime(dto.time)
        self.price = "Free" // Default, can be extracted from notes if needed
        self.venue = dto.address.isEmpty ? "Location TBD" : dto.address
        self.speakers = "" // Can be extracted from notes if needed
        self.url = dto.link
        self.isGaryEvent = false
        self.isPopularEvent = false
        self.week = Self.calculateWeek(from: dto.date)
    }
    
    // Helper to extract title from URL
    private static func extractTitleFromURL(_ urlString: String) -> String {
        guard let url = URL(string: urlString) else {
            return "Event"
        }
        
        // Try to get title from URL path
        let pathComponents = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        
        if let lastComponent = pathComponents.last {
            // Clean up the component
            var title = lastComponent
                .replacingOccurrences(of: "-", with: " ")
                .replacingOccurrences(of: "_", with: " ")
            
            // Capitalize words
            title = title.capitalized
            
            // If it's too short or generic, try the domain
            if title.count < 5 {
                if let host = url.host {
                    title = host.replacingOccurrences(of: "www.", with: "").replacingOccurrences(of: ".com", with: "").capitalized + " Event"
                }
            }
            
            return title.isEmpty ? "Event" : title
        }
        
        // Fallback to domain name
        if let host = url.host {
            return host.replacingOccurrences(of: "www.", with: "").replacingOccurrences(of: ".com", with: "").capitalized + " Event"
        }
        
        return "Event"
    }
    
    // Helper to format date from ISO format
    private static func formatDate(_ isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: isoDate) else {
            return isoDate // Return original if parsing fails
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
    
    // Helper to calculate week from date
    private static func calculateWeek(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: dateString) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date).uppercased()
    }
    
    static func normalizeTime(_ rawTime: String) -> String {
        var value = rawTime.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return "TBD" }
        
        let separators = ["–", "—", "-", " to ", " TO ", "–", "—", " until ", "|"]
        for separator in separators {
            if let range = value.range(of: separator) {
                value = String(value[..<range.lowerBound])
                break
            }
        }
        
        value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return "TBD" }
        
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "h:mm a"
        
        let dateFormats = [
            "MMM dd, yyyy h:mm a",
            "MMM d, yyyy h:mm a",
            "MMM dd yyyy h:mm a",
            "MMM d yyyy h:mm a",
            "M/d/yyyy h:mm a",
            "yyyy-MM-dd h:mm a"
        ]
        
        for format in dateFormats {
            parser.dateFormat = format
            if let date = parser.date(from: value) {
                return output.string(from: date)
            }
        }
        
        let compact = value.replacingOccurrences(of: " ", with: "").uppercased()
        parser.dateFormat = "h:mma"
        if let date = parser.date(from: compact) {
            return output.string(from: date)
        }
        
        if let regex = try? NSRegularExpression(pattern: #"(\d{1,2}:\d{2})\s*([APap][mM])"#, options: []) {
            let range = NSRange(location: 0, length: value.utf16.count)
            if let match = regex.firstMatch(in: value, options: [], range: range),
               let timeRange = Range(match.range(at: 1), in: value),
               let ampmRange = Range(match.range(at: 2), in: value) {
                let timePart = String(value[timeRange])
                let ampmPart = String(value[ampmRange]).uppercased()
                return "\(timePart) \(ampmPart)"
            }
        }
        
        return value
    }
    
    // Original initializer for compatibility
    init(id: String = UUID().uuidString, title: String, date: String, time: String, price: String, venue: String, speakers: String, url: String, isGaryEvent: Bool, isPopularEvent: Bool, week: String) {
        self.id = id
        self.title = title
        self.date = date
        self.time = GarysGuideEvent.normalizeTime(time)
        self.price = price
        self.venue = venue
        self.speakers = speakers
        self.url = url
        self.isGaryEvent = isGaryEvent
        self.isPopularEvent = isPopularEvent
        self.week = week
    }
    
    
    // Computed properties for display
    var displayDate: String {
        if time.isEmpty || time == "TBD" {
            return date
        } else {
            return "\(date) • \(time)"
        }
    }
    
    var displayPrice: String {
        return price == "Free" ? "FREE" : price
    }
    
    var displayVenue: String {
        return venue == "TBD" ? "Venue TBD" : venue
    }
    
    var hasSpeakers: Bool {
        return !speakers.isEmpty
    }
    
    var eventType: String {
        if isPopularEvent {
            return "Popular Event"
        } else {
            return "Regular Event"
        }
    }
    
    var eventTypeColor: Color {
        if isPopularEvent {
            return .blue
        } else {
            return .gray
        }
    }
    
    func withPopularFlag(_ flag: Bool) -> GarysGuideEvent {
        return GarysGuideEvent(
            id: id,
            title: title,
            date: date,
            time: time,
            price: price,
            venue: venue,
            speakers: speakers,
            url: url,
            isGaryEvent: isGaryEvent,
            isPopularEvent: flag,
            week: week
        )
    }
}

// MARK: - Founder Events Service
class GarysGuideService: ObservableObject {
    @Published var events: [GarysGuideEvent] = []
    @Published var popularEvents: [GarysGuideEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFetchingPopular = false
    
    private let popularScraper = GarysGuideScraper()
    
    init() {
        loadEvents()
    }
    
    func loadEvents() {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Loading events from Founder Events API...")
        
        Task {
            do {
                let eventDTOs = try await EventAPIService.shared.fetchTodayEvents()
                
                await MainActor.run {
                    self.events = eventDTOs.map { GarysGuideEvent(from: $0) }
                    self.isLoading = false
                    self.errorMessage = nil
                    print("✅ Loaded \(self.events.count) events from Founder Events API")
                }
                
                await MainActor.run {
                    self.loadPopularEventsFromScraper()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load events: \(error.localizedDescription)"
                    print("❌ Error loading events: \(error)")
                    
                    // Load fallback events on error
                    if self.events.isEmpty {
                        self.loadFallbackEvents()
                    }
                }
            }
        }
    }
    
    private func loadPopularEventsFromScraper() {
        print("🔥 Fetching dedicated Popular Events from Gary's Guide...")
        isFetchingPopular = true
        popularScraper.fetchEvents(limit: 50) { [weak self] scraped in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetchingPopular = false
                let popularList = scraped.prefix(50).map { $0.withPopularFlag(true) }
                self.popularEvents = Array(popularList)
                print("✅ Loaded \(self.popularEvents.count) popular events directly from Gary's Guide")
            }
        }
    }
    
    private func loadFallbackEvents() {
        print("🔄 Loading fallback events...")
        
        // Create current NYC tech events (updated for September 2024)
        let fallbackEvents = [
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "NYC AI Engineers: September Tech Talk",
                date: "Sep 18",
                time: "6:00 PM",
                price: "Free",
                venue: "WeWork Union Square",
                speakers: "With Arthur from Browser Company & Graphite team",
                url: "https://www.garysguide.com/events/nyc-ai-engineers-sept",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 18"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Startup Grind NYC: Fundraising 101",
                date: "Sep 19",
                time: "6:30 PM",
                price: "$25",
                venue: "Google NYC",
                speakers: "With VCs from Andreessen Horowitz and Union Square Ventures",
                url: "https://www.garysguide.com/events/startup-grind-fundraising",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 19"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Women in Tech NYC: Leadership Panel",
                date: "Sep 20",
                time: "7:00 PM",
                price: "Free",
                venue: "Flatiron Building",
                speakers: "With CTOs from Stripe, Airbnb, and MongoDB",
                url: "https://www.garysguide.com/events/women-in-tech-leadership",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 20"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Product Management Meetup",
                date: "Sep 21",
                time: "1:00 PM",
                price: "Free",
                venue: "TechHub NYC",
                speakers: "With PMs from Meta, Google, and Spotify",
                url: "https://www.garysguide.com/events/pm-meetup-sept",
                isGaryEvent: false,
                isPopularEvent: false,
                week: "SEP 21"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Blockchain & Web3 Summit",
                date: "Sep 22",
                time: "10:00 AM",
                price: "$50",
                venue: "Brooklyn Navy Yard",
                speakers: "With founders from Coinbase, OpenSea, and Polygon",
                url: "https://www.garysguide.com/events/blockchain-web3-summit",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 22"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "React NYC: Building Scalable Apps",
                date: "Sep 23",
                time: "6:00 PM",
                price: "Free",
                venue: "Microsoft NYC",
                speakers: "With React core team members and Netflix engineers",
                url: "https://www.garysguide.com/events/react-nyc-scalable-apps",
                isGaryEvent: false,
                isPopularEvent: false,
                week: "SEP 23"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "FinTech Innovation Night",
                date: "Sep 24",
                time: "6:30 PM",
                price: "$30",
                venue: "Goldman Sachs NYC",
                speakers: "With executives from Square, Robinhood, and Plaid",
                url: "https://www.garysguide.com/events/fintech-innovation-night",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 24"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "DevOps & Cloud Infrastructure Meetup",
                date: "Sep 25",
                time: "6:00 PM",
                price: "Free",
                venue: "AWS NYC Office",
                speakers: "With engineers from AWS, Docker, and Kubernetes",
                url: "https://www.garysguide.com/events/devops-cloud-meetup",
                isGaryEvent: false,
                isPopularEvent: false,
                week: "SEP 25"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Cybersecurity Summit NYC",
                date: "Sep 26",
                time: "9:00 AM",
                price: "$75",
                venue: "Javits Center",
                speakers: "With CISOs from major banks and tech companies",
                url: "https://www.garysguide.com/events/cybersecurity-summit-nyc",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 26"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Mobile Dev NYC: iOS 18 & Android 15",
                date: "Sep 27",
                time: "6:30 PM",
                price: "Free",
                venue: "Apple Store SoHo",
                speakers: "With mobile developers from Uber, Spotify, and TikTok",
                url: "https://www.garysguide.com/events/mobile-dev-nyc-sept",
                isGaryEvent: false,
                isPopularEvent: false,
                week: "SEP 27"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Data Science & Machine Learning Expo",
                date: "Sep 28",
                time: "10:00 AM",
                price: "$40",
                venue: "Columbia University",
                speakers: "With data scientists from Netflix, Spotify, and Palantir",
                url: "https://www.garysguide.com/events/data-science-ml-expo",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 28"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Startup Weekend NYC",
                date: "Sep 29",
                time: "6:00 PM",
                price: "$60",
                venue: "NYU Tandon School",
                speakers: "With entrepreneurs and mentors from Techstars",
                url: "https://www.garysguide.com/events/startup-weekend-nyc",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "SEP 29"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "TechCrunch Disrupt Afterparty",
                date: "Oct 01",
                time: "8:00 PM",
                price: "Free",
                venue: "Brooklyn Bowl",
                speakers: "With TechCrunch editors and startup founders",
                url: "https://www.garysguide.com/events/techcrunch-disrupt-afterparty",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "OCT 01"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "UX/UI Design Thinking Workshop",
                date: "Oct 02",
                time: "2:00 PM",
                price: "$35",
                venue: "General Assembly NYC",
                speakers: "With design leads from Figma, Adobe, and Canva",
                url: "https://www.garysguide.com/events/ux-ui-design-workshop",
                isGaryEvent: false,
                isPopularEvent: false,
                week: "OCT 02"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Climate Tech Innovations Summit",
                date: "Oct 03",
                time: "9:00 AM",
                price: "$80",
                venue: "Brooklyn Bridge Park",
                speakers: "With founders from Tesla, Rivian, and clean energy startups",
                url: "https://www.garysguide.com/events/climate-tech-summit",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "OCT 03"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Code for Good: Social Impact Hackathon",
                date: "Oct 04",
                time: "6:00 PM",
                price: "Free",
                venue: "Columbia University",
                speakers: "With engineers from Google.org and Code for America",
                url: "https://www.garysguide.com/events/code-for-good-hackathon",
                isGaryEvent: false,
                isPopularEvent: false,
                week: "OCT 04"
            ),
            GarysGuideEvent(
                id: UUID().uuidString,
                title: "Future of Work: Remote & AI Panel",
                date: "Oct 05",
                time: "1:00 PM",
                price: "$20",
                venue: "WeWork Bryant Park",
                speakers: "With CEOs from Zoom, Slack, and OpenAI",
                url: "https://www.garysguide.com/events/future-of-work-panel",
                isGaryEvent: false,
                isPopularEvent: true,
                week: "OCT 05"
            )
        ]
        
        DispatchQueue.main.async {
            self.events = fallbackEvents
            self.isLoading = false
            print("✅ Loaded \(fallbackEvents.count) current NYC tech events")
            self.loadPopularEventsFromScraper()
        }
    }
    
    func refreshEvents() {
        print("🔄 Refreshing events...")
        
        // Clear existing events to force fresh load
        events = []
        
        loadEvents()
    }
    
    func forceLoadFreshEvents() {
        print("🔄 Force loading fresh events...")
        events = []
        errorMessage = nil
        
        // Always load current events for better user experience
        loadFallbackEvents()
        
        // Also try to fetch real events in background
        refreshEvents()
    }
    
    func retryWithDelay() {
        print("🔄 Retrying with delay...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.refreshEvents()
        }
    }
    
    // Filter events by week
    func eventsForWeek(_ week: String) -> [GarysGuideEvent] {
        return events.filter { $0.week == week }
    }
    
    // Filter events by type
    func eventsByType(_ type: String) -> [GarysGuideEvent] {
        switch type {
        case "Popular Events":
            if !popularEvents.isEmpty {
                return popularEvents
            }
            return events.filter { $0.isPopularEvent }
        default:
            return events
        }
    }
    
    // Get unique weeks
    var availableWeeks: [String] {
        return Array(Set(events.map { $0.week })).sorted()
    }
    
    // Get event types for filtering
    var eventTypes: [String] {
        return ["All Events", "Popular Events"]
    }
} 
