//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI
import Combine

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        VStack {
            switch viewState.status {
                case .buildingModel(_), .error(_):
                    List {
                        ForEach(viewState.jobMessages) { message in
                            Text(message.message)
                        }
                    }
                    .introspectTableView { tableView in
                        viewState.jobMessages.publisher
                            .debounce(for: 50, scheduler: DispatchQueue.main)
                            .collect()
                            .sink { [weak tableView] _ in
                                guard let tableView = tableView, let dataSource = tableView.dataSource, let sections = dataSource.numberOfSections?(in: tableView), sections > 0 else { return }
                                let indexPath = IndexPath(row: viewState.jobMessages.count - 1, section: 0)
                                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                            }
                            .store(in: &viewState.cancellables)
                    }
                    .padding(.top)
                default:
                    Form {
                    Section(header: Text("Device")) {
                        let connectedDevices = deviceData.allConnectedAndReadyToUseDevices()
                        if connectedDevices.hasItems {
                            Picker("Selected", selection: $viewState.selectedDevice) {
                                ForEach(connectedDevices, id: \.self) { handler in
                                    Text(handler.device.name)
                                        .tag(handler.device)
                                }
                            }
                            .setAsComboBoxStyle()
                            .onAppear() {
                                viewState.selectedDevice = deviceData.allConnectedAndReadyToUseDevices().first?.device ?? Constant.unselectedDevice
                            }
                        } else {
                            Text("No Devices Scanned.")
                                .foregroundColor(Assets.middleGrey.color)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Section(header: Text("Optimizations")) {
                        Toggle(isOn: $viewState.enableEONCompiler, label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable EON™ Compiler")
                                Text("Same accuracy, up to 50% less memory. Open source.")
                                    .font(.caption)
                                    .foregroundColor(Assets.middleGrey.color)
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
                    }
                    
                    Section(header: Text("Classifier")) {
                        Picker("Classifier", selection: $viewState.optimization) {
                            ForEach(DeploymentViewState.Classifier.allCases, id: \.self) { classifier in
                                Text(classifier.rawValue).tag(classifier)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("\(DeploymentViewState.Classifier.Quantized.rawValue) is recommended for best performance. ")
                            .font(.caption)
                            .foregroundColor(Assets.middleGrey.color)
                    }
                }
                    .padding(.bottom)
            }
            
            DeploymentViewProgressView(retryAction: retry, buildAction: attemptToBuild)
                .environmentObject(viewState)
        }
        .background(Color.formBackground)
        .onAppear() {
            attemptToConnect()
        }
    }
}

// MARK: - Logic

fileprivate extension DeploymentView {
    
    func attemptToBuild() {
        guard let currentProject = appData.selectedProject,
              let apiToken = appData.apiToken else { return }
        viewState.sendBuildRequest(for: currentProject, using: apiToken) { [self] response, error in
            guard let response = response else {
                if let error = error {
                    self.viewState.status = .error(error)
                }
                return
            }
            self.viewState.status = .buildingModel(response.id)
        }
    }
    
    func retry() {
        viewState.status = .idle
        attemptToConnect()
    }
    
    func attemptToConnect() {
        guard viewState.isReadyToConnect,
              let currentProject = appData.selectedProject,
              let socketToken = appData.projectSocketTokens[currentProject] else {
            // TODO: Error: Token missing.
            return
        }
        viewState.connect(using: socketToken)
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DeploymentView()
                .setTitle(Tabs.Deployment.description)
                .wrapInNavigationViewForiOS()
                .environmentObject(Preview.noDevicesAppData)
                .environmentObject(Preview.noDevicesScannerData)    
        }
    }
}
#endif
