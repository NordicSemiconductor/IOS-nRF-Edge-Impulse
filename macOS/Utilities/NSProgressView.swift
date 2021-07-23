//
//  NSProgressView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 23/7/21.
//

import SwiftUI

#if os(OSX)

// MARK: - NSProgressView

struct NSProgressView: NSViewRepresentable {
    
    @Binding var value: Double
    var maxValue: Double
    var isIndeterminate: Bool
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        update(progressIndicator)
        return progressIndicator
    }
    
    func updateNSView(_ NSView: NSProgressIndicator, context: NSViewRepresentableContext<Self>) {
        update(NSView)
    }
}

// MARK: - Private

fileprivate extension NSProgressView {
    
    func update(_ progressIndicator: NSProgressIndicator) {
        if isIndeterminate {
            progressIndicator.isIndeterminate = true
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.minValue = 0.0
            progressIndicator.doubleValue = value
            progressIndicator.maxValue = maxValue
            progressIndicator.stopAnimation(nil)
        }
    }
}

#endif
