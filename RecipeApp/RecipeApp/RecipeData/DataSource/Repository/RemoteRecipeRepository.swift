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

    // Local read, no network — matches RemoteRecipeRepositoryImpl delegating straight to
    // savedRecipesManager.observeSavedRecipes().first() on Android.
    func fetchSavedRecipes() async throws -> [RecipeUIModel] {
        savedDishesManager.fetchAllSaved()
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
    func toggleSavedRecipe(recipeId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?) {
        savedDishesManager.toggleSaved(
            dishId: recipeId,
            recipeName: recipeName,
            recipeImageURL: recipeImageURL,
            readyInMinutes: readyInMinutes,
            cuisines: cuisines
        )
    }

    func removeSavedRecipe(recipeId: Int, recipeName: String?, recipeImageURL: String?) {
        savedDishesManager.remove(dishId: recipeId, recipeName: recipeName, recipeImageURL: recipeImageURL)
    }

    func isRecipeSaved(recipeId: Int) -> Bool {
        savedDishesManager.isSaved(dishId: recipeId)
    }

    func getCuisines() -> [String] {
        Cuisines.cuisines
    }
}
