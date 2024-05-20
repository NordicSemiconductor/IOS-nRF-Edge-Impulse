//
//  DFUPackage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 17/11/21.
//

import Foundation
import OSLog
import ZIPFoundation
import iOSMcuManagerLibrary

// MARK: - DFUPackage

struct DFUPackage {
    
    private static let logger = Logger(category: "DFUPackage")
    
    // MARK: Properties
    
    let images: [ImageManager.Image]
    
    // MARK: Init
    
    init(_ data: Data) throws {
        guard let tempUrlPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            throw NordicError(description: "Unable to write to Cache Directory.")
        }
        let zipFileURL = URL(fileURLWithPath: tempUrlPath + "/\(abs(data.hashValue)).zip")
        try data.write(to: zipFileURL)
        defer {
            DFUPackage.cleanup(zipFileURL)
        }
        
        guard Archive(url: zipFileURL, accessMode: .read) != nil else {
            throw NordicError(description: "Server did not return a .ZIP file.")
        }

        let fileManager = FileManager()
        let directoryURL = URL(fileURLWithPath: tempUrlPath + "/\(abs(data.hashValue))/", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.unzipItem(at: zipFileURL, to: directoryURL)
        defer {
            DFUPackage.cleanup(directoryURL)
        }

        let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
        guard let manifestFile = contents.first(where: { $0.pathExtension == "json" }) else {
            throw NordicError(description: "JSON File to parse as Manifest not found.")
        }

        let jsonData = try Data(contentsOf: manifestFile)
        let manifest = try JSONDecoder().decode(DFUManifest.self, from: jsonData)
        self.images = try manifest.files.compactMap({ manifestFile -> ImageManager.Image in
            guard let url = contents.first(where: { $0.absoluteString.contains(manifestFile.file) }) else {
                throw NordicError(description: "Unable to find \(manifestFile.file) for Image \(manifestFile.imageIndex)")
            }
            let imageData = try Data(contentsOf: url)
            let hash = try McuMgrImage(data: imageData).hash
            return ImageManager.Image(image: manifestFile.imageIndex, hash: hash, data: imageData)
        })
    }
}

// MARK: Cleanup

private extension DFUPackage {
    
    static func cleanup(_ url: URL) {
        do {
            let fileManager = FileManager()
            try fileManager.removeItem(at: url)
        } catch {
            logger.debug("Unable to delete file at \(url.absoluteString): \(error.localizedDescription)")
        }
    }
}
