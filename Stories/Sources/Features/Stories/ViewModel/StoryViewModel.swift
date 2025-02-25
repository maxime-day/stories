//
//  Untitled.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import UIKit

final class StoryViewModel: Identifiable {
    let id: String
    let isViewed: Bool
    let image: UIImage
    let username: String
    
    init(id: String,
         isViewed: Bool,
         image: UIImage,
         username: String) {
        self.id = id
        self.isViewed = isViewed
        self.image = image
        self.username = username
    }
}
