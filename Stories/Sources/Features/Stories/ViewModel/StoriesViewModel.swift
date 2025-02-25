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
        guard state == .idle else {
            return
        }
        
        state = .isLoading
        
        // If not connected to internet, fetch local json
        // If connected :
        // Fetch stories json from API with a timeout
        // Then fetch images with a TaskGroup for each story with a timeout
        // Once done, set isLoaded to true and view will be refreshed
        
        // Fetch and decode model from json result :
        let story1 = Story(id: "1",
                           user: StoryUser(id: "1", name: "mdaymard", profilePictureURL: "https://i.pravatar.cc/300?u=1"),
                           isViewed: false,
                           storyUnits: [])
        
        let story2 = Story(id: "2",
                           user: StoryUser(id: "2", name: "other_user", profilePictureURL: "https://i.pravatar.cc/300?u=2"),
                           isViewed: false,
                           storyUnits: [])
        
        // Convert to view model
        guard let pictureURL = URL(string: story1.user.profilePictureURL) else {
            throw StoriesViewModelError.badURL
        }
        let image1 = try await fetchStoryImage(imageURL: pictureURL)
        let storyViewModel1 = StoryViewModel(id: story1.id,
                                             isViewed: story1.isViewed,
                                             image: image1,
                                             username: story1.user.name)
        
        stories = [storyViewModel1]
        
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
