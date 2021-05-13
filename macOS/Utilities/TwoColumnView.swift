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
    private let columns: [GridItem]
    
    // MARK: Init
    
    init(columns: [GridItem] = DefaultColumns, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.columns = columns
    }
    
    // MARK: View
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8, pinnedViews: []) {
            content()
        }
    }
}

// MARK: Default Columns

fileprivate var DefaultColumns: [GridItem] = [
    GridItem(.fixed(120), spacing: 0),
    GridItem(.flexible(minimum: 200, maximum: .infinity), spacing: 0)
]

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
