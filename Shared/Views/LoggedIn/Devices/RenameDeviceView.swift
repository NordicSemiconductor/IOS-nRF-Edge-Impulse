//
//  RenameDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import SwiftUI
import Combine

// MARK: - RenameDeviceView

struct RenameDeviceView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: Properties
    
    var presentedDevice: Binding<RegisteredDevice?>
    @State private var newDeviceName: String
    @State private var viewState: ViewState
    
    @State private var cancellables: Set<AnyCancellable>
    
    // MARK: Init
    
    init(_ presentedDevice: Binding<RegisteredDevice?>, oldName: String,
         viewState: ViewState = .waitingForInput) {
        self.presentedDevice = presentedDevice
        self.viewState = viewState
        self.newDeviceName = oldName
        self.cancellables = Set<AnyCancellable>()
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Rename Device")
                .font(.headline)
            
            switch viewState {
            case .requestIsOngoing:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            case .success:
                Text("Success!")
                    .foregroundColor(.green)
                    .padding(4)
            default:
                TextField("", text: $newDeviceName)
                    .modifier(FixPlaceholder(for: $newDeviceName, text: "New Device Name"))
                    .disableAllAutocorrections()
                    .foregroundColor(.accentColor)
                    .modifier(RoundedTextFieldShape(.lightGrey))
                    .disabled(!textFieldEnabled)
                    .padding(4)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(Assets.red.color)
                    .padding(4)
            }
            
            Button("OK", action: buttonClicked)
                .disabled(!buttonEnabled)
        }
        .padding()
    }
    
    // MARK: Logic
    
    private var textFieldEnabled: Bool {
        switch viewState {
        case .waitingForInput:
            return true
        default:
            return false
        }
    }
    
    private var buttonEnabled: Bool {
        switch viewState {
        case .requestIsOngoing:
            return false
        default:
            return true
        }
    }
    
    private var errorMessage: String? {
        switch viewState {
        case .error(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

// MARK: - Private

internal extension RenameDeviceView {
    
    enum ViewState {
        case waitingForInput
        case requestIsOngoing
        case error(_ error: Error)
        case success
    }
}

fileprivate extension RenameDeviceView {
    
    func buttonClicked() {
        switch viewState {
        case .waitingForInput:
            attemptRename()
        case .requestIsOngoing:
            break
        case .error(_), .success:
            presentedDevice.wrappedValue = nil
        }
    }
    
    func attemptRename() {
        guard let device = presentedDevice.wrappedValue,
              let currentProject = appData.selectedProject,
              let apiKey = appData.apiToken,
              let renameRequest = HTTPRequest.renameDevice(device, as: newDeviceName,
                                                           in: currentProject, using: apiKey) else { return }
        
        viewState = .requestIsOngoing
        Network.shared.perform(renameRequest, responseType: RenameDeviceResponse.self)
            .sinkOrRaiseAppEventError(onError: { error in
                self.viewState = .error(error)
            }, receiveValue: { _ in
                self.viewState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    self.buttonClicked()
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - Preview

#if DEBUG
struct RenameDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenameDeviceView(.constant(RegisteredDevice.mock), oldName: RegisteredDevice.mock.deviceId)
            RenameDeviceView(.constant(RegisteredDevice.mock), oldName: RegisteredDevice.mock.deviceId, viewState: .requestIsOngoing)
            RenameDeviceView(.constant(RegisteredDevice.mock), oldName: RegisteredDevice.mock.deviceId, viewState: .error(NordicError.init(description: "A")))
            RenameDeviceView(.constant(RegisteredDevice.mock), oldName: RegisteredDevice.mock.deviceId, viewState: .success)
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(Preview.mockScannerData)
    }
}
#endif
