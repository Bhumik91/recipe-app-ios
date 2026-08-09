//
//  PermissionStatus.swift
//  RecipeApp
//

import Foundation

/// Authorization state, normalized across every iOS permission API.
/// Handlers map their own framework's status enum onto this one.
enum PermissionStatus {
    /// Never asked — the system prompt can still be shown.
    case notDetermined
    /// Granted, including the quieter variants some frameworks expose (e.g. provisional
    /// notification authorization).
    case authorized
    /// Refused by the user. The system prompt will not appear again; only Settings can change it.
    case denied
    /// Blocked outside the user's control (parental controls, MDM policy). Prompting is pointless.
    case restricted

    /// Whether the app may proceed with the feature behind this permission.
    var isGranted: Bool {
        self == .authorized
    }

    /// Whether asking would actually show the system prompt.
    var canPrompt: Bool {
        self == .notDetermined
    }
}
