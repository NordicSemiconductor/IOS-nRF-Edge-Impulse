//
//  Filesystem.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 31/3/21.
//

import Foundation

// MARK: - Encodable

extension Encodable {
    
    func writeToDocumentsDirectory(fileName: String, andExtension fileExtension: String) throws {
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(self),
              let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CodableError.directoryNotFound("Could not find Documents Directory.")
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName + "." + fileExtension)
        try data.write(to: fileURL)
    }
}

// MARK: - Decodable

extension Decodable {
    
    static func readFromDocumentsDirectory(fileName: String, andExtension fileExtension: String) throws -> Self {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CodableError.directoryNotFound("Could not find Documents Directory.")
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName + "." + fileExtension)
        let data = try Data(contentsOf: fileURL)
        
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

// MARK: - Error

enum CodableError: Error {
    case directoryNotFound(String)
}
