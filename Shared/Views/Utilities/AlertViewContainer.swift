//
//  RenameDeviceAlertView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/7/21.
//

import SwiftUI

struct AlertViewContainer<Container: View, AlertView: View, BindingIdentifiable: Identifiable>: View {
    
    // MARK: Private Properties
    
    private var content: () -> Container
    private var alertView: (BindingIdentifiable) -> AlertView
    private var isShowing: Binding<BindingIdentifiable?>
    
    // MARK: Init
    
    init(@ViewBuilder content: @escaping () -> Container,
         @ViewBuilder alertView: @escaping (BindingIdentifiable) -> AlertView,
                      isShowing: Binding<BindingIdentifiable?>) {
        self.content = content
        self.alertView = alertView
        self.isShowing = isShowing
    }
    
    // MARK: View
    
    var body: some View {
        #if os(iOS)
        ZStack {
            content()
            
            if let identifiable = isShowing.wrappedValue {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.vertical)
                    .onTapGesture {
                        isShowing.wrappedValue = nil
                    }
                
                alertView(identifiable)
                    .cornerRadius(20.0)
                    .shadow(radius: 20.0)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                        textField.selectAll(nil)
                    }
            }
        }
        #elseif os(OSX)
        content()
            .sheet(item: isShowing) { identifiable in
                alertView(identifiable)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }
            }
        #endif
    }
}
