//
//  AuthModel.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

struct SignInRequest: Codable {
    let username: String
    let password: String
}

struct SignInResponse: Codable {
    let token: String
}
