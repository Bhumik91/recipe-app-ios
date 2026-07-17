//
//  SignupViewModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//

import Combine
import Foundation

final class SignupViewModel {
    // MARK: - Published Properties
    @Published private(set) var state: ViewState<Void> = .idle
    // MARK: - Sign Up Action
    func signup(name: String?, userName: String?, password: String?, confirmPassword: String?, termsAccepted: Bool) {
        // Name Validation
        guard let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .failure(AuthFieldError.name)
            return
        }
        // Password Validation
        guard let password, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .failure(AuthFieldError.password)
            return
        }
        // Confirm Password Validation
        guard let confirmPassword, !confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .failure(AuthFieldError.confirmPassword(reason: .empty))
            return
        }
        guard confirmPassword == password else {
            state = .failure(AuthFieldError.confirmPassword(reason: .mismatch))
            return
        }
        // Terms Validation
        guard termsAccepted else {
            state = .failure(AuthFieldError.terms)
            return
        }
        // Success Delay Implementation (3000 milliseconds)
        state = .loading
        Task {
            do {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                state = .success(Void())
            } catch {
                state = .failure(NetworkError.unknown)
            }
        }
    }
}
