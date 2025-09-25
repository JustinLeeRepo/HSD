//
//  SignOutViewModel.swift
//  
//
//  Created by Justin Lee on 9/23/25.
//

import DependencyContainer
import NetworkService
import SharedUI
import SwiftUI

@Observable
class SignOutViewModel {
    let errorViewModel: ErrorViewModel
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.errorViewModel = ErrorViewModel()
        self.authService = authService
    }
    
    func signOut() async {
        do {
            try await authService.signOut()
        }
        catch {
            Task { @MainActor in
                self.errorViewModel.error = error
            }
        }
    }
}
