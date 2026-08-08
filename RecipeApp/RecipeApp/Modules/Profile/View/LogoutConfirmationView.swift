//
//  LogoutConfirmationView.swift
//  RecipeApp
//

import UIKit

/// Card body of the logout confirmation dialog. Mirrors Android's
/// `dialog_logout_confirmation.xml` — title, explanation, then Cancel / Logout.
final class LogoutConfirmationView: UIView {
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var confirmButton: UIButton!

    // MARK: - Properties
    var onCancel: (() -> Void)?
    var onConfirm: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("LogoutConfirmationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func confirmTapped() {
        onConfirm?()
    }
}

// MARK: - Presentation
/// Presents `LogoutConfirmationView` as a centered card, reusing the share alert's
/// presentation controller and animator so both dialogs behave identically.
final class LogoutConfirmationViewController: UIViewController {
    private let alertView = LogoutConfirmationView()

    /// Called after the dialog has finished dismissing, so the logout navigation isn't
    /// racing the dismissal animation.
    var onConfirm: (() -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self

        alertView.onCancel = { [weak self] in self?.dismiss(animated: true) }
        alertView.onConfirm = { [weak self] in
            guard let self else { return }
            dismiss(animated: true) { [weak self] in
                self?.onConfirm?()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = alertView
    }
}

extension LogoutConfirmationViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ShareAlertPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        ShareAlertTransitionAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ShareAlertTransitionAnimator(isPresenting: false)
    }
}
