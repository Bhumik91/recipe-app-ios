//
//  SavedRecipeViewModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 22/07/26.
//

import Combine

enum SavedRecipeSnackbarEvent {
    case showUndo
}

@MainActor
final class SavedRecipeViewModel {

    // MARK: - Published State
    @Published private(set) var recipes: [RecipeUIModel] = []
    @Published private(set) var state: ViewState<[RecipeUIModel]> = .idle
    /// One-shot events. A PassthroughSubject (not @Published) so the snackbar isn't
    /// replayed to a late subscriber when the view reappears.
    let snackbarEvent = PassthroughSubject<SavedRecipeSnackbarEvent, Never>()

    // MARK: - Dependencies
    private let recipeRepository: RecipeRepositoryProtocol

    // MARK: - Pending Delete
    private var pendingDelete: PendingDelete?
    private var pendingDeleteTask: Task<Void, Never>?

    /// A row removed from the list but not yet from storage, held so Undo can restore it.
    private struct PendingDelete {
        let recipe: RecipeUIModel
        let index: Int
    }

    private static let undoWindow: Duration = .seconds(3)

    // MARK: - Init
    init(recipeRepository: RecipeRepositoryProtocol) {
        self.recipeRepository = recipeRepository
    }

    // MARK: - Loading
    func loadRecipes() {
        state = .loading
        Task {
            do {
                let recipes = try await recipeRepository.fetchSavedRecipes()
                self.recipes = recipes
                self.state = .success(recipes)
            } catch let error as NetworkError {
                self.state = .failure(error)
            } catch {
                self.state = .failure(NetworkError.unknown)
            }
        }
    }

    // MARK: - Remove & Undo

    /// Removes the row from the list straight away so the UI feels instant, then waits out
    /// the undo window before deleting it for real. Undo cancels that wait, so the
    /// repository is never told about it.
    func removeRecipe(at index: Int) {
        guard recipes.indices.contains(index) else { return }

        // Only one pending delete at a time — a second swipe commits nothing extra,
        // it just replaces what Undo would restore.
        pendingDeleteTask?.cancel()

        let recipe = recipes[index]
        pendingDelete = PendingDelete(recipe: recipe, index: index)

        recipes.remove(at: index)
        state = .success(recipes)
        snackbarEvent.send(.showUndo)

        pendingDeleteTask = Task { [weak self] in
            try? await Task.sleep(for: Self.undoWindow)
            guard !Task.isCancelled else { return }
            // Fires on the committed deletion, so an undone swipe logs nothing.
            self?.recipeRepository.removeSavedRecipe(
                recipeId: recipe.id,
                recipeName: recipe.title,
                recipeImageURL: recipe.imageURL
            )
            self?.clearPendingDelete()
        }
    }

    func undoRemoveRecipe() {
        pendingDeleteTask?.cancel()

        guard let pending = pendingDelete else { return }
        let insertAt = min(pending.index, recipes.count)
        recipes.insert(pending.recipe, at: insertAt)
        state = .success(recipes)
        clearPendingDelete()
    }

    private func clearPendingDelete() {
        pendingDelete = nil
        pendingDeleteTask = nil
    }
}
