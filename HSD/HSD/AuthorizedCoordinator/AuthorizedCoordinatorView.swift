//
//  AuthorizedCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import SwiftUI

struct AuthorizedCoordinatorView: View {
    typealias Tab = AuthorizedCoordinator.Tab
    @Bindable var coordinator: AuthorizedCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.tab) {
            Button {
                Task {
                    await coordinator.signOut()
                }
            } label: {
                Text("sign out")
            }
            .tabItem {
                generateLabel(title: "One", image: "dog")
            }
            .tag(Tab.first)
            
            Text("2")
                .tabItem {
                    generateLabel(title: "Two", image: "cat")
                }
                .tag(Tab.second)
            
            Text("3")
                .tabItem {
                    generateLabel(title: "Three", image: "skateboard")
                }
                .tag(Tab.third)
            
            Text("4")
                .tabItem {
                    generateLabel(title: "Four", image: "person")
                }
                .tag(Tab.fourth)
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
    let coordinator = AuthorizedCoordinator()
    return AuthorizedCoordinatorView(coordinator: coordinator)
}
