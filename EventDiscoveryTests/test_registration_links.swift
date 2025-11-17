#!/usr/bin/env swift

import Foundation

// Test to find registration links in Gary's Guide events
print("=== TESTING REGISTRATION LINKS EXTRACTION ===")

class RegistrationLinkTester {
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func testRegistrationLinks() {
        print("🔍 Testing registration link extraction...")
        
        guard let url = URL(string: garysGuideURL) else {
            print("❌ Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                    self.findRegistrationLinks(htmlString)
                }
            }
        }
        
        task.resume()
    }
    
    private func findRegistrationLinks(_ html: String) {
        print("\n=== REGISTRATION LINK SEARCH ===")
        
        // Look for various registration link patterns
        let patterns = [
            // Pattern 1: Look for "Register" links
            #"href="([^"]*register[^"]*)"#,
            
            // Pattern 2: Look for "RSVP" links
            #"href="([^"]*rsvp[^"]*)"#,
            
            // Pattern 3: Look for "Sign up" links
            #"href="([^"]*sign.?up[^"]*)"#,
            
            // Pattern 4: Look for "Join" links
            #"href="([^"]*join[^"]*)"#,
            
            // Pattern 5: Look for "Attend" links
            #"href="([^"]*attend[^"]*)"#,
            
            // Pattern 6: Look for external registration URLs (Eventbrite, Meetup, etc.)
            #"href="(https://[^"]*(eventbrite|meetup|ticketmaster|brownpapertickets|eventful)[^"]*)"#,
            
            // Pattern 7: Look for "Add to Calendar" links
            #"href="([^"]*calendar[^"]*)"#,
            
            // Pattern 8: Look for "Book" or "Buy" links
            #"href="([^"]*(book|buy|ticket)[^"]*)"#
        ]
        
        for (index, pattern) in patterns.enumerated() {
            let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(location: 0, length: html.utf16.count)
            
            if let matches = regex?.matches(in: html, options: [], range: range) {
                print("✅ Pattern \(index + 1): Found \(matches.count) matches")
                
                // Show first few matches
                for (matchIndex, match) in matches.prefix(3).enumerated() {
                    if match.numberOfRanges >= 2 {
                        let link = extractString(from: html, range: match.range(at: 1))
                        print("  Match \(matchIndex + 1): \(link)")
                    }
                }
            } else {
                print("❌ Pattern \(index + 1): No matches")
            }
        }
        
        // Also look for common registration text patterns
        print("\n=== REGISTRATION TEXT SEARCH ===")
        let textPatterns = [
            "Register",
            "RSVP",
            "Sign up",
            "Join",
            "Attend",
            "Book now",
            "Get tickets",
            "Add to calendar"
        ]
        
        for text in textPatterns {
            let count = html.components(separatedBy: text).count - 1
            if count > 0 {
                print("✅ Found '\(text)' \(count) times")
            }
        }
        
        // Look for specific registration platforms
        print("\n=== REGISTRATION PLATFORMS SEARCH ===")
        let platforms = [
            "eventbrite.com",
            "meetup.com",
            "ticketmaster.com",
            "brownpapertickets.com",
            "eventful.com",
            "calendly.com",
            "zoom.us",
            "teams.microsoft.com"
        ]
        
        for platform in platforms {
            let count = html.components(separatedBy: platform).count - 1
            if count > 0 {
                print("✅ Found \(platform) \(count) times")
            }
        }
    }
    
    private func extractString(from html: String, range: NSRange) -> String {
        guard range.location != NSNotFound,
              let swiftRange = Range(range, in: html) else {
            return ""
        }
        return String(html[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Run the test
let tester = RegistrationLinkTester()
tester.testRegistrationLinks()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(10)) 