//
//  CalendarManager.swift
//  ScheduleShare
//
//  Calendar integration using EventKit
//

import Foundation
import EventKit
import UIKit

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var hasCalendarPermission = false
    @Published var hasFullCalendarAccess = false
    
    init() {
        checkCalendarPermission()
    }
    
    // MARK: - Permission Handling
    func checkCalendarPermission() {
        if #available(iOS 17.0, *) {
            // Use new granular permissions for iOS 17+
            switch EKEventStore.authorizationStatus(for: .event) {
            case .fullAccess:
                hasCalendarPermission = true
                hasFullCalendarAccess = true
            case .writeOnly:
                hasCalendarPermission = true
                hasFullCalendarAccess = false
            case .denied, .restricted:
                hasCalendarPermission = false
                hasFullCalendarAccess = false
            case .notDetermined:
                requestCalendarPermission()
            @unknown default:
                hasCalendarPermission = false
                hasFullCalendarAccess = false
            }
        } else {
            // Fallback to legacy permission system for iOS 16 and below
            switch EKEventStore.authorizationStatus(for: .event) {
            case .authorized:
                hasCalendarPermission = true
                hasFullCalendarAccess = true
            case .denied, .restricted:
                hasCalendarPermission = false
                hasFullCalendarAccess = false
            case .notDetermined:
                requestCalendarPermission()
            @unknown default:
                hasCalendarPermission = false
                hasFullCalendarAccess = false
            }
        }
    }
    
    func requestCalendarPermission() {
        if #available(iOS 17.0, *) {
            // Request "Add Events Only" permission (writeOnly) for iOS 17+
            // This gives users the option to choose between "Add Events Only" and "Full Access"
            eventStore.requestWriteOnlyAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasCalendarPermission = granted
                    if let error = error {
                        print("❌ Calendar permission request failed: \(error.localizedDescription)")
                    } else {
                        print("✅ Calendar permission granted: \(granted ? "Write-only access" : "Denied")")
                    }
                }
            }
        } else {
            // Fallback to legacy permission request for iOS 16 and below
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasCalendarPermission = granted
                    if let error = error {
                        print("❌ Calendar permission request failed: \(error.localizedDescription)")
                    } else {
                        print("✅ Calendar permission granted: \(granted ? "Full access" : "Denied")")
                    }
                }
            }
        }
    }
    
    @available(iOS 17.0, *)
    func requestFullCalendarAccess() {
        print("🔐 Requesting full calendar access...")
        print("🔍 Current authorization status: \(EKEventStore.authorizationStatus(for: .event))")
        
        // Request full access if user initially only granted write-only access
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            DispatchQueue.main.async {
                print("🔐 Full access request completed")
                print("🔍 Granted: \(granted)")
                print("🔍 Error: \(error?.localizedDescription ?? "none")")
                print("🔍 New authorization status: \(EKEventStore.authorizationStatus(for: .event))")
                
                if granted {
                    self?.hasCalendarPermission = true
                    self?.hasFullCalendarAccess = true
                    print("✅ Full calendar access granted")
                } else {
                    print("❌ Full calendar access denied")
                    
                    // Check if user already has some level of access
                    let currentStatus = EKEventStore.authorizationStatus(for: .event)
                    if currentStatus == .writeOnly {
                        print("ℹ️ User still has write-only access")
                        self?.hasCalendarPermission = true
                        self?.hasFullCalendarAccess = false
                    }
                }
                
                if let error = error {
                    print("❌ Full access request failed: \(error.localizedDescription)")
                }
                
                // Force a recheck of permissions
                self?.checkCalendarPermission()
            }
        }
    }
    
    // Alternative method for iOS 17+ to request access more explicitly
    @available(iOS 17.0, *)
    func requestFullCalendarAccessAlternative() {
        print("🔐 Requesting full calendar access (alternative method)...")
        
        // Use the standard requestAccess method which should show both options
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                print("🔐 Alternative access request completed")
                print("🔍 Granted: \(granted)")
                print("🔍 Error: \(error?.localizedDescription ?? "none")")
                print("🔍 New authorization status: \(EKEventStore.authorizationStatus(for: .event))")
                
                // Recheck permissions after the request
                self?.checkCalendarPermission()
                
                if let error = error {
                    print("❌ Alternative access request failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Event Management
    func saveEvent(_ calendarEvent: CalendarEvent, completion: @escaping (Result<String, Error>) -> Void) {
        print("🏪 CalendarManager.saveEvent called")
        print("🔑 Has permission: \(hasCalendarPermission)")
        
        guard hasCalendarPermission else {
            print("❌ No calendar permission!")
            completion(.failure(CalendarError.noPermission))
            return
        }
        
        print("📅 Creating EKEvent...")
        let event = EKEvent(eventStore: eventStore)
        event.title = calendarEvent.title
        event.startDate = calendarEvent.startDate
        event.endDate = calendarEvent.endDate
        event.notes = calendarEvent.notes
        event.location = calendarEvent.location
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        print("💾 Event details:")
        print("   Title: \(event.title ?? "nil")")
        print("   Start: \(event.startDate?.description ?? "nil")")
        print("   End: \(event.endDate?.description ?? "nil")")
        print("   Location: \(event.location ?? "nil")")
        print("   Calendar: \(event.calendar?.title ?? "nil")")
        
        do {
            print("🔄 Attempting to save to EventStore...")
            try eventStore.save(event, span: .thisEvent)
            print("✅ EventStore save successful! Event ID: \(event.eventIdentifier)")
            completion(.success(event.eventIdentifier))
        } catch {
            print("❌ EventStore save failed: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func updateEvent(identifier: String, with calendarEvent: CalendarEvent, completion: @escaping (Result<Void, Error>) -> Void) {
        guard hasCalendarPermission else {
            completion(.failure(CalendarError.noPermission))
            return
        }
        
        guard let event = eventStore.event(withIdentifier: identifier) else {
            completion(.failure(CalendarError.eventNotFound))
            return
        }
        
        event.title = calendarEvent.title
        event.startDate = calendarEvent.startDate
        event.endDate = calendarEvent.endDate
        event.notes = calendarEvent.notes
        event.location = calendarEvent.location
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteEvent(identifier: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard hasCalendarPermission else {
            completion(.failure(CalendarError.noPermission))
            return
        }
        
        guard let event = eventStore.event(withIdentifier: identifier) else {
            completion(.failure(CalendarError.eventNotFound))
            return
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Calendar Queries
    func getEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
        // Reading events requires full access (not available with write-only permission)
        guard hasFullCalendarAccess else { 
            print("⚠️ Cannot read calendar events: Full access required")
            return [] 
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    func getUpcomingEvents(days: Int = 30) -> [EKEvent] {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate) ?? startDate
        return getEvents(from: startDate, to: endDate)
    }
    
    // MARK: - Calendar Creation and Sharing
    func createSharedCalendar(name: String, completion: @escaping (Result<EKCalendar, Error>) -> Void) {
        guard hasCalendarPermission else {
            completion(.failure(CalendarError.noPermission))
            return
        }
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = name
        calendar.cgColor = UIColor.systemBlue.cgColor
        
        // Use the default source (usually iCloud)
        if let source = eventStore.defaultCalendarForNewEvents?.source {
            calendar.source = source
        } else if let source = eventStore.sources.first(where: { $0.sourceType == .local }) {
            calendar.source = source
        } else {
            completion(.failure(CalendarError.noValidSource))
            return
        }
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            completion(.success(calendar))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getAvailableCalendars() -> [EKCalendar] {
        // Reading calendar list requires full access
        guard hasFullCalendarAccess else { 
            print("⚠️ Cannot read calendar list: Full access required")
            return [] 
        }
        return eventStore.calendars(for: .event)
    }
    
    // MARK: - Import Functionality
    
    // Helper method to detect duplicate events
    private func isDuplicateEvent(_ newEvent: CalendarEvent, existingEvents: [CalendarEvent]) -> Bool {
        for existingEvent in existingEvents {
            // Check for exact match by eventIdentifier (most reliable)
            if let newIdentifier = newEvent.eventIdentifier,
               let existingIdentifier = existingEvent.eventIdentifier,
               newIdentifier == existingIdentifier {
                print("🔍 Duplicate found by eventIdentifier: \(newEvent.title)")
                return true
            }
            
            // Check for likely duplicate by title + start time + location
            let titleMatch = newEvent.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                           existingEvent.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            let timeMatch = abs(newEvent.startDate.timeIntervalSince(existingEvent.startDate)) < 300 // Within 5 minutes
            
            let locationMatch = {
                let newLoc = newEvent.location?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let existingLoc = existingEvent.location?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return newLoc == existingLoc
            }()
            
            if titleMatch && timeMatch && locationMatch {
                print("🔍 Duplicate found by content match: \(newEvent.title) at \(newEvent.startDate)")
                return true
            }
        }
        
        return false
    }
    
    // Helper method to filter out duplicates from import results
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
        
        print("📊 Import filtering results:")
        print("   Total events: \(importedEvents.count)")
        print("   Unique events: \(uniqueEvents.count)")
        print("   Duplicate events: \(duplicateEvents.count)")
        
        return (unique: uniqueEvents, duplicates: duplicateEvents)
    }
    
    func importEventsFromAppleCalendar(from startDate: Date, to endDate: Date, existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        // Importing requires full calendar access to read existing events
        guard hasFullCalendarAccess else {
            completion(.failure(CalendarError.noPermission))
            return
        }
        
        print("📥 Starting calendar import from \(startDate) to \(endDate)")
        print("📥 Checking against \(existingEvents.count) existing events")
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let appleEvents = eventStore.events(matching: predicate)
        
        print("📥 Found \(appleEvents.count) events in Apple Calendar")
        
        var importedEvents: [CalendarEvent] = []
        
        for appleEvent in appleEvents {
            // Convert EKEvent to CalendarEvent
            let calendarEvent = CalendarEvent(
                title: appleEvent.title ?? "Untitled Event",
                startDate: appleEvent.startDate,
                endDate: appleEvent.endDate,
                location: appleEvent.location,
                notes: appleEvent.notes,
                eventIdentifier: appleEvent.eventIdentifier
            )
            
            importedEvents.append(calendarEvent)
        }
        
        // Filter out duplicates
        let filtered = filterDuplicates(from: importedEvents, against: existingEvents)
        
        let result = ImportResult(
            uniqueEvents: filtered.unique,
            duplicateEvents: filtered.duplicates,
            totalFound: importedEvents.count
        )
        
        completion(.success(result))
    }
    
    func importUpcomingEvents(days: Int = 30, existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate) ?? startDate
        importEventsFromAppleCalendar(from: startDate, to: endDate, existingEvents: existingEvents, completion: completion)
    }
    
    func importEventsFromDateRange(startDate: Date, endDate: Date, existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        importEventsFromAppleCalendar(from: startDate, to: endDate, existingEvents: existingEvents, completion: completion)
    }
    
    func getAvailableCalendarsForImport() -> [EKCalendar] {
        // Get list of calendars user can import from
        guard hasFullCalendarAccess else { 
            print("⚠️ Cannot read calendar list: Full access required for import")
            return [] 
        }
        
        return eventStore.calendars(for: .event).filter { calendar in
            // Filter out calendars that might not be suitable for import
            return calendar.allowsContentModifications || calendar.type == .local || calendar.type == .calDAV || calendar.type == .exchange
        }
    }
    
    func importEventsFromSpecificCalendars(_ calendars: [EKCalendar], from startDate: Date, to endDate: Date, existingEvents: [CalendarEvent], completion: @escaping (Result<ImportResult, Error>) -> Void) {
        guard hasFullCalendarAccess else {
            completion(.failure(CalendarError.noPermission))
            return
        }
        
        print("📥 Importing from \(calendars.count) specific calendars")
        print("📥 Checking against \(existingEvents.count) existing events")
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let appleEvents = eventStore.events(matching: predicate)
        
        print("📥 Found \(appleEvents.count) events in selected calendars")
        
        var importedEvents: [CalendarEvent] = []
        
        for appleEvent in appleEvents {
            let calendarEvent = CalendarEvent(
                title: appleEvent.title ?? "Untitled Event",
                startDate: appleEvent.startDate,
                endDate: appleEvent.endDate,
                location: appleEvent.location,
                notes: appleEvent.notes,
                eventIdentifier: appleEvent.eventIdentifier
            )
            
            importedEvents.append(calendarEvent)
        }
        
        // Filter out duplicates
        let filtered = filterDuplicates(from: importedEvents, against: existingEvents)
        
        let result = ImportResult(
            uniqueEvents: filtered.unique,
            duplicateEvents: filtered.duplicates,
            totalFound: importedEvents.count
        )
        
        print("📊 Final import results:")
        print("   Total found: \(result.totalFound)")
        print("   New events: \(result.uniqueCount)")
        print("   Duplicates skipped: \(result.duplicateCount)")
        
        completion(.success(result))
    }
    
    // MARK: - Export Functionality
    func exportCalendarEvents(_ events: [CalendarEvent]) -> String {
        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//ScheduleShare//EN
        
        """
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        for event in events {
            let startDateString = formatter.string(from: event.startDate)
            let endDateString = formatter.string(from: event.endDate)
            let uid = UUID().uuidString
            
            icsContent += """
            BEGIN:VEVENT
            UID:\(uid)
            DTSTART:\(startDateString)
            DTEND:\(endDateString)
            SUMMARY:\(event.title)
            """
            
            if let location = event.location {
                icsContent += "\nLOCATION:\(location)"
            }
            
            if let notes = event.notes {
                icsContent += "\nDESCRIPTION:\(notes)"
            }
            
            icsContent += "\nEND:VEVENT\n"
        }
        
        icsContent += "END:VCALENDAR"
        return icsContent
    }
}

// MARK: - Import Result Types
struct ImportResult {
    let uniqueEvents: [CalendarEvent]
    let duplicateEvents: [CalendarEvent]
    let totalFound: Int
    
    var duplicateCount: Int {
        return duplicateEvents.count
    }
    
    var uniqueCount: Int {
        return uniqueEvents.count
    }
    
    var hasNewEvents: Bool {
        return !uniqueEvents.isEmpty
    }
    
    var hasDuplicates: Bool {
        return !duplicateEvents.isEmpty
    }
}

// MARK: - Error Types
enum CalendarError: Error, LocalizedError {
    case noPermission
    case eventNotFound
    case noValidSource
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "Calendar permission is required"
        case .eventNotFound:
            return "Event not found"
        case .noValidSource:
            return "No valid calendar source available"
        case .saveFailed:
            return "Failed to save calendar event"
        }
    }
}