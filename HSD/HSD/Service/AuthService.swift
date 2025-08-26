//
//  AuthService.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Foundation

struct User {
    var token: String
}

//ObservableObject conformance instead of @Observable annotation
//because withObservationTracking is unreliable after first callback
class CurrentUser: ObservableObject {
    static let shared = CurrentUser()
    
    @Published private(set) var user: User?
    @Published private(set) var isSignedIn: Bool = false
    
    private init() {}
    
    func setCurrentUser(_ user: User) {
        self.user = user
        self.isSignedIn = true
    }
    
    func clearUser() {
        self.user = nil
        self.isSignedIn = false
    }
}

enum AuthError: Error {
    case noSignIn
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noSignIn:
            return NSLocalizedString("Signin service must be implemented.", comment: "My error")
        }
    }
}

class AuthService {
    static let shared = AuthService()
    private let userState: CurrentUser = .shared
    
    var user: User? {
        userState.user
    }
    
    /// throws service error
    func signIn(username: String, password: String) async throws {
        //TODO: fill out service client auth endpoint
        throw AuthError.noSignIn
    }
    
    /// throws service error
    func expressSignIn() async throws {
        let user = User(token: "")
        
        Task { @MainActor in
            userState.setCurrentUser(user)
        }
    }
    
    /// throws service error
    func signOut() async throws {
        guard let user = userState.user else { return }
        
        //TODO: hit service to revoke user token
        
        Task { @MainActor in
            userState.clearUser()
        }
    }
}
