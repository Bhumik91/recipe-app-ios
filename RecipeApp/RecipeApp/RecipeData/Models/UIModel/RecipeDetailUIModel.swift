//
//  RecipeDetailUIModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 21/07/26.
//

import Foundation

struct RecipeDetailUIModel {
    let id: Int
    let title: String
    let imageURL: String?
    let servings: Int
    let readyInMinutes: Int
    let attribution: String?
    let shareURL: String?
    let ingredients: [IngredientUIModel]
    let instructionSteps: [StepUIModel]
    var isSaved: Bool
}

struct IngredientUIModel {
    let id: Int
    let name: String
    let imageURL: String
    let baseAmount: Double
    let unit: String

    func scaledAmount(baseServings: Int, targetServings: Int) -> Double {
        baseAmount * (Double(targetServings) / Double(max(baseServings, 1)))
    }

    func displayAmount(baseServings: Int, targetServings: Int) -> String {
        let scaled = scaledAmount(baseServings: baseServings, targetServings: targetServings)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: scaled)) ?? "\(scaled)"
        return "\(formatted) \(unit)".trimmingCharacters(in: .whitespaces)
    }
}

struct StepUIModel {
    let number: Int
    let instruction: String
    let requiredIngredientNames: [String]
}
