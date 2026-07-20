//
//  APIClient.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Foundation
import Alamofire

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndPoint, responseType: T.Type) async throws -> T
}

final class APIClient: APIClientProtocol {
    // MARK: - Properties
    private let session: Session
    // MARK: - Initializer
    init(session: Session = .default) {
        self.session = session
    }
    // MARK: - Request Methods
    func request<T: Decodable>(_ endpoint: APIEndPoint,responseType: T.Type) async throws -> T {
        let urlRequest = try buildURLRequest(endpoint)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlRequest).validate().responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data): continuation.resume(returning: data)
                case .failure(let error): continuation.resume(throwing: NetworkError.map(error))
                }
            }
        }
    }
    // MARK: - Helper Methods
    private func buildURLRequest(_ endpoint: APIEndPoint) throws -> URLRequest {
        // Making URLComponenet from base url and path
        guard var components = URLComponents(string: (endpoint.baseURL + endpoint.path)) else {
            throw NetworkError.invalidURL
        }
        // Adding query parameters
        if let queryParameters = endpoint.queryParameters {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key , value: $0.value) }
        }
        // Conveting URLComponenet into URL object
        guard let url = components.url else { throw NetworkError.invalidURL }
        // Initializing URL Request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Adding body in url request
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
        }
        
        return request
    }
}
