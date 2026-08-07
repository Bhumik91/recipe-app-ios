//
//  SessionManaging.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//

protocol SessionManaging {
    var isLoggedIn: Bool { get }
    var userId: Int { get }
    var userName: String? { get }
    var accessToken: String? { get }
    /// Whether onboarding has ever been completed on this device.
    /// Survives `clearSession()` — a logged-out user lands on Login, not the intro.
    var hasCompletedOnboarding: Bool { get }
    func saveAuthSession(_ response: LoginResponse)
    func markOnboardingCompleted()
    func clearSession()
}