//
//  NotificationLog+CoreDataClass.swift
//  RecipeApp
//

import CoreData
import Foundation

/// Managed object for one row of the notification log.
/// Codegen is Manual/None, so this class and its properties are hand-written.
/// Never let one escape its context — map to `NotificationLogUIModel` at the store boundary.
@objc(NotificationLog)
public class NotificationLog: NSManagedObject {}
