#!/usr/bin/env swift

import Foundation

// Real Event APIs Test
// Run with: swift test_event_apis.swift

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

// MARK: - Event APIs
func getEventsFromEventbriteAPI() async throws -> [RealEvent] {
    print("🎫 Fetching events from Eventbrite API...")
    
    // Eventbrite API endpoint for NYC tech events
    let urlString = "https://www.eventbriteapi.com/v3/events/search/?location.address=new+york&start_date.range_start=\(getCurrentWeekStart())&start_date.range_end=\(getCurrentWeekEnd())&categories=102" // Tech category
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer YOUR_EVENTBRITE_API_KEY", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "API", code: httpResponse?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    // Parse Eventbrite response
    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let events = jsonResponse?["events"] as? [[String: Any]] ?? []
    
    return events.compactMap { eventData in
        guard let title = eventData["name"] as? [String: Any],
              let text = title["text"] as? String,
              let start = eventData["start"] as? [String: Any],
              let dateTime = start["local"] as? String,
              let venue = eventData["venue"] as? [String: Any],
              let address = venue["address"] as? [String: Any],
              let city = address["city"] as? String else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let startDate = dateFormatter.date(from: dateTime) ?? Date()
        let endDate = startDate.addingTimeInterval(7200) // 2 hours
        
        let description = (eventData["description"] as? [String: Any])?["text"] as? String ?? ""
        
        return RealEvent(
            title: text,
            startDate: startDate,
            endDate: endDate,
            location: city,
            description: description,
            source: "Eventbrite",
            url: eventData["url"] as? String ?? ""
        )
    }
}

func getEventsFromMeetupAPI() async throws -> [RealEvent] {
    print("👥 Fetching events from Meetup API...")
    
    // Meetup API endpoint for NYC events
    let urlString = "https://api.meetup.com/find/upcoming_events?lat=40.7128&lon=-74.0060&radius=25&start_date_range=\(getCurrentWeekStart())&end_date_range=\(getCurrentWeekEnd())"
    
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "API", code: httpResponse?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let events = jsonResponse?["events"] as? [[String: Any]] ?? []
    
    return events.compactMap { eventData in
        guard let name = eventData["name"] as? String,
              let time = eventData["time"] as? TimeInterval,
              let group = eventData["group"] as? [String: Any],
              let city = group["city"] as? String else {
            return nil
        }
        
        let startDate = Date(timeIntervalSince1970: time / 1000)
        let endDate = startDate.addingTimeInterval(7200)
        
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

// MARK: - Main Test Function
func runRealEventTest() async {
    print("🧪 Starting Real Event API Test")
    print(String(repeating: "=", count: 50))
    print("📅 Looking for events this week: \(getCurrentWeekStart()) to \(getCurrentWeekEnd())")
    print(String(repeating: "=", count: 50))
    
    var allEvents: [RealEvent] = []
    
    // Test Eventbrite API
    do {
        let eventbriteEvents = try await getEventsFromEventbriteAPI()
        allEvents.append(contentsOf: eventbriteEvents)
        print("✅ Eventbrite: \(eventbriteEvents.count) events found")
    } catch {
        print("❌ Eventbrite API failed: \(error.localizedDescription)")
        print("💡 You need to add your Eventbrite API key to test this")
    }
    
    // Test Meetup API
    do {
        let meetupEvents = try await getEventsFromMeetupAPI()
        allEvents.append(contentsOf: meetupEvents)
        print("✅ Meetup: \(meetupEvents.count) events found")
    } catch {
        print("❌ Meetup API failed: \(error.localizedDescription)")
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
        print("💡 Try adding API keys or check the date range")
    }
}

// MARK: - Run Test
print("🚀 Real Event API Test")
print("Press Enter to start...")
_ = readLine()

await runRealEventTest() 