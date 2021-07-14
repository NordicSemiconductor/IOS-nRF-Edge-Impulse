//
//  FormIniOSListInMacOS.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import SwiftUI

struct FormIniOSListInMacOS<Content: View>: View {
    
    // MARK: Private Properties
    
    var content: () -> Content
    
    // MARK: Init
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    // MARK: View
    
    #if os(iOS)
    var body: some View {
        Form {
            content()
        }
    }
    #elseif os(OSX)
    var body: some View {
        List {
            content()
        }
    }
    #endif
}
