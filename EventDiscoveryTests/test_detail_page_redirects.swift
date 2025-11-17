#!/usr/bin/env swift

import Foundation

// Test to verify redirect URL extraction from event detail pages
print("=== TESTING DETAIL PAGE REDIRECT EXTRACTION ===")

class DetailPageRedirectTester {
    func testDetailPageRedirects() {
        print("🔍 Testing redirect extraction from event detail pages...")
        
        // Test with a few known event URLs
        let testEventUrls = [
            "https://www.garysguide.com/events/7md1azk/Startup-Luncheon",
            "https://www.garysguide.com/events/55ajswc/Startup-Mixer",
            "https://www.garysguide.com/events/h5zj6us/Tech-Alley-First-Thursdays"
        ]
        
        let group = DispatchGroup()
        
        for (index, eventUrl) in testEventUrls.enumerated() {
            group.enter()
            
            print("\n--- Testing Event \(index + 1): \(eventUrl) ---")
            fetchRedirectURL(from: eventUrl) { redirectUrl in
                if let redirectUrl = redirectUrl {
                    print("✅ Found redirect: \(redirectUrl)")
                } else {
                    print("❌ No redirect found")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("\n=== DETAIL PAGE REDIRECT TEST COMPLETED ===")
        }
    }
    
    private func fetchRedirectURL(from eventUrl: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: eventUrl) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                // Look for redirect URLs (gary.to links)
                let redirectPattern = #"href="(http://gary\.to/[^"]*)"#
                let redirectRegex = try? NSRegularExpression(pattern: redirectPattern, options: [.caseInsensitive])
                let redirectMatches = redirectRegex?.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) ?? []
                
                if let firstMatch = redirectMatches.first {
                    let redirectUrl = self.extractString(from: htmlString, range: firstMatch.range(at: 1))
                    completion(redirectUrl)
                } else {
                    // Look for external registration links
                    let registrationPattern = #"href="(https://[^"]*(eventbrite|meetup|ticketmaster|brownpapertickets|eventful|calendly|zoom|teams|register|rsvp)[^"]*)"#
                    let registrationRegex = try? NSRegularExpression(pattern: registrationPattern, options: [.caseInsensitive])
                    let registrationMatches = registrationRegex?.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count)) ?? []
                    
                    if let firstMatch = registrationMatches.first {
                        let registrationUrl = self.extractString(from: htmlString, range: firstMatch.range(at: 1))
                        completion(registrationUrl)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        
        task.resume()
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
let tester = DetailPageRedirectTester()
tester.testDetailPageRedirects()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(15)) 