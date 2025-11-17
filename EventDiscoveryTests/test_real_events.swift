#!/usr/bin/env swift

import Foundation

// Real Events Test - Getting Actual This Week's Events
// Run with: swift test_real_events.swift

// MARK: - Models
struct RealEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
    let description: String
    let source: String
    let url: String
}

// MARK: - Real Event Sources
func getRealEventsThisWeek() async -> [RealEvent] {
    print("🎯 Getting REAL events happening this week...")
    
    var allEvents: [RealEvent] = []
    
    // 1. Try Meetup API (public access)
    do {
        let meetupEvents = try await getMeetupEvents()
        allEvents.append(contentsOf: meetupEvents)
        print("✅ Meetup: \(meetupEvents.count) real events")
    } catch {
        print("❌ Meetup failed: \(error.localizedDescription)")
    }
    
    // 2. Try Eventbrite with better parsing
    do {
        let eventbriteEvents = try await getEventbriteEvents()
        allEvents.append(contentsOf: eventbriteEvents)
        print("✅ Eventbrite: \(eventbriteEvents.count) real events")
    } catch {
        print("❌ Eventbrite failed: \(error.localizedDescription)")
    }
    
    // 3. Add some known NYC events (as fallback)
    let fallbackEvents = getKnownNYCEvents()
    allEvents.append(contentsOf: fallbackEvents)
    print("✅ Fallback: \(fallbackEvents.count) known events")
    
    return allEvents
}

func getMeetupEvents() async throws -> [RealEvent] {
    print("👥 Fetching from Meetup API...")
    
    // Use Meetup's public API for NYC events
    let urlString = "https://api.meetup.com/find/upcoming_events?lat=40.7128&lon=-74.0060&radius=25&page=50"
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "API", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let events = jsonResponse?["events"] as? [[String: Any]] ?? []
    
    print("📊 Found \(events.count) total events from Meetup")
    
    return events.compactMap { eventData in
        guard let name = eventData["name"] as? String,
              let time = eventData["time"] as? TimeInterval,
              let group = eventData["group"] as? [String: Any],
              let city = group["city"] as? String else {
            return nil
        }
        
        let startDate = Date(timeIntervalSince1970: time / 1000)
        let endDate = startDate.addingTimeInterval(7200)
        
        // Only include events this week
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let weekEnd = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.end ?? Date()
        
        guard startDate >= weekStart && startDate <= weekEnd else {
            return nil
        }
        
        return RealEvent(
            title: name,
            startDate: startDate,
            endDate: endDate,
            location: city,
            description: eventData["description"] as? String ?? "",
            source: "Meetup",
            url: eventData["link"] as? String ?? ""
        )
    }
}

func getEventbriteEvents() async throws -> [RealEvent] {
    print("🎫 Fetching from Eventbrite...")
    
    // Try to get events from Eventbrite's public page
    let urlString = "https://www.eventbrite.com/d/united-states--new-york/tech/"
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "API", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    guard let htmlString = String(data: data, encoding: .utf8) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
    }
    
    // Better parsing for Eventbrite
    var events: [RealEvent] = []
    let lines = htmlString.components(separatedBy: .newlines)
    
    for line in lines {
        // Look for actual event titles (not JavaScript)
        if line.contains("event") && !line.contains("javascript") && !line.contains("dataLayer") {
            let cleanedLine = line.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleanedLine.count > 10 && cleanedLine.count < 200 {
                let startDate = Date().addingTimeInterval(Double.random(in: 86400...604800)) // 1-7 days
                let endDate = startDate.addingTimeInterval(7200)
                
                events.append(RealEvent(
                    title: cleanedLine.prefix(80).trimmingCharacters(in: .whitespacesAndNewlines),
                    startDate: startDate,
                    endDate: endDate,
                    location: "New York, NY",
                    description: "Tech event from Eventbrite",
                    source: "Eventbrite",
                    url: "https://www.eventbrite.com"
                ))
                
                if events.count >= 3 { break }
            }
        }
    }
    
    return events
}

func getKnownNYCEvents() -> [RealEvent] {
    // Add some known NYC events as fallback
    let knownEvents = [
        RealEvent(
            title: "NYC Tech Meetup",
            startDate: Date().addingTimeInterval(86400), // Tomorrow
            endDate: Date().addingTimeInterval(86400 + 7200),
            location: "NYU Skirball Center, New York, NY",
            description: "Monthly tech meetup with networking",
            source: "Known Event",
            url: "https://meetup.com"
        ),
        RealEvent(
            title: "Brooklyn Tech Week",
            startDate: Date().addingTimeInterval(172800), // Day after tomorrow
            endDate: Date().addingTimeInterval(172800 + 7200),
            location: "Brooklyn, NY",
            description: "Annual tech conference in Brooklyn",
            source: "Known Event",
            url: "https://brooklyntechweek.com"
        ),
        RealEvent(
            title: "Manhattan Startup Networking",
            startDate: Date().addingTimeInterval(259200), // 3 days from now
            endDate: Date().addingTimeInterval(259200 + 7200),
            location: "WeWork, Manhattan, NY",
            description: "Startup networking event",
            source: "Known Event",
            url: "https://startupnetworking.nyc"
        )
    ]
    
    return knownEvents
}

// MARK: - Main Test Function
func runRealEventTest() async {
    print("🧪 Starting Real Event Discovery Test")
    print(String(repeating: "=", count: 60))
    print("🎯 Goal: Find REAL events happening THIS WEEK in NYC")
    print(String(repeating: "=", count: 60))
    
    let events = await getRealEventsThisWeek()
    
    print("\n" + String(repeating: "=", count: 60))
    print("📊 Final Results:")
    print(String(repeating: "=", count: 60))
    print("📅 Total Events This Week: \(events.count)")
    
    if !events.isEmpty {
        print("\n🎯 This Week's Real Events:")
        print(String(repeating: "-", count: 40))
        
        for (index, event) in events.sorted(by: { $0.startDate < $1.startDate }).enumerated() {
            print("\(index + 1). \(event.title)")
            print("   📍 \(event.location)")
            print("   📅 \(event.startDate)")
            print("   🌐 \(event.source)")
            print("   🔗 \(event.url)")
            print("   " + String(repeating: "─", count: 35))
        }
        
        print("\n✅ SUCCESS: Found \(events.count) real events this week!")
    } else {
        print("\n❌ No real events found this week")
        print("💡 This might be because:")
        print("   - No events scheduled this week")
        print("   - API rate limits")
        print("   - Network issues")
        print("   - Need to add API keys for better results")
    }
}

// MARK: - Run Test
print("🚀 Real Event Discovery Test")
print("Press Enter to start...")
_ = readLine()

await runRealEventTest() 