//
//  LinkedInProfilesView.swift
//  ScheduleShare
//
//  Created by Weijia Huang on 8/4/25.
//

import SwiftUI

struct LinkedInProfilesView: View {
    @EnvironmentObject var appState: AppState
    @State private var linkedInProfiles: [LinkedInProfile] = []
    @State private var filteredProfiles: [LinkedInProfile] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var showingDeleteConfirmation = false
    @State private var profileToDelete: LinkedInProfile?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                contentSection
            }
            .navigationTitle("LinkedIn Connections")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadLinkedInProfiles()
            }
            .refreshable {
                loadLinkedInProfiles()
            }
            .overlay(toastOverlay)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Delete Connection", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    profileToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    deleteProfile()
                }
            } message: {
                if let profile = profileToDelete {
                    Text("Are you sure you want to delete \(profile.name)? This action cannot be undone.")
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Search Bar
            if !linkedInProfiles.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search by name, event, company, or notes...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { _ in
                            filterProfiles()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            filterProfiles()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                if !linkedInProfiles.isEmpty {
                    Button(action: {
                        // Select all for bulk actions
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle")
                            Text("Select All")
                        }
                        .font(.subheadline)
                        .foregroundColor(.founderAccent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.founderAccent.opacity(0.1))
                        )
                    }
                }
                
                Spacer()
                
                NavigationLink(destination: MessageTemplateSettingsView()) {
                    HStack(spacing: 6) {
                        Image(systemName: "message.circle.fill")
                        Text("Message Settings")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                if !linkedInProfiles.isEmpty {
                    Text("Long press to delete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    private var contentSection: some View {
        Group {
            if isLoading {
                loadingView
            } else if linkedInProfiles.isEmpty {
                emptyStateView
            } else if filteredProfiles.isEmpty && !searchText.isEmpty {
                noSearchResultsView
            } else {
                profilesListView
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading LinkedIn profiles...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.founderAccent.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("Build Your Network")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Connect with people from your events")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(.founderAccent)
                    Text("Share a LinkedIn profile from LinkedIn app")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "2.circle.fill")
                        .foregroundColor(.founderAccent)
                    Text("Link it to an event")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "3.circle.fill")
                        .foregroundColor(.founderAccent)
                    Text("Send personalized messages")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                openLinkedInApp()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                    Text("Open LinkedIn")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.founderAccent)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
    }
    
    private var noSearchResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Try searching with different keywords")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                searchText = ""
                filterProfiles()
            }) {
                Text("Clear Search")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
    }
    
    private var profilesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredProfiles) { profile in
                    NavigationLink(destination: LinkedInProfileDetailView(profile: profile)) {
                        LinkedInProfileRow(
                            profile: profile, 
                            appState: appState,
                            onToast: { message in
                                showToast(message)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            if let index = linkedInProfiles.firstIndex(where: { $0.id == profile.id }) {
                                deleteProfiles(offsets: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            if let index = linkedInProfiles.firstIndex(where: { $0.id == profile.id }) {
                                deleteProfiles(offsets: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private var toastOverlay: some View {
        Group {
            if showingToast {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(toastMessage)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation {
            showingToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingToast = false
            }
        }
    }
    
    private func deleteProfiles(offsets: IndexSet) {
        let profilesToDelete = offsets.map { filteredProfiles[$0] }
        
        // Remove from both arrays
        for profile in profilesToDelete {
            if let index = linkedInProfiles.firstIndex(where: { $0.id == profile.id }) {
                linkedInProfiles.remove(at: index)
            }
        }
        
        // Update filtered profiles
        filterProfiles()
        
        // Save updated profiles to App Groups
        appState.saveLinkedInProfilesToAppGroups(linkedInProfiles)
        
        // Show confirmation toast
        if profilesToDelete.count == 1 {
            showToast("Deleted \(profilesToDelete[0].name)")
        } else {
            showToast("Deleted \(profilesToDelete.count) profiles")
        }
        
        print("🗑️ Deleted \(profilesToDelete.count) LinkedIn profiles")
    }
    
    private func confirmDeleteProfile(_ profile: LinkedInProfile) {
        profileToDelete = profile
        showingDeleteConfirmation = true
    }
    
    private func deleteProfile() {
        guard let profile = profileToDelete,
              let index = linkedInProfiles.firstIndex(where: { $0.id == profile.id }) else {
            return
        }
        
        // Remove from local array
        linkedInProfiles.remove(at: index)
        
        // Update filtered profiles
        filterProfiles()
        
        // Save updated profiles to App Groups
        appState.saveLinkedInProfilesToAppGroups(linkedInProfiles)
        
        // Show confirmation toast
        showToast("Deleted \(profile.name)")
        
        print("🗑️ Deleted LinkedIn profile: \(profile.name)")
        
        // Reset state
        profileToDelete = nil
    }
    
    private func loadLinkedInProfiles() {
        print("🔍 Loading LinkedIn profiles from share extension storage...")
        isLoading = true
        
        // Use AppState method to load profiles from App Groups
        let profiles = appState.loadLinkedInProfilesFromAppGroups()
        self.linkedInProfiles = profiles
        self.filteredProfiles = profiles
        isLoading = false
        
        if profiles.isEmpty {
            print("⚠️ No LinkedIn profiles found")
        } else {
            print("✅ Successfully loaded \(profiles.count) LinkedIn profiles")
        }
    }
    
    private func filterProfiles() {
        if searchText.isEmpty {
            filteredProfiles = linkedInProfiles
        } else {
            let searchLowercased = searchText.lowercased()
            filteredProfiles = linkedInProfiles.filter { profile in
                // Search in name
                if profile.name.lowercased().contains(searchLowercased) {
                    return true
                }
                
                // Search in company
                if let company = profile.company, company.lowercased().contains(searchLowercased) {
                    return true
                }
                
                // Search in title
                if let title = profile.title, title.lowercased().contains(searchLowercased) {
                    return true
                }
                
                // Search in event name
                if let eventID = profile.linkedEventID,
                   let event = appState.events.first(where: { $0.id.uuidString == eventID }),
                   event.title.lowercased().contains(searchLowercased) {
                    return true
                }
                
                // Search in notes
                let notesKey = "notes_\(profile.id.uuidString)"
                if let notes = UserDefaults.standard.string(forKey: notesKey),
                   notes.lowercased().contains(searchLowercased) {
                    return true
                }
                
                return false
            }
        }
    }
    
    private func openLinkedInApp() {
        print("🔗 Attempting to open LinkedIn app...")
        
        // Try to open LinkedIn app first
        if let linkedInURL = URL(string: "linkedin://") {
            if UIApplication.shared.canOpenURL(linkedInURL) {
                UIApplication.shared.open(linkedInURL) { success in
                    if success {
                        print("✅ Successfully opened LinkedIn app")
                    } else {
                        print("❌ Failed to open LinkedIn app")
                        self.showToast("Could not open LinkedIn app")
                    }
                }
            } else {
                print("⚠️ LinkedIn app not installed, opening App Store")
                openLinkedInInAppStore()
            }
        }
    }
    
    private func openLinkedInInAppStore() {
        if let appStoreURL = URL(string: "https://apps.apple.com/app/linkedin/id288429040") {
            UIApplication.shared.open(appStoreURL) { success in
                if success {
                    print("✅ Opened LinkedIn in App Store")
                    self.showToast("Opening LinkedIn in App Store...")
                } else {
                    print("❌ Failed to open App Store")
                    self.showToast("Could not open App Store")
                }
            }
        }
    }
}

struct LinkedInProfileRow: View {
    let profile: LinkedInProfile
    let appState: AppState
    let onToast: (String) -> Void
    @State private var eventTitle = "Unknown Event"
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.founderAccent.opacity(0.3), Color.founderAccent.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(profile.name.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.founderAccent)
                )
            
            // Profile Info
            VStack(alignment: .leading, spacing: 6) {
                Text(profile.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let company = profile.company {
                    Text(company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                
                if let title = profile.title {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Event Badge
                HStack(spacing: 6) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(eventTitle)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            Spacer()
            
            // Action Button
            Button(action: {
                Task {
                    await openLinkedInWithMessage(profile: profile)
                }
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "message.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Message")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            loadEventTitle()
        }
    }
    
    private func loadEventTitle() {
        if let eventID = profile.linkedEventID {
            // Try to find in CalendarEvent
            if let event = appState.events.first(where: { $0.id.uuidString == eventID }) {
                eventTitle = event.title
                return
            }
            
            // If no event found, show a fallback message
            eventTitle = "Event Not Found"
        } else {
            eventTitle = "No Event Linked"
        }
    }
    
    private func openLinkedInWithMessage(profile: LinkedInProfile) async {
        // Show loading toast
        onToast("Generating personalized message...")
        
        // Try to scrape LinkedIn profile for more info
        let enhancedProfile = await scrapeLinkedInProfile(profile)
        
        // Create a more customized message with scraped info
        let message = createEnhancedMessage(for: enhancedProfile)
        
        // Copy message to clipboard
        UIPasteboard.general.string = message
        print("✅ Customized message copied to clipboard: \(message)")
        
        // Show toast notification about clipboard
        onToast("Personalized message copied! Opening LinkedIn...")
        
        // Try to open LinkedIn profile without overwriting clipboard
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        await openLinkedInProfileOnly(profile: profile)
    }
    
    
    private func openLinkedInProfileOnly(profile: LinkedInProfile) async {
        let cleanURL = cleanLinkedInURL(profile.profileURL)
        print("🔗 Attempting to open LinkedIn URL (without clipboard): \(cleanURL)")
        
        // Try LinkedIn app first (only if available)
        if let username = extractUsernameFromURL(cleanURL) {
            let linkedInAppURL = "linkedin://profile/\(username)"
            if let appURL = URL(string: linkedInAppURL) {
                print("🔗 Checking if LinkedIn app is available: \(linkedInAppURL)")
                if UIApplication.shared.canOpenURL(appURL) {
                    print("✅ LinkedIn app available, opening...")
                    let success = await UIApplication.shared.open(appURL, options: [:])
                    if success {
                        print("✅ Successfully opened LinkedIn app")
                        return
                    } else {
                        print("⚠️ LinkedIn app failed, trying web...")
                    }
                } else {
                    print("⚠️ LinkedIn app not available, trying web...")
                }
            }
        }
        
        // Try to open in Safari without copying to clipboard
        await openLinkedInWebOnly(cleanURL)
    }
    
    private func openLinkedInWeb(_ cleanURL: String) async {
        print("🌐 Attempting to open LinkedIn URL: \(cleanURL)")
        
        guard let url = URL(string: cleanURL) else {
            print("❌ Invalid URL: \(cleanURL)")
            onToast("Invalid LinkedIn URL")
            return
        }
        
        // Try opening with different options to bypass iOS restrictions
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [
            .universalLinksOnly: false
        ]
        
        let success = await UIApplication.shared.open(url, options: options)
        
        if success {
            print("✅ Successfully opened LinkedIn in Safari")
            onToast("Opening LinkedIn in Safari...")
        } else {
            print("❌ Failed to open LinkedIn URL, copying to clipboard")
            UIPasteboard.general.string = cleanURL
            onToast("LinkedIn URL copied! Open Safari and paste to visit the profile.")
        }
    }
    
    private func openLinkedInWebOnly(_ cleanURL: String) async {
        print("🌐 Attempting to open LinkedIn URL (without clipboard): \(cleanURL)")
        
        guard let url = URL(string: cleanURL) else {
            print("❌ Invalid URL: \(cleanURL)")
            return
        }
        
        // Try opening with different options to bypass iOS restrictions
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [
            .universalLinksOnly: false
        ]
        
        let success = await UIApplication.shared.open(url, options: options)
        
        if success {
            print("✅ Successfully opened LinkedIn in Safari")
        } else {
            print("❌ Failed to open LinkedIn URL in Safari")
            // Don't copy to clipboard to preserve the message
        }
    }
    
    private func extractUsernameFromURL(_ url: String) -> String? {
        let patterns = [
            "https://www\\.linkedin\\.com/in/([^/?]+)",
            "http://www\\.linkedin\\.com/in/([^/?]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let usernameRange = Range(match.range(at: 1), in: url) {
                return String(url[usernameRange])
            }
        }
        return nil
    }
    
    private func cleanLinkedInURL(_ url: String) -> String {
        if let urlComponents = URLComponents(string: url) {
            var cleanComponents = urlComponents
            cleanComponents.query = nil
            cleanComponents.fragment = nil
            return cleanComponents.string ?? url
        }
        return url
    }
    
    private func scrapeLinkedInProfile(_ profile: LinkedInProfile) async -> LinkedInProfile {
        print("🔍 Scraping LinkedIn profile for enhanced info...")
        
        let cleanURL = cleanLinkedInURL(profile.profileURL)
        
        do {
            // Create URL request
            guard let url = URL(string: cleanURL) else {
                print("❌ Invalid URL for scraping")
                return profile
            }
            
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            // Make the request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let html = String(data: data, encoding: .utf8) {
                    print("✅ Successfully fetched LinkedIn page")
                    return parseLinkedInHTML(html, originalProfile: profile)
                }
            } else {
                print("⚠️ LinkedIn page returned status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        } catch {
            print("❌ Failed to scrape LinkedIn profile: \(error)")
        }
        
        return profile
    }
    
    private func parseLinkedInHTML(_ html: String, originalProfile: LinkedInProfile) -> LinkedInProfile {
        print("🔍 Parsing LinkedIn HTML for profile info...")
        
        var enhancedProfile = originalProfile
        var extractedName = originalProfile.name
        var extractedTitle: String?
        var extractedCompany: String?
        
        // Extract name from title tag or meta tags
        if let nameMatch = html.range(of: #"<title>([^|]+)\|"#, options: .regularExpression) {
            let nameString = String(html[nameMatch])
            if let nameRange = nameString.range(of: #"<title>([^|]+)\|"#, options: .regularExpression) {
                let name = String(nameString[nameRange]).replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "|", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty && name != "LinkedIn" {
                    extractedName = name
                    print("✅ Extracted name: \(name)")
                }
            }
        }
        
        // Extract title/headline from meta tags
        if let titleMatch = html.range(of: #"property="og:title" content="([^"]+)""#, options: .regularExpression) {
            let titleString = String(html[titleMatch])
            if let titleRange = titleString.range(of: #"content="([^"]+)""#, options: .regularExpression) {
                let title = String(titleString[titleRange]).replacingOccurrences(of: "content=\"", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty && title != extractedName {
                    extractedTitle = title
                    print("✅ Extracted title: \(title)")
                }
            }
        }
        
        // Extract company from description or title
        if let descMatch = html.range(of: #"property="og:description" content="([^"]+)""#, options: .regularExpression) {
            let descString = String(html[descMatch])
            if let descRange = descString.range(of: #"content="([^"]+)""#, options: .regularExpression) {
                let description = String(descString[descRange]).replacingOccurrences(of: "content=\"", with: "").replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Try to extract company from description
                if let companyMatch = description.range(of: #"at ([^|]+)"#, options: .regularExpression) {
                    let company = String(description[companyMatch]).replacingOccurrences(of: "at ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    if !company.isEmpty {
                        extractedCompany = company
                        print("✅ Extracted company: \(company)")
                    }
                }
            }
        }
        
        // Create enhanced profile with extracted info
        enhancedProfile = LinkedInProfile(
            profileURL: originalProfile.profileURL,
            name: extractedName,
            company: extractedCompany ?? originalProfile.company,
            title: extractedTitle ?? originalProfile.title,
            eventID: originalProfile.linkedEventID
        )
        
        print("✅ Enhanced profile created with scraped info")
        return enhancedProfile
    }
    
    private func createEnhancedMessage(for profile: LinkedInProfile) -> String {
        // Get custom template from UserDefaults, fallback to default
        let customTemplate = UserDefaults.standard.string(forKey: "LinkedInMessageTemplate") ?? getDefaultTemplate()
        
        // Replace placeholders with actual values
        let name = profile.name.isEmpty ? "there" : profile.name
        let event = eventTitle != "Unknown Event" ? eventTitle : "an event"
        let title = profile.title ?? "your role"
        let company = profile.company ?? "your company"
        
        return customTemplate
            .replacingOccurrences(of: "{NAME}", with: name)
            .replacingOccurrences(of: "{EVENT}", with: event)
            .replacingOccurrences(of: "{TITLE}", with: title)
            .replacingOccurrences(of: "{COMPANY}", with: company)
    }
    
    private func getDefaultTemplate() -> String {
        return """
Hi {NAME}!

I hope you're doing well. I came across your profile and noticed we both attended {EVENT}. I'm impressed by your role as {TITLE} at {COMPANY}. I'd be excited to connect and potentially collaborate in the future.

Looking forward to connecting!

Best regards
"""
    }
    
    private func createPredefinedMessage(for profile: LinkedInProfile) -> String {
        let eventContext = eventTitle != "Unknown Event" ? " at \(eventTitle)" : ""
        
        return """
        Hi \(profile.name)!
        
        I hope you're doing well. I came across your profile and noticed we both attended\(eventContext). I'd love to connect and learn more about your work at \(profile.company ?? "your company").
        
        Looking forward to connecting!
        
        Best regards
        """
    }
}

// MARK: - LinkedIn Profile Detail View
struct LinkedInProfileDetailView: View {
    let profile: LinkedInProfile
    @EnvironmentObject var appState: AppState
    @State private var notes: String = ""
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var eventTitle = "Unknown Event"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.founderAccent.opacity(0.3), Color.founderAccent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(String(profile.name.prefix(1)).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.founderAccent)
                        )
                    
                    // Name and Info
                    VStack(spacing: 8) {
                        Text(profile.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        if let company = profile.company {
                            Text(company)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let title = profile.title {
                            Text(title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                
                // Event Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shared Event")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text(eventTitle)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                // Notes Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Notes")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            saveNotes()
                            showToast("Notes saved!")
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save")
                            }
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                            )
                        }
                    }
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .onChange(of: notes) { _ in
                            // Auto-save after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                saveNotes()
                            }
                        }
                }
                
                // Action Button
                Button(action: {
                    openLinkedInProfile(profile: profile)
                }) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("View LinkedIn Profile")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadEventTitle()
            loadNotes()
        }
        .onDisappear {
            saveNotes()
        }
        .overlay(
            // Toast notification
            Group {
                if showingToast {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text(toastMessage)
                                .foregroundColor(.white)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
    }
    
    private func loadEventTitle() {
        if let eventID = profile.linkedEventID {
            if let event = appState.events.first(where: { $0.id.uuidString == eventID }) {
                eventTitle = event.title
            } else {
                eventTitle = "Event Not Found"
            }
        } else {
            eventTitle = "No Event Linked"
        }
    }
    
    private func loadNotes() {
        let key = "notes_\(profile.id.uuidString)"
        notes = UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    private func saveNotes() {
        let key = "notes_\(profile.id.uuidString)"
        UserDefaults.standard.set(notes, forKey: key)
        UserDefaults.standard.synchronize() // Force immediate save
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation {
            showingToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingToast = false
            }
        }
    }
    
    private func openLinkedInWithMessage(profile: LinkedInProfile) async {
        showToast("Generating personalized message...")
        
        // Create a more customized message with scraped info
        let message = createEnhancedMessage(for: profile)
        
        // Copy message to clipboard
        UIPasteboard.general.string = message
        print("✅ Customized message copied to clipboard: \(message)")
        
        // Show toast notification about clipboard
        showToast("Personalized message copied! Opening LinkedIn...")
        
        // Try to open LinkedIn profile without overwriting clipboard
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        await openLinkedInProfileOnly(profile: profile)
    }
    
    private func openLinkedInProfile(profile: LinkedInProfile) {
        let cleanURL = cleanLinkedInURL(profile.profileURL)
        print("🔗 Attempting to open LinkedIn URL: \(cleanURL)")
        
        guard let url = URL(string: cleanURL) else {
            print("❌ Invalid URL: \(cleanURL)")
            showToast("Invalid LinkedIn URL")
            return
        }
        
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [
            .universalLinksOnly: false
        ]
        
        UIApplication.shared.open(url, options: options) { success in
            if success {
                print("✅ Successfully opened LinkedIn in Safari")
                showToast("Opening LinkedIn in Safari...")
            } else {
                print("❌ Failed to open LinkedIn URL, copying to clipboard")
                UIPasteboard.general.string = cleanURL
                showToast("LinkedIn URL copied! Open Safari and paste to visit the profile.")
            }
        }
    }
    
    private func openLinkedInProfileOnly(profile: LinkedInProfile) async {
        let cleanURL = cleanLinkedInURL(profile.profileURL)
        print("🔗 Attempting to open LinkedIn URL (without clipboard): \(cleanURL)")
        
        // Try LinkedIn app first (only if available)
        if let username = extractUsernameFromURL(cleanURL) {
            let linkedInAppURL = "linkedin://profile/\(username)"
            if let appURL = URL(string: linkedInAppURL) {
                print("🔗 Checking if LinkedIn app is available: \(linkedInAppURL)")
                if UIApplication.shared.canOpenURL(appURL) {
                    print("✅ LinkedIn app available, opening...")
                    let success = await UIApplication.shared.open(appURL, options: [:])
                    if success {
                        print("✅ Successfully opened LinkedIn app")
                        return
                    } else {
                        print("⚠️ LinkedIn app failed, trying web...")
                    }
                } else {
                    print("⚠️ LinkedIn app not available, trying web...")
                }
            }
        }
        
        // Try to open in Safari without copying to clipboard
        await openLinkedInWebOnly(cleanURL)
    }
    
    private func openLinkedInWebOnly(_ cleanURL: String) async {
        print("🌐 Attempting to open LinkedIn URL (without clipboard): \(cleanURL)")
        
        guard let url = URL(string: cleanURL) else {
            print("❌ Invalid URL: \(cleanURL)")
            return
        }
        
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [
            .universalLinksOnly: false
        ]
        
        let success = await UIApplication.shared.open(url, options: options)
        
        if success {
            print("✅ Successfully opened LinkedIn in Safari")
        } else {
            print("❌ Failed to open LinkedIn URL in Safari")
        }
    }
    
    private func extractUsernameFromURL(_ url: String) -> String? {
        let patterns = [
            "https://www\\.linkedin\\.com/in/([^/?]+)",
            "http://www\\.linkedin\\.com/in/([^/?]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let usernameRange = Range(match.range(at: 1), in: url) {
                return String(url[usernameRange])
            }
        }
        return nil
    }
    
    private func cleanLinkedInURL(_ url: String) -> String {
        if let urlComponents = URLComponents(string: url) {
            var cleanComponents = urlComponents
            cleanComponents.query = nil
            cleanComponents.fragment = nil
            return cleanComponents.string ?? url
        }
        return url
    }
    
    private func createEnhancedMessage(for profile: LinkedInProfile) -> String {
        // Get custom template from UserDefaults, fallback to default
        let customTemplate = UserDefaults.standard.string(forKey: "LinkedInMessageTemplate") ?? getDefaultTemplate()
        
        // Replace placeholders with actual values
        let name = profile.name.isEmpty ? "there" : profile.name
        let event = eventTitle != "Unknown Event" ? eventTitle : "an event"
        let title = profile.title ?? "your role"
        let company = profile.company ?? "your company"
        
        return customTemplate
            .replacingOccurrences(of: "{NAME}", with: name)
            .replacingOccurrences(of: "{EVENT}", with: event)
            .replacingOccurrences(of: "{TITLE}", with: title)
            .replacingOccurrences(of: "{COMPANY}", with: company)
    }
    
    private func getDefaultTemplate() -> String {
        return """
Hi {NAME}!

I hope you're doing well. I came across your profile and noticed we both attended {EVENT}. I'm impressed by your role as {TITLE} at {COMPANY}. I'd be excited to connect and potentially collaborate in the future.

Looking forward to connecting!

Best regards
"""
    }
}

#Preview {
    LinkedInProfilesView()
        .environmentObject(AppState())
}