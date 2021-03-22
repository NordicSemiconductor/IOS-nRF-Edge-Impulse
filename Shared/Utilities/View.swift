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
    
    // MARK: - NavBar
    
    func setTitle(_ title: String) -> AnyView {
        let anyView: AnyView
        #if os(iOS)
        anyView = AnyView(navigationBarTitle("nRF Edge Impulse", displayMode: .inline))
        #else
        anyView = AnyView(navigationTitle(title))
        #endif
        return anyView
    }
    
    func toolbarPrincipalImage(_ image: Image) -> AnyView {
        let anyView: AnyView
        #if os(iOS)
        anyView = AnyView(toolbar {
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
        anyView = AnyView(self)
        #endif
        return anyView
    }
    
    // MARK: - NavigationView
    
    func wrapInNavigationViewForiOS() -> AnyView {
        let anyView: AnyView
        #if os(iOS)
        anyView = AnyView(
            NavigationView {
                self
            }
            .setBackgroundColor(.blue)
            .setSingleColumnNavigationViewStyle()
            .accentColor(.white))
        #else
        anyView = AnyView(self)
        #endif
        return anyView
    }
    
    // MARK: - UITextField
    
    func roundedTextFieldShape(backgroundAsset: Assets, hasTextFieldBelow: Bool = false) -> AnyView {
        var anyView: AnyView
        #if os(iOS)
        anyView = AnyView(frame(maxWidth: 300)
            .frame(height: 20)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30))
        if hasTextFieldBelow {
            anyView = AnyView(anyView.padding(.bottom, 16))
        }
        #else
        anyView = AnyView(self)
        #endif
        return anyView
    }
    
    // MARK: - Button
    
    func circularButtonShape(backgroundAsset: Assets) -> AnyView {
        let anyView: AnyView
        #if os(iOS)
        anyView = AnyView(frame(width: 80, height: 12)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(backgroundAsset.color)
                            .cornerRadius(30))
        #else
        anyView = AnyView(self)
        #endif
        return anyView
    }
}

// MARK: - Picker

extension Picker {
    
    func setAsComboBoxStyle() -> AnyView {
        let anyView: AnyView
        #if os(iOS)
        anyView = AnyView(pickerStyle(InlinePickerStyle())
                            .frame(maxHeight: 75))
        #else
        anyView = AnyView(self)
        #endif
        return anyView
    }
}

// MARK: - NavigationView

extension NavigationView {
    
    @inlinable func setSingleColumnNavigationViewStyle() -> AnyView {
        let anyView: AnyView
        #if os(iOS)
        anyView = AnyView(navigationViewStyle(StackNavigationViewStyle()))
        #else
        anyView = AnyView(self)
        #endif
        return anyView
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
