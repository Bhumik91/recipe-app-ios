//
//  DependencyContainer.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
// MARK: - Dependency Injection Container
//
@MainActor
final class DependencyContainer {
    // MARK: - Properties
    let sessionManager: SessionManaging
    let apiClient: APIClientProtocol
    let authRepository: AuthRepositoryProtocol
    let savedDishesManager: SavedRecipeStoring
    let recentSearchesManager: RecentSearchesStoring
    let recipeRepository: RecipeRepositoryProtocol
    // MARK: - Initializer
    init() {
        let sessionManager = KeychainSessionStore()
        self.sessionManager = sessionManager
        let apiClient = APIClient()
        self.apiClient = apiClient
        let savedDishesManager = UserDefaultsSavedRecipeStore(userId: sessionManager.userId)
        self.savedDishesManager = savedDishesManager
        self.recentSearchesManager = UserDefaultsRecentSearchesStore(userId: sessionManager.userId)
        let jsonRecipeRepository = JSONRecipeRepository(
            savedDishesManager: savedDishesManager
        )
        let remoteRecipeRepository = RemoteRecipeRepository(
            apiClient: apiClient,
            savedDishesManager: savedDishesManager
        )
        self.recipeRepository = FallbackRecipeRepository(remote: remoteRecipeRepository, dummy: jsonRecipeRepository)
        self.authRepository = AuthRepository(apiClient: apiClient, sessionManager: sessionManager)
    }
}
