//
//  UnauthorizedCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import SwiftUI

struct UnauthorizedCoordinatorView: View {
    @Bindable var coordinator: UnauthorizedCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            UnauthorizedView(viewModel: coordinator.unauthorizedViewModel)
                .navigationDestination(for: SignInViewModel.self) { viewModel in
                    SignInView(viewModel: viewModel)
                }
        }
    }
}

#Preview {
    let coordinator = UnauthorizedCoordinator()
    return UnauthorizedCoordinatorView(coordinator: coordinator)
}
