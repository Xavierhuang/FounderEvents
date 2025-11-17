//
//  FounderEventsApp.swift
//  Founder Events
//
//  Created by Weijia Huang on 8/4/25.
//

import SwiftUI

@main
struct FounderEventsApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(appState)
                .environmentObject(calendarManager)
        }
    }
}

struct MainAppView: View {
    @State private var showingSplash = true
    
    var body: some View {
        Group {
            if showingSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingSplash = false
                            }
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
