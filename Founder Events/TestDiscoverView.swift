import SwiftUI

struct TestDiscoverView: View {
    @StateObject private var garysGuideService = GarysGuideService()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Discover Test")
                    .font(.title)
                    .padding()
                
                if garysGuideService.isLoading {
                    Text("Loading...")
                        .foregroundColor(.blue)
                } else if let errorMessage = garysGuideService.errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            garysGuideService.refreshEvents()
                        }
                        .padding()
                    }
                } else {
                    Text("Events loaded: \(garysGuideService.events.count)")
                        .foregroundColor(.green)
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(garysGuideService.events.prefix(5)) { event in
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                        .font(.headline)
                                    Text(event.displayDate)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Discover Test")
        }
    }
}

#Preview {
    TestDiscoverView()
}
