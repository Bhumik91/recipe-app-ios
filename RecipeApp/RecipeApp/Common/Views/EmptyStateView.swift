//
//  EmptyStateView.swift
//  RecipeApp
//

import UIKit

// Reusable title + message placeholder for any screen/section with nothing to show —
// an empty list, or (with retryTitle/onRetry set) a fetch error with a "Try Again" action.
final class EmptyStateView: UIView {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryLabel = UILabel()
    private var onRetry: (() -> Void)?

    init(title: String, message: String, retryTitle: String? = nil, onRetry: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.onRetry = onRetry
        setupUI(title: title, message: message, retryTitle: retryTitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Lets a container reuse the same instance for a new error/empty state instead of
    // re-instantiating the view (e.g. HomeViewController swapping error text on retry).
    func update(title: String, message: String, retryTitle: String? = nil, onRetry: (() -> Void)? = nil) {
        self.onRetry = onRetry
        titleLabel.text = title
        messageLabel.text = message
        retryLabel.isHidden = retryTitle == nil
        retryLabel.text = retryTitle
    }

    private func setupUI(title: String, message: String, retryTitle: String?) {
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(named: "BrandGray1") ?? .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.text = message
        messageLabel.font = UIFont(name: "Poppins-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = UIColor(named: "BrandGray4") ?? .gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        retryLabel.text = retryTitle
        retryLabel.font = UIFont(name: "Poppins-SemiBold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        retryLabel.textColor = UIColor(named: "BrandPrimary80") ?? .systemBlue
        retryLabel.textAlignment = .center
        retryLabel.isHidden = retryTitle == nil
        retryLabel.isUserInteractionEnabled = true
        retryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRetryTap)))

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, retryLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.setCustomSpacing(16, after: messageLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    @objc private func handleRetryTap() {
        onRetry?()
    }
}
