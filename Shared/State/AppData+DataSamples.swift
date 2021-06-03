//
//  AppData+DataSamples.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/5/21.
//

import Foundation

// MARK: - Public API

extension AppData {
    
    func requestDataSamples() {
        guard let selectedProject = selectedProject, selectedProject != Project.Unselected else { return }
        for category in DataSample.Category.allCases {
            requestDataSamples(for: category)
        }
    }
    
    func requestNewSampleID(project: Project, configuration: DataAcquisitionViewState, deliveryBlock: @escaping (StartSamplingResponse?, Error?) -> Void) {
        let sampleMessage = configuration.newSampleMessage()
        guard let startRequest = HTTPRequest.startSampling(sampleMessage, project: project, device: configuration.selectedDevice) else { return }
        
        Network.shared.perform(startRequest, responseType: StartSamplingResponse.self)
            .onUnauthorisedUserError(logout)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    deliveryBlock(nil, error)
                default:
                    break
                }
            }, receiveValue: { response in
                deliveryBlock(response, nil)
            })
            .store(in: &cancellables)
    }
}

// MARK: - Private

private extension AppData {
    
    private func requestDataSamples(for category: DataSample.Category) {
        guard let currentProject = selectedProject,
              let projectApiKey = projectDevelopmentKeys[currentProject]?.apiKey,
              let httpRequest = HTTPRequest.getSamples(for: currentProject, in: category, using: projectApiKey) else {
            requestProjectDevelopmentKeys()
            return
        }
        
        Network.shared.perform(httpRequest, responseType: GetSamplesResponse.self)
            .onUnauthorisedUserError(logout)
            .sinkOrRaiseAppEventError { [weak self] samplesResponse in
                self?.samplesForCategory[category] = samplesResponse.samples
            }
            .store(in: &cancellables)
    }
    
    private func requestProjectDevelopmentKeys() {
        guard let currentProject = selectedProject, let token = apiToken,
              let httpRequest = HTTPRequest.getProjectDevelopmentKeys(for: currentProject, using: token) else {
            // TODO: Error
            return
        }
        
        Network.shared.perform(httpRequest, responseType: ProjectDevelopmentKeysResponse.self)
            .onUnauthorisedUserError(logout)
            .sinkOrRaiseAppEventError { [weak self] projectKeysResponse in
                guard let self = self, let currentProject = self.selectedProject else {
                    // TODO: No Selected Project Error.
                    return
                }
                self.projectDevelopmentKeys[currentProject] = projectKeysResponse
                self.requestDataSamples()
            }
            .store(in: &cancellables)
    }
}
