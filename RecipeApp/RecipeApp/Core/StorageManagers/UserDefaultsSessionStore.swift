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
    // MARK: - Save Session
    func saveAuthSession(_ response: LoginResponse) {
        defaults.set(response.userId, forKey: Keys.userId)
        defaults.set(response.name, forKey: Keys.userName)
        defaults.set(response.accessToken, forKey: Keys.accessToken)
        defaults.set(response.refreshToken, forKey: Keys.refreshToken)
        defaults.set(true, forKey: Keys.isLoggedIn)
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
    }
}
