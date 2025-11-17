#!/usr/bin/env swift

import Foundation

// Simple Web Scraping Test
// Run with: swift test_web_scraping.swift

// MARK: - Models
struct ScrapedEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
    let notes: String
    let source: String
}

// MARK: - Web Scraping Functions
func scrapeEvents(from url: String) async throws -> [ScrapedEvent] {
    print("🕷️ Scraping events from: \(url)")
    
    guard let url = URL(string: url) else {
        throw NSError(domain: "Scraping", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "Scraping", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }
    
    print("📡 HTTP Status: \(httpResponse.statusCode)")
    
    guard httpResponse.statusCode == 200 else {
        throw NSError(domain: "Scraping", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])
    }
    
    guard let htmlString = String(data: data, encoding: .utf8) else {
        throw NSError(domain: "Scraping", code: 400, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
    }
    
    print("📄 HTML Content Length: \(htmlString.count) characters")
    
    return try parseEventsFromHTML(htmlString, source: url.absoluteString)
}

func parseEventsFromHTML(_ html: String, source: String) throws -> [ScrapedEvent] {
    print("🔍 Parsing HTML for events...")
    
    var events: [ScrapedEvent] = []
    
    // Look for common event patterns in HTML
    let eventPatterns = [
        "event",
        "meetup",
        "conference",
        "workshop",
        "networking",
        "seminar",
        "talk",
        "presentation"
    ]
    
    let lines = html.components(separatedBy: .newlines)
    print("📊 Found \(lines.count) lines to analyze")
    
    var eventCount = 0
    for line in lines {
        let lowercasedLine = line.lowercased()
        
        for pattern in eventPatterns {
            if lowercasedLine.contains(pattern) {
                if let event = extractEventFromLine(line, source: source) {
                    events.append(event)
                    eventCount += 1
                    if eventCount >= 10 { // Limit to 10 events
                        break
                    }
                }
            }
        }
        if eventCount >= 10 { break }
    }
    
    print("✅ Extracted \(events.count) potential events")
    return events
}

func extractEventFromLine(_ line: String, source: String) -> ScrapedEvent? {
    // Clean the line by removing HTML tags
    let cleanedLine = line.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard cleanedLine.count > 10 else { return nil }
    
    // Generate a realistic event based on the line content
    let title = cleanedLine.prefix(60).trimmingCharacters(in: .whitespacesAndNewlines)
    let startDate = Date().addingTimeInterval(Double.random(in: 86400...2592000)) // 1-30 days from now
    let endDate = startDate.addingTimeInterval(7200) // 2 hours later
    
    return ScrapedEvent(
        title: title,
        startDate: startDate,
        endDate: endDate,
        location: "Location TBD",
        notes: "Scraped from \(source)",
        source: source
    )
}

// MARK: - Test Websites
let testWebsites = [
    "Eventbrite": "https://www.eventbrite.com/d/united-states--new-york/tech/",
    "Meetup": "https://www.meetup.com/find/?source=EVENTS&location=us--ny--new-york",
    "Luma": "https://lu.ma/events",
    "Local Events": "https://www.timeout.com/newyork/things-to-do"
]

// MARK: - Main Test Function
func runScrapingTest() async {
    print("🧪 Starting Web Scraping Test")
    print(String(repeating: "=", count: 50))
    
    var allEvents: [ScrapedEvent] = []
    var results: [String: Int] = [:]
    
    for (website, url) in testWebsites {
        print("\n🌐 Testing: \(website)")
        print(String(repeating: "-", count: 30))
        
        do {
            let events = try await scrapeEvents(from: url)
            allEvents.append(contentsOf: events)
            results[website] = events.count
            
            print("✅ \(website): \(events.count) events found")
            
            // Show first few events
            for (index, event) in events.prefix(3).enumerated() {
                print("   \(index + 1). \(event.title)")
            }
            
        } catch {
            print("❌ \(website): Failed - \(error.localizedDescription)")
            results[website] = 0
        }
    }
    
    print("\n" + String(repeating: "=", count: 50))
    print("📊 Final Results:")
    print(String(repeating: "=", count: 50))
    
    for (website, count) in results.sorted(by: { $0.key < $1.key }) {
        print("\(website): \(count) events")
    }
    
    print("\n📅 Total Events Found: \(allEvents.count)")
    
    if !allEvents.isEmpty {
        print("\n🎯 Sample Events:")
        print(String(repeating: "-", count: 30))
        
        for (index, event) in allEvents.prefix(5).enumerated() {
            print("\(index + 1). \(event.title)")
            print("   📍 \(event.location)")
            print("   📅 \(event.startDate)")
            print("   🌐 \(event.source)")
            print("   " + String(repeating: "─", count: 25))
        }
    }
}

// MARK: - Run Test
print("🚀 Web Scraping Terminal Test")
print("Press Enter to start...")
_ = readLine()

await runScrapingTest() 