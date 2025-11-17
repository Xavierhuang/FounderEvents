import SwiftUI

struct DiscoverView: View {
    @StateObject private var garysGuideService = GarysGuideService()
    @ObservedObject var appState: AppState
    @State private var selectedEventType = "All Events"
    
    var filteredEvents: [GarysGuideEvent] {
        var events = garysGuideService.events
        
        // Filter by event type only
        if selectedEventType != "All Events" {
            events = events.filter { event in
                switch selectedEventType {
                case "Popular Events":
                    return event.isPopularEvent
                case "Free Events":
                    return event.price == "Free"
                case "Paid Events":
                    return event.price != "Free"
                default:
                    return true
                }
            }
        }
        
        return events
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Event type filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(["All Events", "Popular Events", "Free Events", "Paid Events"], id: \.self) { type in
                        FilterChip(
                            title: type,
                            isSelected: selectedEventType == type
                        ) {
                            selectedEventType = type
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var eventsListView: some View {
        Group {
            if garysGuideService.isLoading {
                LoadingView()
            } else if let errorMessage = garysGuideService.errorMessage, garysGuideService.events.isEmpty {
                ErrorStateView(errorMessage: errorMessage) {
                    garysGuideService.forceLoadFreshEvents()
                }
            } else if filteredEvents.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEvents) { event in
                            SimpleEventCard(event: event, appState: appState)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    // Pull to refresh functionality
                    garysGuideService.refreshEvents()
                }
            }
        }
    }
    
    private var networkOverlay: some View {
        Group {
            if garysGuideService.errorMessage != nil && garysGuideService.events.isEmpty {
                VStack {
                    Spacer()
                    
                    // Network access banner
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.white)
                            Text("Internet Access Required")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        Text("Enable WiFi or cellular data to discover events from Founder Events")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            garysGuideService.forceLoadFreshEvents()
                        }) {
                            Text("Try Again")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.founderWarning)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.founderWarning)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                eventsListView
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        garysGuideService.forceLoadFreshEvents()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.founderAccent)
                    }
                }
            }
            .onAppear {
                // Ensure events are loaded when view appears
                if garysGuideService.events.isEmpty && !garysGuideService.isLoading {
                    garysGuideService.loadEvents()
                }
                
                // Debug: Print current state
                print("🔍 DiscoverView State:")
                print("   - isLoading: \(garysGuideService.isLoading)")
                print("   - events count: \(garysGuideService.events.count)")
                print("   - error message: \(garysGuideService.errorMessage ?? "nil")")
                print("   - filtered events count: \(filteredEvents.count)")
            }
            .overlay(networkOverlay)
        }
    }
}

// MARK: - Simple Event Card
struct SimpleEventCard: View {
    let event: GarysGuideEvent
    @ObservedObject var appState: AppState
    @EnvironmentObject var linkedInManager: LinkedInProfileManager
    @State private var showingCalendarAlert = false
    @State private var calendarAlertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with title and badges
            HStack(alignment: .top) {
                Text(event.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Event type badge
                if event.isPopularEvent {
                    Text("🔥 Popular")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.orange.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            
            // Date and time
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.founderAccent)
                        .font(.subheadline)
                    
                    Text(event.displayDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Price
                Text(event.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(event.price == "Free" ? .founderSuccess : .founderWarning)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(event.price == "Free" ? 
                                  Color.founderSuccess.opacity(0.15) : 
                                  Color.founderWarning.opacity(0.15)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(event.price == "Free" ? Color.founderSuccess.opacity(0.3) : Color.founderWarning.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Venue
            if !event.displayVenue.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "location")
                        .foregroundColor(.founderPrimary)
                        .font(.subheadline)
                    
                    Text(event.displayVenue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                // Add to Calendar button
                Button(action: {
                    addToCalendar()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.subheadline)
                        Text("Add to Calendar")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.founderAccent, Color.founderAccent.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.founderAccent.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // View Details button
                Button(action: {
                    openEventURL()
                }) {
                    HStack(spacing: 6) {
                        Text(getButtonText())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.founderAccent)
                        
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                            .foregroundColor(.founderAccent)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.founderAccent.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.founderAccent.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .alert("Calendar", isPresented: $showingCalendarAlert) {
            Button("OK") { }
        } message: {
            Text(calendarAlertMessage)
        }

    }
    
    private func addToCalendar() {
        print("🎯🎯🎯 addToCalendar() called for event: \(event.title)")
        print("🎯🎯🎯 Event date: '\(event.date)', time: '\(event.time)'")
        
        // Parse the actual event date and time
        let eventDate = parseEventDateTime(date: event.date, time: event.time)
        
        guard let startDate = eventDate else {
            print("🎯🎯🎯 Failed to parse event date and time")
            calendarAlertMessage = "Could not parse event date and time"
            showingCalendarAlert = true
            return
        }
        
        print("🎯🎯🎯 Parsed start date: \(startDate)")
        
        // Create end date (1 hour duration)
        let endDate = startDate.addingTimeInterval(3600)
        print("🎯🎯🎯 End date: \(endDate)")
        
        // Create calendar event with the correct date and time
        let calendarEvent = CalendarEvent(
            title: event.title,
            startDate: startDate,
            endDate: endDate,
            location: event.venue,
            notes: "Event URL: \(event.url)\nSpeakers: \(event.speakers)\nPrice: \(event.price)"
        )
        
        print("🎯🎯🎯 Created calendar event:")
        print("   Title: \(calendarEvent.title)")
        print("   Start: \(calendarEvent.startDate)")
        print("   End: \(calendarEvent.endDate)")
        print("   Location: \(calendarEvent.location ?? "No location")")
        
        // Check if event already exists
        let existingEvent = appState.events.first { existing in
            existing.title == event.title &&
            Calendar.current.isDate(existing.startDate, inSameDayAs: startDate)
        }
        
        if existingEvent != nil {
            print("🎯🎯🎯 Event already exists in calendar")
            calendarAlertMessage = "Event already exists in your calendar"
            showingCalendarAlert = true
        } else {
            print("🎯🎯🎯 Adding new event to calendar")
            print("🎯🎯🎯 About to call appState.addEvent()")
            appState.addEvent(calendarEvent)
            print("🎯🎯🎯 appState.addEvent() completed for: \(calendarEvent.title)")
            calendarAlertMessage = "Event added to your calendar successfully!"
            showingCalendarAlert = true
        }
    }
    
    private func parseEventDateTime(date: String, time: String) -> Date? {
        print("🔍 parseEventDateTime called with date: '\(date)', time: '\(time)'")
        
        // Get current year
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // Create full date string with current year
        let fullDateString = "\(date) \(currentYear)"
        print("📅 Full date string: '\(fullDateString)'")
        
        // Parse the date with year
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM dd yyyy"
        fullDateFormatter.locale = Locale(identifier: "en_US")
        
        guard let eventDate = fullDateFormatter.date(from: fullDateString) else {
            print("❌ Failed to parse date: \(fullDateString)")
            return nil
        }
        
        print("📅 Parsed event date: \(eventDate)")
        
        // Check if the event date is in the past (before today)
        let calendar = Calendar.current
        let today = Date()
        let eventMonth = calendar.component(.month, from: eventDate)
        let eventDay = calendar.component(.day, from: eventDate)
        
        // Always use current year - no events should be moved to next year
        let adjustedYear = currentYear
        print("✅ Using current year for event: \(currentYear)")
        
        // Recreate the date with the adjusted year
        let adjustedDateString = "\(date) \(adjustedYear)"
        print("📅 Adjusted date string: '\(adjustedDateString)'")
        
        guard let adjustedEventDate = fullDateFormatter.date(from: adjustedDateString) else {
            print("❌ Failed to parse adjusted date: \(adjustedDateString)")
            return nil
        }
        
        print("📅 Final event date: \(adjustedEventDate)")
        
        // Parse the time - try different formats
        let timeFormats = ["h:mm a", "h:mma", "HH:mm", "h:mm"]
        var eventTime: Date?
        
        for format in timeFormats {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = format
            timeFormatter.locale = Locale(identifier: "en_US")
            
            if let parsedTime = timeFormatter.date(from: time) {
                eventTime = parsedTime
                print("⏰ Parsed time with format '\(format)': \(parsedTime)")
                break
            }
        }
        
        guard let eventTime = eventTime else {
            print("❌ Failed to parse time: \(time)")
            return nil
        }
        
        // Combine date and time
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: adjustedEventDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: eventTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        // Set timezone to Eastern Time (Gary's Guide events are typically in NYC)
        combinedComponents.timeZone = TimeZone(identifier: "America/New_York")
        
        let finalDate = calendar.date(from: combinedComponents)
        print("🎯 Final combined date: \(finalDate?.description ?? "nil")")
        
        return finalDate
    }
    
    private func openEventURL() {
        print("🔗 Opening event URL: \(event.url)")
        
        var finalURL = event.url
        
        // If it's a gary.to link, add cache-busting parameter
        if event.url.contains("gary.to/") {
            let timestamp = Int(Date().timeIntervalSince1970)
            finalURL = "\(event.url)?t=\(timestamp)"
            print("🔄 Added cache-busting to gary.to URL: \(finalURL)")
        }
        
        if let url = URL(string: finalURL) {
            // For gary.to links, open in Safari to avoid in-app caching
            let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [
                .universalLinksOnly: false
            ]
            
            UIApplication.shared.open(url, options: options) { success in
                if success {
                    print("✅ Successfully opened event URL")
                } else {
                    print("❌ Failed to open event URL: \(finalURL)")
                    // Fallback to Gary's Guide search
                    self.openGarysGuideFallback()
                }
            }
        } else {
            print("❌ Invalid event URL: \(finalURL)")
            openGarysGuideFallback()
        }
    }
    
    private func openGarysGuideFallback() {
        // Fallback: Search for the event on Gary's Guide
        let searchQuery = event.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let fallbackURL = "https://www.garysguide.com/events?search=\(searchQuery)"
        
        if let url = URL(string: fallbackURL) {
            UIApplication.shared.open(url)
            print("🔄 Opened Gary's Guide search as fallback")
        }
    }
    
    // Alternative: Open original Gary's Guide event page instead of redirect
    private func openOriginalEventPage() {
        // Try to find the original Gary's Guide URL for this event
        let eventSlug = event.title.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        let originalURL = "https://www.garysguide.com/events?search=\(eventSlug)"
        
        if let url = URL(string: originalURL) {
            UIApplication.shared.open(url)
            print("🔄 Opened original Gary's Guide page for: \(event.title)")
        }
    }
    
    private func getButtonText() -> String {
        if event.url.contains("gary.to/") {
            return "Register"
        } else if event.url.contains("eventbrite.com") || event.url.contains("meetup.com") {
            return "Register"
        } else {
            return "View Details"
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isSelected ? 
                                    [Color.founderAccent, Color.founderAccent.opacity(0.8)] : 
                                    [Color(.systemGray6), Color(.systemGray6)]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: isSelected ? Color.founderAccent.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Elegant spinning progress indicator
            ZStack {
                Circle()
                    .stroke(
                        Color.founderAccent.opacity(0.15),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Color.founderAccent,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 16) {
                Text("Discovering Events")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                
                Text("Using WiFi or cellular data")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No events found")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Try adjusting your filters or check back later for new events.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.founderWarning)
            
            Text("Network Connection Error")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline)
                    Text("Try Again")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.founderAccent)
                .cornerRadius(8)
            }
            
            Text("Showing sample events while offline. Enable WiFi or cellular data for live events.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DiscoverView(appState: AppState())
} 