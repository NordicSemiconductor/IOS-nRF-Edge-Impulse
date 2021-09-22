//
//  DFUManifest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/8/21.
//

import Foundation

// MARK: - DFUManifest

struct DFUManifest: Codable {
    
    let formatVersion: Int
    let time: TimeInterval
    let files: [File]
    
    enum CodingKeys: String, CodingKey {
        case formatVersion = "format-version"
        case time, files
    }
}

// MARK: - DFUManifest.File

extension DFUManifest {
    
    struct File: Codable {
        
        let imageIndex: Int
        let size: Int
        let file: String
        let modTime: Int
        let mcuBootVersion: String?
        let type: String
        let board: String
        let soc: String
        
        // MARK: CodingKeys
        
        enum CodingKeys: String, CodingKey {
            case size, file
            case modTime = "modtime"
            case mcuBootVersion = "version_MCUBOOT"
            case type, board, soc
            case imageIndex = "image_index"
        }
        
        // MARK: Init
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            size = try values.decode(Int.self, forKey: .size)
            file = try values.decode(String.self, forKey: .file)
            modTime = try values.decode(Int.self, forKey: .modTime)
            mcuBootVersion = try? values.decode(String.self, forKey: .mcuBootVersion)
            type = try values.decode(String.self, forKey: .type)
            board = try values.decode(String.self, forKey: .board)
            soc = try values.decode(String.self, forKey: .soc)
            let imageIndexString = try values.decode(String.self, forKey: .imageIndex)
            guard let imageIndex = Int(imageIndexString) else {
                throw DecodingError.dataCorruptedError(forKey: .imageIndex, in: values,
                                                       debugDescription: "`imageIndex` could not be parsed from String to Int.")
            }
            self.imageIndex = imageIndex
        }
    }
}
