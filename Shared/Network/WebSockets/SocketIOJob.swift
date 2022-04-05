//
//  SocketIOJob.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import Foundation

struct SocketIOJob: Identifiable, Hashable {
    
    // MARK: - RegEx
    
    static let MainRegEx: NSRegularExpression! =
        try? NSRegularExpression(pattern: #"[0-9]+\["job-(.*)-([0-9]+)",\{.*\}\]"#, options: [])
    
    // MARK: - Properties
    
    let id: Int
    let kind: String
    let jobId: Int
    
    // MARK: - Init
    
    init(from inputString: String) throws {
        let cleanString = inputString.replacingOccurrences(of: "\\n", with: "")
        
        let cleanStringRange = NSRange(cleanString.startIndex..<cleanString.endIndex, in: cleanString)
        guard let match = Self.MainRegEx.firstMatch(in: cleanString, options: [], range: cleanStringRange),
              // +1 because the full string is returned as the first match
              match.numberOfRanges == 3 else { throw NordicError.testError }
        
        kind = String(cleanString[Range(match.range(at: 1), in: cleanString)!])
        jobId = Int(String(cleanString[Range(match.range(at: 2), in: cleanString)!]))!
        id = abs(inputString.hashValue) + jobId
    }
}
