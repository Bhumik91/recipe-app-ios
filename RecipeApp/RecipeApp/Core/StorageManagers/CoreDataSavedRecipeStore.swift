//
//  CoreDataSavedRecipeStore.swift
//  RecipeApp
//

import CoreData
import Foundation

/// Core Data implementation of `SavedRecipeStoring`, the Room replacement for
/// `RoomSavedRecipesStorage`. Stores full recipe data (not just the id) so the Saved tab
/// renders without a network round-trip.
final class CoreDataSavedRecipeStore: SavedRecipeStoring {

    // MARK: - Dependencies
    private let stack: CoreDataStack
    private let sessionManager: SessionManaging
    private let recipeNotifier: RecipeNotifying?
    private let notificationLogStore: NotificationLogStoring?

    // MARK: - Init
    init(
        stack: CoreDataStack,
        sessionManager: SessionManaging,
        recipeNotifier: RecipeNotifying? = nil,
        notificationLogStore: NotificationLogStoring? = nil
    ) {
        self.stack = stack
        self.sessionManager = sessionManager
        self.recipeNotifier = recipeNotifier
        self.notificationLogStore = notificationLogStore
        migrateLegacyUserDefaultsIfNeeded()
    }

    // MARK: - Read
    // Resolved per call, not stored, so a logout/login switch within the container's
    // lifetime never reads or writes under the wrong id.
    private var userId: Int64 { Int64(sessionManager.userId) }

    func savedDishIds() -> [Int] {
        fetchRows().map { Int($0.recipeId) }
    }

    func isSaved(dishId: Int) -> Bool {
        row(for: dishId) != nil
    }

    func fetchAllSaved() -> [RecipeUIModel] {
        fetchRows().map { $0.toUIModel() }
    }

    // MARK: - Write
    func save(dishId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?) {
        guard row(for: dishId) == nil else { return }
        let entry = SavedRecipe(context: stack.viewContext)
        entry.recipeId = Int64(dishId)
        entry.userId = userId
        entry.title = recipeName ?? "Recipe #\(dishId)"
        entry.imageURL = recipeImageURL ?? ""
        entry.readyInMinutes = Int64(readyInMinutes ?? 0)
        entry.cuisines = cuisines?.joined(separator: ",")
        entry.savedAt = Date()
        save(context: stack.viewContext)
        notifyAndLog(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL, action: .saved)
    }

    func remove(dishId: Int, recipeName: String?, recipeImageURL: String?) {
        guard let entry = row(for: dishId) else { return }
        stack.viewContext.delete(entry)
        save(context: stack.viewContext)
        notifyAndLog(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL, action: .removed)
    }

    func toggleSaved(dishId: Int, recipeName: String?, recipeImageURL: String?, readyInMinutes: Int?, cuisines: [String]?) {
        if isSaved(dishId: dishId) {
            remove(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL)
        } else {
            save(dishId: dishId, recipeName: recipeName, recipeImageURL: recipeImageURL, readyInMinutes: readyInMinutes, cuisines: cuisines)
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

    // MARK: - Fetching
    // No DB-level uniqueness constraint on recipeId+userId — enforced here instead, the same
    // shape Room's OnConflictStrategy.REPLACE gets for free.
    private func row(for dishId: Int) -> SavedRecipe? {
        let request = SavedRecipe.fetchRequest()
        request.predicate = Self.predicate(recipeId: Int64(dishId), userId: userId)
        request.fetchLimit = 1
        return try? stack.viewContext.fetch(request).first
    }

    private func fetchRows() -> [SavedRecipe] {
        let request = SavedRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %lld", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    private static func predicate(recipeId: Int64, userId: Int64) -> NSPredicate {
        NSPredicate(format: "recipeId == %lld AND userId == %lld", recipeId, userId)
    }

    private func save(context: NSManagedObjectContext) {
        // A failed write must never crash the save/remove that triggered it.
        try? context.save()
    }

    // MARK: - Legacy Migration
    // UserDefaultsSavedRecipeStore only ever persisted ids, so there is nothing richer to
    // carry over — each migrated row starts with placeholder metadata, same as the
    // "Recipe #<id>" fallback the id-only convenience methods already use elsewhere.
    // Runs once per container lifetime; DependencyContainer is rebuilt on every login, so
    // this naturally migrates whichever user's legacy data is active at construction time.
    private func migrateLegacyUserDefaultsIfNeeded() {
        let legacyDefaults = UserDefaults(suiteName: "com.recipeapp.saveddishes") ?? .standard
        let legacyKey = "savedDishes_\(sessionManager.userId)"
        guard let legacyIds = legacyDefaults.array(forKey: legacyKey) as? [Int], !legacyIds.isEmpty else { return }

        for dishId in legacyIds where row(for: dishId) == nil {
            let entry = SavedRecipe(context: stack.viewContext)
            entry.recipeId = Int64(dishId)
            entry.userId = userId
            entry.title = "Recipe #\(dishId)"
            entry.imageURL = ""
            entry.readyInMinutes = 0
            entry.savedAt = Date()
        }
        save(context: stack.viewContext)
        legacyDefaults.removeObject(forKey: legacyKey)
    }
}

// MARK: - Mapping
private extension SavedRecipe {
    /// Maps into a detached value type. Call on the object's own context queue.
    func toUIModel() -> RecipeUIModel {
        RecipeUIModel(
            id: Int(recipeId),
            title: title,
            readyInMinutes: Int(readyInMinutes),
            imageURL: imageURL,
            isSaved: true,
            cuisines: cuisines?.split(separator: ",").map(String.init) ?? []
        )
    }
}
