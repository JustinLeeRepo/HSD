//
//  HSDApp.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import SwiftUI

@main
struct HSDApp: App {
    var body: some Scene {
        var coordinator = RootCoordinator()
        WindowGroup {
            RootCoordinatorView(coordinator: coordinator)
        }
    }
}
