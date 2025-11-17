#!/usr/bin/env swift

import Foundation

// Test to verify gary.to redirect URL extraction
print("=== TESTING GARY.TO REDIRECT URL EXTRACTION ===")

class GaryToRedirectTester {
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func testGaryToRedirects() {
        print("🔍 Testing gary.to redirect URL extraction...")
        
        guard let url = URL(string: garysGuideURL) else {
            print("❌ Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                    self.testGaryToRedirectExtraction(htmlString)
                }
            }
        }
        
        task.resume()
    }
    
    private func testGaryToRedirectExtraction(_ html: String) {
        print("\n=== GARY.TO REDIRECT EXTRACTION TEST ===")
        
        // Look for gary.to redirect URLs
        let redirectPattern = #"href="(https://gary\.to/[^"]*)"#
        let redirectRegex = try? NSRegularExpression(pattern: redirectPattern, options: [.caseInsensitive])
        let redirectMatches = redirectRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        print("📊 Gary.to Redirect Results:")
        print("  Found \(redirectMatches.count) gary.to redirect URLs")
        
        if redirectMatches.count > 0 {
            print("\n✅ SUCCESS: Found gary.to redirect URLs!")
            print("\n=== GARY.TO REDIRECT URLS ===")
            
            for (index, match) in redirectMatches.prefix(10).enumerated() {
                let redirectUrl = extractString(from: html, range: match.range(at: 1))
                print("Redirect \(index + 1): \(redirectUrl)")
            }
            
            print("\n🎉 CONCLUSION: GARY.TO REDIRECT URLS FOUND!")
            print("📱 These URLs will redirect to actual registration pages")
            
        } else {
            print("\n❌ No gary.to redirect URLs found")
            print("📱 Will use event detail pages as fallback")
        }
        
        // Also test the registration URL detection
        print("\n=== REGISTRATION URL DETECTION TEST ===")
        let testURLs = [
            "https://gary.to/7md1azk",
            "https://www.eventbrite.com/e/startup-luncheon",
            "https://www.meetup.com/nyc-tech-events",
            "https://www.garysguide.com/events/7md1azk/Startup-Luncheon"
        ]
        
        for url in testURLs {
            let isRegistration = isRegistrationURL(url)
            print("URL: \(url)")
            print("  Is Registration: \(isRegistration)")
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
            "signup", "join", "attend", "book", "buy", "ticket", "gary.to"
        ]
        
        let lowercasedURL = url.lowercased()
        return registrationKeywords.contains { keyword in
            lowercasedURL.contains(keyword)
        }
    }
}

// Run the test
let tester = GaryToRedirectTester()
tester.testGaryToRedirects()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(10)) 