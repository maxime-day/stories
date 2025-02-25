//
//  Story.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation
import UIKit

struct Story: Decodable, Identifiable {
    let id: String
    let user: StoryUser
    let isViewed: Bool
    let storyUnits: [StoryUnit]
}
