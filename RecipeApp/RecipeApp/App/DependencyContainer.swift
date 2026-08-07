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
    let permissionManager: PermissionManaging
    let recipeNotifier: RecipeNotifying
    // MARK: - Initializer
    init() {
        let sessionManager = KeychainSessionStore()
        self.sessionManager = sessionManager
        let apiClient = APIClient(sessionManager: sessionManager)
        self.apiClient = apiClient
        // The notifier goes to the saved-recipe store so a save/remove posts at the point
        // the state actually changes.
        let permissionManager = PermissionManager()
        self.permissionManager = permissionManager
        let recipeNotifier = SystemRecipeNotifier(permissionManager: permissionManager)
        self.recipeNotifier = recipeNotifier
        let savedDishesManager = UserDefaultsSavedRecipeStore(
            userId: sessionManager.userId,
            recipeNotifier: recipeNotifier
        )
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
