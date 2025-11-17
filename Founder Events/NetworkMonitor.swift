//
//  NetworkMonitor.swift
//  ScheduleShare
//
//  Network connectivity monitoring
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("🌐 Network status changed: \(path.status == .satisfied ? "Connected" : "Disconnected")")
            }
        }
        monitor.start(queue: queue)
        
        // Check initial network state
        let currentPath = monitor.currentPath
        DispatchQueue.main.async {
            self.isConnected = currentPath.status == .satisfied
            print("🌐 Initial network status: \(currentPath.status == .satisfied ? "Connected" : "Disconnected")")
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
