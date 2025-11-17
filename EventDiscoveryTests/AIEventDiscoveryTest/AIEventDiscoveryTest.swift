//
//  AIEventDiscoveryTest.swift
//  EventDiscoveryTests
//
//  Test AI-powered event discovery functionality
//

import SwiftUI
import OpenAI

struct AIEventDiscoveryTest: View {
    @State private var searchResults: [CalendarEvent] = []
    @State private var isSearching = false
    @State private var searchQuery = ""
    @State private var location = "New York, NY"
    @State private var interests = ["tech", "networking", "social"]
    
    private let openAI = OpenAI(apiToken: "YOUR_OPENAI_API_KEY_HERE")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Test Controls
                VStack(spacing: 12) {
                    TextField("Search Query", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Location", text: $location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Test AI Event Discovery") {
                        Task {
                            await testAIDiscovery()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .disabled(isSearching)
                }
                .padding()
                
                if isSearching {
                    VStack {
                        ProgressView("Searching for events...")
                        Text("🤖 AI is discovering events...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Results
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults) { event in
                            EventResultCard(event: event)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Event Discovery Test")
        }
    }
    
    private func testAIDiscovery() async {
        isSearching = true
        defer { isSearching = false }
        
        do {
            let events = try await discoverEventsWithAI()
            await MainActor.run {
                searchResults = events
            }
        } catch {
            print("❌ AI discovery failed: \(error)")
        }
    }
    
    private func discoverEventsWithAI() async throws -> [CalendarEvent] {
        let prompt = """
        Find upcoming events in \(location) for interests: \(interests.joined(separator: ", "))
        
        Return as JSON array with this exact format:
        [
            {
                "title": "Event Title",
                "startDate": "2025-08-15T18:00:00Z",
                "endDate": "2025-08-15T20:00:00Z",
                "location": "Event Location",
                "description": "Event description",
                "source": "Website URL",
                "confidence": 0.9
            }
        ]
        
        Only return valid JSON, no other text.
        """
        
        let response = try await openAI.chats.create(
            model: .gpt4,
            messages: [.init(role: .user, content: prompt)]
        )
        
        let content = response.choices.first?.message.content ?? ""
        print("🤖 AI Response: \(content)")
        
        return try parseAIResponse(content)
    }
    
    private func parseAIResponse(_ response: String) throws -> [CalendarEvent] {
        // Clean the response
        let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to extract JSON
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw AIEventDiscoveryError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let aiEvents = try decoder.decode([AIEvent].self, from: data)
            
            return aiEvents.map { aiEvent in
                CalendarEvent(
                    title: aiEvent.title,
                    startDate: aiEvent.startDate,
                    endDate: aiEvent.endDate,
                    location: aiEvent.location,
                    notes: aiEvent.description,
                    extractedInfo: ExtractedEventInfo(
                        rawText: response,
                        title: aiEvent.title,
                        startDateTime: aiEvent.startDate,
                        endDateTime: aiEvent.endDate,
                        location: aiEvent.location,
                        description: aiEvent.description,
                        confidence: aiEvent.confidence
                    )
                )
            }
        } catch {
            print("❌ Failed to parse AI response: \(error)")
            throw AIEventDiscoveryError.parsingFailed
        }
    }
}

// MARK: - Supporting Types

struct AIEvent: Codable {
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String
    let description: String
    let source: String
    let confidence: Double
}

enum AIEventDiscoveryError: Error {
    case invalidResponse
    case parsingFailed
}

struct EventResultCard: View {
    let event: CalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(event.startDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let location = event.location {
                Text(location)
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            
            if let notes = event.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    AIEventDiscoveryTest()
} 