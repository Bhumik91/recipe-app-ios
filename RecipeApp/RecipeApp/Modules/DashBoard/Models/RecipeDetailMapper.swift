//
//  RecipeDetailMapper.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 21/07/26.
//

extension RecipeDetailDTO {
    func toUIModel(isSaved: Bool) -> RecipeDetailUIModel {
        RecipeDetailUIModel(
            id: id,
            title: title ?? "",
            imageURL: image,
            servings: servings ?? 1,
            readyInMinutes: readyInMinutes ?? 0,
            attribution: sourceName,
            shareURL: spoonacularSourceUrl,
            ingredients: (extendedIngredients ?? []).map { $0.toUIModel() },
            instructionSteps: (analyzedInstructions ?? [])
                .flatMap { $0.steps ?? [] }
                .map { $0.toUIModel() },
            isSaved: isSaved
        )
    }
}

extension IngredientDTO {
    func toUIModel() -> IngredientUIModel {
        IngredientUIModel(
            id: id ?? 0,
            name: name ?? "",
            imageURL: image.map { "https://img.spoonacular.com/ingredients_100x100/\($0)" } ?? "",
            baseAmount: measures?.metric?.amount ?? 0,
            unit: measures?.metric?.unitShort ?? ""
        )
    }
}

extension StepDTO {
    func toUIModel() -> StepUIModel {
        StepUIModel(
            number: number ?? 0,
            instruction: step ?? "",
            requiredIngredientNames: (ingredients ?? [])
                .compactMap { $0.name }
                .filter { !$0.isEmpty }
        )
    }
}
