//
//  Modifiers+macOS.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 22/4/21.
//

import SwiftUI
import AppKit

// MARK: - View

extension View {
    
    func withTabBarStyle() -> some View {
        self
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .border(Color.secondary.opacity(0.2))
    }
}

// MARK: - NSTableView

extension NSTableView {
  
    // Fix for 'List' in macOS always having white backgrounds in Light Mode.
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    
        backgroundColor = .clear
        enclosingScrollView?.drawsBackground = false
    }
}
