//
//  PermissionManaging.swift
//  RecipeApp
//

import Foundation

/// The app's single entry point for permission checks and requests.
/// Free of UIKit types, so it is safe to inject into ViewModels and storage types.
protocol PermissionManaging: AnyObject {
    func status(of permission: AppPermission) async -> PermissionStatus

    /// Convenience for the common "may I proceed?" question.
    func isGranted(_ permission: AppPermission) async -> Bool

    @discardableResult
    func request(_ permission: AppPermission) async -> PermissionStatus

    /// Requests the permission only when it has never been asked for. Returns the resulting
    /// status either way, so callers can distinguish "just granted" from "already denied".
    @discardableResult
    func requestIfNeeded(_ permission: AppPermission) async -> PermissionStatus
}
