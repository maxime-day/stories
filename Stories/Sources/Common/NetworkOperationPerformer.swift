//
//  NetworkOperationPerformer.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation
import Network

public protocol NetworkOperationPerformerProtocol {
    func invokeUponNetworkAccess<T: Sendable>(within timeoutDuration: Duration,
                                              _ closure: @escaping @Sendable () async throws -> T) async throws -> Result<T, NetworkOperationExecutionError>
}

public enum NetworkOperationExecutionError: Error {
    case dismissed
    case timedOut
}

final class NetworkOperationPerformer: NetworkOperationPerformerProtocol {
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkOperationPerformer")
    
    init() {
        networkMonitor.start(queue: queue)
    }
    
    private func waitForNetwork() async throws {
        for await path in networkMonitor {
            if path.status == .satisfied { return }
        }
        try Task.checkCancellation()
    }
    
    private func waitForNetworkWithTimeout(after duration: Duration = .seconds(10)) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            defer { group.cancelAll() }
            
            group.addTask { [weak self] in
                guard let self else {
                    throw NetworkOperationExecutionError.dismissed
                }
                try await waitForNetwork()
            }
            group.addTask {
                try await Task.sleep(for: duration)
                throw NetworkOperationExecutionError.timedOut
            }
            
            try await group.next()
        }
    }
    
    /// Invokes the given `closure` if and only if access to the network is initially
    /// available or becomes available within the given `timeoutDuration`.
    @available(macOS 13, iOS 16.0, *)
    public func invokeUponNetworkAccess<T: Sendable>(within timeoutDuration: Duration,
                                                     _ closure: @escaping @Sendable () async throws -> T) async throws -> Result<T, NetworkOperationExecutionError> {
        do {
            try await waitForNetworkWithTimeout(after: timeoutDuration)
        } catch {
            return .failure(NetworkOperationExecutionError.timedOut)
        }
        return try await .success(closure())
    }
}
