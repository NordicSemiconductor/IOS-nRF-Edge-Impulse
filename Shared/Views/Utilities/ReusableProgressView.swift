//
//  ReusableProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/8/21.
//

import SwiftUI
import Combine

// MARK: - ReusableProgressView

struct ReusableProgressView: View {
    
    // MARK: Properties
    
    var progress: Binding<Double>
    var isIndeterminate: Binding<Bool>
    
    var statusText: Binding<String>
    var statusColor: Binding<Color>
    
    @State var buttonText = "Button"
    var buttonEnabled: Binding<Bool>
    
    let buttonAction: () -> ()
    
    // MARK: View
    
    // MARK: Helpers
    
    var connectionStatusTopPadding: CGFloat {
        #if os(macOS)
        return 0
        #else
        return 16
        #endif
    }
    
    var buttonTopPadding: CGFloat {
        #if os(macOS)
        return 0
        #else
        return 8
        #endif
    }
    
    var body: some View {
        VStack {
            #if os(OSX)
            NSProgressView(value: progress.projectedValue, maxValue: 100.0,
                           isIndeterminate: isIndeterminate.wrappedValue)
                .padding(.horizontal)
            #else
            ProgressView(value: progress.wrappedValue, total: 100.0)
                .padding(.top, 4)
                .padding(.horizontal)
            #endif
            
            HStack {
                ConnectionStatus(color: statusColor.wrappedValue)
                Text(statusText.wrappedValue.uppercasingFirst)
                    .lineLimit(1)
            }
            .padding(.top, connectionStatusTopPadding)
            
            #if os(OSX)
            Button(buttonText, action: buttonAction)
                .padding(.top, buttonTopPadding)
                .disabled(!buttonEnabled.wrappedValue)
            #else
            Button(buttonText, action: buttonAction)
                .foregroundColor(buttonEnabled.wrappedValue ? .textColor : .disabledTextColor)
                .padding(.top, buttonTopPadding)
                .disabled(!buttonEnabled.wrappedValue)
            #endif
        }
        .padding(.vertical)
    }
}

// MARK: - Preview

#if DEBUG
//struct ReusableProgressView_Previews: PreviewProvider {
//    
//    static var noOp: () -> () = { }
//    
//    static var previews: some View {
//        ReusableProgressView(buttonAction: noOp)
//    }
//}
#endif
