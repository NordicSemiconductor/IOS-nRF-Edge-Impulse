//
//  DataSamplesView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import SwiftUI
import Combine

struct DataSamplesView: View {
    
    @EnvironmentObject var appData: AppData
    @State private var cancellables = Set<AnyCancellable>()
    
    // MARK: View
    
    var body: some View {
        Text("Hello, World!")
            .onAppear() {
                guard !Constant.isRunningInPreviewMode else { return }
                // User might change the Project, so onAppear is a good bet.
                requestDataSamples()
            }
            .onDisappear() {
                cancellables.forEach {
                    $0.cancel()
                }
                cancellables.removeAll()
            }
    }
}

extension DataSamplesView {
    
    func requestDataSamples() {
        guard let currentProject = appData.selectedProject,
              let projectApiKey = appData.projectDevelopmentKeys[currentProject]?.apiKey,
              let httpRequest = HTTPRequest.getSamples(for: currentProject, in: .training, using: projectApiKey) else {
            requestProjectDevelopmentKeys()
            return
        }
        
        Network.shared.perform(httpRequest, responseType: GetSamplesResponse.self)
            .onUnauthorisedUserError(appData.logout)
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    AppEvents.shared.error = ErrorEvent(error)
                default:
                    break
                }
            },
            receiveValue: { samplesResponse in
                guard samplesResponse.success else {
                    let errorMessage = samplesResponse.error ?? "Hello"
                    AppEvents.shared.error = ErrorEvent(title: "Samples Request", localizedDescription: errorMessage)
                    return
                }
            })
            .store(in: &cancellables)
    }
    
    func requestProjectDevelopmentKeys() {
        guard let currentProject = appData.selectedProject,
              let token = appData.apiToken,
              let httpRequest = HTTPRequest.getProjectDevelopmentKeys(for: currentProject, using: token) else {
            // TODO: Error
            return
        }
        
        Network.shared.perform(httpRequest, responseType: ProjectDevelopmentKeysResponse.self)
            .onUnauthorisedUserError(appData.logout)
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    AppEvents.shared.error = ErrorEvent(error)
                default:
                    break
                }
            },
            receiveValue: { projectKeysResponse in
                guard projectKeysResponse.success else {
                    let errorMessage = projectKeysResponse.error ?? "Hello"
                    AppEvents.shared.error = ErrorEvent(title: "Samples Request", localizedDescription: errorMessage)
                    return
                }
                
                guard let currentProject = appData.selectedProject else { return }
                appData.projectDevelopmentKeys[currentProject] = projectKeysResponse
                requestDataSamples()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Preview

#if DEBUG
struct DataSamplesView_Previews: PreviewProvider {
    static var previews: some View {
        DataSamplesView()
    }
}
#endif
