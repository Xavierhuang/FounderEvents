#!/usr/bin/env swift

import Foundation

// Test the updated scraper with detail page redirect fetching
print("=== TESTING UPDATED SCRAPER WITH DETAIL PAGE REDIRECTS ===")

class UpdatedScraperTester {
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func testUpdatedScraper() {
        print("🔍 Testing updated scraper with detail page redirect fetching...")
        
        guard let url = URL(string: garysGuideURL) else {
            print("❌ Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                    self.testParseEventsWithRedirects(htmlString)
                }
            }
        }
        
        task.resume()
    }
    
    private func testParseEventsWithRedirects(_ html: String) {
        print("\n=== PARSING EVENTS WITH REDIRECT FETCHING ===")
        
        // Extract event titles and URLs (first 3 events for testing)
        let titlePattern = #"<b>([^<]+)</b></a>"#
        let titleRegex = try? NSRegularExpression(pattern: titlePattern)
        let titleMatches = titleRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        let urlPattern = #"https://www\.garysguide\.com/events/[^"']*"#
        let urlRegex = try? NSRegularExpression(pattern: urlPattern)
        let urlMatches = urlRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        let minCount = min(3, titleMatches.count, urlMatches.count) // Test first 3 events
        
        print("📊 Testing first \(minCount) events with redirect fetching...")
        
        let group = DispatchGroup()
        var testEvents: [(title: String, url: String, redirectUrl: String?)] = []
        
        for i in 0..<minCount {
            group.enter()
            
            let title = extractString(from: html, range: titleMatches[i].range(at: 1))
            let eventUrl = extractString(from: html, range: urlMatches[i].range(at: 0))
            
            print("\n--- Processing Event \(i + 1): \(title) ---")
            print("  Event URL: \(eventUrl)")
            
            fetchRedirectURL(from: eventUrl) { redirectUrl in
                let finalUrl = redirectUrl ?? eventUrl
                testEvents.append((title: title, url: eventUrl, redirectUrl: redirectUrl))
                
                print("  Final URL: \(finalUrl)")
                if let redirectUrl = redirectUrl {
                    print("  ✅ Found redirect: \(redirectUrl)")
                } else {
                    print("  ⚠️ Using event detail page as fallback")
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("\n=== FINAL RESULTS ===")
            for (index, event) in testEvents.enumerated() {
                print("Event \(index + 1): \(event.title)")
                print("  Original URL: \(event.url)")
                if let redirectUrl = event.redirectUrl {
                    print("  ✅ Redirect URL: \(redirectUrl)")
                } else {
                    print("  ⚠️ No redirect found, using detail page")
                }
                print("---")
            }
            
            print("✅ Updated scraper test completed successfully!")
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
let tester = UpdatedScraperTester()
tester.testUpdatedScraper()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(20)) 