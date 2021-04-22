//
//  Modifiers+macOS.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 22/4/21.
//

import SwiftUI

extension View {
    
    func withTabBarStyle() -> some View {
        self
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .border(Color.secondary.opacity(0.2))
    }
}
