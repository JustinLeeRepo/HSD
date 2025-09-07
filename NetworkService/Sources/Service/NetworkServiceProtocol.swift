//
//  NetworkServiceProtocol.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum ServiceError: Error, LocalizedError, Equatable{
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
    
    static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.decodingError, .decodingError),
             (.encodingError, .encodingError):
            return true
        case (.serverError(let code1), .serverError(let code2)):
            return code1 == code2
        case (.networkError(let err1), .networkError(let err2)):
            return err1.localizedDescription == err2.localizedDescription
        default:
            return false
        }
    }
}

public protocol NetworkServiceProtocol {
    func performRequest<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func performRequest(_ endpoint: APIEndpoint) async throws
}

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Codable? { get }
    var authToken: String? { get }
}
