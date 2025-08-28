//
//  UnauthorizedViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Combine
import SwiftUI

@Observable class UnauthorizedViewModel {
    var isLoading = false
    var error: Error?
    
    private let unauthorizedEventPublisher: PassthroughSubject<UnauthorizedEvent, Never>
    private let authService = AuthService.shared
    
    init(unauthorizedEventPublisher: PassthroughSubject<UnauthorizedEvent, Never>) {
        self.unauthorizedEventPublisher = unauthorizedEventPublisher
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
                self.error = error
            }
        }
    }
}
