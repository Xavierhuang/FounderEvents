import Foundation

struct LinkedInProfile: Identifiable, Codable {
    let id: UUID
    let profileURL: String
    let name: String
    let company: String?
    let title: String?
    let linkedDate: Date
    let linkedEventID: String?
    
    init(profileURL: String, name: String = "", company: String? = nil, title: String? = nil, eventID: String? = nil) {
        self.id = UUID()
        self.profileURL = profileURL
        self.name = name
        self.company = company
        self.title = title
        self.linkedDate = Date()
        self.linkedEventID = eventID
    }
    
    // Initializer that preserves existing ID (for updates)
    init(id: UUID, profileURL: String, name: String, company: String?, title: String?, linkedDate: Date, eventID: String?) {
        self.id = id
        self.profileURL = profileURL
        self.name = name
        self.company = company
        self.title = title
        self.linkedDate = linkedDate
        self.linkedEventID = eventID
    }
}

class LinkedInProfileManager: ObservableObject {
    @Published var profiles: [LinkedInProfile] = []
    @Published var pendingProfile: LinkedInProfile?
    
    init() {
        loadProfiles()
        checkForSharedProfiles()
    }
    
    func addProfile(_ profile: LinkedInProfile) {
        profiles.append(profile)
        saveProfiles()
    }
    
    func getProfilesForEvent(_ eventID: String) -> [LinkedInProfile] {
        return profiles.filter { $0.linkedEventID == eventID }
    }
    
    func handleURLScheme(_ url: URL) {
        // Handle URL scheme callbacks from share extension
        if url.scheme == "scheduleshare" && url.host == "linkedin-profile" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let dataParam = components.queryItems?.first(where: { $0.name == "data" })?.value,
               let data = Data(base64Encoded: dataParam),
               let profile = try? JSONDecoder().decode(LinkedInProfile.self, from: data) {
                
                // Set as pending profile for user to assign to an event
                DispatchQueue.main.async {
                    self.pendingProfile = profile
                }
                
                print("✅ Received LinkedIn profile via URL scheme: \(profile.name)")
            }
        }
    }
    
    func assignPendingProfileToEvent(_ eventID: String, calendarManager: CalendarManager, appState: AppState) {
        guard let profile = pendingProfile else { return }
        
        // Create a new profile with the event ID, preserving the existing ID
        let updatedProfile = LinkedInProfile(
            id: profile.id,
            profileURL: profile.profileURL,
            name: profile.name,
            company: profile.company,
            title: profile.title,
            linkedDate: profile.linkedDate,
            eventID: eventID
        )
        
        // Add to profiles and clear pending
        addProfile(updatedProfile)
        pendingProfile = nil
        
        // Update the actual calendar event with the LinkedIn profile information
        updateCalendarEventWithProfile(updatedProfile, eventID: eventID, calendarManager: calendarManager, appState: appState)
        
        print("✅ LinkedIn profile assigned to event: \(profile.name)")
    }
    
    private func updateCalendarEventWithProfile(_ profile: LinkedInProfile, eventID: String, calendarManager: CalendarManager, appState: AppState) {
        // Find the event by ID
        guard let event = appState.events.first(where: { $0.id.uuidString == eventID }) else {
            print("⚠️ Could not find event with ID: \(eventID)")
            return
        }
        
        // Create updated event with LinkedIn profile information in notes
        var updatedNotes = event.notes ?? ""
        if !updatedNotes.isEmpty {
            updatedNotes += "\n\n"
        }
        
        updatedNotes += "LinkedIn Attendee:\n"
        updatedNotes += "• Name: \(profile.name)"
        if let company = profile.company {
            updatedNotes += "\n• Company: \(company)"
        }
        if let title = profile.title {
            updatedNotes += "\n• Title: \(title)"
        }
        updatedNotes += "\n• Profile: \(profile.profileURL)"
        updatedNotes += "\n• Linked: \(formatDate(profile.linkedDate))"
        
        // Create updated calendar event
        let updatedEvent = CalendarEvent(
            from: event,
            notes: updatedNotes
        )
        
        // Update the calendar event
        if let eventIdentifier = event.eventIdentifier {
            calendarManager.updateEvent(identifier: eventIdentifier, with: updatedEvent) { result in
                switch result {
                case .success:
                    print("✅ Calendar event updated with LinkedIn profile: \(profile.name)")
                case .failure(let error):
                    print("❌ Failed to update calendar event: \(error)")
                }
            }
        } else {
            print("⚠️ Event has no calendar identifier, cannot update")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func checkForSharedProfiles() {
        // Check if there are any profiles shared via the share extension
        let defaults = UserDefaults.standard
        if let profilesData = defaults.array(forKey: "LocalLinkedInProfiles") as? [Data] {
            for data in profilesData {
                if let profile = try? JSONDecoder().decode(LinkedInProfile.self, from: data) {
                    // If the profile already has an event ID, add it directly
                    if let eventID = profile.linkedEventID {
                        // Profile is already linked to an event, add it directly
                        addProfile(profile)
                        print("📱 Found linked LinkedIn profile: \(profile.name) -> Event ID: \(eventID)")
                    } else {
                        // Profile needs to be assigned to an event
                        DispatchQueue.main.async {
                            self.pendingProfile = profile
                        }
                        print("📱 Found unassigned LinkedIn profile: \(profile.name)")
                    }
                    break
                }
            }
            
            // Clear the shared data after processing
            defaults.removeObject(forKey: "LocalLinkedInProfiles")
        }
    }
    
    func checkForSharedProfilesOnAppActivation() {
        // This method should be called when the app becomes active
        // to check for any profiles shared via the share extension
        checkForSharedProfiles()
        
        // Also check for selected event info from share extension
        checkForSelectedEventInfo()
    }
    
    private func checkForSelectedEventInfo() {
        let defaults = UserDefaults.standard
        if let eventInfo = defaults.dictionary(forKey: "LastSelectedEventInfo"),
           let eventID = eventInfo["eventID"] as? String,
           let eventTitle = eventInfo["eventTitle"] as? String {
            
            print("🎯 Found selected event info from share extension:")
            print("   Event ID: \(eventID)")
            print("   Event Title: \(eventTitle)")
            
            // Check if we have a pending profile that needs to be assigned
            if let pending = pendingProfile {
                print("🎯 Assigning pending profile to selected event")
                
                // Create a new profile with the event ID, preserving the existing ID
                let updatedProfile = LinkedInProfile(
                    id: pending.id,
                    profileURL: pending.profileURL,
                    name: pending.name,
                    company: pending.company,
                    title: pending.title,
                    linkedDate: pending.linkedDate,
                    eventID: eventID
                )
                
                // Save the updated profile
                addProfile(updatedProfile)
                pendingProfile = nil
                
                // Clear the selected event info
                defaults.removeObject(forKey: "LastSelectedEventInfo")
                defaults.synchronize()
                
                print("✅ Profile successfully assigned to event: \(eventTitle)")
            } else {
                print("⚠️ No pending profile found to assign")
            }
        }
    }
    
    private func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: "LinkedInProfiles")
        }
    }
    
    private func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: "LinkedInProfiles"),
           let decoded = try? JSONDecoder().decode([LinkedInProfile].self, from: data) {
            profiles = decoded
        }
    }
}
