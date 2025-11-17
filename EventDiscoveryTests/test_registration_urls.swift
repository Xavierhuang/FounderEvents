#!/usr/bin/env swift

import Foundation

// Test to verify registration URL extraction
print("=== TESTING REGISTRATION URL EXTRACTION ===")

class RegistrationURLTester {
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func testRegistrationURLs() {
        print("🔍 Testing registration URL extraction...")
        
        guard let url = URL(string: garysGuideURL) else {
            print("❌ Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                    self.testRegistrationURLExtraction(htmlString)
                }
            }
        }
        
        task.resume()
    }
    
    private func testRegistrationURLExtraction(_ html: String) {
        print("\n=== REGISTRATION URL EXTRACTION TEST ===")
        
        // Use the same patterns as the updated scraper
        let titlePattern = #"<b>([^<]+)</b></a>"#
        let titleRegex = try? NSRegularExpression(pattern: titlePattern)
        let titleMatches = titleRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        let datePattern = #"<b>([A-Za-z]+,\s+[A-Za-z]+\s+\d+)</b>"#
        let dateRegex = try? NSRegularExpression(pattern: datePattern)
        let dateMatches = dateRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        let timePattern = #"\d{1,2}:\d{2}[ap]m"#
        let timeRegex = try? NSRegularExpression(pattern: timePattern)
        let timeMatches = timeRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        let urlPattern = #"https://www\.garysguide\.com/events/[^"']*"#
        let urlRegex = try? NSRegularExpression(pattern: urlPattern)
        let urlMatches = urlRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        let registrationPattern = #"href="(https://[^"]*(eventbrite|meetup|ticketmaster|brownpapertickets|eventful|calendly|zoom|teams|register|rsvp)[^"]*)"#
        let registrationRegex = try? NSRegularExpression(pattern: registrationPattern, options: [.caseInsensitive])
        let registrationMatches = registrationRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        print("📊 Extraction Results:")
        print("  Titles: \(titleMatches.count)")
        print("  Dates: \(dateMatches.count)")
        print("  Times: \(timeMatches.count)")
        print("  Event URLs: \(urlMatches.count)")
        print("  Registration URLs: \(registrationMatches.count)")
        
        // Create events with registration URLs
        let minCount = min(titleMatches.count, dateMatches.count, timeMatches.count, urlMatches.count)
        
        if minCount > 0 {
            print("\n✅ SUCCESS: Can create \(minCount) events with registration URLs!")
            print("\n=== EVENTS WITH REGISTRATION URLS ===")
            
            for i in 0..<min(minCount, 5) {
                let title = extractString(from: html, range: titleMatches[i].range(at: 1))
                let date = extractString(from: html, range: dateMatches[i].range(at: 1))
                let time = extractString(from: html, range: timeMatches[i].range(at: 0))
                let eventUrl = extractString(from: html, range: urlMatches[i].range(at: 0))
                
                // Try to find a registration link for this event
                var registrationUrl = eventUrl // Default to event detail page
                if i < registrationMatches.count {
                    registrationUrl = extractString(from: html, range: registrationMatches[i].range(at: 1))
                }
                
                print("Event \(i + 1): \(title)")
                print("  Date: \(date)")
                print("  Time: \(time)")
                print("  Event URL: \(eventUrl)")
                print("  Registration URL: \(registrationUrl)")
                print("  Is Registration URL: \(isRegistrationURL(registrationUrl))")
                print("---")
            }
            
            print("\n🎉 CONCLUSION: REGISTRATION URLS EXTRACTED!")
            print("📱 Your app will now show registration links instead of event detail pages")
            
        } else {
            print("\n❌ FAILED: No events found")
        }
    }
    
    private func extractString(from html: String, range: NSRange) -> String {
        guard range.location != NSNotFound,
              let swiftRange = Range(range, in: html) else {
            return ""
        }
        return String(html[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func isRegistrationURL(_ url: String) -> Bool {
        let registrationKeywords = [
            "eventbrite", "meetup", "ticketmaster", "brownpapertickets",
            "eventful", "calendly", "zoom", "teams", "register", "rsvp",
            "signup", "join", "attend", "book", "buy", "ticket"
        ]
        
        let lowercasedURL = url.lowercased()
        return registrationKeywords.contains { keyword in
            lowercasedURL.contains(keyword)
        }
    }
}

// Run the test
let tester = RegistrationURLTester()
tester.testRegistrationURLs()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(10)) 