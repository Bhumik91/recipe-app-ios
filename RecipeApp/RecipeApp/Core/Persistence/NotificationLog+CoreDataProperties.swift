//
//  NotificationLog+CoreDataProperties.swift
//  RecipeApp
//

import CoreData
import Foundation

extension NotificationLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationLog> {
        NSFetchRequest<NotificationLog>(entityName: "NotificationLog")
    }

    // Core Data has no autoincrement, so identity is a UUID.
    @NSManaged public var id: UUID
    @NSManaged public var recipeId: Int64
    @NSManaged public var recipeName: String
    @NSManaged public var recipeImageURL: String?
    // Raw value of `RecipeAction` — Core Data cannot persist a Swift enum.
    @NSManaged public var action: String
    @NSManaged public var timestamp: Date
    @NSManaged public var userId: Int64
}
