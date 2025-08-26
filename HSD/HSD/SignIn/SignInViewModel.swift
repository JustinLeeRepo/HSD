//
//  SignInViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import SwiftUI

@Observable
class SignInViewModel {
    var model: SignInModel
    var error: Error?
    
    private let authService = AuthService.shared
    
    init(model: SignInModel) {
        self.model = model
    }
    
    var isUsernameEmpty: Bool {
        usernameText.isEmpty
    }
    
    var isPasswordEmpty: Bool {
        passwordText.isEmpty
    }
    
    var usernameText: String {
        get {
            model.usernameText
        }
        set {
            withAnimation {
                model.usernameText = newValue
            }
        }
    }
    
    var passwordText: String {
        get {
            model.passwordText
        }
        set {
            withAnimation {
                model.passwordText = newValue
            }
        }
    }
    
    var buttonTitle: String {
        model.buttonTitle
    }
    
    func clearUsername() {
        usernameText = ""
    }
    
    func clearPassword() {
        passwordText = ""
    }
    
    var isProceedButtonDisabled: Bool {
        return isUsernameEmpty || isPasswordEmpty
    }
    
    func proceed(dismiss: @escaping () -> Void = {} ) {
        Task {
            do {
                // TODO: create auth service and sign in api
                try await authService.signIn(username: usernameText, password: passwordText)
                
                dismiss()
                Task { @MainActor in
                    self.error = nil
                }
            }
            catch {
                Task { @MainActor in
                    self.error = error
                }
            }
        }
    }
}

extension SignInViewModel: Hashable {
    static func == (lhs: SignInViewModel, rhs: SignInViewModel) -> Bool {
        lhs.model == rhs.model
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(model)
    }
}
