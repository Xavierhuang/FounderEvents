//
//  EventRegistrationView.swift
//  Founder Events
//
//  Event Registration Form
//

import SwiftUI

struct EventRegistrationView: View {
    let event: PublicEvent
    let onSuccess: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var quantity = 1
    
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var totalAmount: Double {
        event.price * Double(quantity)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.purple)
                                Text(event.startDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(.purple)
                                Text(event.startDate.formatted(date: .omitted, time: .shortened))
                                    .font(.subheadline)
                            }
                        }
                        .foregroundColor(.secondary)
                        
                        if event.price > 0 {
                            HStack {
                                Text("Price:")
                                    .foregroundColor(.secondary)
                                Text("$\(String(format: "%.2f", event.price))")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Your Information") {
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                    
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                if event.capacity != nil {
                    Section("Tickets") {
                        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                        
                        if event.price > 0 {
                            HStack {
                                Text("Total")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$\(String(format: "%.2f", totalAmount))")
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
                
                Section {
                    VStack(spacing: 12) {
                        if event.requiresApproval {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("This event requires organizer approval")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: submitRegistration) {
                            HStack {
                                Spacer()
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Registering...")
                                } else {
                                    Text(event.price > 0 ? "Register & Pay $\(String(format: "%.2f", totalAmount))" : "Register for Free")
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
            }
            .navigationTitle("Register for Event")
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
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && email.contains("@")
    }
    
    private func submitRegistration() {
        Task {
            isSubmitting = true
            
            do {
                let request = RegisterForEventRequest(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    quantity: quantity
                )
                
                _ = try await PublicEventAPIService.shared.registerForEvent(
                    slug: event.slug,
                    request: request
                )
                
                await MainActor.run {
                    onSuccess()
                    dismiss()
                }
            } catch let error as APIError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to register for event"
                    showError = true
                    isSubmitting = false
                }
            }
        }
    }
}

struct EventRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        EventRegistrationView(
            event: PublicEvent(
                id: "1",
                slug: "test-event",
                title: "Test Event",
                description: "Test description",
                shortDescription: nil,
                startDate: Date(),
                endDate: Date().addingTimeInterval(7200),
                timezone: "America/New_York",
                locationType: .PHYSICAL,
                venueName: "Test Venue",
                venueAddress: nil,
                venueCity: "New York",
                venueState: "NY",
                venueZipCode: nil,
                virtualLink: nil,
                coverImage: nil,
                images: nil,
                isPublic: true,
                requiresApproval: false,
                capacity: 50,
                registrationDeadline: nil,
                price: 0,
                currency: "USD",
                status: .PUBLISHED,
                visibility: .PUBLIC,
                isFeatured: false,
                metaTitle: nil,
                metaDescription: nil,
                tags: [],
                viewCount: 0,
                registrationCount: 0,
                likeCount: 0,
                shareCount: 0,
                organizerId: "1",
                organizer: nil,
                createdAt: Date(),
                updatedAt: Date(),
                publishedAt: Date()
            )
        ) {}
    }
}

