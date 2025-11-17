#!/usr/bin/env swift

import Foundation

// Gary's Guide Scraper - Get Real NYC Tech Events
// Run with: swift test_garysguide_scraper.swift

// MARK: - Models
struct GarysGuideEvent {
    let title: String
    let date: Date
    let time: String
    let location: String
    let description: String
    let url: String
    let isFree: Bool
    let price: String?
}

// MARK: - Gary's Guide Scraper
func scrapeGarysGuide() async throws -> [GarysGuideEvent] {
    print("🎯 Scraping Gary's Guide for real NYC tech events...")
    
    let urlString = "https://www.garysguide.com/events"
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "Scraping", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
        throw NSError(domain: "Scraping", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error"])
    }
    
    guard let htmlString = String(data: data, encoding: .utf8) else {
        throw NSError(domain: "Scraping", code: 400, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
    }
    
    print("📄 HTML Content Length: \(htmlString.count) characters")
    
    return parseGarysGuideHTML(htmlString)
}

func parseGarysGuideHTML(_ html: String) -> [GarysGuideEvent] {
    print("🔍 Parsing Gary's Guide HTML...")
    
    var events: [GarysGuideEvent] = []
    
    // Split HTML into lines for easier parsing
    let lines = html.components(separatedBy: .newlines)
    
    // Look for event patterns in Gary's Guide format
    var currentEvent: [String: String] = [:]
    var inEventSection = false
    
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Look for event links (Gary's Guide format)
        if trimmedLine.contains("href=") && trimmedLine.contains("events/") {
            // Extract event URL
            if let urlStart = trimmedLine.range(of: "href=\"")?.upperBound,
               let urlEnd = trimmedLine.range(of: "\"", range: urlStart..<trimmedLine.endIndex)?.lowerBound {
                let eventUrl = String(trimmedLine[urlStart..<urlEnd])
                currentEvent["url"] = "https://www.garysguide.com" + eventUrl
            }
        }
        
        // Look for event titles
        if trimmedLine.contains("]") && trimmedLine.contains("[") && trimmedLine.contains("Aug") {
            // Extract title from format like "[Event Title](url)"
            if let titleStart = trimmedLine.range(of: "[")?.upperBound,
               let titleEnd = trimmedLine.range(of: "]", range: titleStart..<trimmedLine.endIndex)?.lowerBound {
                let title = String(trimmedLine[titleStart..<titleEnd])
                currentEvent["title"] = title
            }
        }
        
        // Look for dates and times
        if trimmedLine.contains("Aug") && (trimmedLine.contains("pm") || trimmedLine.contains("am")) {
            // Extract date and time
            let dateTimePattern = "Aug \\d{2}.*?(\\d{1,2}:\\d{2}(am|pm))"
            if let range = trimmedLine.range(of: dateTimePattern, options: .regularExpression) {
                let dateTime = String(trimmedLine[range])
                currentEvent["datetime"] = dateTime
            }
        }
        
        // Look for locations
        if trimmedLine.contains("Venue") || trimmedLine.contains("St") || trimmedLine.contains("Ave") {
            let location = trimmedLine.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if location.count > 5 && location.count < 100 {
                currentEvent["location"] = location
            }
        }
        
        // Look for price information
        if trimmedLine.contains("Free") || trimmedLine.contains("$") {
            currentEvent["price"] = trimmedLine.contains("Free") ? "Free" : "Paid"
        }
        
        // If we have enough info for an event, add it
        if let title = currentEvent["title"], 
           let datetime = currentEvent["datetime"],
           !title.isEmpty && title.count > 5 {
            
            // Parse date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            dateFormatter.locale = Locale(identifier: "en_US")
            
            let currentYear = Calendar.current.component(.year, from: Date())
            let dateString = "Aug \(datetime.components(separatedBy: " ").first ?? "01") \(currentYear)"
            
            if let date = dateFormatter.date(from: dateString) {
                let event = GarysGuideEvent(
                    title: title,
                    date: date,
                    time: datetime,
                    location: currentEvent["location"] ?? "TBA",
                    description: currentEvent["description"] ?? "",
                    url: currentEvent["url"] ?? "",
                    isFree: currentEvent["price"] == "Free",
                    price: currentEvent["price"]
                )
                
                events.append(event)
            }
            
            // Reset for next event
            currentEvent = [:]
        }
    }
    
    print("✅ Found \(events.count) events from Gary's Guide")
    return events
}

// MARK: - Filter Events This Week
func filterEventsThisWeek(_ events: [GarysGuideEvent]) -> [GarysGuideEvent] {
    let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
    let weekEnd = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.end ?? Date()
    
    return events.filter { event in
        event.date >= weekStart && event.date <= weekEnd
    }
}

// MARK: - Main Test Function
func runGarysGuideTest() async {
    print("🧪 Starting Gary's Guide Scraper Test")
    print(String(repeating: "=", count: 60))
    print("🎯 Goal: Get REAL NYC tech events from Gary's Guide")
    print(String(repeating: "=", count: 60))
    
    do {
        let allEvents = try await scrapeGarysGuide()
        let thisWeekEvents = filterEventsThisWeek(allEvents)
        
        print("\n" + String(repeating: "=", count: 60))
        print("📊 Results:")
        print(String(repeating: "=", count: 60))
        print("📅 Total Events Found: \(allEvents.count)")
        print("📅 This Week's Events: \(thisWeekEvents.count)")
        
        if !thisWeekEvents.isEmpty {
            print("\n🎯 This Week's Real Events from Gary's Guide:")
            print(String(repeating: "-", count: 40))
            
            for (index, event) in thisWeekEvents.sorted(by: { $0.date < $1.date }).enumerated() {
                print("\(index + 1). \(event.title)")
                print("   📅 \(event.date) at \(event.time)")
                print("   📍 \(event.location)")
                print("   💰 \(event.isFree ? "Free" : "Paid")")
                print("   🔗 \(event.url)")
                print("   " + String(repeating: "─", count: 35))
            }
            
            print("\n✅ SUCCESS: Found \(thisWeekEvents.count) real events this week!")
        } else {
            print("\n❌ No events found this week")
            print("💡 This might be because:")
            print("   - No events scheduled this week")
            print("   - Parsing needs improvement")
            print("   - Website structure changed")
        }
        
        // Show all events for debugging
        if !allEvents.isEmpty {
            print("\n📋 All Events Found (for debugging):")
            print(String(repeating: "-", count: 30))
            
            for (index, event) in allEvents.prefix(10).enumerated() {
                print("\(index + 1). \(event.title) - \(event.date)")
            }
        }
        
    } catch {
        print("❌ Gary's Guide scraping failed: \(error.localizedDescription)")
    }
}

// MARK: - Run Test
print("🚀 Gary's Guide Scraper Test")
print("Press Enter to start...")
_ = readLine()

await runGarysGuideTest() 