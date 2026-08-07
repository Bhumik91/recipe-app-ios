//
//  PermissionManager.swift
//  RecipeApp
//

import Foundation

/// Routes each permission to its registered `PermissionHandling` implementation.
/// The registry is the only place that changes when a permission is added.
final class PermissionManager: PermissionManaging {

    // MARK: - Registry
    private let handlers: [AppPermission: PermissionHandling]

    // MARK: - Init
    /// - Parameter handlers: one handler per supported permission; tests can inject fakes.
    init(handlers: [PermissionHandling] = [NotificationPermissionHandler()]) {
        self.handlers = Dictionary(
            handlers.map { ($0.permission, $0) },
            // A duplicate registration is a programming error, not a runtime condition —
            // keep the first and let the assertion below surface it in debug builds.
            uniquingKeysWith: { first, _ in first }
        )
        assert(
            Set(handlers.map(\.permission)).count == handlers.count,
            "Two handlers registered for the same AppPermission"
        )
    }

    // MARK: - PermissionManaging
    func status(of permission: AppPermission) async -> PermissionStatus {
        guard let handler = handlers[permission] else {
            assertionFailure("No PermissionHandling registered for \(permission)")
            return .denied
        }
        return await handler.status()
    }

    func isGranted(_ permission: AppPermission) async -> Bool {
        await status(of: permission).isGranted
    }

    @discardableResult
    func request(_ permission: AppPermission) async -> PermissionStatus {
        guard let handler = handlers[permission] else {
            assertionFailure("No PermissionHandling registered for \(permission)")
            return .denied
        }
        return await handler.request()
    }

    @discardableResult
    func requestIfNeeded(_ permission: AppPermission) async -> PermissionStatus {
        let current = await status(of: permission)
        guard current.canPrompt else { return current }
        return await request(permission)
    }
}
