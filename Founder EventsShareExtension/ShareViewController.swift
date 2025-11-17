//
//  ShareViewController.swift
//  ScheduleShareShareExtension
//
//  Share extension for linking LinkedIn profiles to events
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {
    
    // MARK: - Properties
    private var eventsTableView: UITableView!
    private var headerLabel: UILabel!
    private var toggleButton: UIButton!
    private var postButton: UIBarButtonItem!
    
    private var allEvents: [CalendarEvent] = []
    private var filteredEvents: [CalendarEvent] = []
    private var showOnlyTodaysEvents = true
    private var selectedEventID: String?
    private var linkedInProfile: LinkedInProfile?
    private var potentialNameFromShare: String?
    private var showingCreateEvent = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadEvents()
        processSharedContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh events when view appears in case new events were added
        loadEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupNavigationBar() {
        // Create navigation bar
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)
        
        // Create navigation item
        let navItem = UINavigationItem(title: "Founder Events")
        
        // Add cancel button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navItem.leftBarButtonItem = cancelButton
        
        // Add create event button and post button
        let createEventButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createEventTapped))
        let postButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postTapped))
        postButton.isEnabled = false
        navItem.rightBarButtonItems = [postButton, createEventButton]
        
        navBar.setItems([navItem], animated: false)
        
        // Store reference to post button for enabling/disabling
        self.postButton = postButton
        
        // Set up constraints for navigation bar
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(domain: "FounderEvents", code: 0, userInfo: [NSLocalizedDescriptionKey: "User cancelled"]))
    }
    
    @objc private func createEventTapped() {
        showCreateEventDialog()
    }
    
    private func isContentValid() -> Bool {
        return selectedEventID != nil
    }
    
    private func setupUI() {
        // Set background color
        view.backgroundColor = UIColor.systemBackground
        
        // Add navigation bar
        setupNavigationBar()
        
        // Create header label
        headerLabel = UILabel()
        headerLabel.text = "Link LinkedIn Profile to Event (or tap ➕ to create new event)"
        headerLabel.numberOfLines = 0
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Select an event to save this LinkedIn profile to. You can view all your connections later in the app."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create toggle button
        toggleButton = UIButton(type: .system)
        toggleButton.setTitle(showOnlyTodaysEvents ? "Today's Events" : "All Events", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toggleButton.backgroundColor = UIColor.systemBlue
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.layer.cornerRadius = 20
        toggleButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        toggleButton.addTarget(self, action: #selector(toggleEventFilter), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove the custom link profile button - we're using navigation bar button only
        
        // Create events table view
        eventsTableView = UITableView(frame: .zero, style: .plain)
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "EventCell")
        eventsTableView.backgroundColor = UIColor.systemBackground
        eventsTableView.separatorStyle = .singleLine
        eventsTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all views to the main view
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(toggleButton)
        view.addSubview(eventsTableView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Header label constraints - positioned below navigation bar
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Toggle button constraints
            toggleButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            toggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Events table view constraints
            eventsTableView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 20),
            eventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadEvents() {
        print("🔍 Share Extension: Loading events...")
        
        // Try to load events with retry mechanism
        loadEventsWithRetry(attempt: 1, maxAttempts: 3)
    }
    
    private func loadEventsWithRetry(attempt: Int, maxAttempts: Int) {
        let delay = Double(attempt) * 0.5 // Increasing delay: 0.5s, 1.0s, 1.5s
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("🔍 Share Extension: Attempt \(attempt) of \(maxAttempts) to load events...")
            
            // Try to load from App Groups
            if let events = self.loadEventsFromAppGroups() {
                self.allEvents = events
                self.filterEvents()
                print("✅ Share Extension: Loaded \(events.count) events from App Groups on attempt \(attempt)")
                print("📅 Filtered to \(self.filteredEvents.count) events for today")
                for (index, event) in self.filteredEvents.enumerated() {
                    print("📱 Event \(index + 1): '\(event.title)' on \(event.startDate)")
                }
                self.eventsTableView.reloadData()
            } else if attempt < maxAttempts {
                print("⚠️ Share Extension: No events found on attempt \(attempt), retrying...")
                self.loadEventsWithRetry(attempt: attempt + 1, maxAttempts: maxAttempts)
            } else {
                print("⚠️ Share Extension: No events found after \(maxAttempts) attempts")
                // No fallback to sample events - show empty state instead
                self.allEvents = []
                self.filteredEvents = []
                self.showNoEventsMessage()
                self.eventsTableView.reloadData()
            }
            
            print("🔍 Share Extension: Final events count: \(self.filteredEvents.count)")
        }
    }
    
    @objc private func toggleEventFilter() {
        showOnlyTodaysEvents.toggle()
        filterEvents()
        eventsTableView.reloadData()
        
        // Update the custom toggle button title
        toggleButton.setTitle(showOnlyTodaysEvents ? "All Events" : "Today Only", for: .normal)
        
        print("🔄 Toggled event filter. Now showing: \(showOnlyTodaysEvents ? "Today's events" : "All events")")
    }
    
    @objc private func postTapped() {
        guard let eventID = selectedEventID,
              let profile = linkedInProfile else {
            print("❌ No event selected or profile missing")
            print("❌ selectedEventID: \(selectedEventID ?? "nil")")
            print("❌ linkedInProfile: \(linkedInProfile?.name ?? "nil")")
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        
        print("🎯 Share Extension: User tapped Post button")
        print("🎯 Selected Event ID: \(eventID)")
        print("🎯 LinkedIn Profile: \(profile.name)")
        
        // Create the final profile with the selected event ID, preserving the existing ID
        let finalProfile = LinkedInProfile(
            id: profile.id,
            profileURL: profile.profileURL,
            name: profile.name,
            company: profile.company,
            title: profile.title,
            linkedDate: profile.linkedDate,
            eventID: eventID
        )
        
        // Save to local storage
        saveProfileToLocalStorage(finalProfile)
        
        // Also save the selected event info for the main app to pick up
        saveSelectedEventInfo(eventID: eventID, eventTitle: getEventTitle(for: eventID))
        
        print("✅ LinkedIn profile linked to event: \(profile.name)")
        print("✅ Profile saved with event ID: \(eventID)")
        
        // Complete the request
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func filterEvents() {
        if showOnlyTodaysEvents {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            filteredEvents = allEvents.filter { event in
                let eventDate = calendar.startOfDay(for: event.startDate)
                return eventDate >= today && eventDate < tomorrow
            }
            print("📅 Filtered to \(filteredEvents.count) events for today out of \(allEvents.count) total events")
        } else {
            filteredEvents = allEvents
            print("📅 Showing all \(filteredEvents.count) events")
        }
    }
    
    private func loadEventsFromAppGroups() -> [CalendarEvent]? {
        print("🔍 Share Extension: Attempting to access App Groups...")
        
        // Try to access App Groups UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: "group.com.HainanMandi.eventsAI") {
            print("✅ Share Extension: Successfully accessed App Groups UserDefaults")
            
            // Force synchronization to ensure we have the latest data
            sharedDefaults.synchronize()
            print("🔄 Share Extension: Forced App Groups synchronization")
            
            // Check if data exists
            if let data = sharedDefaults.data(forKey: "SharedEvents") {
                print("✅ Share Extension: Found data in App Groups, size: \(data.count) bytes")
                
                do {
                    let decodedEvents = try JSONDecoder().decode([CalendarEvent].self, from: data)
                    print("✅ Share Extension: Successfully decoded \(decodedEvents.count) events from App Groups")
                    for (index, event) in decodedEvents.enumerated() {
                        print("📱 Share Extension Event \(index + 1): '\(event.title)' on \(event.startDate)")
                    }
                    return decodedEvents
                } catch {
                    print("❌ Share Extension: Failed to decode events from App Groups: \(error)")
                    return nil
                }
            } else {
                print("❌ Share Extension: No data found for key 'SharedEvents' in App Groups")
                
                // Debug: List all available keys
                let allKeys = sharedDefaults.dictionaryRepresentation().keys
                print("🔍 Share Extension: Available keys in App Groups: \(Array(allKeys))")
                return nil
            }
        } else {
            print("❌ Share Extension: Failed to access App Groups UserDefaults with suiteName: group.com.HainanMandi.eventsAI")
            return nil
        }
    }
    
    private func showNoEventsMessage() {
        headerLabel.text = "No events found. Tap ➕ to create the event you're attending."
    }
    
    private func processSharedContent() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            // Extract name from the shared item's metadata
            extractNameFromSharedContent(item)
            
            if let attachments = item.attachments {
                for provider in attachments {
                    // Handle URLs (LinkedIn profiles)
                    if provider.hasItemConformingToTypeIdentifier("public.url") {
                        provider.loadItem(forTypeIdentifier: "public.url", options: nil) { [weak self] (data, error) in
                            DispatchQueue.main.async {
                                if let url = data as? URL {
                                    self?.handleLinkedInProfile(url: url)
                                }
                            }
                        }
                    }
                    
                    // Handle text content
                    if provider.hasItemConformingToTypeIdentifier("public.text") {
                        provider.loadItem(forTypeIdentifier: "public.text", options: nil) { [weak self] (data, error) in
                            DispatchQueue.main.async {
                                if let text = data as? String, text.contains("linkedin.com") {
                                    if let url = URL(string: text) {
                                        self?.handleLinkedInProfile(url: url)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func extractNameFromSharedContent(_ inputItem: NSExtensionItem) {
        // Extract from attributedTitle (most reliable)
        if let attributedTitle = inputItem.attributedTitle {
            let titleString = attributedTitle.string
            
            // LinkedIn shares often include the person's name in the title
            let cleaningPatterns = [
                " | LinkedIn",
                " - LinkedIn", 
                " on LinkedIn",
                " | Professional Profile",
                " - Professional Profile"
            ]
            
            var cleanTitle = titleString
            for pattern in cleaningPatterns {
                cleanTitle = cleanTitle.replacingOccurrences(of: pattern, with: "")
            }
            cleanTitle = cleanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if isValidPersonName(cleanTitle) {
                print("✅ Found name from shared title: '\(cleanTitle)'")
                self.potentialNameFromShare = cleanTitle
                return
            }
        }
        
        // Extract from attributedContentText
        if let attributedContentText = inputItem.attributedContentText {
            let contentString = attributedContentText.string
            
            // Look for name patterns in the shared content
            let namePatterns = [
                #"([A-Z][a-z]{2,}\s+[A-Z][a-z]{2,}(?:\s+[A-Z][a-z]{2,})?)"#,  // First Last or First Middle Last
                #"([A-Z][a-z]{2,}\s+[A-Z]\.\s+[A-Z][a-z]{2,})"#,  // First M. Last
                #"([A-Z][a-z]{2,}\s+[A-Z][a-z]{2,}\s+[A-Z][a-z]{2,})"#  // First Middle Last
            ]
            
            for pattern in namePatterns {
                if let range = contentString.range(of: pattern, options: .regularExpression) {
                    let potentialName = String(contentString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if isValidPersonName(potentialName) {
                        print("✅ Found name from shared content text: '\(potentialName)'")
                        self.potentialNameFromShare = potentialName
                        return
                    }
                }
            }
        }
    }
    
    private func isValidPersonName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic validation
        guard trimmed.count >= 4 && trimmed.count <= 100 else { return false }
        
        // Must contain at least one space (first + last name)
        guard trimmed.contains(" ") else { return false }
        
        // Should contain only letters, spaces, periods, and apostrophes
        let allowedCharacters = CharacterSet.letters.union(.whitespaces).union(CharacterSet(charactersIn: ".'"))
        guard trimmed.rangeOfCharacter(from: allowedCharacters.inverted) == nil else { return false }
        
        // Shouldn't contain common non-name patterns
        let invalidPatterns = [
            "linkedin", "profile", "www.", "http", "javascript", "function", "var ",
            "null", "undefined", "error", "loading", "please", "click", "here", "view",
            "connect", "message", "follow", "company", "title", "description"
        ]
        
        let lowercased = trimmed.lowercased()
        for pattern in invalidPatterns {
            if lowercased.contains(pattern) {
                return false
            }
        }
        
        // Must start with capital letter
        guard trimmed.first?.isUppercase == true else { return false }
        
        // Should look like a real name (at least 2 words, each starting with capital)
        let words = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard words.count >= 2 else { return false }
        
        for word in words {
            // Each word should start with capital letter and be at least 2 characters
            guard word.count >= 2 && word.first?.isUppercase == true else { return false }
        }
        
        return true
    }
    
    private func handleLinkedInProfile(url: URL) {
        if url.absoluteString.contains("linkedin.com/in/") {
            let profileURL = url.absoluteString
            let finalName = potentialNameFromShare ?? extractNameFromURL(url)
            
            // If we got a username-like name, offer to let user correct it
            let extractedFromURL = extractNameFromURL(url)
            let isLikelyUsername = !finalName.contains(" ") || finalName.lowercased() == extractedFromURL.lowercased()
            
            if isLikelyUsername && potentialNameFromShare == nil {
                showNameCorrectionAlert(for: profileURL, suggestedName: finalName)
            } else {
                let profile = LinkedInProfile(
                    profileURL: profileURL,
                    name: finalName,
                    company: nil,
                    title: nil,
                    eventID: nil
                )
                
                self.linkedInProfile = profile
                print("✅ LinkedIn profile processed: \(finalName)")
            }
        }
    }
    
    private func showNameCorrectionAlert(for profileURL: String, suggestedName: String) {
        let alert = UIAlertController(
            title: "Confirm LinkedIn Name",
            message: "The detected name '\(suggestedName)' might be a username. Please enter the person's real name:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g., Erin Andersen"
            textField.text = suggestedName
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Still save with the username as fallback
            let profile = LinkedInProfile(
                profileURL: profileURL,
                name: suggestedName,
                company: nil,
                title: nil,
                eventID: nil
            )
            
            self.linkedInProfile = profile
            print("✅ LinkedIn profile saved with username: \(suggestedName)")
        })
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
               let correctedName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !correctedName.isEmpty {
                
                let profile = LinkedInProfile(
                    profileURL: profileURL,
                    name: correctedName,
                    company: nil,
                    title: nil,
                    eventID: nil
                )
                
                self?.linkedInProfile = profile
                print("✅ LinkedIn profile saved with corrected name: \(correctedName)")
            } else {
                // Fallback to username if user entered nothing
                let profile = LinkedInProfile(
                    profileURL: profileURL,
                    name: suggestedName,
                    company: nil,
                    title: nil,
                    eventID: nil
                )
                
                self?.linkedInProfile = profile
                print("✅ LinkedIn profile saved with fallback name: \(suggestedName)")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showCreateEventDialog() {
        let alert = UIAlertController(
            title: "Create New Event",
            message: "Add the event you're currently attending:",
            preferredStyle: .alert
        )
        
        // Event title field
        alert.addTextField { textField in
            textField.placeholder = "Event title"
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .yes
        }
        
        // Location field
        alert.addTextField { textField in
            textField.placeholder = "Location (optional)"
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .yes
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let titleField = alert.textFields?[0],
                  let locationField = alert.textFields?[1],
                  let eventTitle = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !eventTitle.isEmpty else {
                return
            }
            
            let location = locationField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.createNewEvent(title: eventTitle, location: location)
        })
        
        present(alert, animated: true)
    }
    
    private func createNewEvent(title: String, location: String?) {
        // Create event for current time (assume you're at the event now)
        let now = Date()
        let endTime = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now.addingTimeInterval(7200)
        
        let newEvent = CalendarEvent(
            title: title,
            startDate: now,
            endDate: endTime,
            location: location,
            notes: "Created from share extension"
        )
        
        // Add to the events list
        allEvents.insert(newEvent, at: 0)
        
        // Update filtered events
        filterEvents()
        
        // Refresh the table
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
            
            // Auto-select the new event
            self.selectedEventID = newEvent.id.uuidString
            self.postButton.isEnabled = self.isContentValid()
            
            // Select the first row (the new event)
            if !self.filteredEvents.isEmpty {
                let indexPath = IndexPath(row: 0, section: 0)
                self.eventsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }
        
        // Save the new event to App Groups so main app can access it
        saveNewEventToAppGroups(newEvent)
        
        print("✅ New event created: '\(title)'")
    }
    
    private func saveNewEventToAppGroups(_ newEvent: CalendarEvent) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.HainanMandi.eventsAI") else {
            return
        }
        
        // Load existing events
        var existingEvents: [CalendarEvent] = []
        if let data = sharedDefaults.data(forKey: "SharedEvents") {
            do {
                existingEvents = try JSONDecoder().decode([CalendarEvent].self, from: data)
            } catch {
                print("❌ Failed to decode existing events: \(error)")
            }
        }
        
        // Add new event at the beginning
        existingEvents.insert(newEvent, at: 0)
        
        // Save back to App Groups
        do {
            let encoded = try JSONEncoder().encode(existingEvents)
            sharedDefaults.set(encoded, forKey: "SharedEvents")
            sharedDefaults.synchronize()
            print("✅ Saved new event to App Groups")
        } catch {
            print("❌ Failed to save new event: \(error)")
        }
    }
    
    private func extractNameFromURL(_ url: URL) -> String {
        let pathComponents = url.pathComponents
        if pathComponents.count > 2 && pathComponents[1] == "in" {
            let username = pathComponents[2]
            
            // Remove LinkedIn profile IDs (alphanumeric strings at the end)
            // Pattern: name-name-12345abc or name-12345abc
            let cleanedUsername = username.replacingOccurrences(
                of: #"-[a-f0-9]{8,}$"#,
                with: "",
                options: .regularExpression
            )
            
            // Convert to readable name
            let name = cleanedUsername.replacingOccurrences(of: "-", with: " ").capitalized
            
            // If the name is too short or looks like an ID, use fallback
            if name.count < 2 || name.allSatisfy({ $0.isNumber }) {
                return "LinkedIn User"
            }
            
            return name
        }
        return "LinkedIn User"
    }
    
    
    private func getEventTitle(for eventID: String) -> String {
        if let event = allEvents.first(where: { $0.id.uuidString == eventID }) {
            return event.title
        }
        return "Unknown Event"
    }
    
    private func saveSelectedEventInfo(eventID: String, eventTitle: String) {
        let defaults = UserDefaults.standard
        let eventInfo = [
            "eventID": eventID,
            "eventTitle": eventTitle,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]
        
        defaults.set(eventInfo, forKey: "LastSelectedEventInfo")
        defaults.synchronize()
        print("💾 Saved selected event info: \(eventTitle) (ID: \(eventID))")
    }
    
    
    private func saveProfileToLocalStorage(_ profile: LinkedInProfile) {
        // Save to local storage (share extension)
        let defaults = UserDefaults.standard
        var profiles: [Data] = defaults.array(forKey: "LocalLinkedInProfiles") as? [Data] ?? []
        
        if let encoded = try? JSONEncoder().encode(profile) {
            profiles.append(encoded)
            defaults.set(profiles, forKey: "LocalLinkedInProfiles")
            defaults.synchronize()
            print("💾 Saved profile to share extension local storage")
        }
        
        // Also save to App Groups so main app can access it
        saveProfileToAppGroups(profile)
    }
    
    private func saveProfileToAppGroups(_ profile: LinkedInProfile) {
        print("💾 Saving LinkedIn profile to App Groups...")
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.HainanMandi.eventsAI") {
            // Load existing profiles
            var profiles: [LinkedInProfile] = []
            if let data = sharedDefaults.data(forKey: "LinkedInProfiles") {
                do {
                    profiles = try JSONDecoder().decode([LinkedInProfile].self, from: data)
                    print("📱 Loaded \(profiles.count) existing LinkedIn profiles from App Groups")
                } catch {
                    print("❌ Failed to decode existing LinkedIn profiles: \(error)")
                }
            }
            
            // Add new profile at the beginning (most recent first)
            profiles.insert(profile, at: 0)
            
            // Save back to App Groups
            do {
                let encoded = try JSONEncoder().encode(profiles)
                sharedDefaults.set(encoded, forKey: "LinkedInProfiles")
                sharedDefaults.synchronize()
                print("✅ Saved \(profiles.count) LinkedIn profiles to App Groups")
                print("✅ Profile: \(profile.name) linked to event: \(profile.linkedEventID ?? "nil")")
            } catch {
                print("❌ Failed to encode LinkedIn profiles for App Groups: \(error)")
            }
        } else {
            print("❌ Failed to access App Groups for LinkedIn profiles")
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ShareViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredEvents.isEmpty {
            if showOnlyTodaysEvents {
                return "No events today"
            } else {
                return "No events available"
            }
        }
        if showOnlyTodaysEvents {
            return "Today's Events"
        } else {
            return "All Events"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            headerView.textLabel?.textColor = UIColor.secondaryLabel
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let event = filteredEvents[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = event.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = UIColor.label
        
        cell.detailTextLabel?.text = formatEventDate(event.startDate)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = UIColor.secondaryLabel
        
        // Show checkmark if selected
        if selectedEventID == event.id.uuidString {
            cell.accessoryType = .checkmark
            cell.accessoryView = nil
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            cell.tintColor = UIColor.systemBlue
        } else {
            cell.accessoryType = .none
            cell.accessoryView = nil
            cell.backgroundColor = UIColor.systemBackground
        }
        
        // Add some padding
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = filteredEvents[indexPath.row]
        selectedEventID = event.id.uuidString
        
        // Update UI
        tableView.reloadData()
        
        // Update the navigation bar post button
        postButton.isEnabled = isContentValid()
        
        print("✅ Selected event: \(event.title)")
        print("🔧 Post button enabled: \(postButton.isEnabled)")
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// CalendarEvent struct (copy from your main app)
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var extractedInfo: ExtractedEventInfo?
    var eventIdentifier: String?
    
    init(id: UUID = UUID(), title: String, startDate: Date, endDate: Date, location: String? = nil, notes: String? = nil, extractedInfo: ExtractedEventInfo? = nil, eventIdentifier: String? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.extractedInfo = extractedInfo
        self.eventIdentifier = eventIdentifier
    }
}

// LinkedInProfile struct (copy from your main app)
struct LinkedInProfile: Codable {
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

// ExtractedEventInfo struct (needed for CalendarEvent)
struct ExtractedEventInfo: Codable, Equatable {
    let rawText: String
    var title: String?
    var startDateTime: Date?
    var endDateTime: Date?
    var location: String?
    var description: String?
    var confidence: Double
    
    init(rawText: String, title: String? = nil, startDateTime: Date? = nil, endDateTime: Date? = nil, location: String? = nil, description: String? = nil, confidence: Double = 0.5) {
        self.rawText = rawText
        self.title = title
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.location = location
        self.description = description
        self.confidence = confidence
    }
}



