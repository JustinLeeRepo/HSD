//
//  NetworkService.swift
//  HSD
//
//  Created by Justin Lee on 8/25/25.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    //12daf8a6-cb58-42fd-9f78-1af6e4b12991
    private let baseURL = "https://mocki.io/v1/"
    private let session: URLSession = .shared
    
    func performRequest<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try createRequest(endpoint: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try validateResponse(response: response)
            
            return try decodeData(data: data)
            
        } catch let error as ServiceError {
            throw error
        } catch {
            throw ServiceError.networkError(error)
        }
    }
    
    func performRequest(_ endpoint: APIEndpoint) async throws {
        let request = try createRequest(endpoint: endpoint)
        
        do {
            let (_, response) = try await session.data(for: request)
            
            try validateResponse(response: response)
            
        } catch let error as ServiceError {
            throw error
        } catch {
            throw ServiceError.networkError(error)
        }
    }
    
    private func createRequest(endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint.path)") else {
            throw ServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let authToken = endpoint.authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
            } catch {
                throw ServiceError.encodingError
            }
        }
        
        return request
    }
    
    private func validateResponse(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.networkError(URLError(.badServerResponse))
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw ServiceError.unauthorized
        default:
            throw ServiceError.serverError(httpResponse.statusCode)
        }
    }
    
    private func decodeData<T: Codable>(
        data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64,
        nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw
    ) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = keyDecodingStrategy
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.dataDecodingStrategy = dataDecodingStrategy
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
            
            let result = try decoder.decode(T.self, from: data)
            return result
        }
        catch {
            throw ServiceError.decodingError
        }
    }
}
