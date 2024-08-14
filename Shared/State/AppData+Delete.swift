//
//  AppData+Delete.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/5/22.
//

import Foundation
import iOS_Common_Libraries

extension AppData {
    
    // MARK: - User Account
    
    func deleteUserAccount(with password: String, and totpToken: String?) {
        let parameters = DeleteUserParameters(password: password, totpToken: totpToken)
        guard let apiToken,
              let deleteUserAccountRequest = HTTPRequest.deleteUser(with: parameters, using: apiToken) else { return }
        
        Network.shared.perform(deleteUserAccountRequest, responseType: DeleteUserAPIResponse.self)
            .onUnauthorisedUserError(logout)
            .sinkReceivingError(onError: { error in
                AppEvents.shared.error = ErrorEvent(error)
            }, receiveValue: { [weak self] _ in
                self?.logout()
            })
            .store(in: &self.cancellables)
    }
}
