//
//  IntegrationTest.swift
//  EventDiscoveryTests
//
//  Test integration of AI discovery and web scraping
//

import SwiftUI
import OpenAI

struct IntegrationTest: View {
    @State private var allEvents: [CalendarEvent] = []
    @State private var aiEvents: [CalendarEvent] = []
    @State private var scrapedEvents: [CalendarEvent] = []
    @State private var isTesting = false
    @State private var testResults: [String: Int] = [:]
    @State private var selectedSource = "All Sources"
    
    private let openAI = OpenAI(apiToken: "YOUR_OPENAI_API_KEY_HERE")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Test Controls
                VStack(spacing: 12) {
                    Picker("Source", selection: $selectedSource) {
                        Text("All Sources").tag("All Sources")
                        Text("AI Discovery").tag("AI Discovery")
                        Text("Web Scraping").tag("Web Scraping")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Test Full Integration") {
                        Task {
                            await testFullIntegration()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .disabled(isTesting)
                    
                    Button("Test AI Only") {
                        Task {
                            await testAIOnly()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(isTesting)
                    
                    Button("Test Scraping Only") {
                        Task {
                            await testScrapingOnly()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .disabled(isTesting)
                }
                .padding()
                
                if isTesting {
                    VStack {
                        ProgressView("Testing integration...")
                        Text("🔄 Testing \(selectedSource)...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Results Summary
                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Results:")
                            .font(.headline)
                        
                        ForEach(Array(testResults.keys.sorted()), id: \.self) { source in
                            HStack {
                                Text(source)
                                Spacer()
                                Text("\(testResults[source] ?? 0) events")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Events:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(allEvents.count)")
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Filtered Events
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEvents) { event in
                            EventResultCard(event: event, showSource: true)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Integration Test")
        }
    }
    
    private var filteredEvents: [CalendarEvent] {
        switch selectedSource {
        case "AI Discovery":
            return aiEvents
        case "Web Scraping":
            return scrapedEvents
        default:
            return allEvents
        }
    }
    
    private func testFullIntegration() async {
        isTesting = true
        defer { isTesting = false }
        
        do {
            // Test AI discovery
            let aiEvents = try await testAIDiscovery()
            
            // Test web scraping
            let scrapedEvents = try await testWebScraping()
            
            // Combine and deduplicate
            let combinedEvents = combineAndDeduplicate(aiEvents: aiEvents, scrapedEvents: scrapedEvents)
            
            await MainActor.run {
                self.aiEvents = aiEvents
                self.scrapedEvents = scrapedEvents
                self.allEvents = combinedEvents
                self.testResults = [
                    "AI Discovery": aiEvents.count,
                    "Web Scraping": scrapedEvents.count,
                    "Combined": combinedEvents.count
                ]
            }
        } catch {
            print("❌ Integration test failed: \(error)")
        }
    }
    
    private func testAIOnly() async {
        isTesting = true
        defer { isTesting = false }
        
        do {
            let events = try await testAIDiscovery()
            await MainActor.run {
                aiEvents = events
                allEvents = events
                testResults = ["AI Discovery": events.count]
            }
        } catch {
            print("❌ AI test failed: \(error)")
        }
    }
    
    private func testScrapingOnly() async {
        isTesting = true
        defer { isTesting = false }
        
        do {
            let events = try await testWebScraping()
            await MainActor.run {
                scrapedEvents = events
                allEvents = events
                testResults = ["Web Scraping": events.count]
            }
        } catch {
            print("❌ Scraping test failed: \(error)")
        }
    }
    
    private func testAIDiscovery() async throws -> [CalendarEvent] {
        let prompt = """
        Find upcoming events in New York City for tech, networking, and social interests.
        
        Return as JSON array with this exact format:
        [
            {
                "title": "Event Title",
                "startDate": "2025-08-15T18:00:00Z",
                "endDate": "2025-08-15T20:00:00Z",
                "location": "Event Location",
                "description": "Event description",
                "source": "AI Discovery",
                "confidence": 0.9
            }
        ]
        
        Only return valid JSON, no other text.
        """
        
        let response = try await openAI.chats.create(
            model: .gpt4,
            messages: [.init(role: .user, content: prompt)]
        )
        
        let content = response.choices.first?.message.content ?? ""
        return try parseAIResponse(content)
    }
    
    private func testWebScraping() async throws -> [CalendarEvent] {
        let testURLs = [
            "https://www.eventbrite.com/d/united-states--new-york/tech/",
            "https://www.meetup.com/find/?source=EVENTS&location=us--ny--new-york"
        ]
        
        var allEvents: [CalendarEvent] = []
        
        for url in testURLs {
            do {
                let events = try await scrapeEvents(from: url)
                allEvents.append(contentsOf: events)
            } catch {
                print("❌ Failed to scrape \(url): \(error)")
            }
        }
        
        return allEvents
    }
    
    private func scrapeEvents(from url: String) async throws -> [CalendarEvent] {
        guard let url = URL(string: url) else {
            throw IntegrationTestError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw IntegrationTestError.encodingError
        }
        
        return parseEventsFromHTML(htmlString, source: url.absoluteString)
    }
    
    private func parseEventsFromHTML(_ html: String, source: String) -> [CalendarEvent] {
        // Simplified parsing - same as WebScrapingTest
        var events: [CalendarEvent] = []
        
        let eventPatterns = ["event", "meetup", "conference", "workshop", "networking"]
        let lines = html.components(separatedBy: .newlines)
        
        for line in lines {
            let lowercasedLine = line.lowercased()
            
            for pattern in eventPatterns {
                if lowercasedLine.contains(pattern) {
                    if let event = extractEventFromLine(line, source: source) {
                        events.append(event)
                    }
                }
            }
        }
        
        return Array(Set(events)).prefix(5).map { $0 }
    }
    
    private func extractEventFromLine(_ line: String, source: String) -> CalendarEvent? {
        let cleanedLine = line.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleanedLine.count > 10 else { return nil }
        
        let title = cleanedLine.prefix(50).trimmingCharacters(in: .whitespacesAndNewlines)
        let startDate = Date().addingTimeInterval(Double.random(in: 86400...2592000))
        let endDate = startDate.addingTimeInterval(7200)
        
        return CalendarEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: "Location TBD",
            notes: "Scraped from \(source)",
            extractedInfo: ExtractedEventInfo(
                rawText: cleanedLine,
                title: title,
                startDateTime: startDate,
                endDateTime: endDate,
                location: "Location TBD",
                description: cleanedLine,
                confidence: 0.7
            )
        )
    }
    
    private func parseAIResponse(_ response: String) throws -> [CalendarEvent] {
        let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw IntegrationTestError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let aiEvents = try decoder.decode([AIEvent].self, from: data)
            
            return aiEvents.map { aiEvent in
                CalendarEvent(
                    title: aiEvent.title,
                    startDate: aiEvent.startDate,
                    endDate: aiEvent.endDate,
                    location: aiEvent.location,
                    notes: aiEvent.description,
                    extractedInfo: ExtractedEventInfo(
                        rawText: response,
                        title: aiEvent.title,
                        startDateTime: aiEvent.startDate,
                        endDateTime: aiEvent.endDate,
                        location: aiEvent.location,
                        description: aiEvent.description,
                        confidence: aiEvent.confidence
                    )
                )
            }
        } catch {
            print("❌ Failed to parse AI response: \(error)")
            throw IntegrationTestError.parsingFailed
        }
    }
    
    private func combineAndDeduplicate(aiEvents: [CalendarEvent], scrapedEvents: [CalendarEvent]) -> [CalendarEvent] {
        var combined = aiEvents + scrapedEvents
        
        // Simple deduplication based on title similarity
        var uniqueEvents: [CalendarEvent] = []
        var seenTitles: Set<String> = []
        
        for event in combined {
            let normalizedTitle = event.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !seenTitles.contains(normalizedTitle) {
                uniqueEvents.append(event)
                seenTitles.insert(normalizedTitle)
            }
        }
        
        return uniqueEvents.sorted { $0.startDate < $1.startDate }
    }
}

// MARK: - Supporting Types

struct AIEvent: Codable {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
    let description: String
    let source: String
    let confidence: Double
}

enum IntegrationTestError: Error {
    case invalidURL
    case encodingError
    case invalidResponse
    case parsingFailed
}

struct EventResultCard: View {
    let event: CalendarEvent
    let showSource: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(event.startDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let location = event.location {
                Text(location)
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            
            if showSource, let extractedInfo = event.extractedInfo {
                Text("Source: \(extractedInfo.rawText.contains("AI") ? "AI Discovery" : "Web Scraping")")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            if let notes = event.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    IntegrationTest()
} 