//
//  TwoColumnView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/5/21.
//

import SwiftUI

struct TwoColumnView<Content: View>: View {
    
    // MARK: Private Properties
    
    private var content: () -> Content
    
    // MARK: Init
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    // MARK: View
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8, pinnedViews: []) {
            content()
        }
    }
    
    // MARK: Column Setup
    
    private var columns: [GridItem] = [
        GridItem(.fixed(120), spacing: 0),
        GridItem(.flexible(minimum: 200, maximum: .infinity), spacing: 0)
    ]
}

// MARK: - Preview

#if DEBUG
struct TwoColumnView_Previews: PreviewProvider {
    static var previews: some View {
        TwoColumnView {
            Text("Hello")
            Text("Hello, too")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
