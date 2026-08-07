//
//  SessionManger.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Foundation

final class UserDefaultsSessionStore: SessionManaging {
    // MARK: - Storage Properties
    private let suiteName = "com.recipeapp.session"
    private lazy var defaults: UserDefaults = UserDefaults(suiteName: suiteName) ?? .standard
    // MARK: - Read-Only Properties
    var isLoggedIn: Bool { defaults.bool(forKey: Keys.isLoggedIn) }
    var userId: Int { defaults.integer(forKey: Keys.userId) }
    var userName: String? { defaults.string(forKey: Keys.userName) }
    var accessToken: String? { defaults.string(forKey: Keys.accessToken) }
    // Kept in .standard, not the session suite: clearSession() wipes the whole suite, and
    // this flag has to outlive a logout so the intro isn't shown again.
    var hasCompletedOnboarding: Bool { UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding) }
    // MARK: - Save Session
    func saveAuthSession(_ response: LoginResponse) {
        defaults.set(response.userId, forKey: Keys.userId)
        defaults.set(response.name, forKey: Keys.userName)
        defaults.set(response.accessToken, forKey: Keys.accessToken)
        defaults.set(response.refreshToken, forKey: Keys.refreshToken)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }

    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: Keys.hasCompletedOnboarding)
    }
    // MARK: - Clear Session
    func clearSession() {
        defaults.removePersistentDomain(forName: suiteName)
    }
    // MARK: - Keys
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let userId = "userId"
        static let userName = "userName"
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
}
