import SwiftUI
import EventKit
import UniformTypeIdentifiers

struct CalendarImportView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var googleCalendarService = GoogleCalendarService.shared
    
    @State private var selectedCalendarSource = CalendarSource.apple
    @State private var selectedTimeRange = ImportTimeRange.upcoming
    @State private var customStartDate = Date()
    @State private var customEndDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days
    @State private var availableCalendars: [EKCalendar] = []
    @State private var selectedCalendars: Set<String> = []
    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var showingPreview = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var importComplete = false
    @State private var showingGoogleInstructions = false
    @State private var showingDocumentPicker = false
    
    enum CalendarSource: String, CaseIterable {
        case apple = "Apple Calendar"
        case google = "Google Calendar"
        
        var icon: String {
            switch self {
            case .apple: return "calendar"
            case .google: return "globe"
            }
        }
        
        var color: Color {
            switch self {
            case .apple: return .founderAccent
            case .google: return .blue
            }
        }
    }
    
    enum ImportTimeRange: String, CaseIterable {
        case upcoming = "Next 30 Days"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case custom = "Custom Range"
        
        var icon: String {
            switch self {
            case .upcoming: return "calendar.badge.clock"
            case .thisWeek: return "calendar"
            case .thisMonth: return "calendar.badge.exclamationmark"
            case .custom: return "calendar.badge.plus"
            }
        }
    }
    
    var body: some View {
        return NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Permission Check
                    if !calendarManager.hasFullCalendarAccess {
                        permissionSection
                    } else {
                        // Calendar Source Selection
                        calendarSourceSection
                        
                        // Source-specific content
                        if selectedCalendarSource == .apple {
                            // Apple Calendar import flow
                            timeRangeSection
                            calendarSelectionSection
                            importButtonSection
                        } else {
                            // Google Calendar import flow
                            googleCalendarSection
                        }
                        
                        // Preview Section
                        if let result = importResult, result.totalFound > 0 {
                            previewSection
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Import Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: importComplete ? Button("Done") {
                    // Add imported events to app state
                    if let result = importResult {
                        for event in result.uniqueEvents {
                            appState.addEvent(event)
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                } : nil
            )
            .sheet(isPresented: $showingGoogleInstructions) {
                GoogleCalendarInstructionsView()
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { url in
                    importFromICSFile(url: url)
                }
            }
            .onAppear {
                loadAvailableCalendars()
            }
            .alert("Import Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var calendarSourceSection: some View {
        return VStack(alignment: .leading, spacing: 16) {
            Text("Select Calendar Source")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                ForEach(CalendarSource.allCases, id: \.self) { source in
                    CalendarSourceCard(
                        source: source,
                        isSelected: selectedCalendarSource == source
                    ) {
                        selectedCalendarSource = source
                        // Reset import state when switching sources
                        importResult = nil
                        importComplete = false
                    }
                }
            }
        }
    }
    
    private var googleCalendarSection: some View {
        return VStack(alignment: .leading, spacing: 20) {
            Text("Import from Google Calendar")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Method 1: Instructions for manual export
                Button(action: {
                    showingGoogleInstructions = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Export from Google Calendar")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Get step-by-step instructions to export your Google Calendar as an .ics file")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Method 2: Import ICS file
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                    .foregroundColor(.green)
                                Text("Import ICS File")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            
                            Text("Select a .ics file you've exported from Google Calendar")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Future: Direct API integration
                Button(action: {
                    alertMessage = "Direct Google Calendar API integration coming soon! For now, please use the export method above."
                    showingAlert = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.orange)
                                Text("Direct Integration")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            Text("Coming soon: Direct Google Calendar API access")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Text("Soon")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var headerSection: some View {
        return VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 40))
                .foregroundColor(.founderAccent)
                .padding()
                .background(
                    Circle()
                        .fill(Color.founderAccent.opacity(0.1))
                        .frame(width: 80, height: 80)
                )
            
            Text("Import from Apple Calendar")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Import existing events from your Apple Calendar app into Founder Events")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var permissionSection: some View {
        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Full Calendar Access Required")
                    .font(.headline)
            }
            
            Text("To import events from Apple Calendar, Founder Events needs 'Full Access' to read your existing events. Currently you have 'Add Events Only' permission.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if #available(iOS 17.0, *) {
                VStack(spacing: 12) {
                    Button("Upgrade to Full Access") {
                        calendarManager.requestFullCalendarAccess()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.founderAccent)
                    .cornerRadius(12)
                    
                    HStack(spacing: 16) {
                        Button("Try Alternative Method") {
                            calendarManager.requestFullCalendarAccessAlternative()
                        }
                        .foregroundColor(.founderAccent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.founderAccent.opacity(0.1))
                        )
                        
                        Button("Open Settings") {
                            openAppSettings()
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    
                    Text("If upgrade fails, try the alternative method or manually change permissions in Settings → Privacy & Security → Calendars → ScheduleShare")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var timeRangeSection: some View {
        return VStack(alignment: .leading, spacing: 16) {
            Text("Select Time Range")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ImportTimeRange.allCases, id: \.self) { range in
                    TimeRangeCard(
                        range: range,
                        isSelected: selectedTimeRange == range
                    ) {
                        selectedTimeRange = range
                    }
                }
            }
            
            // Custom Date Range Picker
            if selectedTimeRange == .custom {
                VStack(spacing: 12) {
                    DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    private var calendarSelectionSection: some View {
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Select Calendars")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(selectedCalendars.count == availableCalendars.count ? "Deselect All" : "Select All") {
                    if selectedCalendars.count == availableCalendars.count {
                        selectedCalendars.removeAll()
                    } else {
                        selectedCalendars = Set(availableCalendars.map { $0.calendarIdentifier })
                    }
                }
                .font(.subheadline)
                .foregroundColor(.founderAccent)
            }
            
            if availableCalendars.isEmpty {
                Text("No calendars available for import")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(availableCalendars, id: \.calendarIdentifier) { calendar in
                    CalendarRow(
                        calendar: calendar,
                        isSelected: selectedCalendars.contains(calendar.calendarIdentifier)
                    ) {
                        if selectedCalendars.contains(calendar.calendarIdentifier) {
                            selectedCalendars.remove(calendar.calendarIdentifier)
                        } else {
                            selectedCalendars.insert(calendar.calendarIdentifier)
                        }
                    }
                }
            }
        }
    }
    
    private var importButtonSection: some View {
        return Button(action: performImport) {
            HStack {
                if isImporting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                }
                Text(isImporting ? "Importing..." : "Import Events")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isImporting ? Color.gray : Color.founderAccent)
            )
        }
        .disabled(isImporting || selectedCalendars.isEmpty)
    }
    
    private var previewSection: some View {
        return VStack(alignment: .leading, spacing: 16) {
            if let result = importResult {
                // Header with counts
                HStack {
                    Text("Import Results")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("\(result.totalFound) found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if result.hasNewEvents {
                                Text("\(result.uniqueCount) new")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.green.opacity(0.1))
                                    )
                            }
                            
                            if result.hasDuplicates {
                                Text("\(result.duplicateCount) duplicates")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                
                // Show new events
                if result.hasNewEvents {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Events to Import:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        ForEach(result.uniqueEvents.prefix(5)) { event in
                            ImportPreviewRow(event: event, isNew: true)
                        }
                        
                        if result.uniqueCount > 5 {
                            Text("... and \(result.uniqueCount - 5) more new events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        }
                    }
                }
                
                // Show duplicates if any
                if result.hasDuplicates {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duplicates Found (will be skipped):")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        
                        ForEach(result.duplicateEvents.prefix(3)) { event in
                            ImportPreviewRow(event: event, isNew: false)
                        }
                        
                        if result.duplicateCount > 3 {
                            Text("... and \(result.duplicateCount - 3) more duplicates")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        }
                    }
                }
                
                // Import button
                if result.hasNewEvents && !importComplete {
                    Button("Import \(result.uniqueCount) New Events") {
                        importComplete = true
                        let message = result.hasDuplicates ? 
                            "Successfully imported \(result.uniqueCount) new events! \(result.duplicateCount) duplicates were skipped." :
                            "Successfully imported \(result.uniqueCount) events!"
                        alertMessage = message
                        showingAlert = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
                } else if !result.hasNewEvents {
                    VStack(spacing: 8) {
                        Text("No New Events to Import")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("All found events already exist in your ScheduleShare calendar.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private func loadAvailableCalendars() {
        availableCalendars = calendarManager.getAvailableCalendarsForImport()
        // Auto-select all calendars by default
        selectedCalendars = Set(availableCalendars.map { $0.calendarIdentifier })
    }
    
    private func performImport() {
        guard !selectedCalendars.isEmpty else { return }
        
        isImporting = true
        
        let calendarsToImport = availableCalendars.filter { selectedCalendars.contains($0.calendarIdentifier) }
        let (startDate, endDate) = getDateRange()
        
        // Pass existing events for duplicate detection
        let existingEvents = appState.events
        
        calendarManager.importEventsFromSpecificCalendars(calendarsToImport, from: startDate, to: endDate, existingEvents: existingEvents) { result in
            DispatchQueue.main.async {
                self.isImporting = false
                
                switch result {
                case .success(let importResult):
                    self.importResult = importResult
                    print("📥 Import completed:")
                    print("   Total found: \(importResult.totalFound)")
                    print("   New events: \(importResult.uniqueCount)")
                    print("   Duplicates: \(importResult.duplicateCount)")
                    
                case .failure(let error):
                    self.alertMessage = "Import failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func getDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .upcoming:
            return (now, calendar.date(byAdding: .day, value: 30, to: now) ?? now)
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? now
            return (startOfWeek, endOfWeek)
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now
            return (startOfMonth, endOfMonth)
        case .custom:
            return (customStartDate, customEndDate)
        }
    }
    
    private func importFromICSFile(url: URL) {
        isImporting = true
        
        let existingEvents = appState.events
        
        googleCalendarService.importFromGoogleCalendar(
            method: .icsFile(url),
            existingEvents: existingEvents
        ) { result in
            DispatchQueue.main.async {
                self.isImporting = false
                
                switch result {
                case .success(let importResult):
                    self.importResult = importResult
                    print("📥 Google Calendar ICS import completed:")
                    print("   Total found: \(importResult.totalFound)")
                    print("   New events: \(importResult.uniqueCount)")
                    print("   Duplicates: \(importResult.duplicateCount)")
                    
                case .failure(let error):
                    self.alertMessage = "Google Calendar import failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - Supporting Views

struct CalendarSourceCard: View {
    let source: CalendarImportView.CalendarSource
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: source.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : source.color)
                
                Text(source.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? source.color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create content types for ICS files
        let icsType = UTType(filenameExtension: "ics") ?? .data
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [icsType, .data, .text], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onDocumentPicked(url)
        }
    }
}

// MARK: - Supporting Views

struct TimeRangeCard: View {
    let range: CalendarImportView.ImportTimeRange
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: range.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .founderAccent)
                
                Text(range.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.founderAccent : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CalendarRow: View {
    let calendar: EKCalendar
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color(calendar.cgColor))
                    .frame(width: 16, height: 16)
                
                Text(calendar.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .founderAccent : .secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImportPreviewRow: View {
    let event: CalendarEvent
    let isNew: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(isNew ? .primary : .secondary)
                
                Text(event.startDate.formattedDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(isNew ? .founderAccent : .secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: isNew ? "calendar.badge.plus" : "calendar.badge.exclamationmark")
                .foregroundColor(isNew ? .green : .orange)
        }
        .padding(.vertical, 4)
        .opacity(isNew ? 1.0 : 0.6)
    }
}

#Preview {
    CalendarImportView()
        .environmentObject(AppState())
        .environmentObject(CalendarManager())
}
