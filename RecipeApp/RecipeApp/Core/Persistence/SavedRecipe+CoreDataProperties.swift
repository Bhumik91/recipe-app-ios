//
//  SavedRecipe+CoreDataProperties.swift
//  RecipeApp
//

import CoreData
import Foundation

extension SavedRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRecipe> {
        NSFetchRequest<SavedRecipe>(entityName: "SavedRecipe")
    }

    @NSManaged public var recipeId: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var title: String
    @NSManaged public var imageURL: String
    @NSManaged public var readyInMinutes: Int64
    @NSManaged public var savedAt: Date
    // Comma-joined; no Android equivalent — see the entity note in the migration plan.
    @NSManaged public var cuisines: String?
}
