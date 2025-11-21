//
//  ProfileSetupView.swift
//  Founder Events
//
//  Profile Setup and Edit View
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var website = ""
    @State private var twitter = ""
    @State private var linkedin = ""
    @State private var instagram = ""
    
    @State private var selectedAvatar: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var avatarBase64: String?
    
    @State private var selectedCover: PhotosPickerItem?
    @State private var coverImage: UIImage?
    @State private var coverBase64: String?
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let existingProfile: UserProfile?
    let onComplete: () -> Void
    
    var isEditMode: Bool {
        existingProfile != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Cover Image
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cover Image")
                            .font(.headline)
                        
                        ZStack(alignment: .bottomTrailing) {
                            if let coverImage = coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                            } else if let coverURL = existingProfile?.coverImage {
                                AsyncImage(url: URL(string: coverURL)) { image in
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
                                .cornerRadius(12)
                            } else {
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                            }
                            
                            PhotosPicker(selection: $selectedCover, matching: .images) {
                                HStack(spacing: 4) {
                                    Image(systemName: "camera.fill")
                                    Text("Change Cover")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            }
                            .padding(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Avatar
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            if let avatarImage = avatarImage {
                                Image(uiImage: avatarImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 4)
                            } else if let avatarURL = existingProfile?.avatar {
                                AsyncImage(url: URL(string: avatarURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 4)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 4)
                            }
                            
                            PhotosPicker(selection: $selectedAvatar, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Text("Profile Picture")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .offset(y: -60)
                    .padding(.bottom, -60)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("johndoe", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            
                            Text("Your profile will be at: foundersevents.app/@\(username)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("John Doe", text: $displayName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Website")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("https://yourwebsite.com", text: $website)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Twitter")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("@")
                                    .foregroundColor(.secondary)
                                TextField("username", text: $twitter)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LinkedIn")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextField("https://linkedin.com/in/username", text: $linkedin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instagram")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("@")
                                    .foregroundColor(.secondary)
                                TextField("username", text: $instagram)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isLoading ? "Saving..." : (isEditMode ? "Save Changes" : "Create Profile"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || username.isEmpty || displayName.isEmpty)
                    .opacity((isLoading || username.isEmpty || displayName.isEmpty) ? 0.6 : 1.0)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle(isEditMode ? "Edit Profile" : "Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditMode {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if let profile = existingProfile {
                    username = profile.username
                    displayName = profile.displayName
                    bio = profile.bio ?? ""
                    website = profile.website ?? ""
                    twitter = profile.twitter ?? ""
                    linkedin = profile.linkedin ?? ""
                    instagram = profile.instagram ?? ""
                }
            }
            .onChange(of: selectedAvatar) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        avatarImage = uiImage
                        avatarBase64 = convertImageToBase64(image: uiImage)
                    }
                }
            }
            .onChange(of: selectedCover) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        coverImage = uiImage
                        coverBase64 = convertImageToBase64(image: uiImage)
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        Task {
            isLoading = true
            
            do {
                let request = CreateProfileRequest(
                    username: username,
                    displayName: displayName,
                    bio: bio.isEmpty ? nil : bio,
                    avatar: avatarBase64 ?? existingProfile?.avatar,
                    coverImage: coverBase64 ?? existingProfile?.coverImage,
                    website: website.isEmpty ? nil : website,
                    twitter: twitter.isEmpty ? nil : twitter,
                    linkedin: linkedin.isEmpty ? nil : linkedin,
                    instagram: instagram.isEmpty ? nil : instagram
                )
                
                if isEditMode {
                    _ = try await PublicEventAPIService.shared.updateProfile(request)
                } else {
                    _ = try await PublicEventAPIService.shared.createProfile(request)
                }
                
                await MainActor.run {
                    onComplete()
                    dismiss()
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
    
    private func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
        return "data:image/jpeg;base64," + imageData.base64EncodedString()
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView(existingProfile: nil) {}
    }
}

