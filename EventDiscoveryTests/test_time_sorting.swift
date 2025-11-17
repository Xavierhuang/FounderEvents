#!/usr/bin/env swift

import Foundation

// Test time sorting functionality
print("=== TESTING TIME SORTING ===")

class TimeSortingTester {
    func testTimeSorting() {
        print("🔍 Testing time sorting...")
        
        // Create test events with different times on the same date
        let testEvents = [
            GarysGuideEvent(title: "Event 1", date: "Aug 07", time: "11:00pm", price: "Free", venue: "Venue 1", speakers: "Speaker 1", url: "http://test1.com", isGaryEvent: false, isPopularEvent: false, week: "AUG 04"),
            GarysGuideEvent(title: "Event 2", date: "Aug 07", time: "1:00pm", price: "Free", venue: "Venue 2", speakers: "Speaker 2", url: "http://test2.com", isGaryEvent: false, isPopularEvent: false, week: "AUG 04"),
            GarysGuideEvent(title: "Event 3", date: "Aug 07", time: "3:00pm", price: "Free", venue: "Venue 3", speakers: "Speaker 3", url: "http://test3.com", isGaryEvent: false, isPopularEvent: false, week: "AUG 04"),
            GarysGuideEvent(title: "Event 4", date: "Aug 07", time: "12:00am", price: "Free", venue: "Venue 4", speakers: "Speaker 4", url: "http://test4.com", isGaryEvent: false, isPopularEvent: false, week: "AUG 04"),
            GarysGuideEvent(title: "Event 5", date: "Aug 07", time: "6:00pm", price: "Free", venue: "Venue 5", speakers: "Speaker 5", url: "http://test5.com", isGaryEvent: false, isPopularEvent: false, week: "AUG 04")
        ]
        
        print("📅 Original events order:")
        for (index, event) in testEvents.enumerated() {
            print("  \(index + 1). \(event.title) - \(event.date) \(event.time)")
        }
        
        // Test chronological sorting
        print("\n🔄 Testing chronological sorting...")
        let sortedEvents = testEvents.sorted { event1, event2 in
            let date1 = parseDateForSorting(event1.date)
            let date2 = parseDateForSorting(event2.date)
            
            if date1 == date2 {
                // If same date, sort by time - convert times to comparable values
                let time1 = parseTimeForSorting(event1.time)
                let time2 = parseTimeForSorting(event2.time)
                return time1 < time2
            }
            return date1 < date2
        }
        
        print("📅 Sorted events order:")
        for (index, event) in sortedEvents.enumerated() {
            print("  \(index + 1). \(event.title) - \(event.date) \(event.time)")
        }
        
        // Verify the order is correct
        let expectedOrder = ["12:00am", "1:00pm", "3:00pm", "6:00pm", "11:00pm"]
        let actualOrder = sortedEvents.map { $0.time }
        
        print("\n✅ Expected order: \(expectedOrder)")
        print("✅ Actual order: \(actualOrder)")
        
        let isCorrect = actualOrder == expectedOrder
        print("✅ Time sorting is \(isCorrect ? "CORRECT" : "INCORRECT")")
        
        print("\n✅ Time sorting test completed!")
    }
    
    private func parseDateForSorting(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        dateFormatter.locale = Locale(identifier: "en_US")
        
        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())
        let fullDateString = "\(dateString) \(currentYear)"
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM dd yyyy"
        fullDateFormatter.locale = Locale(identifier: "en_US")
        
        return fullDateFormatter.date(from: fullDateString) ?? Date()
    }
    
    private func parseTimeForSorting(_ timeString: String) -> Date {
        // Try different time formats
        let timeFormats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        
        for format in timeFormats {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = format
            timeFormatter.locale = Locale(identifier: "en_US")
            
            if let parsedTime = timeFormatter.date(from: timeString) {
                return parsedTime
            }
        }
        
        // If all parsing fails, return a default date
        return Date()
    }
}

// Mock GarysGuideEvent for testing
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

// Run the test
let tester = TimeSortingTester()
tester.testTimeSorting() 