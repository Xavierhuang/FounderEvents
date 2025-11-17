#!/usr/bin/env swift

import Foundation

// Test Gary's Guide calendar integration
print("=== TESTING GARY'S GUIDE CALENDAR INTEGRATION ===")

class GarysGuideCalendarIntegrationTester {
    func testCalendarIntegration() {
        print("🔍 Testing Gary's Guide calendar integration...")
        
        // Simulate a Gary's Guide event
        let garyEvent = GarysGuideEvent(
            title: "AI Tech Meetup",
            date: "Aug 15",
            time: "2:00pm",
            price: "Free",
            venue: "Tech Hub NYC",
            speakers: "With John Smith",
            url: "http://gary.to/test123",
            isGaryEvent: true,
            isPopularEvent: false,
            week: "AUG 11"
        )
        
        print("📅 Gary's Guide Event:")
        print("   Title: \(garyEvent.title)")
        print("   Date: \(garyEvent.date)")
        print("   Time: \(garyEvent.time)")
        print("   Venue: \(garyEvent.venue)")
        
        // Parse the date and time
        if let parsedDate = parseEventDateTime(date: garyEvent.date, time: garyEvent.time) {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            formatter.timeZone = TimeZone(identifier: "America/New_York")
            
            print("✅ Parsed date: \(formatter.string(from: parsedDate))")
            
            // Create a calendar event
            let endDate = parsedDate.addingTimeInterval(3600) // 1 hour duration
            let calendarEvent = CalendarEvent(
                title: garyEvent.title,
                startDate: parsedDate,
                endDate: endDate,
                location: garyEvent.venue,
                notes: "Event URL: \(garyEvent.url)\nSpeakers: \(garyEvent.speakers)\nPrice: \(garyEvent.price)"
            )
            
            print("📝 Created calendar event:")
            print("   Title: \(calendarEvent.title)")
            print("   Start: \(formatter.string(from: calendarEvent.startDate))")
            print("   End: \(formatter.string(from: calendarEvent.endDate))")
            print("   Location: \(calendarEvent.location ?? "No location")")
            
            // Test calendar day matching
            testCalendarDayMatching(event: calendarEvent, targetDate: parsedDate)
            
        } else {
            print("❌ Failed to parse date")
        }
    }
    
    private func testCalendarDayMatching(event: CalendarEvent, targetDate: Date) {
        print("\n🔍 Testing calendar day matching...")
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        
        // Test matching against the target date
        let isSameDay = calendar.isDate(event.startDate, inSameDayAs: targetDate)
        print("   Event matches target date: \(isSameDay ? "Yes" : "No")")
        
        // Test matching against different dates
        let testDates = [
            ("Same day", targetDate),
            ("Next day", calendar.date(byAdding: .day, value: 1, to: targetDate)!),
            ("Previous day", calendar.date(byAdding: .day, value: -1, to: targetDate)!),
            ("Same day different time", calendar.date(byAdding: .hour, value: 5, to: targetDate)!)
        ]
        
        for (description, testDate) in testDates {
            let matches = calendar.isDate(event.startDate, inSameDayAs: testDate)
            print("   \(description): \(matches ? "Match" : "No match")")
        }
        
        // Test if the event would appear in a calendar grid
        let eventDay = calendar.component(.day, from: event.startDate)
        let eventMonth = calendar.component(.month, from: event.startDate)
        let eventYear = calendar.component(.year, from: event.startDate)
        
        print("\n📅 Event calendar details:")
        print("   Day: \(eventDay)")
        print("   Month: \(eventMonth)")
        print("   Year: \(eventYear)")
        
        // Check if this would be visible in the current month view
        let currentDate = Date()
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let isInCurrentMonth = eventMonth == currentMonth && eventYear == currentYear
        print("   Would appear in current month (\(currentMonth)/\(currentYear)): \(isInCurrentMonth ? "Yes" : "No")")
    }
    
    private func parseEventDateTime(date: String, time: String) -> Date? {
        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // Create full date string with current year
        let fullDateString = "\(date) \(currentYear)"
        
        // Parse the date with year
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM dd yyyy"
        fullDateFormatter.locale = Locale(identifier: "en_US")
        
        guard let eventDate = fullDateFormatter.date(from: fullDateString) else {
            return nil
        }
        
        // Check if the event date is in the past (before today)
        let calendar = Calendar.current
        let today = Date()
        let eventMonth = calendar.component(.month, from: eventDate)
        let eventDay = calendar.component(.day, from: eventDate)
        
        // If the event month is before current month (and we're not in December), 
        // or if it's the same month but day is before today, assume it's next year
        var adjustedYear = currentYear
        if (eventMonth < currentMonth && currentMonth != 12) || 
           (eventMonth == currentMonth && eventDay < calendar.component(.day, from: today)) {
            adjustedYear = currentYear + 1
        }
        
        // Recreate the date with the adjusted year
        let adjustedDateString = "\(date) \(adjustedYear)"
        
        guard let adjustedEventDate = fullDateFormatter.date(from: adjustedDateString) else {
            return nil
        }
        
        // Parse the time - try different formats
        let timeFormats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        var eventTime: Date?
        
        for format in timeFormats {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = format
            timeFormatter.locale = Locale(identifier: "en_US")
            
            if let parsedTime = timeFormatter.date(from: time) {
                eventTime = parsedTime
                break
            }
        }
        
        guard let eventTime = eventTime else {
            return nil
        }
        
        // Combine date and time
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: adjustedEventDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: eventTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        // Set timezone to Eastern Time (Gary's Guide events are typically in NYC)
        combinedComponents.timeZone = TimeZone(identifier: "America/New_York")
        
        return calendar.date(from: combinedComponents)
    }
}

// Mock models for testing
struct GarysGuideEvent {
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
}

struct CalendarEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
}

// Run the test
let tester = GarysGuideCalendarIntegrationTester()
tester.testCalendarIntegration()

print("\n=== GARY'S GUIDE CALENDAR INTEGRATION TEST COMPLETE ===")
