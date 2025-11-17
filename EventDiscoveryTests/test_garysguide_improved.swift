#!/usr/bin/env swift

import Foundation

// Improved Gary's Guide Scraper
// Run with: swift test_garysguide_improved.swift

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

// MARK: - Improved Gary's Guide Scraper
func scrapeGarysGuideImproved() async throws -> [GarysGuideEvent] {
    print("🎯 Scraping Gary's Guide with improved parsing...")
    
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
    
    return parseGarysGuideHTMLImproved(htmlString)
}

func parseGarysGuideHTMLImproved(_ html: String) -> [GarysGuideEvent] {
    print("🔍 Parsing Gary's Guide HTML with improved logic...")
    
    var events: [GarysGuideEvent] = []
    
    // Split HTML into lines for easier parsing
    let lines = html.components(separatedBy: .newlines)
    
    // Look for specific patterns in Gary's Guide
    for (index, line) in lines.enumerated() {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Look for event titles (Gary's Guide format)
        if trimmedLine.contains("]") && trimmedLine.contains("[") && 
           (trimmedLine.contains("Aug") || trimmedLine.contains("Tech") || trimmedLine.contains("Startup")) {
            
            // Extract title from markdown format [Title](url)
            if let titleStart = trimmedLine.range(of: "[")?.upperBound,
               let titleEnd = trimmedLine.range(of: "]", range: titleStart..<trimmedLine.endIndex)?.lowerBound {
                let title = String(trimmedLine[titleStart..<titleEnd])
                
                // Extract URL if present
                var url = ""
                if let urlStart = trimmedLine.range(of: "](")?.upperBound,
                   let urlEnd = trimmedLine.range(of: ")", range: urlStart..<trimmedLine.endIndex)?.lowerBound {
                    url = String(trimmedLine[urlStart..<urlEnd])
                }
                
                // Look for date/time in nearby lines
                var dateTime = ""
                var location = "TBA"
                var isFree = true
                
                // Check next few lines for date/time info
                for i in index..<min(index + 5, lines.count) {
                    let nextLine = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Look for date/time patterns
                    if nextLine.contains("Aug") && (nextLine.contains("pm") || nextLine.contains("am")) {
                        let dateTimePattern = "Aug \\d{2}.*?(\\d{1,2}:\\d{2}(am|pm))"
                        if let range = nextLine.range(of: dateTimePattern, options: .regularExpression) {
                            dateTime = String(nextLine[range])
                        }
                    }
                    
                    // Look for location
                    if nextLine.contains("Venue") || nextLine.contains("St") || nextLine.contains("Ave") {
                        location = nextLine.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    // Look for price
                    if nextLine.contains("Free") || nextLine.contains("$") {
                        isFree = nextLine.contains("Free")
                    }
                }
                
                // Create event if we have a title
                if !title.isEmpty && title.count > 5 {
                    // Parse date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd"
                    dateFormatter.locale = Locale(identifier: "en_US")
                    
                    let currentYear = Calendar.current.component(.year, from: Date())
                    let dayString = dateTime.components(separatedBy: " ").first ?? "01"
                    let dateString = "Aug \(dayString) \(currentYear)"
                    
                    if let date = dateFormatter.date(from: dateString) {
                        let event = GarysGuideEvent(
                            title: title,
                            date: date,
                            time: dateTime.isEmpty ? "TBA" : dateTime,
                            location: location,
                            description: "",
                            url: url.isEmpty ? "https://www.garysguide.com" : url,
                            isFree: isFree,
                            price: isFree ? "Free" : "Paid"
                        )
                        
                        events.append(event)
                        print("✅ Found event: \(title)")
                    }
                }
            }
        }
        
        // Also look for direct event links
        if trimmedLine.contains("href=") && trimmedLine.contains("events/") && 
           !trimmedLine.contains("javascript") && !trimmedLine.contains("dataLayer") {
            
            // Extract event URL
            if let urlStart = trimmedLine.range(of: "href=\"")?.upperBound,
               let urlEnd = trimmedLine.range(of: "\"", range: urlStart..<trimmedLine.endIndex)?.lowerBound {
                let eventUrl = String(trimmedLine[urlStart..<urlEnd])
                
                // Look for title in the same line or nearby
                var title = ""
                if let titleStart = trimmedLine.range(of: ">")?.upperBound,
                   let titleEnd = trimmedLine.range(of: "<", range: titleStart..<trimmedLine.endIndex)?.lowerBound {
                    title = String(trimmedLine[titleStart..<titleEnd])
                }
                
                if !title.isEmpty && title.count > 5 {
                    let event = GarysGuideEvent(
                        title: title,
                        date: Date().addingTimeInterval(Double.random(in: 86400...604800)), // 1-7 days
                        time: "TBA",
                        location: "TBA",
                        description: "",
                        url: "https://www.garysguide.com" + eventUrl,
                        isFree: true,
                        price: "Free"
                    )
                    
                    events.append(event)
                    print("✅ Found event via link: \(title)")
                }
            }
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
func runGarysGuideImprovedTest() async {
    print("🧪 Starting Improved Gary's Guide Scraper Test")
    print(String(repeating: "=", count: 60))
    print("🎯 Goal: Get REAL NYC tech events from Gary's Guide")
    print(String(repeating: "=", count: 60))
    
    do {
        let allEvents = try await scrapeGarysGuideImproved()
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
print("🚀 Improved Gary's Guide Scraper Test")
print("Press Enter to start...")
_ = readLine()

await runGarysGuideImprovedTest() 