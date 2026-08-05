//
//  RecentSearchesStoring.swift
//  RecipeApp
//

protocol RecentSearchesStoring {
    func recentSearches() -> [SearchRecipeUIModel]
    func addRecentSearches(_ recipes: [SearchRecipeUIModel])
    func clear()
}
