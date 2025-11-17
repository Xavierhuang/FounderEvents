//
//  TextSelectionView.swift
//  ScheduleShare
//
//  View for visually selecting date and location text from extracted content
//

import SwiftUI

struct TextSelectionView: View {
    @Binding var originalText: String
    @Binding var selectedDateText: String
    @Binding var selectedLocationText: String
    @Binding var showingDateSelection: Bool
    @Binding var showingLocationSelection: Bool
    
    let onDateSelected: (String) -> Void
    let onLocationSelected: (String) -> Void
    let onCancel: () -> Void
    
    @State private var highlightedDateText = ""
    @State private var highlightedLocationText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Correct AI Extraction")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tap and drag to select the correct date and location from the extracted text")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Extracted text display
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Extracted Text:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(originalText)
                            .font(.body)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                // Highlighted date text
                                highlightedDateText.isEmpty ? nil :
                                Text(highlightedDateText)
                                    .background(Color.yellow.opacity(0.3))
                                    .cornerRadius(4)
                            )
                            .overlay(
                                // Highlighted location text
                                highlightedLocationText.isEmpty ? nil :
                                Text(highlightedLocationText)
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(4)
                            )
                    }
                }
                
                // Selection buttons
                VStack(spacing: 12) {
                    // Date selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Date:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text(selectedDateText.isEmpty ? "Tap to select date text" : selectedDateText)
                                .foregroundColor(selectedDateText.isEmpty ? .secondary : .primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                            
                            Button("Select") {
                                showingDateSelection = true
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Location selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Location:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text(selectedLocationText.isEmpty ? "Tap to select location text" : selectedLocationText)
                                .foregroundColor(selectedLocationText.isEmpty ? .secondary : .primary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                            
                            Button("Select") {
                                showingLocationSelection = true
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                    )
                    
                    Button("Apply Changes") {
                        if !selectedDateText.isEmpty {
                            onDateSelected(selectedDateText)
                        }
                        if !selectedLocationText.isEmpty {
                            onLocationSelected(selectedLocationText)
                        }
                        onCancel()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green)
                    )
                    .disabled(selectedDateText.isEmpty && selectedLocationText.isEmpty)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onCancel()
                    }
                }
            }
        }
        .sheet(isPresented: $showingDateSelection) {
            TextPickerView(
                title: "Select Date Text",
                originalText: originalText,
                selectedText: $selectedDateText,
                highlightColor: .yellow,
                onTextSelected: { text in
                    selectedDateText = text
                    highlightedDateText = text
                },
                onCancel: {
                    showingDateSelection = false
                }
            )
        }
        .sheet(isPresented: $showingLocationSelection) {
            TextPickerView(
                title: "Select Location Text",
                originalText: originalText,
                selectedText: $selectedLocationText,
                highlightColor: .blue,
                onTextSelected: { text in
                    selectedLocationText = text
                    highlightedLocationText = text
                },
                onCancel: {
                    showingLocationSelection = false
                }
            )
        }
    }
}

struct TextPickerView: View {
    let title: String
    let originalText: String
    @Binding var selectedText: String
    let highlightColor: Color
    let onTextSelected: (String) -> Void
    let onCancel: () -> Void
    
    @State private var startIndex: String.Index?
    @State private var endIndex: String.Index?
    @State private var isSelecting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Tap and drag to select text")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                ScrollView {
                    Text(originalText)
                        .font(.body)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            // Selection overlay
                            selectedText.isEmpty ? nil :
                            Text(selectedText)
                                .background(highlightColor.opacity(0.3))
                                .cornerRadius(4)
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    // Simple text selection logic
                                    let location = value.location
                                    // This is a simplified version - in a real app you'd need more complex text selection
                                }
                        )
                }
                
                // Manual text input as fallback
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or type the text manually:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter the correct text", text: $selectedText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                    )
                    
                    Button("Select") {
                        onTextSelected(selectedText)
                        onCancel()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(highlightColor)
                    )
                    .disabled(selectedText.isEmpty)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onCancel()
                    }
                }
            }
        }
    }
}

#Preview {
    TextSelectionView(
        originalText: .constant("Sample extracted text with date and location information"),
        selectedDateText: .constant(""),
        selectedLocationText: .constant(""),
        showingDateSelection: .constant(false),
        showingLocationSelection: .constant(false),
        onDateSelected: { _ in },
        onLocationSelected: { _ in },
        onCancel: { }
    )
}
