//
//  AppData+Debug.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 14/5/21.
//

import Foundation

#if DEBUG
extension AppData {
    
    func raiseTestError() {
        AppEvents.shared.error = ErrorEvent(title: "Test Error", localizedDescription: "This is to test whether Error Alerts are handled well by \(Constant.appName).")
    }
}
#endif
