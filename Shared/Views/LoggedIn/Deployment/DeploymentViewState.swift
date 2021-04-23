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
    @Published var duration: Duration = .OneShot
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
