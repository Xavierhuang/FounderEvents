//
//  GPTVisionService.swift
//  ScheduleShare
//
//  GPT Vision service for direct image analysis
//

import Foundation
import UIKit

class GPTVisionService: ObservableObject {
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func analyzeImage(_ imageData: Data, prompt: String = "Describe what you see in this image in detail.") async throws -> String {
        if !NetworkMonitor.shared.isConnected {
            print("⚠️ Network appears offline, but attempting API call anyway...")
        }
        guard let base64Image = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw GPTVisionError.imageEncodingFailed
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: baseURL) else {
            throw GPTVisionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw GPTVisionError.requestSerializationFailed
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GPTVisionError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 {
                    throw GPTVisionError.unauthorized
                }
                throw GPTVisionError.apiError(httpResponse.statusCode)
            }
            
            let gptResponse = try JSONDecoder().decode(GPTResponse.self, from: data)
            
            guard let content = gptResponse.choices.first?.message.content else {
                throw GPTVisionError.noContent
            }
            
            return content
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost || urlError.code == .timedOut {
                throw GPTVisionError.offline
            }
            throw urlError
        }
    }

    struct ExtractedEvent: Codable {
        let event_name: String?
        let event_time: String?
        let event_location: String?
    }

    func extractEventDetails(_ imageData: Data) async throws -> ExtractedEvent {
        if !NetworkMonitor.shared.isConnected {
            print("⚠️ Network appears offline, but attempting API call anyway...")
        }
        guard let base64Image = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw GPTVisionError.imageEncodingFailed
        }

        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        let currentDateString = formatter.string(from: currentDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone(identifier: "America/New_York")
        let currentTimeString = timeFormatter.string(from: currentDate)
        
        let systemPrompt = """
        You are an information extraction assistant. From the provided image, extract event details: event_name, event_time, event_location.
        
        CONTEXT:
        - Current date: \(currentDateString)
        - Current time: \(currentTimeString) (New York time)
        - Timezone: America/New_York (Eastern Time)
        
        EXTRACTION RULES:
        1. event_name: Extract the event title/name
        2. event_time: Extract the event time/date. If only time is shown (like "11 a.m."), use that. If only date is shown, use that. If both are shown, include both.
        3. event_location: Extract the location (venue, address, or virtual meeting platform)
        
        DATE/TIME FORMATTING:
        - For times: Use 12-hour format with AM/PM (e.g., "11:00 AM", "2:30 PM")
        - For dates: Use natural format (e.g., "September 15", "Sep 15, 2024", "Tomorrow at 3 PM")
        - If relative dates are used (like "tomorrow", "next week"), interpret them based on current date
        - Always assume Eastern Time unless explicitly stated otherwise
        
        Return ONLY strict JSON with keys: event_name, event_time, event_location. If unknown, use null.
        """
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": systemPrompt],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Extract event details from this image."],
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]

        guard let url = URL(string: baseURL) else { throw GPTVisionError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw GPTVisionError.invalidResponse }
            guard http.statusCode == 200 else {
                if http.statusCode == 401 { throw GPTVisionError.unauthorized }
                throw GPTVisionError.apiError(http.statusCode)
            }
            let gptResponse = try JSONDecoder().decode(GPTResponse.self, from: data)
            guard let content = gptResponse.choices.first?.message.content else { throw GPTVisionError.noContent }
            let jsonData = Data(content.utf8)
            let extracted = try JSONDecoder().decode(ExtractedEvent.self, from: jsonData)
            return extracted
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost || urlError.code == .timedOut { throw GPTVisionError.offline }
            throw urlError
        }
    }
}

enum GPTVisionError: Error, LocalizedError {
    case imageEncodingFailed
    case invalidURL
    case requestSerializationFailed
    case invalidResponse
    case apiError(Int)
    case noContent
    case offline
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "Failed to encode image data"
        case .invalidURL:
            return "Invalid API URL"
        case .requestSerializationFailed:
            return "Failed to serialize request"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code):
            return "API error with status code: \(code)"
        case .noContent:
            return "No content in response"
        case .offline:
            return "You're offline. Please check your internet connection."
        case .unauthorized:
            return "Invalid or missing API key. Please verify your API key."
        }
    }
}

struct GPTResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}
