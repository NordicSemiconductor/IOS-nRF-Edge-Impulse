//
//  AppData+Deployment.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/7/21.
//

import Foundation
import iOS_Common_Libraries

extension AppData {
    
    func requestSelectedProjectSocketToken() {
        guard let currentProject = selectedProject, let apiKey = projectDevelopmentKeys[currentProject]?.apiKey,
              let tokenRequest = HTTPRequest.getSocketToken(for: currentProject, using: apiKey) else { return }

        Network.shared.perform(tokenRequest, responseType: GetSocketTokenResponse.self)
            .onUnauthorisedUserError(logout)
            .sinkOrRaiseAppEventError { [weak self] response in
                self?.projectSocketTokens[currentProject] = response.token
            }
            .store(in: &cancellables)
    }
}
