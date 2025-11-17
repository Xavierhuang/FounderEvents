import SwiftUI

struct SimpleDiscoverView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.founderAccent)
                
                Text("Discover Events")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Find and explore events from Gary's Guide")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Load Events") {
                    // Simple action
                    print("Load events tapped")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.founderAccent)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SimpleDiscoverView(appState: AppState())
}
