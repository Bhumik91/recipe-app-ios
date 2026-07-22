//
//  SavedRecipeStoring.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//

protocol SavedRecipeStoring {
    func savedDishIds() -> [Int]
    func isSaved(dishId: Int) -> Bool
    func save(dishId: Int)
    func remove(dishId: Int)
    func toggleSaved(dishId: Int)
}
