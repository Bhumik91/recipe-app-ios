//
//  DependencyContainer.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
final class DependencyContainer {
    // MARK: - Properties
    let sessionManager: SessionManaging
    let apiClient: APIClientProtocol
    let authRepository: AuthRepositoryProtocol
    // MARK: - Initializer
    init() {
        let sessionManager = KeychainSessionStore()
        self.sessionManager = sessionManager
        let apiClient = APIClient()
        self.apiClient = apiClient
        self.authRepository = AuthRepository(apiClient: apiClient, sessionManager: sessionManager)
    }
}

