//
//  WebScrapingTest.swift
//  EventDiscoveryTests
//
//  Test web scraping functionality for event discovery
//

import SwiftUI
import Foundation

struct WebScrapingTest: View {
    @State private var scrapedEvents: [CalendarEvent] = []
    @State private var isScraping = false
    @State private var selectedWebsite = "Eventbrite"
    @State private var scrapingResults: [String: Int] = [:]
    
    private let testWebsites = [
        "Eventbrite": "https://www.eventbrite.com/d/united-states--new-york/tech/",
        "Meetup": "https://www.meetup.com/find/?source=EVENTS&location=us--ny--new-york",
        "Luma": "https://lu.ma/events",
        "Local Events": "https://www.timeout.com/newyork/things-to-do"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Test Controls
                VStack(spacing: 12) {
                    Picker("Website", selection: $selectedWebsite) {
                        ForEach(Array(testWebsites.keys), id: \.self) { website in
                            Text(website).tag(website)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Test Web Scraping") {
                        Task {
                            await testWebScraping()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(isScraping)
                    
                    Button("Test All Websites") {
                        Task {
                            await testAllWebsites()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .disabled(isScraping)
                }
                .padding()
                
                if isScraping {
                    VStack {
                        ProgressView("Scraping events...")
                        Text("🕷️ Scraping \(selectedWebsite)...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Results Summary
                if !scrapingResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scraping Results:")
                            .font(.headline)
                        
                        ForEach(Array(scrapingResults.keys.sorted()), id: \.self) { website in
                            HStack {
                                Text(website)
                                Spacer()
                                Text("\(scrapingResults[website] ?? 0) events")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Scraped Events
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(scrapedEvents) { event in
                            EventResultCard(event: event)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Web Scraping Test")
        }
    }
    
    private func testWebScraping() async {
        isScraping = true
        defer { isScraping = false }
        
        do {
            let url = testWebsites[selectedWebsite] ?? ""
            let events = try await scrapeEvents(from: url)
            
            await MainActor.run {
                scrapedEvents = events
                scrapingResults[selectedWebsite] = events.count
            }
        } catch {
            print("❌ Web scraping failed: \(error)")
        }
    }
    
    private func testAllWebsites() async {
        isScraping = true
        defer { isScraping = false }
        
        var allEvents: [CalendarEvent] = []
        var results: [String: Int] = [:]
        
        for (website, url) in testWebsites {
            do {
                let events = try await scrapeEvents(from: url)
                allEvents.append(contentsOf: events)
                results[website] = events.count
                print("🕷️ Scraped \(events.count) events from \(website)")
            } catch {
                print("❌ Failed to scrape \(website): \(error)")
                results[website] = 0
            }
        }
        
        await MainActor.run {
            scrapedEvents = allEvents
            scrapingResults = results
        }
    }
    
    private func scrapeEvents(from url: String) async throws -> [CalendarEvent] {
        guard let url = URL(string: url) else {
            throw WebScrapingError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WebScrapingError.httpError
        }
        
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw WebScrapingError.encodingError
        }
        
        return try parseEventsFromHTML(htmlString, source: url.absoluteString)
    }
    
    private func parseEventsFromHTML(_ html: String, source: String) throws -> [CalendarEvent] {
        // This is a simplified parser - in a real implementation, you'd use more sophisticated parsing
        var events: [CalendarEvent] = []
        
        // Look for common event patterns in HTML
        let eventPatterns = [
            "event",
            "meetup",
            "conference",
            "workshop",
            "networking"
        ]
        
        let lines = html.components(separatedBy: .newlines)
        
        for line in lines {
            let lowercasedLine = line.lowercased()
            
            for pattern in eventPatterns {
                if lowercasedLine.contains(pattern) {
                    // Extract potential event information
                    if let event = extractEventFromLine(line, source: source) {
                        events.append(event)
                    }
                }
            }
        }
        
        // Remove duplicates and limit results
        let uniqueEvents = Array(Set(events)).prefix(10).map { $0 }
        
        return Array(uniqueEvents)
    }
    
    private func extractEventFromLine(_ line: String, source: String) -> CalendarEvent? {
        // Simplified event extraction - in reality, you'd use more sophisticated parsing
        let cleanedLine = line.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleanedLine.count > 10 else { return nil }
        
        // Generate a fake event based on the line content
        let title = cleanedLine.prefix(50).trimmingCharacters(in: .whitespacesAndNewlines)
        let startDate = Date().addingTimeInterval(Double.random(in: 86400...2592000)) // 1-30 days from now
        let endDate = startDate.addingTimeInterval(7200) // 2 hours later
        
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
}

// MARK: - Supporting Types

enum WebScrapingError: Error {
    case invalidURL
    case httpError
    case encodingError
    case parsingError
}

struct EventResultCard: View {
    let event: CalendarEvent
    
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
                    .foregroundColor(.blue)
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
    WebScrapingTest()
} 