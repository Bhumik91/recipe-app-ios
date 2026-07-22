//
//  RecipeDetailDTO.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 21/07/26.
//

struct RecipeDetailDTO: Decodable {
    let id: Int
    let title: String?
    let image: String?
    let servings: Int?
    let readyInMinutes: Int?
    let sourceName: String?
    let spoonacularSourceUrl: String?
    let extendedIngredients: [IngredientDTO]?
    let analyzedInstructions: [InstructionGroupDTO]?
}

struct IngredientDTO: Decodable {
    let id: Int?
    let name: String?
    let image: String?
    let measures: MeasuresDTO?
}

struct MeasuresDTO: Decodable {
    let metric: MetricAmountDTO?
}

struct MetricAmountDTO: Decodable {
    let amount: Double?
    let unitShort: String?
    let unitLong: String?
}

struct InstructionGroupDTO: Decodable {
    let name: String?
    let steps: [StepDTO]?
}

struct StepDTO: Decodable {
    let number: Int?
    let step: String?
    let ingredients: [StepIngredientDTO]?
}

struct StepIngredientDTO: Decodable {
    let id: Int?
    let name: String?
}
