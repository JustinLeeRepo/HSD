//
//  RootCoordinator.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Combine
import SwiftUI

@Observable class RootCoordinator {
    var isAuthorized = false
    
    let unauthorizedCoordinator = UnauthorizedCoordinator()
    var authorizedCoordinator: AuthorizedCoordinator?
    
    private var authService = AuthService.shared
    private var currentUser = CurrentUser.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupListener()
    }
    
    private func setupListener() {
        //withObservationTracking only gets callback on first change
        currentUser.$user
            .sink { [weak self] user in
                guard let self = self else { return }
                self.isAuthorized = user != nil
                
                if let user = user {
                    Task { @MainActor in
                        self.authorizedCoordinator = AuthorizedCoordinator()
                    }
                }
                else {
                    Task { @MainActor in
                        self.authorizedCoordinator = nil
                    }
                }
            }
            .store(in: &cancellables)
    }
}
