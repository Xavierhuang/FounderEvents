import SwiftUI

struct LinkedInSharingInstructionsView: View {
    let event: GarysGuideEvent
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var linkedInManager: LinkedInProfileManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Share Your LinkedIn Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Connect with other attendees at this event!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to share:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        LinkedInInstructionStep(number: "1", text: "Open Safari and go to LinkedIn")
                        LinkedInInstructionStep(number: "2", text: "Navigate to the profile you want to share")
                        LinkedInInstructionStep(number: "3", text: "Tap the 'Share' button (square with arrow)")
                        LinkedInInstructionStep(number: "4", text: "Select 'Founder Events' from the list")
                        LinkedInInstructionStep(number: "5", text: "Choose an event to link the profile to!")
                    }
                }
                .padding(.horizontal)
                
                // Event Info
                VStack(spacing: 12) {
                    Text("Event Details")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        Text(event.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(event.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Close Button
                Button("Got it!") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("LinkedIn Sharing")
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
}

struct LinkedInInstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
