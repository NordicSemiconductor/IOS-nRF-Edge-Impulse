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
            
            if viewState.results.isEmpty {
                Text("No Results Available yet.")
                    .foregroundColor(Assets.middleGrey.color)
            } else if viewState.results.count == 1 {
                Text("1 Result")
            } else {
                Text("\(viewState.results.count) Results")
            }
            
            Spacer()
        }
        .font(.footnote)
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct InferencingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InferencingFooterView()
                .environmentObject(InferencingViewState())
            InferencingFooterView()
                .environmentObject(Preview.projectsPreviewAppData.inferencingViewState)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
