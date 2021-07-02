//
//  DeploymentViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import Combine

final class DeploymentViewState: ObservableObject {

    @Published var selectedDevice = Constant.unselectedDevice
    @Published var progress = 0.0
    @Published var enableEONCompiler = true
    @Published var optimization: Classifier = .Quantized
}

// MARK: - API

extension DeploymentViewState {
    
    func build() {
        
    }
}

// MARK: - DeploymentViewState.Duration

extension DeploymentViewState {
    
    enum Classifier: String, RawRepresentable, CaseIterable {
        case Quantized
        case Unoptimized
    }
}
