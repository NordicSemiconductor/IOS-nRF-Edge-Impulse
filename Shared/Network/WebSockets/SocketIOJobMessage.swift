//
//  SocketIOMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/7/21.
//

import Foundation

struct SocketIOJobMessage: Identifiable, Hashable {
    
    // MARK: - Static
    
    // Use https://regexr.com/ to check RegExes.
    static let MainRegEx: NSRegularExpression! =
        try? NSRegularExpression(pattern: #"[0-9]+\[".+",\{"data":"(.*)"(,.*)?\}\]"#, options: [])
    static let ProgressRegEx: NSRegularExpression! =
        try? NSRegularExpression(pattern: #"\[([0-9]+)\/([0-9]+)\].+"#, options: [])
    
    // MARK: - Properties
    
    var id: Int { job.id }
    
    let job: SocketIOJob
    let message: String
    let progress: Double
    
    var hasUserReadableText: Bool {
        message.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
    }
    
    // MARK: - Init
    
    init(from inputString: String) throws {
        let cleanString = inputString.replacingOccurrences(of: "\\n", with: "")
        
        job = try SocketIOJob(from: inputString)
        let cleanStringRange = NSRange(cleanString.startIndex..<cleanString.endIndex, in: cleanString)
        guard let match = Self.MainRegEx.firstMatch(in: cleanString, options: [], range: cleanStringRange),
              // +1 because the full string is returned as the first match
              match.numberOfRanges >= 2 else { throw NordicError.testError }
        
        message = String(cleanString[Range(match.range(at: 1), in: cleanString)!])
        
        guard let progressMatch = Self.ProgressRegEx.firstMatch(in: cleanString, options: [], range: cleanStringRange),
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
