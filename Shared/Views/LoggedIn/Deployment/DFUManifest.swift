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
        let size: Int
        let file: String
        let modTime: TimeInterval
        let loadAddress: Int
        let mcuBootVersion: String
        let type: String
        let board: String
        let soc: String
        
        enum CodingKeys: String, CodingKey {
            case size, file
            case modTime = "modtime"
            case loadAddress = "load_address"
            case mcuBootVersion = "version_MCUBOOT"
            case type, board, soc
        }
    }
}
