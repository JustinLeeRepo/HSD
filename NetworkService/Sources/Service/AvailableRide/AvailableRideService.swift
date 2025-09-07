//
//  AvailableRideService.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

public protocol AvailableRidesServiceProtocol {
    func fetchRides() async throws -> [Ride]
    func fetchRidesPage(pageSize: Int?) async throws -> [Ride]
}

struct AvailableRidesEndpoint: APIEndpoint {
    enum Action {
        case fetchRides(token: String)
        case fetchRidesPage(token: String, page: Int?, pageSize: Int?)
    }
    
    let endpoint = "3aeeaafe-77fe-4953-b0a9-4300d332df7b"
    let action: Action
    
    var path: String {
        switch action {
            
        case .fetchRides(_):
            return endpoint
            
        case .fetchRidesPage(_, let page, let pageSize):
            var path = endpoint
            
            var queryComponents: [String] = []
            
            if let page = page {
                queryComponents.append("page=\(page)")
            }
            
            if let pageSize = pageSize {
                queryComponents.append("page_size=\(pageSize)")
            }
            
            if !queryComponents.isEmpty {
                path += "?" + queryComponents.joined(separator: "&")
            }
            
            return path
        }
    }
    
    var method: HTTPMethod {
        .GET
    }
    
    var body: Codable? {
        nil
    }
    
    var authToken: String? {
        switch action {
        case .fetchRidesPage(let token, _, _):
            return token
        case .fetchRides(let token):
            return token
        }
    }
}

public class AvailableRidesService: AvailableRidesServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let userState: CurrentUser = .shared
    
    private let defaultPageSize = 20
    private var page: Int? = 0
    
    public init(networkService: NetworkServiceProtocol? = nil) {
        self.networkService = networkService ?? NetworkService()
    }

    func resetPagination() {
        self.page = 0
    }

    var currentPage: Int? {
        return page
    }
    
    public func fetchRides() async throws -> [Ride] {
        guard let user = userState.user else { throw ServiceError.unauthorized }
        
        let endpoint = AvailableRidesEndpoint(action: .fetchRides(token: user.token))
        
        let response: RidesResponse = try await networkService.performRequest(endpoint)
        
        return response.rides
    }
    
    public func fetchRidesPage(pageSize: Int? = nil) async throws -> [Ride] {
        throw ServiceError.noData
        
        guard let user = userState.user else { throw ServiceError.unauthorized }
        
        let endpoint = AvailableRidesEndpoint(action: .fetchRidesPage(
            token: user.token,
            page: page,
            pageSize: pageSize ?? defaultPageSize
        ))
        
        let response: RidesResponse = try await networkService.performRequest(endpoint)
        
        self.page = response.pagination.nextPage
        
        return response.rides
    }
}
