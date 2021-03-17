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
    
    func setTitle(_ title: String) -> AnyView {
        #if os(iOS)
        return AnyView(navigationBarTitle("nRF Edge Impulse", displayMode: .inline))
        #else
        return AnyView(navigationTitle(title))
        #endif
    }
    
    func toolbarPrincipalImage(_ image: Image) -> AnyView {
        #if os(iOS)
        return AnyView(toolbar {
            ToolbarItem(placement: .principal) {
                image
                    .resizable()
                    .renderingMode(.template)
                    .colorMultiply(.white)
                    .frame(width: 30, height: 30, alignment: .center)
                    .aspectRatio(contentMode: .fit)
            }
        })
        #else
        return AnyView(self)
        #endif
    }
    
    func circularButtonShape(backgroundAsset: Assets) -> AnyView {
        #if os(iOS)
         return AnyView(frame(width: 80, height: 12)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30))
        #endif
        return AnyView(self)
    }
}

// MARK: - Picker

extension Picker {
    
    func setAsSegmentedControlStyle() -> AnyView {
        #if os(iOS)
        return AnyView(pickerStyle(InlinePickerStyle())
                        .frame(maxHeight: 75))
        #else
        return AnyView(self)
        #endif
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
    
    func setBackgroundColor(_ backgroundColor: Assets) -> NavigationView {
        #if os(iOS)
        let appearance = UINavigationBarAppearance()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = attributes
        appearance.largeTitleTextAttributes = attributes
        appearance.backgroundColor = backgroundColor.uiColor
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        #endif
        return self
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
