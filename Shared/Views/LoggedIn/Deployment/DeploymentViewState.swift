//
//  DeploymentViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import Combine

final class DeploymentViewState: ObservableObject {

    @Published var selectedDevice = Constant.unselectedDevice
    @Published var compiler: Compiler = .EON
    @Published var optimizationLevel: Optimization = .Quant
    @Published var progress = 0.0
    @Published var duration: Duration = .OneShot
}

// MARK: - DeploymentViewState.Compiler

extension DeploymentViewState {
    
    enum Compiler: String, RawRepresentable, CaseIterable {
        case EON
        
        var description: String {
            switch self {
            case .EON:
                return "EON"
            }
        }
    }
}

// MARK: - DeploymentViewState.Optimization

extension DeploymentViewState {
    
    enum Optimization: String, RawRepresentable, CaseIterable {
        case Quant
        
        var description: String {
            switch self {
            case .Quant:
                return "Quant"
            }
        }
    }
}

// MARK: - DeploymentViewState.Duration

extension DeploymentViewState {
    
    enum Duration: String, RawRepresentable, CaseIterable {
        case OneShot
        case Continuous
        
        var description: String {
            switch self {
            case .OneShot:
                return "One Shot"
            case .Continuous:
                return "Continuous"
            }
        }
    }
}
