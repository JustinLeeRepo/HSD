//
//  UnauthorizedCoordinator.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Combine
import NetworkService
import SwiftUI

enum UnauthorizedEvent {
    case proceedToSignIn
}

@Observable
class UnauthorizedCoordinator {
    var path = NavigationPath()
    
    let unauthorizedViewModel: UnauthorizedViewModel
    
    private let unauthorizedEventPublisher: PassthroughSubject<UnauthorizedEvent, Never>
    private var cancellables = Set<AnyCancellable>()
    private let dependencyContainer: DependencyContainer
    
    init(dependencyContainer: DependencyContainer) {
        let unauthorizedEventPublisher = PassthroughSubject<UnauthorizedEvent, Never>()
        
        self.unauthorizedEventPublisher = unauthorizedEventPublisher
        self.unauthorizedViewModel = UnauthorizedViewModel( unauthorizedEventPublisher: unauthorizedEventPublisher, authService: dependencyContainer.makeAuthService())
        self.dependencyContainer = dependencyContainer
        
        setupListener()
    }
    
    private func setupListener() {
        unauthorizedEventPublisher
            .sink { [weak self] event in
                self?.handleNavigationEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func handleNavigationEvent(_ event: UnauthorizedEvent) {
        switch event {
        case .proceedToSignIn:
            let model = SignInModel()
            let viewModel = SignInViewModel(model: model, dependencyContainer: dependencyContainer)
            path.append(viewModel)
            break
        }
    }
}
