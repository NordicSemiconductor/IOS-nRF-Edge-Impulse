//
//  AppData+Delete.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/5/22.
//

import Foundation
import iOS_Common_Libraries

extension AppData {
    
    // MARK: - Project
    
    func deleteProject(_ project: Project, deliveryBlock: @escaping (Error?) -> Void) {
        guard let apiKey = apiToken,
              let deleteProjectRequest = HTTPRequest.deleteProject(project.id, using: apiKey) else { return }
        
        Network.shared.perform(deleteProjectRequest, responseType: DeleteUserAPIResponse.self)
            .onUnauthorisedUserError(logout)
            .sinkReceivingError(onError: { error in
                deliveryBlock(error)
            }, receiveValue: { _ in
                deliveryBlock(nil)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - User Account
    
    func deleteUserAccount() {
        guard let user = user, let apiKey = apiToken,
              let deleteUserAccountRequest = HTTPRequest.deleteUser(user.id, using: apiKey) else { return }
        
        var projectsToDelete = Set<Project>(projects)
        for project in projectsToDelete {
            deleteProject(project, deliveryBlock: { [weak self] in
                if let error = $0 {
                    AppEvents.shared.error = ErrorEvent(error)
                    return
                }
                
                projectsToDelete.remove(project)
                guard projectsToDelete.isEmpty, let self = self else { return }
                
                Network.shared.perform(deleteUserAccountRequest, responseType: DeleteUserAPIResponse.self)
                    .onUnauthorisedUserError(self.logout)
                    .sinkReceivingError(onError: { error in
                        AppEvents.shared.error = ErrorEvent(error)
                    }, receiveValue: { [weak self] _ in
                        self?.logout()
                    })
                    .store(in: &self.cancellables)
            })
        }
    }
}
