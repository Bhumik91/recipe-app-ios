//
//  JSONRecipeRepository.swift
//  RecipeApp
//

import Foundation

final class JSONRecipeRepository: RecipeRepositoryProtocol {
    // MARK: - Properties
    private let savedDishesManager: SavedRecipeStoring
    private let fileName: String
    private let bundle: Bundle

    // MARK: - Initialization
    init(
        savedDishesManager: SavedRecipeStoring,
        fileName: String = "DummyRecipeData",
        bundle: Bundle = .main
    ) {
        self.savedDishesManager = savedDishesManager
        self.fileName = fileName
        self.bundle = bundle
    }

    // MARK: - Network-Backed Reads (Bundled Data)
    // No server to filter against, so cuisine/diet are ignored and the full bundled set is returned.
    func fetchRecipes(cuisine: String?, diet: String?, offset: Int) async throws -> PaginatedRecipes {
        let response = try loadResponse()
        var results = response.results
        if let cuisine, cuisine.lowercased() != "all" {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(cuisine) }
        }
        let page = Array(results.dropFirst(offset).prefix(Page.size))
        let uiModels = page.map { dto in
            dto.toUIModel(isSaved: savedDishesManager.isSaved(dishId: dto.id))
        }
        return PaginatedRecipes(results: uiModels, offset: offset, number: Page.size, totalResults: results.count)
    }

    func fetchRecipes(byIds ids: [Int]) async throws -> [RecipeUIModel] {
        let response = try loadResponse()
        return response.results
            .filter { ids.contains($0.id) }
            .map { dto in
                dto.toUIModel(isSaved: savedDishesManager.isSaved(dishId: dto.id))
            }
    }

    func fetchSavedRecipes() async throws -> [RecipeUIModel] {
        let ids = savedDishesManager.savedDishIds()
        guard !ids.isEmpty else { return [] }
        return try await fetchRecipes(byIds: ids)
    }

    // No server to filter against, so query/diet are ignored and the full bundled set is returned.
    func searchRecipes(query: String, diet: String?) async throws -> [RecipeUIModel] {
        let response = try loadResponse()
        return response.results.map { dto in
            dto.toUIModel(isSaved: savedDishesManager.isSaved(dishId: dto.id))
        }
    }

    // MARK: - Local-Only Operations
    func toggleSavedRecipe(recipeId: Int) {
        savedDishesManager.toggleSaved(dishId: recipeId)
    }

    func removeSavedRecipe(recipeId: Int)  {
        savedDishesManager.remove(dishId: recipeId)
    }

    func isRecipeSaved(recipeId: Int) -> Bool {
        savedDishesManager.isSaved(dishId: recipeId)
    }

    func getCuisines() -> [String] {
        Cuisines.cuisines
    }

    // MARK: - Private Helpers
    private func loadResponse() throws -> RecipeSearchResponse {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw NetworkError.requestFailed(message: "\(fileName).json not found in bundle")
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
