//
//  RecipeDetailViewModel.swift
//  RecipeApp
//

import Combine

@MainActor
final class RecipeDetailViewModel {
    // MARK: - Published State
    @Published private(set) var state: ViewState<RecipeDetailUIModel> = .idle
    @Published private(set) var targetServings: Int = Servings.min

    // MARK: - Dependencies
    private let recipeRepository: RecipeRepositoryProtocol
    private let recipeId: Int

    private enum Servings {
        static let min = 1
        static let max = 10
    }

    // MARK: - Init
    init(recipeRepository: RecipeRepositoryProtocol, recipeId: Int) {
        self.recipeRepository = recipeRepository
        self.recipeId = recipeId
    }

    // MARK: - Data Loading
    func load() {
        state = .loading
        Task {
            do {
                let dto = try await recipeRepository.fetchRecipeDetail(id: recipeId)
                let recipe = dto.toUIModel(isSaved: recipeRepository.isRecipeSaved(recipeId: recipeId))
                targetServings = max(recipe.servings, Servings.min)
                state = .success(recipe)
            } catch let error as NetworkError {
                state = .failure(error)
            } catch {
                state = .failure(NetworkError.unknown)
            }
        }
    }

    // MARK: - Servings
    func incrementServings() {
        targetServings = min(targetServings + 1, Servings.max)
    }

    func decrementServings() {
        targetServings = max(targetServings - 1, Servings.min)
    }

    // MARK: - Save Toggle
    // Local-only, matching Android's RecipeDetailViewModel.onSaveToggled — always succeeds, so
    // there's no failure path to revert from.
    func toggleSaved() {
        guard case .success(var recipe) = state else { return }
        recipe.isSaved.toggle()
        state = .success(recipe)
        // The detail is already loaded, so the notification can name the recipe outright.
        recipeRepository.toggleSavedRecipe(
            recipeId: recipeId,
            recipeName: recipe.title,
            recipeImageURL: recipe.imageURL
        )
    }
}
