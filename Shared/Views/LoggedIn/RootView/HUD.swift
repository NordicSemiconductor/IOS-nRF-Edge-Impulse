//
//  HUD.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 07/07/2021.
//

import SwiftUI

struct HUD<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding()
            .background(
                Capsule()
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .shadow(radius: 12, x: 0, y: 5)
            )
    }
}

struct HUD_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) {
                HUD {
                    Label("Copied", systemImage: "doc.on.doc")
                }
                .previewLayout(PreviewLayout.sizeThatFits)
                .preferredColorScheme($0)
                .padding()
            }
        }
    }
}
