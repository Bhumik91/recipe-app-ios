//
//  PermissionHandling.swift
//  RecipeApp
//

import Foundation

/// Knows how to read and request one specific permission — the extension point for new ones.
/// All async because iOS has no synchronous authorization check for most permissions.
protocol PermissionHandling: AnyObject {
    /// The permission this handler is responsible for; used as its registry key.
    var permission: AppPermission { get }

    func status() async -> PermissionStatus

    /// Prompts only when still undetermined, and returns the resulting status.
    /// Implementations must short-circuit on an already-settled status.
    @discardableResult
    func request() async -> PermissionStatus
}
