//
//  StoryUser.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation

struct StoryUser: Decodable, Identifiable {
    let id: String
    let name: String
    let profilePictureURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePictureURL = "profile_picture_url"
    }
    
    init(id: String, name: String, profilePictureURL: String) {
        self.id = id
        self.name = name
        self.profilePictureURL = profilePictureURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Convertit `id` en String même si c'est un Int dans le JSON
        let idInt = try container.decode(Int.self, forKey: .id)
        self.id = String(idInt)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.profilePictureURL = try container.decode(String.self, forKey: .profilePictureURL)
    }
}

struct StoryUserPage: Decodable {
    let users: [StoryUser]
}

struct StoryUserPaginatedResponse: Decodable {
    let pages: [StoryUserPage]
}
