//
//  ElementPreview.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 22/07/2021.
//

import SwiftUI

struct ElementPreview<Value: View>: View {

    private let viewToPreview: Value

    init(_ viewToPreview: Value) {
        self.viewToPreview = viewToPreview
    }

    var body: some View {
        Group {
            self.viewToPreview
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .previewDisplayName("Default preview 1")
            
            #if os(iOS)
                let color = Color(.systemBackground)
            #else
                let color = Color.secondary
            #endif
            
            self.viewToPreview
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(color)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")

            ForEach(ContentSizeCategory.allCases, id: \.self) { sizeCategory in
                self.viewToPreview
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .environment(\.sizeCategory, sizeCategory)
                    .previewDisplayName("\(sizeCategory)")
            }
        }
        
    }
    
}
