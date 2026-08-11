//
//  HomeSection.swift
//  RecipeApp
//

// Drives HomeViewController's table sections dynamically — savedHeader/savedRecipes
// only appear in the list when there's data, so the table never shows an empty section.
// The greeting/search/chips header isn't here — it floats above the table as its own
// overlay view, see HomeViewController+HeaderVisibility.
enum HomeSection: Equatable {
    case savedHeader
    case savedRecipes
    case exploreHeader
    case exploreRecipes
}
