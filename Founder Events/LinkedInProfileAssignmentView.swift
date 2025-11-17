import SwiftUI

struct LinkedInProfileAssignmentView: View {
    @EnvironmentObject var linkedInManager: LinkedInProfileManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEventID: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerView
                profileInfoView
                eventSelectionView
                Spacer()
                actionButtonsView
            }
            .padding()
            .navigationTitle("Link Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("LinkedIn Profile Received!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose an event to link this profile to")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var profileInfoView: some View {
        Group {
            if let profile = linkedInManager.pendingProfile {
                VStack(spacing: 12) {
                    Text("Profile Details")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        Text(profile.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if let company = profile.company {
                            Text(company)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if let title = profile.title {
                            Text(title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var eventSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Event")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(appState.events) { event in
                        eventRow(for: event)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding(.horizontal)
    }
    
    private func eventRow(for event: CalendarEvent) -> some View {
        Button(action: {
            selectedEventID = event.id.uuidString
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(formatEventDate(event.startDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if selectedEventID == event.id.uuidString {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(selectedEventID == event.id.uuidString ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            if let selectedEventID = selectedEventID {
                Button("Link Profile to Event") {
                    linkProfileToEvent(selectedEventID)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Button("Skip for Now") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray4))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func linkProfileToEvent(_ eventID: String) {
        linkedInManager.assignPendingProfileToEvent(eventID, calendarManager: calendarManager, appState: appState)
        dismiss()
    }
}

#Preview {
    LinkedInProfileAssignmentView()
        .environmentObject(LinkedInProfileManager())
        .environmentObject(AppState())
}
