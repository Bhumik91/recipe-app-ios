//
//  SavedRecipe+CoreDataClass.swift
//  RecipeApp
//

import CoreData
import Foundation

/// Managed object for one saved recipe, the Room replacement for `SavedRecipeEntity`.
/// Codegen is Manual/None, so this class and its properties are hand-written.
/// Never let one escape its context — map to `RecipeUIModel` at the store boundary.
@objc(SavedRecipe)
public class SavedRecipe: NSManagedObject {}
