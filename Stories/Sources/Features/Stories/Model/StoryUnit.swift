//
//  StoryUnit.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation

struct StoryUnit: Decodable, Identifiable {
    let id: String
    let date: Date
    let content: StoryContent
    let author: StoryUser
    let isViewed: Bool
}
