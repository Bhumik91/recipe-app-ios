//
//  UserDefaultsSavedRecipeStore.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//
import Foundation

final class UserDefaultsSavedRecipeStore: SavedRecipeStoring {
    // MARK: - Properties
    private let defaults: UserDefaults
    private let userId: Int
    // MARK: - Init
    init(userId: Int) {
        self.userId = userId
        self.defaults = UserDefaults(suiteName: "com.recipeapp.saveddishes") ?? .standard
    }
    // MARK: - Read
    func savedDishIds() -> [Int] {
        defaults.array(forKey: storageKey) as? [Int] ?? []
    }
    func isSaved(dishId: Int) -> Bool {
        savedDishIds().contains(dishId)
    }
    // MARK: - Write
    func save(dishId: Int) {
        var ids = savedDishIds()
        
        guard !ids.contains(dishId) else { return }
        ids.append(dishId)
        defaults.set(ids, forKey: storageKey)
    }
    func remove(dishId: Int) {
        var ids = savedDishIds()
        ids.removeAll { $0 == dishId }
        defaults.set(ids, forKey: storageKey)
    }
    func toggleSaved(dishId: Int) {
        if isSaved(dishId: dishId) {
            remove(dishId: dishId)
        } else {
            save(dishId: dishId)
        }
    }
    // MARK: - Helper
    private var storageKey: String {
        "savedDishes_\(userId)"
    }
}
