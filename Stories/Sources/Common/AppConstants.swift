//
//  AppConstants.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import Foundation

enum AppConstants {
    static let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    static let timeoutDurationForImages: Duration = .seconds(3)
}
