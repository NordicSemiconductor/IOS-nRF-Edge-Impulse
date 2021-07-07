//
//  HUDState.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 07/07/2021.
//

import SwiftUI

final class HUDState: ObservableObject {
    @Published var isPresented: Bool = false
    private(set) var title: String = ""
    private(set) var systemImage: String = ""
    
    func show(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
        withAnimation {
            isPresented = true
        }
    }
}
