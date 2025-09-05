//
//  CurrentUser.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation
import Keychain

public struct User {
    var token: String
}

//ObservableObject conformance instead of @Observable annotation
//because withObservationTracking is unreliable after first callback
public class CurrentUser: ObservableObject {
    public static let shared = CurrentUser()
    
    @Published public var user: User?
    @Published private(set) var isSignedIn: Bool = false
    
    private init() {
        initUser()
    }
    
    private func initUser() {
        if let token = try? Keychain.shared.get(id: .authToken) {
            let user = User(token: token)
            setCurrentUser(user)
        }
    }
    
    func setCurrentUser(_ user: User) {
        self.user = user
        self.isSignedIn = true
    }
    
    func clearUser() {
        self.user = nil
        self.isSignedIn = false
    }
}
