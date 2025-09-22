//
//  HSDApp.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import DependencyContainer
import SwiftUI

@main
struct HSDApp: App {
    @State private var coordinator = RootCoordinator(dependencyContainer: DependencyContainer())
    
    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(coordinator: coordinator)
        }
    }
}
