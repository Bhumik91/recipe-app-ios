//
//  FallbackRecipeRepository.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 21/07/26.
//

import Foundation

final class FallbackRecipeRepository: RecipeRepositoryProtocol {
    private let remote: RecipeRepositoryProtocol
    private let dummy: RecipeRepositoryProtocol

    init(remote: RecipeRepositoryProtocol, dummy: RecipeRepositoryProtocol) {
        self.remote = remote
        self.dummy = dummy
    }

    private func withFallback<T>(
        remoteCall: () async throws -> T,
        dummyCall: () async throws -> T
    ) async throws -> T {
        do {
            return try await remoteCall()
        } catch NetworkError.quotaExceeded {
            return try await dummyCall()
        }
    }

    func fetchRecipes(cuisine: String?, diet: String?, offset: Int) async throws -> PaginatedRecipes {
        try await withFallback(
            remoteCall: { try await remote.fetchRecipes(cuisine: cuisine, diet: diet, offset: offset) },
            dummyCall: { try await dummy.fetchRecipes(cuisine: cuisine, diet: diet, offset: offset) }
        )
    }

    func fetchRecipes(byIds ids: [Int]) async throws -> [RecipeUIModel] {
        try await withFallback(
            remoteCall: { try await remote.fetchRecipes(byIds: ids) },
            dummyCall: { try await dummy.fetchRecipes(byIds: ids) }
        )
    }

    func fetchSavedRecipes() async throws -> [RecipeUIModel] {
        try await withFallback(
            remoteCall: { try await remote.fetchSavedRecipes() },
            dummyCall: { try await dummy.fetchSavedRecipes() }
        )
    }

    func searchRecipes(query: String, diet: String?) async throws -> [RecipeUIModel] {
        try await withFallback(
            remoteCall: { try await remote.searchRecipes(query: query, diet: diet) },
            dummyCall: { try await dummy.searchRecipes(query: query, diet: diet) }
        )
    }

    // Local-only operations delegate only to remote (not wrapped in withFallback).
    // This is safe because both remote and dummy share the same savedDishesManager instance,
    // so delegating to either gives the same result. If repositories ever get separate
    // managers, this contract must change to delegate to both or switch based on which is active.
    func toggleSavedRecipe(recipeId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?) {
        remote.toggleSavedRecipe(
            recipeId: recipeId,
            recipeName: recipeName,
            recipeImageURL: recipeImageURL,
            readyInMinutes: readyInMinutes,
            cuisines: cuisines
        )
    }

    func removeSavedRecipe(recipeId: Int, recipeName: String?, recipeImageURL: String?) {
        remote.removeSavedRecipe(recipeId: recipeId, recipeName: recipeName, recipeImageURL: recipeImageURL)
    }

    func isRecipeSaved(recipeId: Int) -> Bool {
        remote.isRecipeSaved(recipeId: recipeId)
    }

    func getCuisines() -> [String] {
        remote.getCuisines()
    }

    func fetchRecipeDetail(id: Int) async throws -> RecipeDetailDTO {
        try await withFallback(
            remoteCall: { try await remote.fetchRecipeDetail(id: id) },
            dummyCall: { try await dummy.fetchRecipeDetail(id: id) }
        )
    }
}
