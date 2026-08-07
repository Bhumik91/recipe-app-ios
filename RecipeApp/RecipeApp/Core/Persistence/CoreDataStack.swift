//
//  CoreDataStack.swift
//  RecipeApp
//

import CoreData
import Foundation

/// Owns the `NSPersistentContainer` for `RecipeApp.xcdatamodeld`.
/// Recreates the store if it can't be opened — the log is history, not a source of truth.
final class CoreDataStack {

    // MARK: - Properties
    private let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Init
    init(modelName: String = "RecipeApp") {
        container = NSPersistentContainer(name: modelName)
        loadStores()

        // Background writes must reach the context the UI reads from.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Writing
    /// Runs `block` on a private queue context so callers never wait on disk.
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
        }
    }

    // MARK: - Store Loading
    private func loadStores() {
        guard let error = load() else { return }

        // Destructive fallback, like Room's fallbackToDestructiveMigration.
        assertionFailure("Core Data store failed to load, recreating it: \(error)")
        destroyStores()

        if let secondError = load() {
            assertionFailure("Core Data store unrecoverable after reset: \(secondError)")
        }
    }

    /// Loads the stores synchronously and returns the first failure, if any.
    private func load() -> Error? {
        var loadError: Error?
        // The default store description loads synchronously, so this runs before we return.
        container.loadPersistentStores { _, error in
            loadError = error
        }
        return loadError
    }

    private func destroyStores() {
        let coordinator = container.persistentStoreCoordinator
        for description in container.persistentStoreDescriptions {
            guard let url = description.url else { continue }
            try? coordinator.destroyPersistentStore(at: url, ofType: description.type)
        }
    }
}
