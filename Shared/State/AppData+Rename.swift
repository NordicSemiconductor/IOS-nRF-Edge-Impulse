//
//  AppData+Rename.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/12/21.
//

import Foundation
import iOS_Common_Libraries

extension AppData {
    
    func renameDevice(_ device: Device, to newName: String, onSuccess: @escaping () -> Void) {
        guard let currentProject = selectedProject, let apiKey = apiToken,
              let renameRequest = HTTPRequest.renameDevice(device, as: newName,
                                                           in: currentProject, using: apiKey) else { return }
        
        Network.shared.perform(renameRequest, responseType: RenameDeviceResponse.self)
            .sinkReceivingError(onError: { error in
                AppEvents.shared.error = ErrorEvent(error)
            }, receiveValue: { _ in
                onSuccess()
            })
            .store(in: &cancellables)
    }
}
