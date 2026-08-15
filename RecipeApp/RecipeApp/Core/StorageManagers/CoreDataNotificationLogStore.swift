//
//  CoreDataNotificationLogStore.swift
//  RecipeApp
//

import Combine
import CoreData
import Foundation

/// Core Data implementation of `NotificationLogStoring`.
/// Writes on a background context, reads via `NSFetchedResultsController` on the view context.
final class CoreDataNotificationLogStore: NSObject, NotificationLogStoring {

    // MARK: - Dependencies
    private let stack: CoreDataStack
    private let sessionManager: SessionManaging

    // MARK: - Observation
    private var fetchedResultsController: NSFetchedResultsController<NotificationLog>?
    // Seeded empty so subscribers render the empty state before the first fetch lands.
    private let subject = CurrentValueSubject<[NotificationLogUIModel], Never>([])

    // MARK: - Init
    init(stack: CoreDataStack, sessionManager: SessionManaging) {
        self.stack = stack
        self.sessionManager = sessionManager
        super.init()
    }

    // MARK: - NotificationLogStoring
    func log(recipeId: Int, recipeName: String, recipeImageURL: String?, action: RecipeAction) {
        // Resolved per call, so the row records whoever is logged in at the moment of the tap.
        let userId = Int64(sessionManager.userId)

        stack.performBackgroundTask { context in
            let entry = NotificationLog(context: context)
            entry.id = UUID()
            entry.recipeId = Int64(recipeId)
            entry.recipeName = recipeName
            entry.recipeImageURL = recipeImageURL
            entry.action = action.rawValue
            entry.timestamp = Date()
            entry.userId = userId

            // A failed history write must never break the save that triggered it.
            try? context.save()
        }
    }

    func observeLogs() -> AnyPublisher<[NotificationLogUIModel], Never> {
        startObservingIfNeeded()
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Fetched Results
    private func startObservingIfNeeded() {
        // Rebuild when the user changes; the predicate bakes the id in.
        let userId = Int64(sessionManager.userId)
        if let existing = fetchedResultsController,
           existing.fetchRequest.predicate == Self.predicate(for: userId) {
            return
        }

        let request = NotificationLog.fetchRequest()
        request.predicate = Self.predicate(for: userId)
        // NSFetchedResultsController requires at least one sort descriptor.
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: stack.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        fetchedResultsController = controller

        do {
            try controller.performFetch()
            publishCurrentRows()
        } catch {
            assertionFailure("Notification log fetch failed: \(error)")
            subject.send([])
        }
    }

    private func publishCurrentRows() {
        let rows = fetchedResultsController?.fetchedObjects ?? []
        // Mapped on the view context's queue, so only value types escape.
        subject.send(rows.map { $0.toUIModel() })
    }

    private static func predicate(for userId: Int64) -> NSPredicate {
        NSPredicate(format: "userId == %lld", userId)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CoreDataNotificationLogStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        publishCurrentRows()
    }
}
