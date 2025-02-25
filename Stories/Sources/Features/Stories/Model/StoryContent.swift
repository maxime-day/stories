//
//  StoryContent.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation

struct StoryContent: Decodable {
    var isVideo: Bool
    let url: URL
    let mentions: [StoryUser]
}
