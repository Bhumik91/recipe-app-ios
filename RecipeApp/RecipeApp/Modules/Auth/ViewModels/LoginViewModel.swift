//
//  LoginViewModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Combine

final class LoginViewModel {
    // MARK: - Published Properties
    @Published private(set) var state: ViewState<Void> = .idle
    
    // MARK: - Dependencies
    private let authRepository: AuthRepositoryProtocol
    
    // MARK: - Initializer
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    // MARK: - Authentication Methods
    func login(userName: String?, password:String?) {
        guard let userName, !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .failure(AuthFieldError.userName)
            return
        }
        guard let password, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .failure(AuthFieldError.password)
            return
        }
        state = .loading
        Task {
            do {
                try await authRepository.login(userName: userName, password: password)
                state = .success(Void())
            } catch let error as NetworkError {
                state = .failure(error)
            } catch {
                state = .failure(NetworkError.unknown)
            }
        }
    }
}
