//
//  AuthCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//
import UIKit

final class AuthCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var container: DependencyContainer
    weak var parentDelegate: AuthCoordinatorDelegate?
    // MARK: - Constants
    let storyboard = UIStoryboard(name: "Auth", bundle: nil)
    // MARK: - Initializer
    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    // MARK: - Coordinator
    func start() {
        showLogin()
    }
}
// MARK: - Navigation
extension AuthCoordinator {
    private func showLogin() {
        guard let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController"
        ) as? LoginViewController else {
            fatalError("LoginViewController not found in Auth.storyboard")
        }
        loginVC.viewModel = LoginViewModel(authRepository: container.authRepository)
        loginVC.coordinatorDelegate = self
        navigationController.setViewControllers([loginVC], animated: false)
    }
    private func showSignup() {
        guard let signupVC = storyboard.instantiateViewController(
            withIdentifier: "SignupViewController"
        ) as? SignupViewController else {
            fatalError("SignupViewController not found in Auth.storyboard")
        }
        signupVC.viewModel = SignupViewModel()
        signupVC.coordinatorDelegate = self
        navigationController.pushViewController(signupVC, animated: true)
    }
}
// MARK: - LoginViewControllerDelegate
extension AuthCoordinator: LoginViewControllerDelegate {
    func loginDidSucceed() {
        self.parentDelegate?.authFlowDidFinish(self)
    }
    func loginDidTapSignUp() {
        self.showSignup()
    }
}
// MARK: - SignupViewControllerDelegate
extension AuthCoordinator: SignupViewControllerDelegate {
    func signupDidSucceed() {
        navigationController.popViewController(animated: true)
    }
    func signupDidTapLogin() {
        navigationController.popViewController(animated: true)
    }
}
