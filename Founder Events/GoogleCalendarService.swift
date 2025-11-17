import Foundation
import SwiftUI

// MARK: - Google Calendar Service
class GoogleCalendarService: ObservableObject {
    static let shared = GoogleCalendarService()
    
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    func authenticateWithGoogle(completion: @escaping (Result<String, Error>) -> Void) {
        // For now, we'll implement web-based authentication
        // In a production app, you'd use Google Sign-In SDK
        completion(.failure(GoogleCalendarError.authenticationNotImplemented))
    }
    
    // MARK: - Calendar Import Methods
    
    func importFromGoogleCalendar(method: GoogleImportMethod, existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        switch method {
        case .webExport:
            // Guide user to export from Google Calendar web interface
            completion(.failure(GoogleCalendarError.requiresManualExport))
        case .icsFile(let url):
            importFromICSFile(url: url, existingEvents: existingEvents, completion: completion)
        case .api:
            importViaAPI(existingEvents: existingEvents, completion: completion)
        }
    }
    
    // MARK: - ICS File Import
    
    private func importFromICSFile(url: URL, existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        print("📥 Importing Google Calendar from ICS file: \(url.lastPathComponent)")
        
        do {
            let icsData = try String(contentsOf: url)
            let events = try parseICSData(icsData)
            
            // Filter duplicates using the same logic as Apple Calendar import
            let filtered = filterDuplicates(from: events, against: existingEvents)
            
            let result = ImportResult(
                uniqueEvents: filtered.unique,
                duplicateEvents: filtered.duplicates,
                totalFound: events.count
            )
            
            print("📊 Google Calendar ICS import results:")
            print("   Total found: \(result.totalFound)")
            print("   New events: \(result.uniqueCount)")
            print("   Duplicates: \(result.duplicateCount)")
            
            completion(.success(result))
            
        } catch {
            print("❌ Failed to import ICS file: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - API Import (Future Implementation)
    
    private func importViaAPI(existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        // This would use Google Calendar API
        // For now, return not implemented error
        completion(.failure(GoogleCalendarError.apiNotImplemented))
    }
    
    // MARK: - ICS Parser
    
    private func parseICSData(_ icsData: String) throws -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let lines = icsData.components(separatedBy: .newlines)
        
        var currentEvent: [String: String] = [:]
        var inEvent = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine == "BEGIN:VEVENT" {
                inEvent = true
                currentEvent = [:]
            } else if trimmedLine == "END:VEVENT" {
                if inEvent {
                    if let event = createCalendarEventFromICS(currentEvent) {
                        events.append(event)
                    }
                }
                inEvent = false
                currentEvent = [:]
            } else if inEvent && trimmedLine.contains(":") {
                let components = trimmedLine.components(separatedBy: ":")
                if components.count >= 2 {
                    let key = components[0]
                    let value = components[1...].joined(separator: ":")
                    currentEvent[key] = value
                }
            }
        }
        
        print("📥 Parsed \(events.count) events from ICS data")
        return events
    }
    
    private func createCalendarEventFromICS(_ eventData: [String: String]) -> CalendarEvent? {
        guard let summary = eventData["SUMMARY"] else {
            print("⚠️ Skipping event without SUMMARY")
            return nil
        }
        
        // Parse start date
        let startDate: Date
        if let dtstart = eventData["DTSTART"] {
            startDate = parseICSDate(dtstart) ?? Date()
        } else {
            print("⚠️ Skipping event without DTSTART")
            return nil
        }
        
        // Parse end date
        let endDate: Date
        if let dtend = eventData["DTEND"] {
            endDate = parseICSDate(dtend) ?? startDate.addingTimeInterval(3600)
        } else {
            endDate = startDate.addingTimeInterval(3600) // Default 1 hour
        }
        
        // Extract other fields
        let location = eventData["LOCATION"]
        let description = eventData["DESCRIPTION"]
        let uid = eventData["UID"]
        
        let event = CalendarEvent(
            title: summary,
            startDate: startDate,
            endDate: endDate,
            location: location,
            notes: description,
            eventIdentifier: uid
        )
        
        return event
    }
    
    private func parseICSDate(_ dateString: String) -> Date? {
        // Handle different ICS date formats
        let formatters = [
            "yyyyMMdd'T'HHmmss'Z'",      // 20231215T140000Z
            "yyyyMMdd'T'HHmmss",         // 20231215T140000
            "yyyyMMdd",                  // 20231215
        ]
        
        let cleanDateString = dateString.replacingOccurrences(of: "TZID=.*?:", with: "", options: .regularExpression)
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            if let date = formatter.date(from: cleanDateString) {
                return date
            }
        }
        
        print("⚠️ Could not parse ICS date: \(dateString)")
        return nil
    }
    
    // MARK: - Duplicate Detection (Reused from CalendarManager)
    
    private func filterDuplicates(from importedEvents: [CalendarEvent], against existingEvents: [CalendarEvent]) -> (unique: [CalendarEvent], duplicates: [CalendarEvent]) {
        var uniqueEvents: [CalendarEvent] = []
        var duplicateEvents: [CalendarEvent] = []
        
        for event in importedEvents {
            if isDuplicateEvent(event, existingEvents: existingEvents + uniqueEvents) {
                duplicateEvents.append(event)
            } else {
                uniqueEvents.append(event)
            }
        }
        
        return (unique: uniqueEvents, duplicates: duplicateEvents)
    }
    
    private func isDuplicateEvent(_ newEvent: CalendarEvent, existingEvents: [CalendarEvent]) -> Bool {
        for existingEvent in existingEvents {
            // Check for exact match by eventIdentifier
            if let newIdentifier = newEvent.eventIdentifier,
               let existingIdentifier = existingEvent.eventIdentifier,
               newIdentifier == existingIdentifier {
                return true
            }
            
            // Check for content-based match
            let titleMatch = newEvent.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                           existingEvent.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            let timeMatch = abs(newEvent.startDate.timeIntervalSince(existingEvent.startDate)) < 300
            
            let locationMatch = {
                let newLoc = newEvent.location?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let existingLoc = existingEvent.location?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return newLoc == existingLoc
            }()
            
            if titleMatch && timeMatch && locationMatch {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Google Calendar Types

enum GoogleImportMethod {
    case webExport          // User exports from Google Calendar web
    case icsFile(URL)       // Import from .ics file
    case api                // Direct API integration (future)
}

enum GoogleCalendarError: Error, LocalizedError {
    case authenticationNotImplemented
    case apiNotImplemented
    case requiresManualExport
    case invalidICSFormat
    case fileNotFound
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationNotImplemented:
            return "Google authentication not yet implemented"
        case .apiNotImplemented:
            return "Google Calendar API integration coming soon"
        case .requiresManualExport:
            return "Please export your Google Calendar as an .ics file"
        case .invalidICSFormat:
            return "Invalid ICS file format"
        case .fileNotFound:
            return "ICS file not found"
        case .parsingError(let message):
            return "Error parsing calendar data: \(message)"
        }
    }
}

// MARK: - Google Calendar Instructions View

struct GoogleCalendarInstructionsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 80, height: 80)
                            )
                        
                        Text("Import from Google Calendar")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Follow these steps to export your Google Calendar and import it into ScheduleShare")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionStep(
                            number: 1,
                            title: "Open Google Calendar",
                            description: "Go to calendar.google.com on your computer or phone browser",
                            icon: "safari"
                        )
                        
                        InstructionStep(
                            number: 2,
                            title: "Access Settings",
                            description: "Click the gear icon (⚙️) in the top right, then select 'Settings'",
                            icon: "gear"
                        )
                        
                        InstructionStep(
                            number: 3,
                            title: "Export Calendar",
                            description: "In the left sidebar, click 'Import & export', then click 'Export' to download your calendar as a .zip file",
                            icon: "square.and.arrow.down"
                        )
                        
                        InstructionStep(
                            number: 4,
                            title: "Extract ICS File",
                            description: "Unzip the downloaded file and find the .ics file for the calendar you want to import",
                            icon: "doc.zipper"
                        )
                        
                        InstructionStep(
                            number: 5,
                            title: "Return to ScheduleShare",
                            description: "Come back to this app and use 'Import ICS File' to select your extracted .ics file",
                            icon: "arrow.uturn.left"
                        )
                    }
                    
                    // Quick Link Button
                    Button(action: {
                        if let url = URL(string: "https://calendar.google.com/calendar/u/0/r/settings/export") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "safari")
                            Text("Open Google Calendar Export")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Google Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Instruction Step View
struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                
                Text("\(number)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    GoogleCalendarInstructionsView()
}
