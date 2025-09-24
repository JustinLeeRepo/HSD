//
//  AuthorizedCoordinator.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import DependencyContainer
import Foundation
import SharedUI

@Observable 
public class AuthorizedCoordinator {
    enum Tab: UInt {
        case first
        case second
        case third
        case fourth
    }
    
    var tab: Tab = .first
    
    let availablePickUpCoordinator: AvailablePickUpCoordinator
    let signOutViewModel: SignOutViewModel
    private var cancellables = Set<AnyCancellable>()
    
    public init(dependencyContainer: DependencyContainable) {
        self.availablePickUpCoordinator = AvailablePickUpCoordinator(dependencyContainer: dependencyContainer)
        self.signOutViewModel = SignOutViewModel(authService: dependencyContainer.makeAuthService())
    }
}
