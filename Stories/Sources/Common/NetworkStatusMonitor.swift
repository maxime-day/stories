//
//  NetworkStatusMonitor.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation
import Combine
import Network

@MainActor
protocol NetworkStatusMonitorProtocol {
    var isConnected: Bool { get }
}

@MainActor
final class NetworkStatusMonitor: ObservableObject, NetworkStatusMonitorProtocol {
    @Published var isConnected: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkStatusMonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
