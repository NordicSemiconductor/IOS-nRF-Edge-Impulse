//
//  View.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

// MARK: - FormIniOSListInMacOS

#if os(iOS)
typealias FormIniOSListInMacOS = Form
#elseif os(macOS)
typealias FormIniOSListInMacOS = List
#endif

// MARK: - View

extension View {
    
    @inlinable public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        return frame(width: size.width, height: size.height, alignment: alignment)
    }
    
    @inlinable public func centerTextInsideForm() -> some View {
        // Hack.
        return frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
    
    @inlinable public func withoutListRowInsets() -> some View {
        return listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    // MARK: - NavBar
    
    func setTitle(_ title: String) -> some View {
        #if os(iOS)
        return navigationBarTitle(title, displayMode: .inline)
        #else
        return navigationTitle(title)
        #endif
    }
    
    @ViewBuilder
    func toolbarPrincipalImage(_ image: Image) -> some View {
        #if os(iOS)
        toolbar {
            ToolbarItem(placement: .principal) {
                image
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(size: .ToolbarImageSize)
                    .aspectRatio(contentMode: .fit)
            }
        }
        #else
        self
        #endif
    }
    
    // MARK: - NavigationView
    
    @ViewBuilder
    func wrapInNavigationViewForiOS() -> some View {
        #if os(iOS)
        NavigationView {
            self
        }
        .setBackgroundColor(.blue)
        .setSingleColumnNavigationViewStyle()
        .accentColor(.white)
        #else
        self
        #endif
    }
    
    // MARK: - UITextField
    
    func disableAllAutocorrections() -> some View {
        disableAutocorrection(true)
        #if os(iOS)
            .autocapitalization(.none)
        #endif
    }


    // MARK: - View + HUD
    func hud<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) {
            self
            
            if isPresented.wrappedValue {
                HUD(content: content)
                    .transition(
                        AnyTransition.move(edge: .top).combined(with: .opacity)
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
    }
    
}

// MARK: - Picker

extension Picker {
    
    @ViewBuilder
    func setAsComboBoxStyle() -> some View {
        self
        #if os(iOS)
            .pickerStyle(MenuPickerStyle())
            .accentColor(.primary)
        #endif
    }
    
    func setAsSegmentedControlStyle() -> some View {
        self
        #if os(iOS)
            .pickerStyle(SegmentedPickerStyle())
        #endif
    }
}

// MARK: - NavigationView

extension NavigationView {
    
    func setSingleColumnNavigationViewStyle() -> some View {
        self
        #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
        #endif
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
