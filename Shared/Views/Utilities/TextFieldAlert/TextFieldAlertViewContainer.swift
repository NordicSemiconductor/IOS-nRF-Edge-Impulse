//
//  TextFieldAlertViewContainer.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/7/21.
//

import SwiftUI
import Combine

// MARK: - TextFieldAlertViewContainer

struct TextFieldAlertViewContainer<Container: View>: View {
    
    // MARK: Private Properties
    
    private var content: () -> Container
    private let title: String
    private let message: String
    private var text: Binding<String>
    private var isPresented: Binding<Bool>
    private let onPositiveAction: () -> Void
    
    // MARK: Init
    
    init(@ViewBuilder content: @escaping () -> Container, title: String,
         message: String, text: Binding<String>, isPresented: Binding<Bool>, onPositiveAction: @escaping () -> Void) {
        self.content = content
        self.title = title
        self.message = message
        self.text = text
        self.isPresented = isPresented
        self.onPositiveAction = onPositiveAction
    }
    
    // MARK: View
    
    var body: some View {
        content()
            .alert(title, isPresented: isPresented) {
                Button("Cancel", role: .cancel, action: {
                    isPresented.wrappedValue = false
                })
                
                Button("OK", role: .none, action: onPositiveAction)
        
                TextField(message, text: text)
                    .textContentType(.username)
            }
    }
}
