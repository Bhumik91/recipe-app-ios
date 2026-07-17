//
//  AuthRepositry.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
protocol AuthRepositoryProtocol {
    func login(userName: String, password: String) async throws
}

final class AuthRepository: AuthRepositoryProtocol {
    // MARK: - Properties
    private let apiClient: APIClientProtocol
    private let sessionManager: SessionManaging
    // MARK: - Initializer
    init(apiClient: APIClientProtocol, sessionManager: SessionManaging) {
        self.apiClient = apiClient
        self.sessionManager = sessionManager
    }
    // MARK: - AuthRepositoryProtocol
    func login(userName: String, password: String) async throws {
        let request = LoginRequest(userName: userName, password: password)
        let response =  try await apiClient.request(AuthEndPoint.login(request), responseType: LoginResponse.self)
        guard response.accessToken != nil, response.refreshToken != nil,
              response.userId != nil, response.name != nil else {
            throw NetworkError.decodingFailed
        }
        sessionManager.saveAuthSession(response)
        return 
    }
}
