//
//  SavedRecipeStoring.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//

/// Owns the saved-state of recipes, and is where a save or remove fans out to the
/// notification side effects. Name, image, prep time and cuisines are optional — callers
/// holding only an id fall back to a "Recipe #<id>" placeholder.
protocol SavedRecipeStoring {
    func savedDishIds() -> [Int]
    func isSaved(dishId: Int) -> Bool
    func save(dishId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?)
    func remove(dishId: Int, recipeName: String?, recipeImageURL: String?)
    func toggleSaved(dishId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?)
    /// The current user's saved recipes, read locally — no network round-trip.
    func fetchAllSaved() -> [RecipeUIModel]
}

// MARK: - Id-only Convenience
// Protocol requirements can't carry default arguments, so the id-only forms live here.
extension SavedRecipeStoring {

    func save(dishId: Int) {
        save(dishId: dishId, recipeName: nil, recipeImageURL: nil, readyInMinutes: nil, cuisines: nil)
    }

    func remove(dishId: Int) {
        remove(dishId: dishId, recipeName: nil, recipeImageURL: nil)
    }

    func toggleSaved(dishId: Int) {
        toggleSaved(dishId: dishId, recipeName: nil, recipeImageURL: nil, readyInMinutes: nil, cuisines: nil)
    }
}
