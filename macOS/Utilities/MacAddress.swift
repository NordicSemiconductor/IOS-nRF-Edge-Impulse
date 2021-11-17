//
//  MacAddress.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 24/8/21.
//

import Foundation

final class MacAddress {
    
    static let shared = MacAddress()
    
    // MARK: - Private
    
    private let lock: NSLock
    private var _value: String?
    
    private init() {
        self.lock = NSLock()
        self._value = nil
    }
    
    func get() -> String? {
        // TODO: Fix for macOS 12 or remove.
        if #available(macOS 12.0, *) {
            return nil // App Sandbox doesn't allow us to call system_profiler.
        }
        
        // Ensure Exclusive Access. Or attempt to, at least - the previous way we had to
        // launch the system_profiler process crashed the app randomly with 'Simultaneous
        // access' error.
        lock.lock()
        defer {
            lock.unlock()
        }
        
        guard _value == nil else { return _value }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        task.arguments = ["SPBluetoothDataType"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let lines = String(data: data, encoding: .utf8)?.split(separator: "\n")
            guard let addressLine = lines?.first(where: { $0.contains("Address:") }) else { return nil }
            var result = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
            result.removeFirst(9)
            _value = String(result)
            return _value
        } catch {
            return nil
        }
    }
}
