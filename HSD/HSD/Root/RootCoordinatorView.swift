//
//  RootCoordinatorView.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import SwiftUI

struct RootCoordinatorView: View {
    var coordinator: RootCoordinator
    
    var body: some View {
        if coordinator.isAuthorized {
            ContentView()
        }
        else {
            Text("Unauthorized View")
        }
    }
}

#Preview {
    let coordinator = RootCoordinator()
    return RootCoordinatorView(coordinator: coordinator)
}
