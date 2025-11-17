#!/usr/bin/env swift

import Foundation

// Simple AI Event Discovery Test
// Run with: swift test_ai_discovery.swift

// MARK: - Models
struct AIEvent: Codable {
    let title: String
    let startDate: String
    let endDate: String
    let location: String
    let description: String
    let source: String
    let confidence: Double
}

struct CalendarEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
    let notes: String
}

// MARK: - OpenAI API Call
func callOpenAI(prompt: String) async throws -> String {
    let apiKey = "YOUR_OPENAI_API_KEY_HERE"
    
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
        "model": "gpt-4_1",
        "messages": [
            ["role": "user", "content": prompt]
        ],
        "temperature": 0.7,
        "max_tokens": 1000
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "API call failed"])
    }
    
    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let choices = jsonResponse?["choices"] as? [[String: Any]]
    let firstChoice = choices?.first
    let message = firstChoice?["message"] as? [String: Any]
    let content = message?["content"] as? String ?? ""
    
    return content
}

// MARK: - Event Discovery
func discoverEventsWithAI(location: String, interests: [String]) async throws -> [CalendarEvent] {
    print("🤖 Discovering events in \(location) for interests: \(interests.joined(separator: ", "))")
    
    let prompt = """
    You are an event discovery assistant. Suggest 3-5 REAL upcoming events happening THIS WEEK in \(location) for interests: \(interests.joined(separator: ", ")).
    
    IMPORTANT: 
    - Use ONLY real events that are actually happening this week
    - Use current dates (August 2025) 
    - Return ONLY a valid JSON array with this exact format, no other text:
    [
        {
            "title": "Real Event Title",
            "startDate": "2025-08-15T18:00:00Z",
            "endDate": "2025-08-15T20:00:00Z",
            "location": "Real Event Location",
            "description": "Real event description",
            "source": "AI Discovery",
            "confidence": 0.9
        }
    ]
    
    Focus on events happening this week (August 11-17, 2025). Do not include any explanatory text, only the JSON array.
    """
    
    let response = try await callOpenAI(prompt: prompt)
    print("📡 AI Response received")
    
    return try parseAIResponse(response)
}

func parseAIResponse(_ response: String) throws -> [CalendarEvent] {
    let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let data = cleanedResponse.data(using: .utf8) else {
        throw NSError(domain: "Parsing", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])
    }
    
    do {
        let decoder = JSONDecoder()
        let aiEvents = try decoder.decode([AIEvent].self, from: data)
        
        return aiEvents.map { aiEvent in
            let dateFormatter = ISO8601DateFormatter()
            let startDate = dateFormatter.date(from: aiEvent.startDate) ?? Date()
            let endDate = dateFormatter.date(from: aiEvent.endDate) ?? startDate.addingTimeInterval(7200)
            
            return CalendarEvent(
                title: aiEvent.title,
                startDate: startDate,
                endDate: endDate,
                location: aiEvent.location,
                notes: aiEvent.description
            )
        }
    } catch {
        print("❌ Failed to parse AI response: \(error)")
        print("📄 Raw response: \(cleanedResponse)")
        throw error
    }
}

// MARK: - Main Test Function
func runAITest() async {
    print("🧪 Starting AI Event Discovery Test")
    print(String(repeating: "=", count: 50))
    
    do {
        let events = try await discoverEventsWithAI(
            location: "New York, NY",
            interests: ["tech", "networking", "social"]
        )
        
        print("\n✅ Test completed successfully!")
        print("📅 Found \(events.count) events:")
        print(String(repeating: "=", count: 50))
        
        for (index, event) in events.enumerated() {
            print("\(index + 1). \(event.title)")
            print("   📍 \(event.location)")
            print("   📅 \(event.startDate)")
            print("   📝 \(event.notes)")
            print("   " + String(repeating: "─", count: 30))
        }
        
    } catch {
        print("❌ Test failed: \(error)")
    }
}

// MARK: - Run Test
print("🚀 AI Event Discovery Terminal Test")
print("Press Enter to start...")
_ = readLine()

await runAITest() 