//
//  AITextExtractor.swift
//  ScheduleShare
//
//  AI-powered text extraction using GPT Vision
//

import Foundation
import UIKit

class AITextExtractor: ObservableObject {
    private let visionService = GPTVisionService()
    
    init() {
        // Vision service is ready to use
    }
    
    func extractEventInfo(from image: UIImage, completion: @escaping (Result<ExtractedEventInfo, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(AIExtractionError.invalidImage))
            return
        }
        
        Task {
            do {
                print("🤖 Using GPT Vision for direct image analysis...")
                
                // Use the vision service to extract event details
                let extractedEvent = try await visionService.extractEventDetails(imageData)
                
                print("🔍 Vision extracted: \(extractedEvent)")
                
                // Convert to ExtractedEventInfo format
                let title = extractedEvent.event_name
                let location = formatLocation(extractedEvent.event_location)
                
                // Parse event time
                var startDateTime: Date?
                var endDateTime: Date?
                
                if let timeString = extractedEvent.event_time {
                    // Handle multiple dates by taking the first one
                    let firstTimeString = timeString.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? timeString
                    print("🕐 Processing first time string: '\(firstTimeString)'")
                    
                    // Try to parse the time string
                    startDateTime = parseEventTime(firstTimeString)
                    if startDateTime != nil {
                        // Default to 1 hour duration if no end time specified
                        endDateTime = Calendar.current.date(byAdding: .hour, value: 1, to: startDateTime!)
                    }
                }
                
                let extractedInfo = ExtractedEventInfo(
                    rawText: "GPT Vision Analysis",
                    title: title,
                    startDateTime: startDateTime,
                    endDateTime: endDateTime,
                    location: location,
                    description: "Event details extracted from image using GPT Vision",
                    confidence: 0.9 // High confidence for vision analysis
                )
                
                print("✅ GPT Vision extraction successful!")
                completion(.success(extractedInfo))
                
            } catch {
                print("❌ GPT Vision error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func parseEventTime(_ timeString: String) -> Date? {
        print("🕐 Parsing event time: '\(timeString)'")
        
        // First, try to parse as time-only format (like "11 a.m.", "2 p.m.")
        if let timeOnlyDate = parseTimeOnly(timeString) {
            print("✅ Successfully parsed time-only: \(timeOnlyDate)")
            return timeOnlyDate
        }
        
        // Try various date formats
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "MMM dd, yyyy 'at' HH:mm",
            "MMM dd 'at' HH:mm",
            "MMM dd, yyyy 'at' h:mm a",  // September 10, 2025 at 7:00 PM
            "MMM dd 'at' h:mm a",        // September 10 at 7:00 PM
            "h:mm a",                    // 11:00 AM, 2:30 PM
            "h a",                       // 11 AM, 2 PM
            "MMM dd, yyyy",              // September 10, 2025
            "MMM dd",                    // September 10
            "MM/dd/yyyy HH:mm",
            "MM/dd/yyyy",
            "MMM dd, yyyy"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(identifier: "America/New_York")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = formatter.date(from: timeString) {
                print("✅ Successfully parsed date: \(date) using format: \(format)")
                return date
            }
        }
        
        // Try to parse with more flexible approach
        if let flexibleDate = parseFlexibleDate(timeString) {
            print("✅ Successfully parsed date with flexible parsing: \(flexibleDate)")
            return flexibleDate
        }
        
        print("❌ Failed to parse date, using current date")
        return Date()
    }
    
    private func parseTimeOnly(_ timeString: String) -> Date? {
        // Handle time-only formats like "11 a.m.", "2 p.m.", "11:30 a.m.", etc.
        let cleanedString = timeString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to extract hour and AM/PM
        let timePattern = #"(\d+)(?::(\d+))?\s*(a\.?m\.?|p\.?m\.?)"#
        
        guard let regex = try? NSRegularExpression(pattern: timePattern, options: .caseInsensitive) else {
            return nil
        }
        
        let range = NSRange(location: 0, length: cleanedString.utf16.count)
        guard let match = regex.firstMatch(in: cleanedString, options: [], range: range) else {
            return nil
        }
        
        // Extract hour
        guard let hourRange = Range(match.range(at: 1), in: cleanedString),
              let hour = Int(String(cleanedString[hourRange])) else {
            return nil
        }
        
        // Extract minutes (optional)
        var minute = 0
        if match.range(at: 2).location != NSNotFound,
           let minuteRange = Range(match.range(at: 2), in: cleanedString) {
            minute = Int(String(cleanedString[minuteRange])) ?? 0
        }
        
        // Extract AM/PM
        guard let ampmRange = Range(match.range(at: 3), in: cleanedString) else {
            return nil
        }
        let ampm = String(cleanedString[ampmRange])
        let isPM = ampm.hasPrefix("p")
        
        // Convert to 24-hour format
        var finalHour = hour
        if isPM && hour != 12 {
            finalHour += 12
        } else if !isPM && hour == 12 {
            finalHour = 0
        }
        
        print("🕐 Parsed time-only: hour=\(finalHour), minute=\(minute)")
        
        // Create date for today with the parsed time
        let calendar = Calendar.current
        let today = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        dateComponents.hour = finalHour
        dateComponents.minute = minute
        dateComponents.timeZone = TimeZone(identifier: "America/New_York")
        
        let resultDate = calendar.date(from: dateComponents)
        print("🕐 Created time-only date: \(resultDate?.description ?? "nil")")
        
        return resultDate
    }
    
    private func formatLocation(_ location: String?) -> String? {
        guard let location = location?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        
        let lowercasedLocation = location.lowercased()
        
        // Check for virtual meeting platforms
        if lowercasedLocation.contains("zoom") {
            return "Virtual Meeting (Zoom)"
        } else if lowercasedLocation.contains("google meet") || lowercasedLocation.contains("googlemeet") {
            return "Virtual Meeting (Google Meet)"
        } else if lowercasedLocation.contains("teams") || lowercasedLocation.contains("microsoft teams") {
            return "Virtual Meeting (Microsoft Teams)"
        } else if lowercasedLocation.contains("webex") {
            return "Virtual Meeting (Webex)"
        } else if lowercasedLocation.contains("skype") {
            return "Virtual Meeting (Skype)"
        } else if lowercasedLocation.contains("meet") && lowercasedLocation.contains("google") {
            return "Virtual Meeting (Google Meet)"
        } else if lowercasedLocation.contains("virtual") || lowercasedLocation.contains("online") {
            // If it's already marked as virtual/online, keep it as is
            return location
        }
        
        // For physical locations, return as is
        return location
    }
    
    private func parseFlexibleDate(_ timeString: String) -> Date? {
        // Handle formats like "September 10th, 7 pm"
        let cleanedString = timeString.lowercased()
        
        // Extract month
        let months = ["january", "february", "march", "april", "may", "june",
                     "july", "august", "september", "october", "november", "december"]
        
        var monthIndex: Int?
        var day: Int?
        var hour: Int?
        var minute: Int = 0
        var isPM = false
        
        // Find month
        for (index, month) in months.enumerated() {
            if cleanedString.contains(month) {
                monthIndex = index + 1
                break
            }
        }
        
        // Extract day (look for "10th", "1st", "2nd", "3rd", etc.)
        let dayPattern = #"(\d+)(?:st|nd|rd|th)"#
        if let dayRange = cleanedString.range(of: dayPattern, options: .regularExpression) {
            let dayString = String(cleanedString[dayRange])
            day = Int(dayString.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression))
        }
        
        // Extract time - handle multiple times by taking the first one
        let timePattern = #"(\d+)\s*(?::(\d+))?\s*(am|pm)"#
        if let timeRange = cleanedString.range(of: timePattern, options: .regularExpression) {
            let timeString = String(cleanedString[timeRange])
            print("🕐 Extracted time string: '\(timeString)'")
            
            // Parse hour
            let hourPattern = #"(\d+)"#
            if let hourRange = timeString.range(of: hourPattern, options: .regularExpression) {
                let hourStr = String(timeString[hourRange])
                if let parsedHour = Int(hourStr) {
                    hour = parsedHour
                    print("🕐 Parsed hour: \(parsedHour)")
                }
            }
            
            // Check if PM
            if timeString.contains("pm") {
                isPM = true
                print("🕐 Detected PM")
            }
            
            // Parse minutes if present
            let minutePattern = #":(\d+)"#
            if let minuteRange = timeString.range(of: minutePattern, options: .regularExpression) {
                let minuteStr = String(timeString[minuteRange]).replacingOccurrences(of: ":", with: "")
                if let parsedMinute = Int(minuteStr) {
                    minute = parsedMinute
                    print("🕐 Parsed minutes: \(parsedMinute)")
                }
            }
        }
        
        // Build date
        guard let month = monthIndex, let dayValue = day, let hourValue = hour else {
            return nil
        }
        
        var finalHour = hourValue
        if isPM && hourValue != 12 {
            finalHour += 12
        } else if !isPM && hourValue == 12 {
            finalHour = 0
        }
        
        print("🕐 Final hour after PM conversion: \(finalHour)")
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // Create date components in New York timezone
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = month
        dateComponents.day = dayValue
        dateComponents.hour = finalHour
        dateComponents.minute = minute
        dateComponents.timeZone = TimeZone(identifier: "America/New_York")
        
        let nyDate = calendar.date(from: dateComponents)
        print("🕐 Created NY date: \(nyDate?.description ?? "nil")")
        
        return nyDate
    }
    
    // MARK: - Legacy Text Extraction (kept for compatibility)
    func extractEventInfo(from text: String, completion: @escaping (Result<ExtractedEventInfo, Error>) -> Void) {
        // This method is deprecated - use extractEventInfo(from image:) instead
        print("⚠️ Text-based extraction is deprecated. Please use image-based extraction.")
        
        let fallbackInfo = ExtractedEventInfo(
            rawText: text,
            title: "Event from Text",
            startDateTime: Date(),
            endDateTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()),
            location: nil,
            description: text,
            confidence: 0.3
        )
        
        completion(.success(fallbackInfo))
    }
}

// Error types are defined in Models.swift 
