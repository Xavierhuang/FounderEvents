//
//  EnhancedDiscoverView.swift
//  Founder Events
//
//  Enhanced Discover View with Public Events and Gary's Guide
//

import SwiftUI

struct EnhancedDiscoverView: View {
    @State private var selectedFilter: DiscoverFilter = .all
    @State private var searchText = ""
    @State private var events: [DiscoverEvent] = []
    @State private var isLoading = false
    
    enum DiscoverFilter: String, CaseIterable {
        case all = "All Events"
        case popular = "Popular Events"
        case featured = "Featured Events"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search events...", text: $searchText)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Filter Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DiscoverFilter.allCases, id: \.self) { filter in
                            Button(action: { selectFilter(filter) }) {
                                HStack(spacing: 6) {
                                    if filter == .popular {
                                        Image(systemName: "sparkles")
                                    } else if filter == .featured {
                                        Image(systemName: "star.fill")
                                    }
                                    
                                    Text(filter.rawValue)
                                }
                                .font(.subheadline)
                                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? Color.purple : Color.gray.opacity(0.1))
                                .foregroundColor(selectedFilter == filter ? .white : .primary)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if events.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No events found")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(events) { event in
                                DiscoverEventCard(event: event)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Discover Events")
            .task {
                await loadEvents()
            }
            .refreshable {
                await loadEvents()
            }
        }
    }
    
    private func selectFilter(_ filter: DiscoverFilter) {
        selectedFilter = filter
        Task {
            await loadEvents()
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        
        do {
            let publicEventFilter: PublicEventFilter? = {
                switch selectedFilter {
                case .all: return nil
                case .popular: return .popular
                case .featured: return .featured
                }
            }()
            
            let publicEvents = try await PublicEventAPIService.shared.getDiscoverEvents(filter: publicEventFilter)
            
            await MainActor.run {
                events = publicEvents.map { DiscoverEvent.publicEvent($0) }
                isLoading = false
            }
        } catch {
            print("Error loading events: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Discover Event Wrapper

enum DiscoverEvent: Identifiable {
    case garysGuide(GarysGuideEvent)
    case publicEvent(PublicEvent)
    
    var id: String {
        switch self {
        case .garysGuide(let event): return event.id
        case .publicEvent(let event): return event.id
        }
    }
}

// MARK: - Discover Event Card

struct DiscoverEventCard: View {
    let event: DiscoverEvent
    
    var body: some View {
        switch event {
        case .garysGuide(let garysEvent):
            GarysGuideEventCard(event: garysEvent)
        case .publicEvent(let publicEvent):
            PublicEventCard(event: publicEvent)
        }
    }
}

// MARK: - Gary's Guide Event Card

struct GarysGuideEventCard: View {
    let event: GarysGuideEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                if event.isPopularEvent {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("\(event.date) at \(event.time)")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.caption)
                    Text(event.venue)
                        .font(.caption)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.caption)
                    Text(event.price)
                        .font(.caption)
                        .foregroundColor(event.price == "Free" ? .green : .primary)
                }
            }
            .foregroundColor(.secondary)
            
            if !event.speakers.isEmpty {
                Text("Speakers: \(event.speakers)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            HStack {
                Link(destination: URL(string: event.url)!) {
                    HStack {
                        Image(systemName: "safari")
                        Text("View Details")
                    }
                    .font(.subheadline)
                    .foregroundColor(.purple)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Add to Calendar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Public Event Card

struct PublicEventCard: View {
    let event: PublicEvent
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Cover Image
                if let coverURL = event.coverImage, let url = URL(string: coverURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(8)
                }
                
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
                        Text(event.locationType == .VIRTUAL ? "Virtual" : (event.venueName ?? event.venueCity ?? "TBD"))
                            .font(.caption)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.caption)
                        Text("\(event.registrationCount) registered")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    StatusBadge(status: event.status)
                    
                    if event.price == 0 {
                        Text("FREE")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                    } else {
                        Text("$\(String(format: "%.2f", event.price))")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            PublicEventDetailView(eventSlug: event.slug)
        }
    }
}

struct EnhancedDiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedDiscoverView()
    }
}

