//
//  String.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/2/21.
//

import Foundation

extension String {
    
    func isEmailAddress() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}
