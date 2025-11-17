#!/usr/bin/env swift

import Foundation

// Test Gary's Guide date parsing
print("=== TESTING GARY'S GUIDE DATE PARSING ===")

class GarysGuideDateParsingTester {
    func testDateParsing() {
        print("🔍 Testing date parsing logic...")
        
        // Test cases with different date formats
        let testCases = [
            ("Aug 15", "2:00pm"),
            ("Aug 20", "7:30pm"),
            ("Sep 05", "6:00pm"),
            ("Dec 31", "11:59pm"),
            ("Jan 01", "12:00am")
        ]
        
        for (date, time) in testCases {
            print("\n📅 Testing date: '\(date)', time: '\(time)'")
            
            if let parsedDate = parseEventDateTime(date: date, time: time) {
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                formatter.timeStyle = .short
                formatter.timeZone = TimeZone(identifier: "America/New_York")
                
                print("✅ Parsed successfully: \(formatter.string(from: parsedDate))")
                
                // Check if the date makes sense
                let calendar = Calendar.current
                let now = Date()
                let eventYear = calendar.component(.year, from: parsedDate)
                let currentYear = calendar.component(.year, from: now)
                
                if eventYear < currentYear {
                    print("⚠️ Warning: Event year (\(eventYear)) is before current year (\(currentYear))")
                } else if eventYear > currentYear + 1 {
                    print("⚠️ Warning: Event year (\(eventYear)) is more than 1 year in the future")
                } else {
                    print("✅ Date year looks reasonable")
                }
            } else {
                print("❌ Failed to parse date")
            }
        }
    }
    
    private func parseEventDateTime(date: String, time: String) -> Date? {
        print("🔍 parseEventDateTime called with date: '\(date)', time: '\(time)'")
        
        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // Create full date string with current year
        let fullDateString = "\(date) \(currentYear)"
        print("📅 Full date string: '\(fullDateString)'")
        
        // Parse the date with year
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM dd yyyy"
        fullDateFormatter.locale = Locale(identifier: "en_US")
        
        guard let eventDate = fullDateFormatter.date(from: fullDateString) else {
            print("❌ Failed to parse date: \(fullDateString)")
            return nil
        }
        
        print("📅 Parsed event date: \(eventDate)")
        
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
            print("⚠️ Event date appears to be in the past, adjusting to next year: \(adjustedYear)")
        }
        
        // Recreate the date with the adjusted year
        let adjustedDateString = "\(date) \(adjustedYear)"
        print("📅 Adjusted date string: '\(adjustedDateString)'")
        
        guard let adjustedEventDate = fullDateFormatter.date(from: adjustedDateString) else {
            print("❌ Failed to parse adjusted date: \(adjustedDateString)")
            return nil
        }
        
        print("📅 Final event date: \(adjustedEventDate)")
        
        // Parse the time - try different formats
        let timeFormats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        var eventTime: Date?
        
        for format in timeFormats {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = format
            timeFormatter.locale = Locale(identifier: "en_US")
            
            if let parsedTime = timeFormatter.date(from: time) {
                eventTime = parsedTime
                print("⏰ Parsed time with format '\(format)': \(parsedTime)")
                break
            }
        }
        
        guard let eventTime = eventTime else {
            print("❌ Failed to parse time: \(time)")
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
        
        let finalDate = calendar.date(from: combinedComponents)
        print("🎯 Final combined date: \(finalDate?.description ?? "nil")")
        
        return finalDate
    }
}

// Run the test
let tester = GarysGuideDateParsingTester()
tester.testDateParsing()

print("\n=== DATE PARSING TEST COMPLETE ===")
