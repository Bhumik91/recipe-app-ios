//
//  HomeSection.swift
//  RecipeApp
//

// Drives HomeViewController's table sections dynamically — savedHeader/savedRecipes
// only appear in the list when there's data, so the table never shows an empty section.
enum HomeSection: Equatable {
    case header
    case savedHeader
    case savedRecipes
    case exploreHeader
    case exploreRecipes
}
