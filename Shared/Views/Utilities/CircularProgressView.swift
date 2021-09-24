//
//  CircularProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 24/9/21.
//

import SwiftUI

struct CircularProgressView: View {
    
    #if os(iOS)
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .frame(width: 20, height: 20)
    }
    #endif
    
    #if os(macOS)
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(0.5, anchor: .center)
    }
    #endif
}

#if DEBUG
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView()
    }
}
#endif
