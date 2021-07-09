//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        VStack {
            Form {
            switch viewState.status {
                case .buildingModel(_), .error(_):
                    Section(header: Text("Logs")) {
                        ScrollViewReader { reader in
                            List {
                                ForEach(viewState.jobMessages) { message in
                                    Text(message.message)
                                }
                                .onReceive(viewState.$jobMessages, perform: { _ in
                                    guard let last = viewState.jobMessages.last else { return }
                                    withAnimation {
                                        reader.scrollTo(last, anchor: .bottom)
                                    }
                                })
                            }
                        }
                    }
                default:
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
            }
            .padding(.vertical)
            
            Form {
                ProgressView(value: viewState.progress, total: 100.0)
                viewState.status.view
                switch viewState.status {
                case .error(_):
                    Button("Retry", action: retry)
                        .centerTextInsideForm()
                        .foregroundColor(.primary)
                default:
                    Button("Build", action: attemptToBuild)
                        .centerTextInsideForm()
                        .foregroundColor(viewState.buildButtonEnable ? .primary : Assets.middleGrey.color)
                        .disabled(!viewState.buildButtonEnable)
                }
            }
            .introspectTableView { tableView in
                tableView.isScrollEnabled = false
            }
            .frame(height: 200)
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
