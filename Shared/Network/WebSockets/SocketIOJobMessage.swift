//
//  SocketIOMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/7/21.
//

import Foundation

struct SocketIOJobMessage {
    
    let kind: String
    let message: String
    
    init(from inputString: String) throws {
        let cleanString = inputString.replacingOccurrences(of: "\\n", with: "")
        
        // Use https://regexr.com/ to check RegExes.
        let pattern = #"[0-9]+\["job-(.*)-[0-9]+",\{"data":"(.*)"\}\]"#
        let regEx = try NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(cleanString.startIndex..<cleanString.endIndex, in: cleanString)
        guard let match = regEx.firstMatch(in: cleanString, options: [], range: nsrange),
              // +1 because the full string is returned as the first match
              match.numberOfRanges == 3 else { throw NordicError.testError }
        
        kind = String(cleanString[Range(match.range(at: 1), in: cleanString)!])
        message = String(cleanString[Range(match.range(at: 2), in: cleanString)!])
    }
}
