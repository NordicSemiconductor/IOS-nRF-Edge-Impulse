//
//  View.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

// MARK: - View

extension View {
    
    @inlinable public func centerTextInsideForm() -> some View {
        // Hack.
        return frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
    @inlinable public func withoutListRowInsets() -> some View {
        return listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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

// MARK: - NavigationView

extension NavigationView {
    
    @inlinable func setSingleColumnNavigationViewStyle() -> AnyView {
        #if os(iOS)
        return AnyView(navigationViewStyle(StackNavigationViewStyle()))
        #endif
        return AnyView(self)
    }
}

#if DEBUG
struct Landscape<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        #if os(iOS)
        let screenHeight = UIScreen.main.bounds.width
        let screenWidth = UIScreen.main.bounds.height
        content().previewLayout(PreviewLayout.fixed(width: screenWidth, height: screenHeight))
        #else
        content()
        #endif
    }
}
#endif
