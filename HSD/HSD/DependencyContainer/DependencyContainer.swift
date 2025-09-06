//
//  DependencyContainer.swift
//  HSD
//
//  Created by Justin Lee on 9/6/25.
//

import Foundation
import NetworkService

class DependencyContainer {
    private let availableRideService: AvailableRidesServiceProtocol
    private let authService: AuthServiceProtocol
    
    init() {
        self.availableRideService = AvailableRidesService()
        self.authService = AuthService()
    }
    
    func makeAvailableRideService() -> AvailableRidesServiceProtocol {
        return availableRideService
    }
    
    func makeAuthService() -> AuthServiceProtocol {
        return authService
    }
}
