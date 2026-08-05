//
//  UserDefaultsRecentSearchesStore.swift
//  RecipeApp
//
import Foundation

final class UserDefaultsRecentSearchesStore: RecentSearchesStoring {
    // MARK: - Properties
    private let defaults: UserDefaults
    private let userId: Int
    private let maxRecentSearches = 10

    // MARK: - Init
    init(userId: Int) {
        self.userId = userId
        self.defaults = UserDefaults(suiteName: "com.recipeapp.recentsearches") ?? .standard
    }

    // MARK: - Read
    func recentSearches() -> [SearchRecipeUIModel] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([SearchRecipeUIModel].self, from: data)) ?? []
    }

    // MARK: - Write
    // Moves the given recipes to the front, de-duplicated by id, capped at maxRecentSearches.
    func addRecentSearches(_ recipes: [SearchRecipeUIModel]) {
        guard !recipes.isEmpty else { return }

        let newIds = Set(recipes.map(\.id))
        let updated = recipes + recentSearches().filter { !newIds.contains($0.id) }
        let trimmed = Array(updated.prefix(maxRecentSearches))

        guard let data = try? JSONEncoder().encode(trimmed) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func clear() {
        defaults.removeObject(forKey: storageKey)
    }

    // MARK: - Helper
    private var storageKey: String {
        "recentSearches_\(userId)"
    }
}
