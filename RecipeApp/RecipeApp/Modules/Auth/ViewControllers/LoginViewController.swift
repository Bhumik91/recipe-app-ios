//
//  LoginViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//

import Combine
import UIKit

final class LoginViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private var userNameContainerView: UIView!
    @IBOutlet private var passwordContainerView: UIView!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet private var userNameErrorLabel: UILabel!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var passwordErrorLabel: UILabel!
    @IBOutlet private var googleLoginButton: UIButton!
    @IBOutlet private var facebookLoginButton: UIButton!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var signupClickableLabelView: UILabel!
    // MARK: - Properties
    var viewModel: LoginViewModel?
    private var cancellabels = Set<AnyCancellable>()
    weak var coordinatorDelegate: LoginViewControllerDelegate?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSignupLabel()
        bindViewModel()
    } 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showIdleState()
    }
}
// MARK: - View Model Binding
extension LoginViewController {
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.$state.receive(on: DispatchQueue.main).sink {
            [weak self] reciveValue in
            guard let self else { return }
            switch reciveValue {
            case .idle:
                self.showIdleState()
            case .loading:
                self.showLoadingState(true)
            case .success():
                self.showIdleState()
                self.coordinatorDelegate?.loginDidSucceed()
            case .failure(let error):
                self.showLoadingState(false)
                if let fieldError = error as? AuthFieldError {
                    self.highlightError(fieldError)
                } else if let networkError = error as? NetworkError {
                    self.showAlert(with: networkError)
                } else {
                    self.showAlert(with: NetworkError.unknown)
                }
            }
        }.store(in: &cancellabels)
    }
}
// MARK: - UI Configuration
extension LoginViewController {
    private func configureUI() {
        configureTextFieldContainers()
        configureSocialButton()
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        userNameTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .done
    }
    private func configureTextFieldContainers() {
        let containers = [userNameContainerView, passwordContainerView]

        containers.forEach { container in
            guard let container else { return }
            // Implementing styling for boarder
            container.layer.cornerRadius = 18
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.systemGray5.cgColor
            container.backgroundColor = .white
            // Implementing Shadow and radius
            applyShadow(to: container)
        }
    }
    private func configureSocialButton() {
        let buttons = [googleLoginButton, facebookLoginButton]

            buttons.forEach { button in
                guard let button else { return }
                //Implementing background for button
                button.layer.cornerRadius = 10
                button.backgroundColor = .white
                //Implementing shadow effect for button
                applyShadow(to: button)
            }
    }
    private func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
    }
}
// MARK: - Gesture Configuration
extension LoginViewController {
    private func configureSignupLabel() {
        signupClickableLabelView.isUserInteractionEnabled = true
        // Initializing tap gesture
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(navigateToSignupVC))
        signupClickableLabelView.addGestureRecognizer(tap)
    }
    @objc
    private func navigateToSignupVC() {
        coordinatorDelegate?.loginDidTapSignUp()
    }
}
// MARK: - Actions
extension LoginViewController{
    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        viewModel?.login(
            userName: userNameTextField.text, password: passwordTextField.text)
    }
    
    @IBAction private func textFieldDidChange(_ sender: UITextField) {
        if sender == userNameTextField {
            userNameContainerView.clearFieldError()
            userNameErrorLabel.isHidden = true
        } else if sender == passwordTextField {
            passwordContainerView.clearFieldError()
            passwordErrorLabel.isHidden = true
        }
    }
}
// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if textField == userNameTextField {
            userNameContainerView.clearFieldError()
            userNameErrorLabel.isHidden = true
        } else if textField == passwordTextField {
            passwordContainerView.clearFieldError()
            passwordErrorLabel.isHidden = true
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            if textField == userNameTextField {
                highlightError(.userName)
                DispatchQueue.main.async { textField.becomeFirstResponder() }
            } else if textField == passwordTextField {
                highlightError(.password)
                DispatchQueue.main.async { textField.becomeFirstResponder() }
            }
            return false
        }
        
        if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            loginButtonTapped(loginButton)
        }
        
        return true
    }
}
// MARK: - Helper Methods
extension LoginViewController {
    private func showIdleState() {
        self.userNameTextField.text = nil
        self.passwordTextField.text = nil
        resetFieldStyles()
        self.showLoadingState(false)
    }
    private func showLoadingState(_ isLoading: Bool) {
        self.loginButton.setLoading(isLoading)
        self.userNameTextField.isEnabled = !isLoading
        self.passwordTextField.isEnabled = !isLoading
    }
    private func highlightError(_ error: AuthFieldError) {
        switch error {
        case .userName:
            userNameContainerView.setFieldError()
            userNameTextField.becomeFirstResponder()
            userNameErrorLabel.isHidden = false
            userNameErrorLabel.text = error.message
        case .password:
            passwordContainerView.setFieldError()
            passwordTextField.becomeFirstResponder()
            passwordErrorLabel.isHidden = false
            passwordErrorLabel.text = error.message
        default: showAlert(with: NetworkError.unknown)
        }
    }
    private func resetFieldStyles() {
        userNameContainerView.clearFieldError()
        userNameErrorLabel.isHidden = true
        passwordContainerView.clearFieldError()
        passwordErrorLabel.isHidden = true
    }
}
// MARK: - Keyboard Handling
extension LoginViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
