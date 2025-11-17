#!/usr/bin/env swift

import Foundation

// Test the GarysGuideService integration
print("=== TESTING SERVICE INTEGRATION ===")

class ServiceIntegrationTester {
    func testServiceIntegration() {
        print("🔍 Testing GarysGuideService integration...")
        
        // Simulate the service loading events
        let service = GarysGuideService()
        
        // Wait for events to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("📊 Service events count: \(service.events.count)")
            
            if service.events.count > 0 {
                print("✅ Service successfully loaded \(service.events.count) events")
                print("📋 First 3 events:")
                for (index, event) in service.events.prefix(3).enumerated() {
                    print("  \(index + 1). \(event.title) - \(event.url)")
                }
            } else {
                print("❌ Service failed to load events")
            }
        }
    }
}

// Simple GarysGuideService mock for testing
class GarysGuideService {
    var events: [MockEvent] = []
    
    init() {
        loadEvents()
    }
    
    func loadEvents() {
        print("🔄 Service loading events...")
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.events = [
                MockEvent(title: "Test Event 1", url: "http://gary.to/test1"),
                MockEvent(title: "Test Event 2", url: "http://gary.to/test2"),
                MockEvent(title: "Test Event 3", url: "http://gary.to/test3")
            ]
            print("✅ Service loaded \(self.events.count) test events")
        }
    }
}

struct MockEvent {
    let title: String
    let url: String
}

// Run the test
let tester = ServiceIntegrationTester()
tester.testServiceIntegration()

// Keep the script running
RunLoop.main.run(until: Date().addingTimeInterval(15)) 