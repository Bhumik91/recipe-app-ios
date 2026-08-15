//
//  ShareRecipeAlertView.swift
//  RecipeApp
//

import UIKit

final class ShareRecipeAlertView: UIView {
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var linkLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!

    // MARK: - Constants
    private enum Metric {
        static let copyFeedbackDuration: TimeInterval = 2.0
    }

    // MARK: - Properties
    var onClose: (() -> Void)?
    private var shareURL: String = ""

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
        bundle.loadNibNamed("ShareRecipeAlertView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        setupActions()
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
    }

    @objc private func closeTapped() {
        onClose?()
    }

    @objc private func copyTapped() {
        UIPasteboard.general.string = shareURL
        copyButton.isEnabled = false
        copyButton.setTitle("Link is copied", for: .normal)

        DispatchQueue.main.asyncAfter(deadline: .now() + Metric.copyFeedbackDuration) { [weak self] in
            self?.copyButton.isEnabled = true
            self?.copyButton.setTitle("Copy Link", for: .normal)
        }
    }

    // MARK: - Public API
    func configure(shareURL: String) {
        self.shareURL = shareURL
        linkLabel.text = shareURL
    }
}

// MARK: - Presentation
final class ShareRecipeAlertViewController: UIViewController {
    let alertView = ShareRecipeAlertView()

    init(shareURL: String) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        alertView.configure(shareURL: shareURL)
        alertView.onClose = { [weak self] in self?.dismiss(animated: true) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = alertView
    }
}

extension ShareRecipeAlertViewController: UIViewControllerTransitioningDelegate {
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
