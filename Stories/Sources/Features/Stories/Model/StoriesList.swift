//
//  StoriesList.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

struct StoriesAPIResult {
    let stories: [StoryAPIResult]
}

struct StoryAPIResult {
    let user: StoryUser
    let hasSeenAllStories: Bool
    let stories: [Story]
}
