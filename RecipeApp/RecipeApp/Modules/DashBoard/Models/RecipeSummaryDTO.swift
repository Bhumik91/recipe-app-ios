//
//  RecipeSummaryDTO.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

struct RecipeSummaryDTO: Decodable {
    let id: Int
    let title: String
    let image: String?
    let readyInMinutes: Int?
    // Only present when the endpoint returns full recipe information (complexSearch with
    // addRecipeInformation=true, or informationBulk) — absent from a plain search result.
    let cuisines: [String]?
}

struct RecipeSearchResponse: Decodable {
    let results: [RecipeSummaryDTO]
    let offset: Int
    let number: Int
    let totalResults: Int
}
