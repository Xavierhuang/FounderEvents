//
//  MessageTemplateSettingsView.swift
//  ScheduleShare
//
//  Created by Weijia Huang on 8/4/25.
//

import SwiftUI

struct MessageTemplateSettingsView: View {
    @State private var customTemplate: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isEditing = false
    
    // Default template with placeholders
    private let defaultTemplate = """
Hi {NAME}!

I hope you're doing well. I came across your profile and noticed we both attended {EVENT}. I'm impressed by your role as {TITLE} at {COMPANY}. I'd be excited to connect and potentially collaborate in the future.

Looking forward to connecting!

Best regards
"""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LinkedIn Message Template")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Customize your default LinkedIn message. Use placeholders like {NAME}, {EVENT}, {TITLE}, {COMPANY} to personalize messages.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Placeholders info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Placeholders:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            PlaceholderTag(text: "{NAME}", description: "Person's name")
                            PlaceholderTag(text: "{EVENT}", description: "Event name")
                            PlaceholderTag(text: "{TITLE}", description: "Job title")
                            PlaceholderTag(text: "{COMPANY}", description: "Company name")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Text editor
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Message Template")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button(isEditing ? "Done" : "Edit") {
                                if isEditing {
                                    saveTemplate()
                                }
                                isEditing.toggle()
                            }
                            .foregroundColor(.blue)
                        }
                        
                        if isEditing {
                            TextEditor(text: $customTemplate)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        } else {
                            ScrollView {
                                Text(customTemplate.isEmpty ? defaultTemplate : customTemplate)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .frame(minHeight: 200)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Preview section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView {
                            Text(generatePreview())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemBlue).opacity(0.1))
                                .cornerRadius(8)
                        }
                        .frame(minHeight: 120)
                    }
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button("Reset to Default") {
                            resetToDefault()
                        }
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button("Test Message") {
                            testMessage()
                        }
                        .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Extra padding to avoid tab bar overlap
                }
                .padding(.top)
            }
            .navigationTitle("Message Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadTemplate()
            }
            .alert("Message Template", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadTemplate() {
        if let savedTemplate = UserDefaults.standard.string(forKey: "LinkedInMessageTemplate") {
            customTemplate = savedTemplate
        } else {
            customTemplate = defaultTemplate
        }
    }
    
    private func saveTemplate() {
        UserDefaults.standard.set(customTemplate, forKey: "LinkedInMessageTemplate")
        alertMessage = "Message template saved successfully!"
        showingAlert = true
    }
    
    private func resetToDefault() {
        customTemplate = defaultTemplate
        UserDefaults.standard.set(defaultTemplate, forKey: "LinkedInMessageTemplate")
        alertMessage = "Message template reset to default!"
        showingAlert = true
    }
    
    private func testMessage() {
        let testMessage = generatePreview()
        UIPasteboard.general.string = testMessage
        alertMessage = "Test message copied to clipboard!"
        showingAlert = true
    }
    
    private func generatePreview() -> String {
        let template = customTemplate.isEmpty ? defaultTemplate : customTemplate
        
        return template
            .replacingOccurrences(of: "{NAME}", with: "John Smith")
            .replacingOccurrences(of: "{EVENT}", with: "Tech Startup Meetup")
            .replacingOccurrences(of: "{TITLE}", with: "Senior Software Engineer")
            .replacingOccurrences(of: "{COMPANY}", with: "Apple Inc.")
    }
}

struct PlaceholderTag: View {
    let text: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MessageTemplateSettingsView()
}
