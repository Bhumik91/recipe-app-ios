//
//  RemoteRecipeRepository.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import Foundation

final class RemoteRecipeRepository: RecipeRepositoryProtocol {
    
    private let apiClient: APIClientProtocol
    private let savedDishesManager: SavedRecipeStoring

    init(
        apiClient: APIClientProtocol,
        savedDishesManager: SavedRecipeStoring
    ) {
        self.apiClient = apiClient
        self.savedDishesManager = savedDishesManager
    }

    func fetchRecipes(cuisine: String?, diet: String?, offset: Int) async throws -> PaginatedRecipes {
        let response: RecipeSearchResponse = try await apiClient.request(
            RecipeEndpoint.search(cuisine: cuisine, diet: diet, offset: offset),
            responseType: RecipeSearchResponse.self
        )
        let results = response.results.map { dto in
            dto.toUIModel(isSaved: savedDishesManager.isSaved(dishId: dto.id))
        }
        return PaginatedRecipes(
            results: results,
            offset: response.offset,
            number: response.number,
            totalResults: response.totalResults
        )
    }

    func fetchRecipes(byIds ids: [Int]) async throws -> [RecipeUIModel] {
        let dtos: [RecipeSummaryDTO] = try await apiClient.request(
            RecipeEndpoint.bulkDetails(ids: ids),
            responseType: [RecipeSummaryDTO].self
        )
        return dtos.map { dto in
            dto.toUIModel(isSaved: savedDishesManager.isSaved(dishId: dto.id))
        }
    }

    func fetchSavedRecipes() async throws -> [RecipeUIModel] {
        let ids = savedDishesManager.savedDishIds()
        guard !ids.isEmpty else { return [] }
        return try await fetchRecipes(byIds: ids)
    }

    func searchRecipes(query: String, diet: String?) async throws -> [RecipeUIModel] {
        let response: RecipeSearchResponse = try await apiClient.request(
            RecipeEndpoint.search(query: query, diet: diet, number: Page.size),
            responseType: RecipeSearchResponse.self
        )
        return response.results.map { dto in
            dto.toUIModel(isSaved: savedDishesManager.isSaved(dishId: dto.id))
        }
    }
    
    func fetchRecipeDetail(id: Int) async throws -> RecipeDetailDTO {
        try await apiClient.request(RecipeEndpoint.detail(id: id), responseType: RecipeDetailDTO.self)
    }

    // Local-only operations (never hit the network)
    func toggleSavedRecipe(recipeId: Int) {
        savedDishesManager.toggleSaved(dishId: recipeId)
    }

    func removeSavedRecipe(recipeId: Int) {
        savedDishesManager.remove(dishId: recipeId)
    }

    func isRecipeSaved(recipeId: Int) -> Bool {
        savedDishesManager.isSaved(dishId: recipeId)
    }

    func getCuisines() -> [String] {
        Cuisines.cuisines
    }
}
