//
//  StoryUser.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation

struct StoryUser: Decodable, Identifiable {
    let id: Int
    let name: String
    let profilePictureURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case profilePictureURL = "profile_picture_url"
    }
}

struct UserPage: Decodable {
    let users: [StoryUser]
}

struct UserPaginatedResponse: Decodable {
    let pages: [UserPage]
}
