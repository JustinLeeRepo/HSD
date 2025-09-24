//
//  AuthorizedCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import DependencyContainer
import SharedUI
import SwiftUI

public struct AuthorizedCoordinatorView: View {
    typealias Tab = AuthorizedCoordinator.Tab
    @Bindable var coordinator: AuthorizedCoordinator
    
    public init(coordinator: AuthorizedCoordinator) {
        self.coordinator = coordinator
    }
    
    public var body: some View {
        TabView(selection: $coordinator.tab) {
            AvailablePickUpCoordinatorView(coordinator: coordinator.availablePickUpCoordinator)
                .tabItem {
                    generateLabel(title: "Available Rides", image: "dog")
                }
                .tag(Tab.first)
            
            SignOutView(viewModel: coordinator.signOutViewModel)
                .tabItem {
                    generateLabel(title: "Account", image: "cat")
                }
                .tag(Tab.second)
        }
    }
    
    private func generateLabel(title: String, image: String) -> some View {
        Label {
            Text(title)
                .tabLabelStyle()
        } icon: {
            Image(systemName: image)
        }
    }
}

struct TabLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Manrope-SemiBold", size: 10))
            .lineSpacing(2)
            .multilineTextAlignment(.center)
    }
}

extension View {
    func tabLabelStyle() -> some View {
        self.modifier(TabLabelStyle())
    }
}

#Preview {
    let dependencyContainer = DependencyContainer()
    let coordinator = AuthorizedCoordinator(dependencyContainer: dependencyContainer)
    return AuthorizedCoordinatorView(coordinator: coordinator)
}
