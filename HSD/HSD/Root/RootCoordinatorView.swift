//
//  RootCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Authorized
import DependencyContainer
import SwiftUI
import Unauthorized

struct RootCoordinatorView: View {
    var coordinator: RootCoordinator
    
    var body: some View {
        if coordinator.isAuthorized,
           let authorizedCoordinator = coordinator.authorizedCoordinator {
            AuthorizedCoordinatorView(coordinator: authorizedCoordinator)
        }
        else {
            UnauthorizedCoordinatorView(coordinator: coordinator.unauthorizedCoordinator)
        }
    }
}

#Preview {
    let dependencyContainer = DependencyContainer()
    let coordinator = RootCoordinator(dependencyContainer: dependencyContainer)
    return RootCoordinatorView(coordinator: coordinator)
}
