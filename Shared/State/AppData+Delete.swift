//
//  AppData+Delete.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/5/22.
//

import Foundation

extension AppData {
    
    func deleteUserAccount() {
        guard let user = user, let apiKey = apiToken,
              let deleteUserAccountRequest = HTTPRequest.deleteUser(user.id, using: apiKey) else { return }
        
        Network.shared.perform(deleteUserAccountRequest, responseType: DeleteUserAPIResponse.self)
            .onUnauthorisedUserError(logout)
            .sinkReceivingError(onError: { error in
                AppEvents.shared.error = ErrorEvent(error)
            }, receiveValue: { [weak self] _ in
                self?.logout()
            })
            .store(in: &cancellables)
    }
}
