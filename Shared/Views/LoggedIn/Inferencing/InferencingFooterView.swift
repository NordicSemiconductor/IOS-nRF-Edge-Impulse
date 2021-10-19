//
//  InferencingFooterView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/10/21.
//

import SwiftUI

// MARK: - InferencingFooterView

struct InferencingFooterView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var viewState: InferencingViewState
    
    // MARK: View
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("\(viewState.results.count) Results")
                .font(.footnote)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct InferencingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InferencingFooterView()
                .environmentObject(InferencingViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
