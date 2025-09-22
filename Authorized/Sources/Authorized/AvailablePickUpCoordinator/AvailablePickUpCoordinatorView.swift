//
//  AvailablePickUpCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import DependencyContainer
import SwiftUI

struct AvailablePickUpCoordinatorView: View {
    
    @Bindable var coordinator: AvailablePickUpCoordinator
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            AvailablePickUpView(viewModel: coordinator.availablePickUpViewModel)
                .navigationDestination(for: AvailablePickUpDetailViewModel.self) { viewModel in
                    AvailablePickUpDetailView(viewModel: viewModel)
                }
        }
    }
}

#Preview {
    let dependencyContainer = DependencyContainer()
    let coordinator = AvailablePickUpCoordinator(dependencyContainer: dependencyContainer)
    return AvailablePickUpCoordinatorView(coordinator: coordinator)
}
