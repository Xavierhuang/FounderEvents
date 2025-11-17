#!/usr/bin/env swift

import Foundation

// Test calendar event creation and date handling
print("=== TESTING CALENDAR EVENT CREATION ===")

class CalendarEventCreationTester {
    func testEventCreation() {
        print("🔍 Testing calendar event creation...")
        
        // Test creating events with different dates
        let testEvents = [
            ("AI Tech Meetup", "Aug 15", "2:00pm"),
            ("Startup Networking", "Aug 20", "7:30pm"),
            ("Coding Workshop", "Sep 05", "6:00pm"),
            ("Product Demo", "Dec 31", "11:59pm"),
            ("New Year Party", "Jan 01", "12:00am")
        ]
        
        for (title, date, time) in testEvents {
            print("\n📅 Testing event: \(title)")
            print("   Date: \(date), Time: \(time)")
            
            if let parsedDate = parseEventDateTime(date: date, time: time) {
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                formatter.timeStyle = .short
                formatter.timeZone = TimeZone(identifier: "America/New_York")
                
                print("✅ Parsed date: \(formatter.string(from: parsedDate))")
                
                // Test calendar day matching
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "America/New_York")!
                
                let eventDay = calendar.component(.day, from: parsedDate)
                let eventMonth = calendar.component(.month, from: parsedDate)
                let eventYear = calendar.component(.year, from: parsedDate)
                
                print("   Event day: \(eventDay), month: \(eventMonth), year: \(eventYear)")
                
                // Test if the event would appear on the correct calendar day
                let isSameDay = calendar.isDate(parsedDate, inSameDayAs: parsedDate)
                print("   Would appear on calendar: \(isSameDay ? "Yes" : "No")")
                
            } else {
                print("❌ Failed to parse date")
            }
        }
    }
    
    func testCalendarDayMatching() {
        print("\n🔍 Testing calendar day matching...")
        
        // Create a test event
        let eventDate = parseEventDateTime(date: "Aug 15", time: "2:00pm")!
        
        // Test matching against different dates
        let testDates = [
            ("Same day", eventDate),
            ("Next day", Calendar.current.date(byAdding: .day, value: 1, to: eventDate)!),
            ("Previous day", Calendar.current.date(byAdding: .day, value: -1, to: eventDate)!),
            ("Same day different time", Calendar.current.date(byAdding: .hour, value: 5, to: eventDate)!)
        ]
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        
        for (description, testDate) in testDates {
            let isSameDay = calendar.isDate(eventDate, inSameDayAs: testDate)
            print("   \(description): \(isSameDay ? "Match" : "No match")")
        }
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

// Run the tests
let tester = CalendarEventCreationTester()
tester.testEventCreation()
tester.testCalendarDayMatching()

print("\n=== CALENDAR EVENT CREATION TEST COMPLETE ===")
