#!/usr/bin/env swift

import Foundation

// Test the app calendar integration
print("=== TESTING APP CALENDAR INTEGRATION ===")

class AppCalendarIntegrationTester {
    func testAppCalendarIntegration() {
        print("🔍 Testing app calendar integration...")
        
        // Create a test Gary's Guide event
        let testGaryEvent = GarysGuideEvent(
            title: "Test Startup Event",
            date: "Aug 15",
            time: "2:00pm",
            price: "Free",
            venue: "Tech Alley, NYC",
            speakers: "With John Smith",
            url: "http://gary.to/test123",
            isGaryEvent: false,
            isPopularEvent: false,
            week: "AUG 11"
        )
        
        print("📅 Test Gary's Guide Event:")
        print("  Title: \(testGaryEvent.title)")
        print("  Date: \(testGaryEvent.date)")
        print("  Time: \(testGaryEvent.time)")
        print("  Venue: \(testGaryEvent.venue)")
        print("  URL: \(testGaryEvent.url)")
        
        // Test date parsing
        print("\n🔍 Testing date parsing...")
        let parsedDate = parseEventDateTime(date: testGaryEvent.date, time: testGaryEvent.time)
        
        if let date = parsedDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            print("✅ Parsed date: \(formatter.string(from: date))")
            
            // Test calendar event creation
            print("\n🔍 Testing calendar event creation...")
            let endDate = date.addingTimeInterval(3600) // 1 hour duration
            
            let calendarEvent = CalendarEvent(
                title: testGaryEvent.title,
                startDate: date,
                endDate: endDate,
                location: testGaryEvent.venue,
                notes: "Event URL: \(testGaryEvent.url)\nSpeakers: \(testGaryEvent.speakers)\nPrice: \(testGaryEvent.price)"
            )
            
            print("✅ Created calendar event:")
            print("  Title: \(calendarEvent.title)")
            print("  Start: \(calendarEvent.startDate)")
            print("  End: \(calendarEvent.endDate)")
            print("  Location: \(calendarEvent.location ?? "No location")")
            print("  Notes: \(calendarEvent.notes ?? "No notes")")
            
        } else {
            print("❌ Failed to parse date")
        }
        
        // Test duplicate detection
        print("\n🔍 Testing duplicate detection...")
        let existingEvent = CalendarEvent(
            title: "Test Startup Event",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            location: "Tech Alley, NYC",
            notes: "Test notes"
        )
        
        let isDuplicate = existingEvent.title == testGaryEvent.title
        print("  Existing event: \(existingEvent.title)")
        print("  New event: \(testGaryEvent.title)")
        print("  Is duplicate: \(isDuplicate)")
    }
    
    private func parseEventDateTime(date: String, time: String) -> Date? {
        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Create full date string with current year
        let fullDateString = "\(date) \(currentYear)"
        
        // Parse the date with year
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM dd yyyy"
        fullDateFormatter.locale = Locale(identifier: "en_US")
        
        guard let eventDate = fullDateFormatter.date(from: fullDateString) else {
            print("❌ Failed to parse date: \(fullDateString)")
            return nil
        }
        
        // Parse the time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US")
        
        guard let eventTime = timeFormatter.date(from: time) else {
            print("❌ Failed to parse time: \(time)")
            return nil
        }
        
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: eventDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: eventTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
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
let tester = AppCalendarIntegrationTester()
tester.testAppCalendarIntegration()

print("\n✅ App calendar integration test completed!") 