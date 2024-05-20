//
//  TextFieldAlertView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import SwiftUI
import Combine
import OSLog
import iOS_Common_Libraries

// MARK: - TextFieldAlertView

struct TextFieldAlertView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: Properties
    
    private let title: String
    private let message: String
    private var text: Binding<String>
    private var isShowing: Binding<Bool>
    private let onPositiveAction: () -> Void
    
    // MARK: Init
    
    init(title: String, message: String, text: Binding<String>, isShowing: Binding<Bool>,
         onPositiveAction: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.text = text
        self.isShowing = isShowing
        self.onPositiveAction = onPositiveAction
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .foregroundColor(Assets.textColor.color)
                .font(.headline)
            
            TextField(message, text: text)
                .disableAllAutocorrections()
                .foregroundColor(.textFieldColor)
                .modifier(RoundedTextFieldShape(.nordicLightGrey))
                .frame(maxWidth: 300)
                .padding(4)
            
            AlertButtonsView(okFunction: okButton, cancelFunction: dismiss)
        }
        .padding()
        .frame(width: 350)
        .background(Color.secondarySystemBackground)
    }
}

// MARK: - Private

fileprivate extension TextFieldAlertView {
    
    func okButton() {
        onPositiveAction()
        dismiss()
    }
    
    func dismiss() {
        isShowing.wrappedValue = false
    }
}

// MARK: - Preview

#if DEBUG
//struct TextFieldAlertView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            RenameDeviceView(.constant(Device.connectableMock))
//            RenameDeviceView(.constant(Device.connectableMock), viewState: .requestIsOngoing)
//            RenameDeviceView(.constant(Device.connectableMock), viewState: .error(NordicError.init(description: "A")))
//            RenameDeviceView(.constant(Device.connectableMock), viewState: .success)
//        }
//        .previewLayout(.sizeThatFits)
//        .environmentObject(Preview.mockScannerData)
//        .environmentObject(Preview.mockScannerData)
//    }
//}
#endif
