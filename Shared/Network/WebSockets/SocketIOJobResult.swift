//
//  SocketIOJobResult.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import Foundation

struct SocketIOJobResult: Identifiable, Hashable {
    
    // MARK: - Static
    
    // Use https://regexr.com/ to check RegExes.
    static let ResultRegEx: NSRegularExpression! =
        try? NSRegularExpression(pattern: #"[0-9]+\[".+",\{"success":([a-zA-Z]+).*\}\]"#, options: [])
    
    // MARK: - Properties
    
    var id: Int { job.id }
    
    let job: SocketIOJob
    let success: Bool
    
    // MARK: - Init
    
    init(from inputString: String) throws {
        let cleanString = inputString.replacingOccurrences(of: "\\n", with: "")
        
        job = try SocketIOJob(from: inputString)
        let cleanStringRange = NSRange(cleanString.startIndex..<cleanString.endIndex, in: cleanString)
        guard let match = Self.ResultRegEx.firstMatch(in: cleanString, options: [], range: cleanStringRange),
              // +1 because the full string is returned as the first match
              match.numberOfRanges == 2 else { throw NordicError.testError }
        
        let successString = String(cleanString[Range(match.range(at: 1), in: cleanString)!])
        success = successString == "true"
    }
}
