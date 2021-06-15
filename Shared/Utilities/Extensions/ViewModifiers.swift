//
//  ViewModifiers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/6/21.
//

import SwiftUI

struct CircularButtonShape: ViewModifier {
    
    let backgroundAsset: Assets
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .frame(width: 80, height: 12)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30)
        #else
        self
        #endif
    }
}
