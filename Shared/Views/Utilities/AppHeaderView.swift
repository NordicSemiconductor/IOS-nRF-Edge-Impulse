//
//  AppHeaderView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/4/21.
//

import SwiftUI

struct AppHeaderView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    private let renderingMode: Image.TemplateRenderingMode
    
    private let templateColor = Color.white
    
    // MARK: Init
    
    init(_ mode: Image.TemplateRenderingMode = .original) {
        renderingMode = mode
    }
    
    // MARK: body
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("Nordic")
                .resizable()
                .renderingMode(colorScheme == .light ? renderingMode : .template)
                .foregroundColor(templateColor)
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
            
            Divider()
                .foregroundColor(.white)
                .frame(width: 2, height: 60)
                .padding(.leading, 12)
            
            Image("EdgeImpulse")
                .resizable()
                .renderingMode(colorScheme == .light ? renderingMode : .template)
                .foregroundColor(templateColor)
                .aspectRatio(contentMode: .fit)
                .frame(height: 90)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AppHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppHeaderView()
            AppHeaderView(.template)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
