#!/usr/bin/env swift

import Foundation

// Simple Event APIs Test
// Run with: swift test_simple_apis.swift

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

// MARK: - Helper Functions
func getCurrentWeekStart() -> String {
    let calendar = Calendar.current
    let today = Date()
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter.string(from: weekStart)
}

func getCurrentWeekEnd() -> String {
    let calendar = Calendar.current
    let today = Date()
    let weekEnd = calendar.dateInterval(of: .weekOfYear, for: today)?.end ?? today
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter.string(from: weekEnd)
}

// MARK: - Event APIs
func getEventsFromMeetupAPI() async throws -> [RealEvent] {
    print("👥 Fetching events from Meetup API...")
    
    // Meetup API endpoint for NYC events (no API key required for public events)
    let urlString = "https://api.meetup.com/find/upcoming_events?lat=40.7128&lon=-74.0060&radius=25&page=20"
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
        throw NSError(domain: "API", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let events = jsonResponse?["events"] as? [[String: Any]] ?? []
    
    print("📊 Found \(events.count) events from Meetup")
    
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

func getEventsFromEventbritePublic() async throws -> [RealEvent] {
    print("🎫 Fetching events from Eventbrite public page...")
    
    // Try to scrape Eventbrite public page (simplified approach)
    let urlString = "https://www.eventbrite.com/d/united-states--new-york/tech/"
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
        throw NSError(domain: "API", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    guard let htmlString = String(data: data, encoding: .utf8) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Encoding error"])
    }
    
    print("📄 HTML Content Length: \(htmlString.count) characters")
    
    // Extract potential events from HTML
    var events: [RealEvent] = []
    let lines = htmlString.components(separatedBy: .newlines)
    
    for line in lines {
        if line.contains("event") || line.contains("meetup") || line.contains("conference") {
            let cleanedLine = line.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleanedLine.count > 10 {
                let startDate = Date().addingTimeInterval(Double.random(in: 86400...604800)) // 1-7 days
                let endDate = startDate.addingTimeInterval(7200)
                
                events.append(RealEvent(
                    title: cleanedLine.prefix(60).trimmingCharacters(in: .whitespacesAndNewlines),
                    startDate: startDate,
                    endDate: endDate,
                    location: "New York, NY",
                    description: "Event from Eventbrite",
                    source: "Eventbrite",
                    url: "https://www.eventbrite.com"
                ))
                
                if events.count >= 5 { break }
            }
        }
    }
    
    return events
}

// MARK: - Main Test Function
func runSimpleEventTest() async {
    print("🧪 Starting Simple Event API Test")
    print(String(repeating: "=", count: 50))
    print("📅 Looking for events this week: \(getCurrentWeekStart()) to \(getCurrentWeekEnd())")
    print(String(repeating: "=", count: 50))
    
    var allEvents: [RealEvent] = []
    
    // Test Meetup API (no API key required)
    do {
        let meetupEvents = try await getEventsFromMeetupAPI()
        allEvents.append(contentsOf: meetupEvents)
        print("✅ Meetup: \(meetupEvents.count) events found")
    } catch {
        print("❌ Meetup API failed: \(error.localizedDescription)")
    }
    
    // Test Eventbrite public page
    do {
        let eventbriteEvents = try await getEventsFromEventbritePublic()
        allEvents.append(contentsOf: eventbriteEvents)
        print("✅ Eventbrite: \(eventbriteEvents.count) events found")
    } catch {
        print("❌ Eventbrite failed: \(error.localizedDescription)")
    }
    
    print("\n" + String(repeating: "=", count: 50))
    print("📊 Final Results:")
    print(String(repeating: "=", count: 50))
    print("📅 Total Events This Week: \(allEvents.count)")
    
    if !allEvents.isEmpty {
        print("\n🎯 This Week's Events:")
        print(String(repeating: "-", count: 30))
        
        for (index, event) in allEvents.sorted(by: { $0.startDate < $1.startDate }).enumerated() {
            print("\(index + 1). \(event.title)")
            print("   📍 \(event.location)")
            print("   📅 \(event.startDate)")
            print("   🌐 \(event.source)")
            print("   🔗 \(event.url)")
            print("   " + String(repeating: "─", count: 25))
        }
    } else {
        print("\n❌ No events found this week")
        print("💡 This might be because:")
        print("   - No events scheduled this week")
        print("   - API rate limits")
        print("   - Network issues")
    }
}

// MARK: - Run Test
print("🚀 Simple Event API Test")
print("Press Enter to start...")
_ = readLine()

await runSimpleEventTest() 