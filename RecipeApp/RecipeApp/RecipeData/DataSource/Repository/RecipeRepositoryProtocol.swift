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
    // Name, image, prep time and cuisines travel with the id so the banner, log row and the
    // Saved tab's local cache all need no further network round-trip.
    // TODO: consumed by the recipe card's bookmark toggle
    func toggleSavedRecipe(recipeId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?)
    // TODO: consumed by the Saved screen's remove action
    func removeSavedRecipe(recipeId: Int, recipeName: String?, recipeImageURL: String?)
    // TODO: consumed by the recipe card's bookmark state
    func isRecipeSaved(recipeId: Int) -> Bool
    // TODO: consumed by the cuisine filter chips
    func getCuisines() -> [String]
}

// MARK: - Id-only Convenience
// Protocol requirements can't carry default arguments, so the id-only forms live here.
extension RecipeRepositoryProtocol {

    func toggleSavedRecipe(recipeId: Int) {
        toggleSavedRecipe(recipeId: recipeId, recipeName: nil, recipeImageURL: nil, readyInMinutes: nil, cuisines: nil)
    }

    func removeSavedRecipe(recipeId: Int) {
        removeSavedRecipe(recipeId: recipeId, recipeName: nil, recipeImageURL: nil)
    }
}
