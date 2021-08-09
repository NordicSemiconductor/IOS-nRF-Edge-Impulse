//
//  TextHeader.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 04/08/2021.
//

import SwiftUI

struct TextHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Label(title.uppercased(), image: "")
            Spacer()
        }
        .background(Color.secondarySystemBackground.frame(height: 32))
           
    }
}

#if DEBUG
struct TextHeader_Previews: PreviewProvider {
    static var previews: some View {
        ElementPreview(TextHeader(title: "Custom Header"))
    }
}
#endif
