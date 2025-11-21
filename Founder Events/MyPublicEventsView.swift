//
//  MyPublicEventsView.swift
//  Founder Events
//
//  Manage User's Created Public Events
//

import SwiftUI

struct MyPublicEventsView: View {
    @State private var events: [PublicEvent] = []
    @State private var isLoading = true
    @State private var selectedFilter: EventFilter = .all
    @State private var showCreateEvent = false
    @State private var eventToDelete: PublicEvent?
    @State private var showDeleteAlert = false
    
    enum EventFilter: String, CaseIterable {
        case all = "All Events"
        case upcoming = "Upcoming"
        case past = "Past"
    }
    
    var filteredEvents: [PublicEvent] {
        let now = Date()
        switch selectedFilter {
        case .all:
            return events
        case .upcoming:
            return events.filter { $0.startDate >= now }
        case .past:
            return events.filter { $0.startDate < now }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Tabs
                HStack(spacing: 12) {
                    ForEach(EventFilter.allCases, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            Text(filter.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? Color.purple : Color.gray.opacity(0.1))
                                .foregroundColor(selectedFilter == filter ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No events yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Create your first event to share with the community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showCreateEvent = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Event")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                EventManagementCard(
                                    event: event,
                                    onPublishToggle: { togglePublish(event) },
                                    onFeatureToggle: { toggleFeatured(event) },
                                    onDelete: {
                                        eventToDelete = event
                                        showDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateEvent) {
                CreatePublicEventView {
                    Task {
                        await loadEvents()
                    }
                }
            }
            .alert("Delete Event", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let event = eventToDelete {
                        deleteEvent(event)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this event? This action cannot be undone.")
            }
            .task {
                await loadEvents()
            }
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        
        do {
            if let profile = try await PublicEventAPIService.shared.getProfile() {
                // Fetch user's events from profile endpoint
                events = [] // Will be populated from API
            }
            isLoading = false
        } catch {
            print("Error loading events: \(error)")
            isLoading = false
        }
    }
    
    private func togglePublish(_ event: PublicEvent) {
        Task {
            do {
                let newStatus = event.status == .PUBLISHED ? "DRAFT" : "PUBLISHED"
                _ = try await PublicEventAPIService.shared.updatePublicEvent(
                    slug: event.slug,
                    updates: ["status": newStatus]
                )
                await loadEvents()
            } catch {
                print("Error toggling publish: \(error)")
            }
        }
    }
    
    private func toggleFeatured(_ event: PublicEvent) {
        Task {
            do {
                _ = try await PublicEventAPIService.shared.toggleFeatured(
                    slug: event.slug,
                    isFeatured: !event.isFeatured
                )
                await loadEvents()
            } catch {
                print("Error toggling featured: \(error)")
            }
        }
    }
    
    private func deleteEvent(_ event: PublicEvent) {
        Task {
            do {
                try await PublicEventAPIService.shared.deletePublicEvent(slug: event.slug)
                await loadEvents()
            } catch {
                print("Error deleting event: \(error)")
            }
        }
    }
}

// MARK: - Event Management Card

struct EventManagementCard: View {
    let event: PublicEvent
    let onPublishToggle: () -> Void
    let onFeatureToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var showCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Featured Badge
            HStack(alignment: .top) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                if event.isFeatured {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            if let shortDesc = event.shortDescription {
                Text(shortDesc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Event Details
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .font(.caption)
                    Text(event.locationType == .VIRTUAL ? "Virtual Event" : (event.venueName ?? event.venueCity ?? "TBD"))
                        .font(.caption)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.caption)
                        Text("\(event.registrationCount) registered")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.caption)
                        Text("\(event.viewCount) views")
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(.secondary)
            
            // Status Badges
            HStack(spacing: 8) {
                StatusBadge(status: event.status)
                
                if event.price == 0 {
                    Text("FREE")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            // Publish Button
            Button(action: onPublishToggle) {
                HStack {
                    Image(systemName: event.status == .PUBLISHED ? "archivebox" : "rocket")
                    Text(event.status == .PUBLISHED ? "Unpublish" : "Publish Event")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(event.status == .PUBLISHED ? Color.gray.opacity(0.1) : Color.green)
                .foregroundColor(event.status == .PUBLISHED ? .primary : .white)
                .cornerRadius(10)
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "eye")
                        Text("View")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: onFeatureToggle) {
                    Image(systemName: event.isFeatured ? "star.fill" : "star")
                        .font(.caption)
                        .padding(8)
                        .background(event.isFeatured ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                        .foregroundColor(event.isFeatured ? .yellow : .secondary)
                        .cornerRadius(8)
                }
                
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.secondary)
                        .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
            
            // Public Link
            HStack(spacing: 8) {
                Text("foundersevents.app/events/\(event.slug)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    UIPasteboard.general.string = "https://foundersevents.app/events/\(event.slug)"
                    showCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCopied = false
                    }
                }) {
                    Text(showCopied ? "Copied!" : "Copy")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: PublicEvent.EventStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .PUBLISHED: return Color.green.opacity(0.1)
        case .DRAFT: return Color.gray.opacity(0.1)
        case .CANCELLED: return Color.red.opacity(0.1)
        case .COMPLETED: return Color.blue.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .PUBLISHED: return .green
        case .DRAFT: return .gray
        case .CANCELLED: return .red
        case .COMPLETED: return .blue
        }
    }
}

struct MyPublicEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPublicEventsView()
    }
}

