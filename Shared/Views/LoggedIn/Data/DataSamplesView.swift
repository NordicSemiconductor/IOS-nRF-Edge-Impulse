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
    
    @ObservedObject var viewState = DataSamplesViewState()
    
    @State private var cancellables = Set<AnyCancellable>()
    
    // MARK: View
    
    var body: some View {
        VStack {
            Section(header: Text("Category")) {
                Picker("Selected", selection: $viewState.selectedCategory) {
                    ForEach(DataSample.Category.allCases) { dataType in
                        Text(dataType.rawValue)
                            .tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Collected Samples")) {
                List {
                    ForEach(viewState.samples) { sample in
                        Text(sample.filename)
                    }
                }
            }
        }
        .padding(.vertical)
        .onAppear() {
            guard !Constant.isRunningInPreviewMode else { return }
            // User might change the Project, so onAppear is a good bet.
            requestDataSamples(for: viewState.selectedCategory)
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
    
    func requestDataSamples(for category: DataSample.Category) {
        viewState.samples = []
        guard let currentProject = appData.selectedProject,
              let projectApiKey = appData.projectDevelopmentKeys[currentProject]?.apiKey,
              let httpRequest = HTTPRequest.getSamples(for: currentProject, in: category, using: projectApiKey) else {
            requestProjectDevelopmentKeys()
            return
        }
        
        Network.shared.perform(httpRequest, responseType: GetSamplesResponse.self)
            .onUnauthorisedUserError(appData.logout)
            .sinkOrRaiseAppEventError { samplesResponse in
                viewState.samples = samplesResponse.samples
            }
            .store(in: &cancellables)
    }
    
    func requestProjectDevelopmentKeys() {
        guard let currentProject = appData.selectedProject, let token = appData.apiToken,
              let httpRequest = HTTPRequest.getProjectDevelopmentKeys(for: currentProject, using: token) else {
            // TODO: Error
            return
        }
        
        Network.shared.perform(httpRequest, responseType: ProjectDevelopmentKeysResponse.self)
            .onUnauthorisedUserError(appData.logout)
            .sinkOrRaiseAppEventError { projectKeysResponse in
                guard let currentProject = appData.selectedProject else {
                    // TODO: No Selected Project Error.
                    return
                }
                appData.projectDevelopmentKeys[currentProject] = projectKeysResponse
                requestDataSamples(for: viewState.selectedCategory)
            }
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
