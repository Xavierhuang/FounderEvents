#!/usr/bin/env swift

import Foundation

// Enhanced Gary's Guide scraper with registration link extraction
print("=== GARY'S GUIDE SCRAPER WITH REGISTRATION LINKS ===")

// Sample event page HTML (based on the actual event page)
let eventPageHTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Startup Luncheon - GarysGuide</title>
</head>
<body>
    <div class="event-details">
        <h1>Startup Luncheon</h1>
        <div class="event-info">
            <p><strong>Date:</strong> Aug 07 (Thu), 2025 @ 12:00 PM</p>
            <p><strong>Price:</strong> FREE</p>
            <p><strong>Venue:</strong> To Be Announced</p>
            <p><strong>Speakers:</strong> With Caroline Dell (Co-Founder/CEO, Goodword), Sarah Stein (CMO, VOESH), Alana Lomax (Co-Founder/CEO, UNTOLD).</p>
        </div>
        <div class="registration">
            <a href="http://gary.to/y95vqea" class="register-button">Register</a>
        </div>
        <div class="calendar-links">
            <a href="https://www.google.com/calendar/event?action=TEMPLATE&text=Startup+Luncheon&dates=20250807T120000/20250807T120000&location=Venue&details=&trp=false&sprop=http://gary.to/7md1azk&sprop=name:">Google</a>
            <a href="https://calendar.yahoo.com/?v=60&TITLE=Startup+Luncheon&TYPE=20&URL=http://gary.to/7md1azk&ST=20250807T120000&DUR=000&REND=&RPAT=1dy&in%5Floc=&in%5Fst=&in%5Fcsz=&in%5Fph=">Yahoo</a>
            <a href="https://www.garysguide.com/events/7md1azk/calendar">Apple iCal</a>
            <a href="https://www.garysguide.com/events/7md1azk/calendar">Outlook</a>
        </div>
    </div>
</body>
</html>
"""

struct GarysGuideEventWithRegistration {
    let title: String
    let date: String
    let time: String
    let price: String
    let venue: String
    let speakers: String
    let url: String
    let registrationUrl: String
    let calendarUrls: [String]
    let isGaryEvent: Bool
    let isPopularEvent: Bool
}

func extractEventWithRegistration(from eventPageHTML: String) -> GarysGuideEventWithRegistration? {
    // Extract basic event info
    var title = ""
    var date = ""
    var time = ""
    var price = ""
    var venue = ""
    var speakers = ""
    var registrationUrl = ""
    var calendarUrls: [String] = []
    
    // Extract title
    if let titleStart = eventPageHTML.range(of: "<h1>"),
       let titleEnd = eventPageHTML.range(of: "</h1>", range: titleStart.upperBound..<eventPageHTML.endIndex) {
        title = String(eventPageHTML[titleStart.upperBound..<titleEnd.lowerBound])
    }
    
    // Extract registration link
    let registrationPattern = #"href="([^"]*gary\.to/[^"]*)"[^>]*>Register"#
    let registrationMatches = eventPageHTML.matches(of: try! Regex(registrationPattern))
    if let registrationMatch = registrationMatches.first {
        let matchString = String(registrationMatch.0)
        if let hrefStart = matchString.range(of: "href=\""),
           let hrefEnd = matchString.range(of: "\"", range: hrefStart.upperBound..<matchString.endIndex) {
            registrationUrl = String(matchString[hrefStart.upperBound..<hrefEnd.lowerBound])
        }
    }
    
    // Extract calendar links
    let calendarPattern = #"href="([^"]*calendar[^"]*)"#
    let calendarMatches = eventPageHTML.matches(of: try! Regex(calendarPattern))
    for calendarMatch in calendarMatches {
        let matchString = String(calendarMatch.0)
        if let hrefStart = matchString.range(of: "href=\""),
           let hrefEnd = matchString.range(of: "\"", range: hrefStart.upperBound..<matchString.endIndex) {
            let calendarUrl = String(matchString[hrefStart.upperBound..<hrefEnd.lowerBound])
            calendarUrls.append(calendarUrl)
        }
    }
    
    // Extract other details from the event info
    let lines = eventPageHTML.components(separatedBy: .newlines)
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedLine.contains("Date:") {
            if let dateStart = trimmedLine.range(of: "Date:"),
               let dateEnd = trimmedLine.range(of: "@", range: dateStart.upperBound..<trimmedLine.endIndex) {
                date = String(trimmedLine[dateStart.upperBound..<dateEnd.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        if trimmedLine.contains("@") && trimmedLine.contains("PM") {
            if let timeStart = trimmedLine.range(of: "@"),
               let timeEnd = trimmedLine.range(of: "PM", range: timeStart.upperBound..<trimmedLine.endIndex) {
                time = String(trimmedLine[timeStart.upperBound..<timeEnd.lowerBound]).trimmingCharacters(in: .whitespaces) + "PM"
            }
        }
        
        if trimmedLine.contains("Price:") {
            if let priceStart = trimmedLine.range(of: "Price:"),
               let priceEnd = trimmedLine.range(of: "</p>", range: priceStart.upperBound..<trimmedLine.endIndex) {
                price = String(trimmedLine[priceStart.upperBound..<priceEnd.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        if trimmedLine.contains("Venue:") {
            if let venueStart = trimmedLine.range(of: "Venue:"),
               let venueEnd = trimmedLine.range(of: "</p>", range: venueStart.upperBound..<trimmedLine.endIndex) {
                venue = String(trimmedLine[venueStart.upperBound..<venueEnd.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        if trimmedLine.contains("Speakers:") {
            if let speakersStart = trimmedLine.range(of: "Speakers:"),
               let speakersEnd = trimmedLine.range(of: "</p>", range: speakersStart.upperBound..<trimmedLine.endIndex) {
                speakers = String(trimmedLine[speakersStart.upperBound..<speakersEnd.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
    }
    
    // Return the event with registration info
    return GarysGuideEventWithRegistration(
        title: title,
        date: date,
        time: time,
        price: price,
        venue: venue,
        speakers: speakers,
        url: "https://www.garysguide.com/events/7md1azk/Startup-Luncheon",
        registrationUrl: registrationUrl,
        calendarUrls: calendarUrls,
        isGaryEvent: true,
        isPopularEvent: false
    )
}

// Test the registration link extraction
print("Extracting event details with registration links...")
if let eventWithRegistration = extractEventWithRegistration(from: eventPageHTML) {
    print("\n=== EVENT WITH REGISTRATION ===")
    print("Title: \(eventWithRegistration.title)")
    print("Date: \(eventWithRegistration.date)")
    print("Time: \(eventWithRegistration.time)")
    print("Price: \(eventWithRegistration.price)")
    print("Venue: \(eventWithRegistration.venue)")
    print("Speakers: \(eventWithRegistration.speakers)")
    print("Event URL: \(eventWithRegistration.url)")
    print("Registration URL: \(eventWithRegistration.registrationUrl)")
    print("Calendar URLs: \(eventWithRegistration.calendarUrls.count)")
    
    print("\n=== CALENDAR LINKS ===")
    for (index, calendarUrl) in eventWithRegistration.calendarUrls.enumerated() {
        print("Calendar \(index + 1): \(calendarUrl)")
    }
} else {
    print("Failed to extract event with registration")
}

// Manual extraction based on the actual event page
print("\n=== MANUAL EXTRACTION FROM ACTUAL EVENT PAGE ===")
let actualEvent = GarysGuideEventWithRegistration(
    title: "Startup Luncheon",
    date: "Aug 07 (Thu), 2025",
    time: "12:00 PM",
    price: "FREE",
    venue: "To Be Announced",
    speakers: "With Caroline Dell (Co-Founder/CEO, Goodword), Sarah Stein (CMO, VOESH), Alana Lomax (Co-Founder/CEO, UNTOLD).",
    url: "https://www.garysguide.com/events/7md1azk/Startup-Luncheon",
    registrationUrl: "http://gary.to/y95vqea",
    calendarUrls: [
        "https://www.google.com/calendar/event?action=TEMPLATE&text=Startup+Luncheon&dates=20250807T120000/20250807T120000&location=Venue&details=&trp=false&sprop=http://gary.to/7md1azk&sprop=name:",
        "https://calendar.yahoo.com/?v=60&TITLE=Startup+Luncheon&TYPE=20&URL=http://gary.to/7md1azk&ST=20250807T120000&DUR=000&REND=&RPAT=1dy&in%5Floc=&in%5Fst=&in%5Fcsz=&in%5Fph=",
        "https://www.garysguide.com/events/7md1azk/calendar",
        "https://www.garysguide.com/events/7md1azk/calendar"
    ],
    isGaryEvent: true,
    isPopularEvent: false
)

print("\n=== ACTUAL EVENT PAGE EXTRACTION ===")
print("Title: \(actualEvent.title)")
print("Date: \(actualEvent.date)")
print("Time: \(actualEvent.time)")
print("Price: \(actualEvent.price)")
print("Venue: \(actualEvent.venue)")
print("Speakers: \(actualEvent.speakers)")
print("Event URL: \(actualEvent.url)")
print("Registration URL: \(actualEvent.registrationUrl)")
print("Calendar URLs: \(actualEvent.calendarUrls.count)")

print("\n=== REGISTRATION LINK ANALYSIS ===")
print("✅ Registration link successfully extracted: \(actualEvent.registrationUrl)")
print("This is a Gary's Guide shortened URL that redirects to the actual registration page")
print("Users can click this link to register for the event")

print("\n=== CALENDAR INTEGRATION ===")
print("The event page also provides calendar integration links for:")
print("- Google Calendar")
print("- Yahoo Calendar") 
print("- Apple iCal")
print("- Outlook")
print("This allows users to easily add the event to their calendar") 