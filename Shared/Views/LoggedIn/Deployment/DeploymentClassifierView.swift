//
//  DeploymentClassifierView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/12/21.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - DeploymentClassifierView

struct DeploymentClassifierView: View {
    
    private let classifier: DeploymentViewState.Classifier
    
    // MARK: Init
    
    init(_ classifier: DeploymentViewState.Classifier) {
        self.classifier = classifier
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            Text(classifier.rawValue)
                .font(.body)
                .foregroundColor(Assets.textColor.color)
            
            Text(classifier.userDescription)
                .font(.callout)
                .foregroundColor(.nordicMiddleGrey)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentClassifierView_Previews: PreviewProvider {
    
    @State static var optimization: DeploymentViewState.Classifier = .Default
    
    static var previews: some View {
        Picker(selection: DeploymentClassifierView_Previews.$optimization, label: EmptyView()) {
            ForEach(DeploymentViewState.Classifier.allCases, id: \.self) { classifier in
                DeploymentClassifierView(classifier)
                    .tag(classifier)
            }
        }
    }
}
#endif
