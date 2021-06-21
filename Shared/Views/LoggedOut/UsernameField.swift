//
//  UsernameField.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/4/21.
//

import SwiftUI

struct UsernameField: View {
    
    // MARK: - Private Properties
    
    private var username: Binding<String>
    private var enabled: Bool
    
    // MARK: - Init
    
    init(_ binding: Binding<String>, enabled: Bool) {
        self.username = binding
        self.enabled = enabled
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Image(systemName: "person.fill")
                .frame(size: .StandardImageSize)
                .accentColor(Assets.darkGrey.color)
            TextField("", text: username)
                .modifier(FixPlaceholder(for: username, text: "Username or E-Mail"))
                .disableAllAutocorrections()
                .foregroundColor(.accentColor)
                .modifier(RoundedTextFieldShape(.lightGrey, hasTextFieldBelow: true))
                .disabled(!enabled)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct UsernameField_Previews: PreviewProvider {
    
    @State static var emptyUsername: String = ""
    @State static var username: String = "taylor.swift"
    
    static var previews: some View {
        Group {
            UsernameField($emptyUsername, enabled: true)
            UsernameField($username, enabled: true)
            UsernameField($username, enabled: false)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
