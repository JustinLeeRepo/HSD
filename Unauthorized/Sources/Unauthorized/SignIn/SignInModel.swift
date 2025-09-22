//
//  SignInModel.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Foundation

struct SignInModel: Hashable {
    var usernameText: String = ""
    var passwordText: String = ""
    
    var isUsernameEmpty: Bool = true
    var isPasswordEmpty: Bool = true
    
    var buttonTitle: String {
        "Sign In"
    }
}

