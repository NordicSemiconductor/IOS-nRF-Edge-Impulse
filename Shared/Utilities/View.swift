//
//  View.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

extension View {
    
    @inlinable public func centerTextInsideForm() -> some View {
        // Hack.
        return frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
    func setupNavBar(backgroundColor: Assets, titleColor: Color) {
//        #if targetEnvironment(simulator)
//        
//        #elseif os(iOS)
//        let appearance = UINavigationBarAppearance()
//        let attributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: titleColor
//        ]
//        appearance.titleTextAttributes = attributes
//        appearance.largeTitleTextAttributes = attributes
//        appearance.backgroundColor = backgroundColor.uiColor
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        #endif
    }
}

extension NavigationView {
    
    @inlinable func setSingleColumnNavigationViewStyle() -> AnyView {
        #if os(iOS)
        return AnyView(navigationViewStyle(StackNavigationViewStyle()))
        #endif
        return AnyView(self)
    }
}
