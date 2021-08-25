//
//  MacAddress.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 24/8/21.
//

import Foundation

final class MacAddress {
    
    static let shared = MacAddress()
    
    private let lock: NSLock
    
    private init() {
        self.lock = NSLock()
    }
    
    func read() -> String? {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        let task = Process()
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPBluetoothDataType"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let lines = String(data: data, encoding: .utf8)?.split(separator: "\n")
        guard let addressLine = lines?.first(where: { $0.contains("Address:") }) else { return nil }
        var result = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
        result.removeFirst(9)
        return String(result)
    }
}
