//
//  Story.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation

struct Story: Decodable, Identifiable {
    let id: Int
    let date: Date
    let content: StoryContent
    let author: StoryUser
}
