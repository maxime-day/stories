//
//  ImageDownloader.swift
//  Stories
//
//  Created by Maxime Daymard on 25/02/2025.
//

import UIKit

protocol ImageDownloaderProtocol {
    func downloadImageIfNeeded(from url: URL) async throws -> UIImage
    func downloadImageIfNeeded(from url: URL, completion: @escaping @Sendable (UIImage) -> Void) throws
    
    func isImageDownloaded(from url: URL) -> Bool
    func getDownloadedImage(from url: URL) throws -> UIImage
}

/**
 Downloads files at the specified downloadDirectory. Names them from the last url component
 */
final class ImageDownloader {
    enum ImageError: Error {
        case invalidData
        case notDownloaded
        case invalidDownloadDirectory
    }
    
    private let targetDirectory: URL
    private let fileManager = FileManager.default // Thread-safe
    
    init(targetDirectory: URL) {
        self.targetDirectory = targetDirectory
    }

    private func getLocalFileURL(for url: URL) -> URL {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return targetDirectory.appendingPathComponent(url.lastPathComponent)
        }
            
        var lastPathComponent = url.lastPathComponent
        if let query = components.percentEncodedQuery {
            lastPathComponent = "\(lastPathComponent)?\(query)"
        }
        
        return targetDirectory.appendingPathComponent(lastPathComponent)
    }

    private func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }
        
        try writeDataToTargetDirectory(data, from: url)
        
        return image
    }
    
    private func writeDataToTargetDirectory(_ data: Data, from url: URL) throws {
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: targetDirectory.absoluteString, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: targetDirectory,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } else {
            if !isDirectory.boolValue {
                throw ImageError.invalidDownloadDirectory
            }
        }
        
        try data.write(to: getLocalFileURL(for: url))
    }
}

extension ImageDownloader: ImageDownloaderProtocol {
    func downloadImageIfNeeded(from url: URL) async throws -> UIImage {
        if isImageDownloaded(from: url) {
            return try getDownloadedImage(from: url)
        } else {
            return try await downloadImage(from: url)
        }
    }
    
    func isImageDownloaded(from url: URL) -> Bool {
        let localFileURL = getLocalFileURL(for: url)
        return fileManager.fileExists(atPath: localFileURL.path)
    }
    
    func getDownloadedImage(from url: URL) throws -> UIImage {
        guard isImageDownloaded(from: url) else {
            throw ImageError.notDownloaded
        }

        let localFileURL = getLocalFileURL(for: url)
        let localImageData = try Data(contentsOf: localFileURL)
        
        guard let image = UIImage(data: localImageData) else {
            throw ImageError.invalidData
        }
        return image
    }
    
    func downloadImageIfNeeded(from url: URL, completion: @escaping (UIImage) -> Void) throws {
        if isImageDownloaded(from: url) {
            let downloadedImage = try getDownloadedImage(from: url)
            completion(downloadedImage)
        } else {
            Task {
                let result = try await downloadImage(from: url)
                completion(result)
            }
        }
    }
}
