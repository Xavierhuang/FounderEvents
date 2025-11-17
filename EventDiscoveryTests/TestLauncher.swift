//
//  TestLauncher.swift
//  EventDiscoveryTests
//
//  Main launcher for all event discovery tests
//

import SwiftUI

struct TestLauncher: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Text("🧪 Event Discovery Tests")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("Test AI discovery and web scraping functionality separately")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Test Options
                VStack(spacing: 16) {
                    NavigationLink(destination: AIEventDiscoveryTest()) {
                        TestOptionCard(
                            title: "🤖 AI Event Discovery",
                            subtitle: "Test OpenAI-powered event discovery",
                            description: "Test AI's ability to find events based on location and interests",
                            color: .purple
                        )
                    }
                    
                    NavigationLink(destination: WebScrapingTest()) {
                        TestOptionCard(
                            title: "🕷️ Web Scraping",
                            subtitle: "Test web scraping from event websites",
                            description: "Test scraping events from Eventbrite, Meetup, and other sites",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: IntegrationTest()) {
                        TestOptionCard(
                            title: "🔄 Integration Test",
                            subtitle: "Test combined AI + scraping",
                            description: "Test the full integration of AI discovery and web scraping",
                            color: .green
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Instructions
                VStack(spacing: 8) {
                    Text("📋 Testing Instructions:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("1. Start with AI Event Discovery (easiest)")
                        Text("2. Test Web Scraping (more complex)")
                        Text("3. Run Integration Test (combines both)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .navigationTitle("Event Discovery Tests")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TestOptionCard: View {
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
        }
        .padding()
        .background(color)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    TestLauncher()
} 