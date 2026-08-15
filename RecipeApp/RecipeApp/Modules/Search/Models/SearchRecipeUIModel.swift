//
//  SearchRecipeUIModel.swift
//  RecipeApp
//

struct SearchRecipeUIModel: Codable, Hashable {
    let id: Int
    let title: String
    let imageURL: String
}

extension RecipeUIModel {
    func toSearchUIModel() -> SearchRecipeUIModel {
        SearchRecipeUIModel(id: id, title: title, imageURL: imageURL)
    }
}
