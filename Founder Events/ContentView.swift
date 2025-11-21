//
//  ContentView.swift
//  Founder Events
//
//  Created by Weijia Huang on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var calendarManager = CalendarManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EnhancedDiscoverView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Discover")
                }
                .tag(0)
            
            CalendarView()
                .environmentObject(appState)
                .environmentObject(calendarManager)
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Calendar")
                }
                .tag(1)
            
            MyPublicEventsView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "calendar.badge.checkmark")
                    Text("My Events")
                }
                .tag(2)

            LinkedInProfilesView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Connections")
                }
                .tag(3)
            
            ProfileView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.founderAccent)
        .preferredColorScheme(.light)
        .onChange(of: appState.shouldSwitchToCalendar) { shouldSwitch in
            if shouldSwitch {
                selectedTab = 1 // Switch to calendar tab
            }
        }
        .onAppear {
            // Load events when the main app appears
            appState.loadEventsFromLocalStorage()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var calendarManager: CalendarManager
    private let sharingManager = SharingManager.shared
    
    @State private var showingAbout = false
    @State private var showingExportOptions = false
    @State private var showingClearAlert = false
    @State private var showingImportView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App Info Card
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.founderAccent)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.founderAccent.opacity(0.1))
                                    .frame(width: 100, height: 100)
                            )
                        
                        VStack(spacing: 5) {
                            Text("Founder Events")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Smart Calendar Manager")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("v1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    
                    // Calendar Status Card
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: calendarManager.hasCalendarPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(calendarManager.hasCalendarPermission ? .green : .red)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Calendar Access")
                                    .font(.headline)
                                
                                if calendarManager.hasCalendarPermission {
                                    if #available(iOS 17.0, *) {
                                        Text(calendarManager.hasFullCalendarAccess ? "Full Access" : "Add Events Only")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Full Access")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if !calendarManager.hasCalendarPermission {
                                Button("Grant Access") {
                                    calendarManager.requestCalendarPermission()
                                }
                                .foregroundColor(.founderAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.founderAccent.opacity(0.1))
                                )
                            } else if #available(iOS 17.0, *), calendarManager.hasCalendarPermission && !calendarManager.hasFullCalendarAccess {
                                Menu {
                                    Button("Upgrade to Full Access") {
                                        calendarManager.requestFullCalendarAccess()
                                    }
                                    
                                    Button("Try Alternative Method") {
                                        calendarManager.requestFullCalendarAccessAlternative()
                                    }
                                    
                                    Button("Open Settings") {
                                        openAppSettings()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("Upgrade")
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.founderPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.founderPrimary.opacity(0.1))
                                    )
                                }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "list.number")
                                .foregroundColor(.founderAccent)
                                .font(.title2)
                            Text("Events Created")
                                .font(.headline)
                            Spacer()
                            Text("\(appState.events.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.founderAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.founderAccent.opacity(0.1))
                                )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    
                    // Data Management Card
                    VStack(spacing: 15) {
                        Button(action: { showingImportView = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.founderPrimary)
                                    .font(.title2)
                                Text("Import Calendar Events")
                                    .font(.headline)
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("Apple & Google")
                                        .font(.caption)
                                        .foregroundColor(.founderPrimary)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.founderPrimary.opacity(0.1))
                            )
                        }
                        
                        Button(action: { showingExportOptions = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.founderAccent)
                                    .font(.title2)
                                Text("Export All Events")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.founderAccent.opacity(0.1))
                            )
                        }
                        .disabled(appState.events.isEmpty)
                        
                        Button(action: { showingClearAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                Text("Clear All Events")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .disabled(appState.events.isEmpty)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    
                    // About Card
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.founderAccent)
                                .font(.title2)
                            Text("About Founder Events")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Me")
            .navigationBarTitleDisplayMode(.large)
        }
        .actionSheet(isPresented: $showingExportOptions) {
            ActionSheet(
                title: Text("Export Events"),
                buttons: [
                    .default(Text("Export as ICS File")) {
                        exportEvents(.icsFile)
                    },
                    .default(Text("Share via Email")) {
                        exportEvents(.email)
                    },
                    .cancel()
                ]
            )
        }
        .alert("Clear All Events", isPresented: $showingClearAlert) {
            Button("Clear", role: .destructive) {
                appState.clearAllEvents()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove all \(appState.events.count) events from local storage. Events saved to your iOS Calendar will not be affected.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingImportView) {
            CalendarImportView()
                .environmentObject(appState)
                .environmentObject(calendarManager)
        }
        .navigationViewStyle(.stack)
    }
    
    private func exportEvents(_ method: SharingMethod) {
        sharingManager.shareCalendar(appState.events, method: method) { result in
            // Handle result if needed
        }
    }
    
    private func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Hero Section
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.founderAccent)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.founderAccent.opacity(0.1))
                                    .frame(width: 120, height: 120)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Founder Events")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Save & Share Events")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Features Section
                    VStack(spacing: 20) {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 15) {
                            FeatureCard(icon: "camera.fill", title: "Smart Capture", description: "Take screenshots to extract event details", color: .founderPrimary)
                            FeatureCard(icon: "brain.head.profile", title: "AI Processing", description: "Intelligently parse dates, times, and locations", color: .founderAccent)
                            FeatureCard(icon: "square.and.arrow.up", title: "Easy Sharing", description: "Share events with friends and colleagues", color: .green)
                            FeatureCard(icon: "calendar.badge.plus", title: "Auto Calendar", description: "Automatically save to your calendar", color: .orange)
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 10) {
                        Text("Built with ❤️ using SwiftUI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .navigationViewStyle(.stack)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
