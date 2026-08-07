//
//  ProfileViewModel.swift
//  RecipeApp
//

import Combine

/// Drives the Profile screen: user details and saved recipes.
/// Two independent states, so one failing fetch never blanks out the other.
@MainActor
final class ProfileViewModel {

    // MARK: - Published State
    @Published private(set) var profileState: ViewState<ProfileUIModel> = .idle
    @Published private(set) var recipesState: ViewState<[RecipeUIModel]> = .idle

    // MARK: - Dependencies
    private let authRepository: AuthRepositoryProtocol
    private let recipeRepository: RecipeRepositoryProtocol
    private let sessionManager: SessionManaging

    // MARK: - Init
    init(
        authRepository: AuthRepositoryProtocol,
        recipeRepository: RecipeRepositoryProtocol,
        sessionManager: SessionManaging
    ) {
        self.authRepository = authRepository
        self.recipeRepository = recipeRepository
        self.sessionManager = sessionManager
    }

    // MARK: - Loading
    func loadProfile() {
        profileState = .loading
        Task {
            do {
                let user = try await authRepository.getCurrentUser()
                profileState = .success(user.toUIModel())
            } catch let error as NetworkError {
                profileState = .failure(error)
            } catch {
                profileState = .failure(NetworkError.unknown)
            }
        }
    }

    /// Re-fetched on every appearance, not just the first — a recipe saved or removed on
    /// another tab should be reflected when the user comes back here.
    func loadSavedRecipes() {
        recipesState = .loading
        Task {
            do {
                let recipes = try await recipeRepository.fetchSavedRecipes()
                recipesState = .success(recipes)
            } catch let error as NetworkError {
                recipesState = .failure(error)
            } catch {
                recipesState = .failure(NetworkError.unknown)
            }
        }
    }

    // MARK: - Logout
    /// Clears the Keychain session only. Saved recipes and recent searches stay on device
    /// under userId-scoped keys, and the rebuilt container scopes them to the next user.
    func logout() {
        sessionManager.clearSession()
    }
}
