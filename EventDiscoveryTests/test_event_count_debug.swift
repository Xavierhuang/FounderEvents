#!/usr/bin/env swift

import Foundation

// Test to debug why event count is lower with new title pattern
print("=== DEBUGGING EVENT COUNT ===")

class EventCountDebugger {
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func debugEventCount() {
        print("🔍 Debugging event count with new title pattern...")
        
        guard let url = URL(string: garysGuideURL) else {
            print("❌ Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let htmlString = String(data: data ?? Data(), encoding: .utf8) {
                    self.debugCount(htmlString)
                }
            }
        }
        
        task.resume()
    }
    
    private func debugCount(_ html: String) {
        print("\n=== EVENT COUNT DEBUG ===")
        
        // Test old title pattern
        let oldTitlePattern = #"<b>([^<]+)</b></a>"#
        let oldTitleRegex = try? NSRegularExpression(pattern: oldTitlePattern)
        let oldTitleMatches = oldTitleRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        // Test new title pattern
        let newTitlePattern = #"https://www\.garysguide\.com/events/[^/]+/([^"']*)"#
        let newTitleRegex = try? NSRegularExpression(pattern: newTitlePattern)
        let newTitleMatches = newTitleRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        // Test URL pattern
        let urlPattern = #"https://www\.garysguide\.com/events/[^"']*"#
        let urlRegex = try? NSRegularExpression(pattern: urlPattern)
        let urlMatches = urlRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        print("📊 Pattern matches:")
        print("  Old title pattern: \(oldTitleMatches.count)")
        print("  New title pattern: \(newTitleMatches.count)")
        print("  URL pattern: \(urlMatches.count)")
        
        // Show sample matches for each pattern
        print("\n=== OLD TITLE PATTERN SAMPLES ===")
        for i in 0..<min(5, oldTitleMatches.count) {
            let title = extractString(from: html, range: oldTitleMatches[i].range(at: 1))
            print("  \(i + 1): '\(title)'")
        }
        
        print("\n=== NEW TITLE PATTERN SAMPLES ===")
        for i in 0..<min(5, newTitleMatches.count) {
            let title = extractString(from: html, range: newTitleMatches[i].range(at: 1))
            print("  \(i + 1): '\(title)'")
        }
        
        print("\n=== URL PATTERN SAMPLES ===")
        for i in 0..<min(5, urlMatches.count) {
            let url = extractString(from: html, range: urlMatches[i].range(at: 0))
            print("  \(i + 1): '\(url)'")
        }
        
        // Check if there are URLs without corresponding titles
        print("\n=== ANALYZING MISMATCHES ===")
        
        let urlTitles = newTitleMatches.map { extractString(from: html, range: $0.range(at: 1)) }
        let urls = urlMatches.map { extractString(from: html, range: $0.range(at: 0)) }
        
        print("URLs without titles:")
        for (index, url) in urls.enumerated() {
            if index < urlTitles.count {
                let title = urlTitles[index]
                print("  URL: \(url)")
                print("  Title: \(title)")
                print("  ---")
            } else {
                print("  URL without title: \(url)")
            }
        }
        
        // Test a more flexible title pattern
        print("\n=== TESTING FLEXIBLE TITLE PATTERN ===")
        let flexibleTitlePattern = #"<a[^>]*href="https://www\.garysguide\.com/events/[^"]*"[^>]*>([^<]+)</a>"#
        let flexibleTitleRegex = try? NSRegularExpression(pattern: flexibleTitlePattern)
        let flexibleTitleMatches = flexibleTitleRegex?.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) ?? []
        
        print("Flexible title pattern matches: \(flexibleTitleMatches.count)")
        for i in 0..<min(5, flexibleTitleMatches.count) {
            let title = extractString(from: html, range: flexibleTitleMatches[i].range(at: 1))
            print("  \(i + 1): '\(title)'")
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

// Run the debugger
let debugger = EventCountDebugger()
debugger.debugEventCount()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(15)) 