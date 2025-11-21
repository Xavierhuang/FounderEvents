//
//  ProfileView.swift
//  Founder Events
//
//  User Profile Display View
//

import SwiftUI

struct ProfileView: View {
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var showSetup = false
    @State private var showEdit = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else if let profile = profile {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Cover Image
                            if let coverURL = profile.coverImage, let url = URL(string: coverURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .clipped()
                            } else {
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                            }
                            
                            VStack(spacing: 20) {
                                // Avatar overlapping cover
                                VStack(spacing: 12) {
                                    if let avatarURL = profile.avatar, let url = URL(string: avatarURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 4)
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .frame(width: 100, height: 100)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                            .shadow(radius: 4)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text(profile.displayName)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("@\(profile.username)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .offset(y: -50)
                                .padding(.bottom, -50)
                                
                                // Bio
                                if let bio = profile.bio {
                                    Text(bio)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                
                                // Social Links
                                HStack(spacing: 16) {
                                    if let website = profile.website {
                                        Link(destination: URL(string: website)!) {
                                            Image(systemName: "globe")
                                                .foregroundColor(.purple)
                                        }
                                    }
                                    
                                    if let twitter = profile.twitter {
                                        Link(destination: URL(string: "https://twitter.com/\(twitter)")!) {
                                            Image(systemName: "link")
                                                .foregroundColor(.purple)
                                        }
                                    }
                                    
                                    if let linkedin = profile.linkedin {
                                        Link(destination: URL(string: linkedin)!) {
                                            Image(systemName: "link")
                                                .foregroundColor(.purple)
                                        }
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                // Stats
                                HStack(spacing: 0) {
                                    StatView(title: "Events", value: "\(profile.totalEvents)")
                                    
                                    Divider()
                                        .frame(height: 40)
                                    
                                    StatView(title: "Attendees", value: "\(profile.totalAttendees)")
                                }
                                .padding(.horizontal)
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                // Public Profile Link
                                VStack(spacing: 8) {
                                    Text("Your Public Profile")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text("foundersevents.app/@\(profile.username)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            UIPasteboard.general.string = "https://foundersevents.app/@\(profile.username)"
                                        }) {
                                            Text("Copy")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.purple)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Create Your Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Set up your profile to create and manage events")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { showSetup = true }) {
                            Text("Create Profile")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                if profile != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            showEdit = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                ProfileSetupView(existingProfile: nil) {
                    Task {
                        await loadProfile()
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                ProfileSetupView(existingProfile: profile) {
                    Task {
                        await loadProfile()
                    }
                }
            }
            .task {
                await loadProfile()
            }
            .refreshable {
                await loadProfile()
            }
        }
    }
    
    private func loadProfile() async {
        isLoading = true
        
        do {
            let loadedProfile = try await PublicEventAPIService.shared.getProfile()
            await MainActor.run {
                self.profile = loadedProfile
                isLoading = false
            }
        } catch {
            print("Error loading profile: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Stat View Component

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

