//
//  PublicEventDetailView.swift
//  Founder Events
//
//  Public Event Detail and Registration View
//

import SwiftUI

struct PublicEventDetailView: View {
    let eventSlug: String
    
    @State private var event: PublicEvent?
    @State private var isLoading = true
    @State private var isRegistered = false
    @State private var showRegistrationSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading event...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let event = event {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Cover Image
                            if let coverURL = event.coverImage, let url = URL(string: coverURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                }
                                .frame(height: 240)
                                .frame(maxWidth: .infinity)
                                .clipped()
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // Header
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(event.title)
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        if event.isFeatured {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.title3)
                                        }
                                    }
                                    
                                    HStack(spacing: 12) {
                                        StatusBadge(status: event.status)
                                        
                                        if event.price == 0 {
                                            Text("FREE")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.green.opacity(0.1))
                                                .foregroundColor(.green)
                                                .cornerRadius(6)
                                        } else {
                                            Text("$\(String(format: "%.2f", event.price))")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                
                                // Event Details
                                VStack(alignment: .leading, spacing: 12) {
                                    DetailRow(
                                        icon: "calendar",
                                        text: event.startDate.formatted(date: .long, time: .shortened)
                                    )
                                    
                                    DetailRow(
                                        icon: "clock",
                                        text: "\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))"
                                    )
                                    
                                    if event.locationType == .PHYSICAL || event.locationType == .HYBRID {
                                        DetailRow(
                                            icon: "mappin.circle",
                                            text: [event.venueName, event.venueAddress, event.venueCity, event.venueState]
                                                .compactMap { $0 }
                                                .filter { !$0.isEmpty }
                                                .joined(separator: ", ")
                                        )
                                    }
                                    
                                    if event.locationType == .VIRTUAL || event.locationType == .HYBRID {
                                        if event.virtualLink != nil {
                                            DetailRow(icon: "video", text: "Virtual Event")
                                        }
                                    }
                                    
                                    DetailRow(
                                        icon: "person.2",
                                        text: "\(event.registrationCount) registered" + (event.capacity != nil ? " / \(event.capacity!) capacity" : "")
                                    )
                                }
                                
                                Divider()
                                
                                // Description
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("About This Event")
                                        .font(.headline)
                                    
                                    Text(event.description)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                // Tags
                                if !event.tags.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Tags")
                                            .font(.headline)
                                        
                                        FlowLayout(spacing: 8) {
                                            ForEach(event.tags, id: \.self) { tag in
                                                Text("#\(tag)")
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.purple.opacity(0.1))
                                                    .foregroundColor(.purple)
                                                    .cornerRadius(16)
                                            }
                                        }
                                    }
                                }
                                
                                // Organizer
                                if let organizer = event.organizer {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Organized by")
                                            .font(.headline)
                                        
                                        HStack(spacing: 12) {
                                            if let avatarURL = organizer.profile?.avatar, let url = URL(string: avatarURL) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .foregroundColor(.gray)
                                                }
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.gray)
                                                    .frame(width: 48, height: 48)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(organizer.profile?.displayName ?? organizer.name ?? "Unknown")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                
                                                if let username = organizer.profile?.username {
                                                    Text("@\(username)")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        if event.status == .PUBLISHED {
                            VStack(spacing: 0) {
                                Divider()
                                
                                HStack(spacing: 12) {
                                    if isRegistered {
                                        Button(action: { }) {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                Text("Registered")
                                            }
                                            .font(.headline)
                                            .foregroundColor(.green)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                        .disabled(true)
                                    } else {
                                        Button(action: { showRegistrationSheet = true }) {
                                            HStack {
                                                Image(systemName: "person.crop.circle.badge.plus")
                                                Text(event.price > 0 ? "Register - $\(String(format: "%.2f", event.price))" : "Register for Free")
                                            }
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.purple)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showRegistrationSheet) {
                if let event = event {
                    EventRegistrationView(event: event) {
                        isRegistered = true
                        Task {
                            await loadEvent()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadEvent()
            }
        }
    }
    
    private func loadEvent() async {
        isLoading = true
        
        do {
            let loadedEvent = try await PublicEventAPIService.shared.getPublicEvent(slug: eventSlug)
            await MainActor.run {
                self.event = loadedEvent
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
}

// MARK: - Detail Row Component

struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }
        
        totalHeight += lineHeight
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineX + size.width > bounds.maxX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }
            
            subview.place(at: CGPoint(x: lineX, y: lineY), proposal: .unspecified)
            
            lineHeight = max(lineHeight, size.height)
            lineX += size.width + spacing
        }
    }
}

struct PublicEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PublicEventDetailView(eventSlug: "test-event")
    }
}
