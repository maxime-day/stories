//
//  StoriesViewModel.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation
import UIKit

final class StoriesViewModel {
    let dummyURL = URL(string:"https://picsum.photos/200/300")!
    enum StoriesViewModelError: Error {
        case cancelled
    }
    
    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let networkOperationPerformer = NetworkOperationPerformer()
    lazy var imageDownloader = ImageDownloader(targetDirectory: cacheDirectory)
    
    func fetchStories() async throws -> UIImage {
        let result = try await networkOperationPerformer.invokeUponNetworkAccess(within: .seconds(5)) { [weak self] in
            guard let self else {
                throw StoriesViewModelError.cancelled
            }
            return try await imageDownloader.downloadImageIfNeeded(from: dummyURL)
        }
        
        switch result {
        case .success(let image):
            return image
        case .failure(let error):
            throw error
        }
    }
}
