//
//  AuthorizedCoordinator.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import DependencyContainer
import Foundation
import NetworkService

@Observable 
public class AuthorizedCoordinator {
    enum Tab: UInt {
        case first
        case second
        case third
        case fourth
    }
    
    var tab: Tab = .first
    private(set) var error: Error?
    
    let availablePickUpCoordinator: AvailablePickUpCoordinator
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol
    
    public init(dependencyContainer: DependencyContainer) {
        self.availablePickUpCoordinator = AvailablePickUpCoordinator(dependencyContainer: dependencyContainer)
        self.authService = dependencyContainer.makeAuthService()
    }
    
    func signOut() async {
        do {
            try await authService.signOut()
        }
        catch {
            Task { @MainActor in
                self.error = error
            }
        }
    }
}
