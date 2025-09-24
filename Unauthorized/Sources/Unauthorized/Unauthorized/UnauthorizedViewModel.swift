//
//  UnauthorizedViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Combine
import NetworkService
import SharedUI
import SwiftUI

@Observable class UnauthorizedViewModel {
    var isLoading = false
    var errorViewModel: ErrorViewModel
    
    private let unauthorizedEventPublisher: PassthroughSubject<UnauthorizedEvent, Never>
    private let authService: AuthServiceProtocol
    
    init(unauthorizedEventPublisher: PassthroughSubject<UnauthorizedEvent, Never>,
         authService: AuthServiceProtocol) {
        self.unauthorizedEventPublisher = unauthorizedEventPublisher
        self.authService = authService
        self.errorViewModel = ErrorViewModel()
    }
    
    func proceedToSignIn() {
        unauthorizedEventPublisher.send(.proceedToSignIn)
    }
    
    func expressSignIn() async {
        Task { @MainActor in
            withAnimation {
                isLoading = true
            }
        }
        
        do {
            try await authService.expressSignIn()
            
            Task {@MainActor in
                withAnimation {
                    self.isLoading = false
                }
            }
        }
        catch {
            Task { @MainActor in
                withAnimation {
                    self.isLoading = false
                }
                self.errorViewModel.error = error
            }
        }
    }
}
