//
//  AuthService.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Foundation
import Keychain

protocol AuthServiceProtocol {
    func signIn(username: String, password: String) async throws
    func expressSignIn() async throws
    func signOut() async throws
}

struct AuthEndpoint: APIEndpoint {
    enum Action {
        case signIn(SignInRequest)
        case signOut(String)
    }
    
    let action: Action
    
    var path: String {
        switch action {
        case .signIn:
            return "signin"
        case .signOut:
            return "signout"
        }
    }
    
    var method: HTTPMethod {
        .POST
    }
    
    var body: Codable? {
        switch action {
        case .signIn(let request):
            return request
        case .signOut:
            return nil
        }
    }
    
    var authToken: String? {
        switch action {
        case .signIn:
            return nil
        case .signOut(let token):
            return token
        }
    }
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private let networkService: NetworkServiceProtocol
    private let userState: CurrentUser = .shared
    
    private init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func signIn(username: String, password: String) async throws {
        throw ServiceError.unauthorized
    }
    
    func expressSignIn() async throws {
        let token = "Mila"
        try Keychain.shared.update(id: .authToken, stringData: token)
        let user = User(token: token)
        Task { @MainActor in
            userState.setCurrentUser(user)
        }
    }
    
    func signOut() async throws {
        guard let user = userState.user else { return }
        try Keychain.shared.delete(id: .authToken)
        
        let endpoint = AuthEndpoint(action: .signOut(user.token))
//        try await networkService.performRequest(endpoint)
        
        Task { @MainActor in
            userState.clearUser()
        }
    }
}
