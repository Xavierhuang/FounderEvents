//
//  CreatePublicEventView.swift
//  Founder Events
//
//  Create Public Event Form
//

import SwiftUI

struct CreatePublicEventView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var shortDescription = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(7200)
    @State private var locationType: PublicEvent.LocationType = .PHYSICAL
    @State private var venueName = ""
    @State private var venueAddress = ""
    @State private var venueCity = ""
    @State private var venueState = ""
    @State private var venueZipCode = ""
    @State private var virtualLink = ""
    @State private var coverImage = ""
    @State private var price: Double = 0
    @State private var capacity = ""
    @State private var tags = ""
    @State private var isFeatured = false
    
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Event Title", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(height: 120)
                    }
                    
                    TextField("Short Description (optional)", text: $shortDescription)
                }
                
                Section("Date & Time") {
                    DatePicker("Start Date & Time", selection: $startDate)
                    DatePicker("End Date & Time", selection: $endDate)
                }
                
                Section("Location") {
                    Picker("Location Type", selection: $locationType) {
                        Text("Physical").tag(PublicEvent.LocationType.PHYSICAL)
                        Text("Virtual").tag(PublicEvent.LocationType.VIRTUAL)
                        Text("Hybrid").tag(PublicEvent.LocationType.HYBRID)
                    }
                    .pickerStyle(.segmented)
                    
                    if locationType == .PHYSICAL || locationType == .HYBRID {
                        TextField("Venue Name", text: $venueName)
                        TextField("Street Address", text: $venueAddress)
                        TextField("City", text: $venueCity)
                        TextField("State", text: $venueState)
                        TextField("Zip Code", text: $venueZipCode)
                    }
                    
                    if locationType == .VIRTUAL || locationType == .HYBRID {
                        TextField("Virtual Link (Zoom, Google Meet, etc.)", text: $virtualLink)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                }
                
                Section("Details") {
                    TextField("Cover Image URL (optional)", text: $coverImage)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("0.00", value: $price, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("USD")
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Capacity (optional)", text: $capacity)
                        .keyboardType(.numberPad)
                    
                    TextField("Tags (comma-separated)", text: $tags)
                        .autocapitalization(.none)
                    
                    Toggle("Featured Event", isOn: $isFeatured)
                }
                
                Section {
                    Button(action: createEvent) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Creating Event...")
                            } else {
                                Text("Create Event")
                            }
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.purple)
                    .disabled(isSubmitting || !isFormValid)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && endDate > startDate
    }
    
    private func createEvent() {
        Task {
            isSubmitting = true
            
            do {
                let formatter = ISO8601DateFormatter()
                
                let tagArray = tags.split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                let request = CreatePublicEventRequest(
                    title: title,
                    description: description,
                    shortDescription: shortDescription.isEmpty ? nil : shortDescription,
                    startDate: formatter.string(from: startDate),
                    endDate: formatter.string(from: endDate),
                    timezone: "America/New_York",
                    locationType: locationType.rawValue,
                    venueName: venueName.isEmpty ? nil : venueName,
                    venueAddress: venueAddress.isEmpty ? nil : venueAddress,
                    venueCity: venueCity.isEmpty ? nil : venueCity,
                    venueState: venueState.isEmpty ? nil : venueState,
                    venueZipCode: venueZipCode.isEmpty ? nil : venueZipCode,
                    virtualLink: virtualLink.isEmpty ? nil : virtualLink,
                    coverImage: coverImage.isEmpty ? nil : coverImage,
                    isPublic: true,
                    requiresApproval: false,
                    capacity: Int(capacity),
                    price: price,
                    currency: "USD",
                    tags: tagArray,
                    categoryIds: []
                )
                
                _ = try await PublicEventAPIService.shared.createPublicEvent(request)
                
                await MainActor.run {
                    onComplete()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isSubmitting = false
                }
            }
        }
    }
}

struct CreatePublicEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePublicEventView {}
    }
}

