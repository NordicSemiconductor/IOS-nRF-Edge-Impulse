//
//  PasswordField.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/4/21.
//

import SwiftUI

struct PasswordField: View {
    
    // MARK: - Private Properties
    
    private var password: Binding<String>
    private var enabled: Bool
    
    // MARK: - Init
    
    init(_ binding: Binding<String>, enabled: Bool) {
        self.password = binding
        self.enabled = enabled
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Image(systemName: "key.fill")
                .frame(size: .StandardImageSize)
                .accentColor(Assets.darkGrey.color)
            SecureField("", text: password)
                .modifier(FixPlaceholder(for: password, text: "Password"))
                .disableAllAutocorrections()
                .foregroundColor(.accentColor)
                .modifier(RoundedTextFieldShape(.lightGrey))
                .padding(.bottom, 8)
                .disabled(!enabled)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PasswordField_Previews: PreviewProvider {
    
    @State static var emptyPassword: String = ""
    @State static var password: String = "#LookWhatYouMadeMeDo"
    
    static var previews: some View {
        Group {
            PasswordField($emptyPassword, enabled: true)
            PasswordField($password, enabled: true)
            PasswordField($password, enabled: false)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
