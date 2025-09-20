//
//  DependencyContainer.swift
//  HSD
//
//  Created by Justin Lee on 9/6/25.
//

import Foundation
import NetworkService

public class DependencyContainer {
    private let availableRideService: AvailableRidesServiceProtocol
    private let authService: AuthServiceProtocol
    
    public init() {
        self.availableRideService = AvailableRidesService()
        self.authService = AuthService()
    }
    
    public func makeAvailableRideService() -> AvailableRidesServiceProtocol {
        return availableRideService
    }
    
    public func makeAuthService() -> AuthServiceProtocol {
        return authService
    }
}
