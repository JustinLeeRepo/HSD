//
//  AuthorizedCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import DependencyContainer
import SwiftUI

struct AuthorizedCoordinatorView: View {
    typealias Tab = AuthorizedCoordinator.Tab
    @Bindable var coordinator: AuthorizedCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.tab) {
            AvailablePickUpCoordinatorView(coordinator: coordinator.availablePickUpCoordinator)
            .tabItem {
                generateLabel(title: "Available Rides", image: "dog")
            }
            .tag(Tab.first)
            
            Button {
                Task {
                    await coordinator.signOut()
                }
            } label: {
                Text("sign out")
            }
            .tabItem {
                generateLabel(title: "Account", image: "cat")
            }
            .tag(Tab.second)
        }
        
        if let error = coordinator.error {
            Text(error.localizedDescription)
                .padding()
                .font(.caption)
                .foregroundStyle(.pink)
                .opacity(coordinator.error == nil ? 0 : 1)
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
