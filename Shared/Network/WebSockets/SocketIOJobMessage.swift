//
//  SocketIOMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/7/21.
//

import Foundation

struct SocketIOJobMessage: Identifiable, Hashable {
    let id: Int
    
    let kind: String
    let jobId: Int
    let message: String
    let progress: Double
    
    init(from inputString: String) throws {
        let cleanString = inputString.replacingOccurrences(of: "\\n", with: "")
        
        // Use https://regexr.com/ to check RegExes.
        let mainPattern = #"[0-9]+\["job-(.*)-([0-9]+)",\{"data":"(.*)"\}\]"#
        let mainRegEx = try NSRegularExpression(pattern: mainPattern, options: [])
        let cleanStringRange = NSRange(cleanString.startIndex..<cleanString.endIndex, in: cleanString)
        guard let match = mainRegEx.firstMatch(in: cleanString, options: [], range: cleanStringRange),
              // +1 because the full string is returned as the first match
              match.numberOfRanges == 4 else { throw NordicError.testError }
        
        kind = String(cleanString[Range(match.range(at: 1), in: cleanString)!])
        jobId = Int(String(cleanString[Range(match.range(at: 2), in: cleanString)!]))!
        message = String(cleanString[Range(match.range(at: 3), in: cleanString)!])
        id = inputString.hashValue + jobId
        
        let progressPattern = #"\[([0-9]+)\/([0-9]+)\].+"#
        let progressRegEx = try NSRegularExpression(pattern: progressPattern, options: [])
        guard let progressMatch = progressRegEx.firstMatch(in: cleanString, options: [], range: cleanStringRange),
              // +1 because the full string is returned as the first match
              progressMatch.numberOfRanges == 3 else {
            progress = 0.0
            return
        }
        let currentProgress = Double(String(cleanString[Range(progressMatch.range(at: 1), in: cleanString)!]))!
        let totalProgress = Double(String(cleanString[Range(progressMatch.range(at: 2), in: cleanString)!]))!
        progress = currentProgress / totalProgress * 100.0
    }
}
