//
//  LoginModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/12.
//

import Foundation

class LoginModel {
    var email: String
    var pswd: String
    var loginValid: Bool {
        return emailValidCheck() && pswdValidCheck()
    }
    
    init() {
        email = ""
        pswd = ""
    }
    
    init (email: String, pswd: String) {
        self.email = email
        self.pswd = pswd
    }
    
    private func emailValidCheck() -> Bool {
        return email.count >= 3 && email.contains("@") && email.contains(".")
    }
    
    private func pswdValidCheck() -> Bool {
        return pswd.count >= 4
    }
    
}

enum RegisterSubView: Int {
    case login = -1
    case idSet = 0
    case nameSet = 1
    case imgSet = 2
    case complete = 3
}
