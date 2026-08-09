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
    // MARK: - Notification Side Effects
    // Optional so the store stays usable without a notifier attached.
    private let recipeNotifier: RecipeNotifying?
    private let notificationLogStore: NotificationLogStoring?
    // MARK: - Init
    init(
        userId: Int,
        recipeNotifier: RecipeNotifying? = nil,
        notificationLogStore: NotificationLogStoring? = nil
    ) {
        self.userId = userId
        self.defaults = UserDefaults(suiteName: "com.recipeapp.saveddishes") ?? .standard
        self.recipeNotifier = recipeNotifier
        self.notificationLogStore = notificationLogStore
    }
    // MARK: - Read
    func savedDishIds() -> [Int] {
        defaults.array(forKey: storageKey) as? [Int] ?? []
    }
    func isSaved(dishId: Int) -> Bool {
        savedDishIds().contains(dishId)
    }
    // MARK: - Write
    func save(dishId: Int, recipeName: String?, recipeImageURL: String?) {
        var ids = savedDishIds()

        guard !ids.contains(dishId) else { return }
        ids.append(dishId)
        defaults.set(ids, forKey: storageKey)
        notifyAndLog(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL, action: .saved)
    }
    func remove(dishId: Int, recipeName: String?, recipeImageURL: String?) {
        var ids = savedDishIds()
        ids.removeAll { $0 == dishId }
        defaults.set(ids, forKey: storageKey)
        notifyAndLog(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL, action: .removed)
    }
    func toggleSaved(dishId: Int, recipeName: String?, recipeImageURL: String?) {
        if isSaved(dishId: dishId) {
            remove(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL)
        } else {
            save(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL)
        }
    }
    // MARK: - Notification Side Effects
    // The banner needs notification permission; the log row does not.
    private func notifyAndLog(dishId: Int, recipeName: String?, recipeImageURL: String?, action: RecipeAction) {
        let displayName = recipeName ?? "Recipe #\(dishId)"
        recipeNotifier?.notify(recipeId: dishId, recipeName: displayName, action: action)
        notificationLogStore?.log(
            recipeId: dishId,
            recipeName: displayName,
            recipeImageURL: recipeImageURL,
            action: action
        )
    }
    // MARK: - Helper
    private var storageKey: String {
        "savedDishes_\(userId)"
    }
}
