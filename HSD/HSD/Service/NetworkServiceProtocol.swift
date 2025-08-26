//
//  NetworkServiceProtocol.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum ServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    case serverError(Int)
    case decodingError
    case encodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

protocol NetworkServiceProtocol {
    func performRequest<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func performRequest(_ endpoint: APIEndpoint) async throws
}

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Codable? { get }
    var authToken: String? { get }
}
