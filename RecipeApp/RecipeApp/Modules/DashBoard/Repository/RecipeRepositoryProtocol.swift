//
//  RecipeRepositoryProtocol.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 21/07/26.
//
import Foundation

enum Page { static let size = 10 }

protocol RecipeRepositoryProtocol {
    // Network-backed reads (fall back to dummy data on quota exhaustion)
    // TODO: consumed by the Home screen's explore list
    func fetchRecipes(cuisine: String?, diet: String?, offset: Int) async throws -> PaginatedRecipes
    func fetchRecipes(byIds ids: [Int]) async throws -> [RecipeUIModel]
    // TODO: consumed by the Saved screen
    func fetchSavedRecipes() async throws -> [RecipeUIModel]
    // TODO: consumed by the Search screen
    func searchRecipes(query: String, diet: String?) async throws -> [RecipeUIModel]
    //TODO: consumed by the cuisine recipe details
    func fetchRecipeDetail(id: Int) async throws -> RecipeDetailDTO
    
    // Local-only operations (never hit the network)
    // TODO: consumed by the recipe card's bookmark toggle
    func toggleSavedRecipe(recipeId: Int)
    // TODO: consumed by the Saved screen's remove action
    func removeSavedRecipe(recipeId: Int)
    // TODO: consumed by the recipe card's bookmark state
    func isRecipeSaved(recipeId: Int) -> Bool
    // TODO: consumed by the cuisine filter chips
    func getCuisines() -> [String]
}
