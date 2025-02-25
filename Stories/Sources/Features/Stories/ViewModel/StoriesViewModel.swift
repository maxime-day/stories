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
        case tooManyRetryAttempts
        case internalStateError
        case internalError
        case noMorePagesAvailable
    }
    
    enum State {
        case idle
        case requiresNetwork
        case isLoading
        case isLoaded
    }
    
    @Published var stories: [StoryViewModel] = []
    @Published var state: State = .idle
    var page: Int = 0
    
    private let networkStatusMonitor: NetworkStatusMonitorProtocol = NetworkStatusMonitor()
    private let networkOperationPerformer: NetworkOperationPerformerProtocol = NetworkOperationPerformer()
    private lazy var imageDownloader: ImageDownloaderProtocol = ImageDownloader(targetDirectory: AppConstants.cacheDirectory)
    
    func loadStories() async throws {
        guard state == .idle else {
            throw StoriesViewModelError.internalStateError
        }
        
        try await loadInternal()
    }
    
    func loadMore() async throws {
        guard state != .idle else {
            throw StoriesViewModelError.internalStateError
        }
        
        page += 1
        try await loadInternal()
    }
    
    private func loadInternal(retryAttempts: Int = 0) async throws {
        guard retryAttempts < 3 else {
            throw StoriesViewModelError.tooManyRetryAttempts
        }
        
        state = .isLoading
        
        let storyUsers: StoryUserPage
        // TODO: For this technical test, I only use local decoding
//        if networkStatusMonitor.isConnected {
//            storyUsers = try await fetchStoryUsers(from: page) // TODO
//        } else {
            storyUsers = try await decodeLocalStoryUsers(from: page)
//        }
        
        let storiesData = storyUsers.users.map { user in
            Story(id: user.id,
                  user: user,
                  isViewed: false, // TODO: fetch from API
                  storyUnits: [])
        }
        
        var storiesViewModel: [StoryViewModel] = []
        
        do {
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
                    if let storyViewModel {
                        storiesViewModel.append(storyViewModel)
                    }
                }
            }
            
            stories.append(contentsOf: storiesViewModel)
            state = .isLoaded
        } catch {
            print("Error loading stories : \(error)")
            if !networkStatusMonitor.isConnected {
                state = .requiresNetwork
            } else {
                try await Task.sleep(for: .seconds(1))
                try await loadInternal(retryAttempts: retryAttempts + 1)
            }
        }
    }
    
    private func fetchStoryImage(imageURL: URL) async throws -> UIImage {
        let result = try await networkOperationPerformer.invokeUponNetworkAccess(within: AppConstants.timeoutDurationForImages) { [weak self] in
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
    
//    private func fetchStoryUsers(from page: Int) async throws -> StoryUserPage {
//        // TODO: from API
//    }
    
    private func decodeLocalStoryUsers(from page: Int) async throws -> StoryUserPage {
        guard let url = Bundle.main.url(forResource: "usersExample", withExtension: "json") else {
            throw StoriesViewModelError.internalError
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let paginatedResponse = try decoder.decode(StoryUserPaginatedResponse.self, from: data)
            guard paginatedResponse.pages.count > page else {
                throw StoriesViewModelError.noMorePagesAvailable
            }
            return paginatedResponse.pages[page]
        } catch {
            print("Erreur decoding JSON: \(error)")
            throw StoriesViewModelError.internalError
        }
    }
}
