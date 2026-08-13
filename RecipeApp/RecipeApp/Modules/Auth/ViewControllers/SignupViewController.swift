//
//  SignupViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//
import Combine
import UIKit

final class SignupViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var nameContainerView: UIView!
    @IBOutlet private weak var userNameContainerView: UIView!
    @IBOutlet private weak var passwordContainerView: UIView!
    @IBOutlet private weak var confPasswordContainerView: UIView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confPasswordTextField: UITextField!
    @IBOutlet private weak var googleLoginButton: UIButton!
    @IBOutlet private weak var facebookLoginButton: UIButton!
    @IBOutlet private weak var termsAndcondCheckButton: UIButton!
    @IBOutlet private weak var loginClickableTextView: UILabel!
    @IBOutlet private weak var confPasswordErrorLabel: UILabel!
    @IBOutlet private weak var userNameErrorLabel: UILabel!
    @IBOutlet private weak var nameErrorLabel: UILabel!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var signupButton: UIButton!
    @IBOutlet private weak var termsErrorLabel: UILabel!
    
    
    // MARK: - Properties
    private lazy var fieldMap: [UITextField: (container: UIView, errorLabel: UILabel)] = [
        nameTextField: (nameContainerView, nameErrorLabel),
        userNameTextField: (userNameContainerView, userNameErrorLabel),
        passwordTextField: (passwordContainerView, passwordErrorLabel),
        confPasswordTextField: (confPasswordContainerView, confPasswordErrorLabel)
    ]
    private var cancellabels = Set<AnyCancellable>()
    var viewModel: SignupViewModel?
    weak var coordinatorDelegate: SignupViewControllerDelegate?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureLoginLabel()
        bindViewModel()
        fieldMap.keys.forEach { $0.delegate = self }
    }
}
// MARK: - View Model Binding
extension SignupViewController {
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
                self.coordinatorDelegate?.signupDidSucceed()
            case .failure(let error):
                self.showLoadingState(false)
                if let fieldError = error as? AuthFieldError {
                    self.highlightError(fieldError)
                } else if let networkError = error as? NetworkError {
                    self.showToast(with: networkError)
                } else {
                    self.showToast(with: NetworkError.unknown)
                }
            }
        }.store(in: &cancellabels)
    }
}

// MARK: - UI Configuration
extension SignupViewController {
    private func setupUI() {
        self.navigationItem.hidesBackButton = true
        setupTextFieldBorder()
        setupButtonShadow()
        
        nameTextField.returnKeyType = .next
        userNameTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .next
        confPasswordTextField.returnKeyType = .done
    }
    private func setupTextFieldBorder() {
        let containers = [
            nameContainerView, userNameContainerView, passwordContainerView,
            confPasswordContainerView,
        ]

        containers.forEach { container in
            guard let container else { return }
            // Implementing styling for boarder
            container.layer.cornerRadius = 18
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.systemGray5.cgColor
            container.backgroundColor = .white
            applyShadow(on: container)
        }
    }
    private func setupButtonShadow() {
        let buttons = [googleLoginButton, facebookLoginButton]

        buttons.forEach { button in
            guard let button else { return }
            //Implementing background for button
            button.layer.cornerRadius = 10
            button.backgroundColor = .white
            applyShadow(on: button)
        }
    }
    private func applyShadow(on view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
    }
}
//MARK: - TextFieldDelegate
extension SignupViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        clearError(for: textField)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        guard validate(textField) else {
            return false
        }
        switch textField {
        case nameTextField:
            userNameTextField.becomeFirstResponder()
        case userNameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confPasswordTextField.becomeFirstResponder()
        case confPasswordTextField:
            textField.resignFirstResponder()
            signupButtonTapped(signupButton)
        default:
            break
        }
        return true
    }
}
// MARK: - Gesture Configuration
extension SignupViewController {
    private func configureLoginLabel() {
        loginClickableTextView.isUserInteractionEnabled = true
        // Initializing tap gesture
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLoginLabel))
        loginClickableTextView.addGestureRecognizer(tap)
    }
    @objc
    private func didTapLoginLabel() {
        coordinatorDelegate?.signupDidTapLogin()
    }
}
// MARK: - Actions
private extension SignupViewController {
    @IBAction private func checkBoxTapped(_ sender: UIButton) {
        termsAndcondCheckButton.isSelected.toggle()
    }
    @IBAction private func signupButtonTapped(_ sender: UIButton) {
        viewModel?.signup( name: nameTextField.text, userName: userNameTextField.text, password: passwordTextField.text, confirmPassword: confPasswordTextField.text, termsAccepted: termsAndcondCheckButton.isSelected)
    }
}
// MARK: - Validation Helpers
extension SignupViewController {
    private func clearError(for textField: UITextField) {
        guard let field = fieldMap[textField] else { return }

        field.container.clearFieldError()
        field.errorLabel.isHidden = true
    }
    private func validate(_ textField: UITextField) -> Bool {
        let text = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !text.isEmpty else {
            switch textField {
            case nameTextField:
                highlightError(.name)

            case userNameTextField:
                highlightError(.userName)

            case passwordTextField:
                highlightError(.password)

            case confPasswordTextField:
                highlightError(.confirmPassword(reason: .empty))

            default:
                break
            }
            return false
        }

        return true
    }
    private func highlightError(_ error: AuthFieldError) {
        let fieldMapKey: UITextField? = {
            switch error {
            case .userName: return userNameTextField
            case .password: return passwordTextField
            case .name: return nameTextField
            case .confirmPassword: return confPasswordTextField
            case .terms: return nil
            }
        }()

        if let textField = fieldMapKey, let field = fieldMap[textField] {
            field.container.setFieldError()
            textField.becomeFirstResponder()
            field.errorLabel.isHidden = false
            field.errorLabel.text = error.message
        } else if case .terms = error {
            termsErrorLabel.isHidden = false
            termsErrorLabel.text = error.message
        }
    }
}
// MARK: - UI State Helpers
extension SignupViewController {
    private func showIdleState() {
        self.fieldMap.keys.forEach { $0.text = nil }
        self.resetFieldStyles()
        self.showLoadingState(false)
    }
    private func showLoadingState(_ isLoading: Bool) {
        self.signupButton.setLoading(isLoading)
        self.fieldMap.keys.forEach { $0.isEnabled = !isLoading }
    }
    private func resetFieldStyles() {
        self.fieldMap.values.forEach { field in
            field.container.clearFieldError()
            field.errorLabel.isHidden = true
        }
        self.termsErrorLabel.isHidden = true 
    }
}
// MARK: - Keyboard Handling
extension SignupViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
