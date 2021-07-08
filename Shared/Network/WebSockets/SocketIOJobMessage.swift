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
    
    init(from dataString: String) throws {
        let pattern = #"[0-9]+\["job-(.*)-[0-9]+",\{"data":"(.*)[\\]n*"\}\]"#
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(dataString.startIndex..<dataString.endIndex, in: dataString)
        guard let match = regex.firstMatch(in: dataString, options: [], range: nsrange),
              // +1 because the full string is returned as the first match
              match.numberOfRanges == 3 else { throw NordicError.testError }
        
        kind = String(dataString[Range(match.range(at: 1), in: dataString)!])
        message = String(dataString[Range(match.range(at: 2), in: dataString)!])
    }
}
