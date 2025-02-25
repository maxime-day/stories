//
//  StoriesViewModel.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation
import UIKit

@MainActor
final class StoriesViewModel: ObservableObject {
    enum StoriesViewModelError: Error {
        case cancelled
        case badURL
    }
    
    enum State {
        case idle
        case requiresNetwork
        case isLoading
        case isLoaded
    }
    
    @Published var stories: [StoryViewModel] = []
    @Published var state: State = .idle
    
    private let networkStatusMonitor = NetworkStatusMonitor()
    private let networkOperationPerformer = NetworkOperationPerformer()
    private lazy var imageDownloader = ImageDownloader(targetDirectory: AppConstants.cacheDirectory)
    
    func loadStories() async throws {
        // Fetch and decode models
        let storiesData = [
            Story(id: "1", user: StoryUser(id: "1", name: "mdaymard", profilePictureURL: "https://i.pravatar.cc/300?u=1"), isViewed: false, storyUnits: []),
            Story(id: "2", user: StoryUser(id: "2", name: "other_user", profilePictureURL: "https://i.pravatar.cc/300?u=2"), isViewed: false, storyUnits: [])
        ]
        
        var storiesViewModel: [StoryViewModel] = []
        
        try await withThrowingTaskGroup(of: StoryViewModel?.self) { group in
            for story in storiesData {
                group.addTask { [weak self] in
                    guard let self else {
                        throw StoriesViewModelError.cancelled
                    }
                    guard let pictureURL = URL(string: story.user.profilePictureURL) else {
                        throw StoriesViewModelError.badURL
                    }
                    let image = try await fetchStoryImage(imageURL: pictureURL)
                    return StoryViewModel(id: story.id, isViewed: story.isViewed, image: image, username: story.user.name)
                }
            }
            
            for try await storyViewModel in group {
                if let storyViewModel = storyViewModel {
                    storiesViewModel.append(storyViewModel)
                }
            }
        }
        
        stories = storiesViewModel
        state = .isLoaded
    }

    
    func loadMore() async throws {
        // IF connected, load one more page through an API
        // If not corrected, throw an error
    }
    
    private func fetchStoryImage(imageURL: URL) async throws -> UIImage {
        let result = try await networkOperationPerformer.invokeUponNetworkAccess(within: .seconds(5)) { [weak self] in
            guard let self else {
                throw StoriesViewModelError.cancelled
            }
            return try await imageDownloader.downloadImageIfNeeded(from: imageURL)
        }
        
        switch result {
        case .success(let image):
            return image
        case .failure(let error):
            throw error
        }
    }
}
