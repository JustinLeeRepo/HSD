//
//  AuthorizedCoordinator.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import Foundation

@Observable class AuthorizedCoordinator {
    enum Tab: UInt {
        case first
        case second
        case third
        case fourth
    }
    
    var tab: Tab = .first
    private(set) var error: Error?
    
    let availablePickUpCoordinator: AvailablePickUpCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.availablePickUpCoordinator = AvailablePickUpCoordinator()
    }
    
    func signOut() async {
        do {
            try await AuthService.shared.signOut()
        }
        catch {
            Task { @MainActor in
                self.error = error
            }
        }
    }
}
