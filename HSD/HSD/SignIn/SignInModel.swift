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

// TODO: remove this when auth service and auth service error is created
enum SignInError: Error {
    case noAuthService
}

extension SignInError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noAuthService:
            return NSLocalizedString("Auth service must be implemented.", comment: "My error")
        }
    }
}

