//
//  ProfileTab.swift
//  RecipeApp
//

/// The three segments of the Profile screen.
/// Only `.recipes` has content; the other two are placeholders.
enum ProfileTab: Int, CaseIterable {
    case recipes = 0
    case videos = 1
    case tag = 2

    var title: String {
        switch self {
        case .recipes: return "Recipes"
        case .videos: return "Videos"
        case .tag: return "Tag"
        }
    }

    /// Empty-state copy for the tabs that have no backing feature yet.
    var placeholder: (title: String, message: String)? {
        switch self {
        case .recipes: return nil
        case .videos: return ("No videos yet", "Videos you upload will show up here.")
        case .tag: return ("No tags yet", "Recipes you tag will show up here.")
        }
    }
}
