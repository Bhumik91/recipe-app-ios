//
//  RecipeUIModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//
struct RecipeUIModel {
    let id: Int
    let title: String
    let readyInMinutes: Int
    let imageURL: String
    var isSaved: Bool
}

struct PaginatedRecipes {
    let results: [RecipeUIModel]
    let offset: Int
    let number: Int
    let totalResults: Int
}

extension RecipeSummaryDTO {
    func toUIModel(isSaved: Bool) -> RecipeUIModel {
        RecipeUIModel(
            id: id,
            title: title,
            readyInMinutes: readyInMinutes ?? 0,
            imageURL: image ?? "",
            isSaved: isSaved
        )
    }
}
