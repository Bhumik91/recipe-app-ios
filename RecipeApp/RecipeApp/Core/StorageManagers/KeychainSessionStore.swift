//
//  KeychainSessionStore.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//
import Foundation
import Security

final class KeychainSessionStore: SessionManaging {
    // MARK: - Read-Only Properties
    var isLoggedIn: Bool {
        return read(forKey: Keys.isLoggedIn) == "true"
    }
    var userId: Int {
        if let idString = read(forKey: Keys.userId), let id = Int(idString) {
            return id
        }
        return 0
    }
    var userName: String? {
        return read(forKey: Keys.userName)
    }
    var accessToken: String? {
        return read(forKey: Keys.accessToken)
    }
    // MARK: - Save Session
    func saveAuthSession(_ response: LoginResponse) {
        if let userId = response.userId {
            save(String(userId), forKey: Keys.userId)
        }
        if let name = response.name {
            save(name, forKey: Keys.userName)
        }
        if let accessToken = response.accessToken {
            save(accessToken, forKey: Keys.accessToken)
        }
        if let refreshToken = response.refreshToken {
            save(refreshToken, forKey: Keys.refreshToken)
        }
        save("true", forKey: Keys.isLoggedIn)
    }

    // MARK: - Clear Session
    func clearSession() {
        delete(forKey: Keys.isLoggedIn)
        delete(forKey: Keys.userId)
        delete(forKey: Keys.userName)
        delete(forKey: Keys.accessToken)
        delete(forKey: Keys.refreshToken)
    }
    // MARK: - Keys
    private enum Keys {
        static let isLoggedIn = "com.recipeapp.isLoggedIn"
        static let userId = "com.recipeapp.userId"
        static let userName = "com.recipeapp.userName"
        static let accessToken = "com.recipeapp.accessToken"
        static let refreshToken = "com.recipeapp.refreshToken"
    }
    // MARK: - Keychain Helpers
    private func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    private func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
