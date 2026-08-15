//
//  NotificationLogTableViewCell.swift
//  RecipeApp
//

import UIKit

/// One notification-log row: an action badge, the message, and a relative date.
final class NotificationLogTableViewCell: UITableViewCell {

    // MARK: - Reuse
    static let reuseIdentifier = "NotificationLogTableViewCell"

    // MARK: - Constants
    private enum Metric {
        static let badgeSize: CGFloat = 40
        static let badgeFillAlpha: CGFloat = 0.2
        static let cardInset: CGFloat = 8
        static let horizontalInset: CGFloat = 16
        static let contentSpacing: CGFloat = 12
    }

    // MARK: - Views
    private let cardView = UIView()
    private let badgeView = UIView()
    private let badgeImageView = UIImageView()
    private let messageLabel = UILabel()
    private let dateLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Derived from the badge's own bounds, so it stays circular at any content size.
        badgeView.makeCircular()
    }

    // MARK: - Configuration
    func configure(with log: NotificationLogUIModel) {
        messageLabel.text = log.message
        dateLabel.text = log.timestamp.notificationLogLabel()

        switch log.action {
        case .saved:
            badgeView.backgroundColor = UIColor(resource: .brandPrimary40)
            badgeImageView.image = UIImage(resource: .icSavedOutlined)
            badgeImageView.tintColor = UIColor(resource: .brandPrimary)
        case .removed:
            // Faded fill; at full strength the icon vanishes into its own background.
            badgeView.backgroundColor = UIColor(resource: .brandWarning).withAlphaComponent(Metric.badgeFillAlpha)
            badgeImageView.image = UIImage(resource: .icTrashOutlined)
            badgeImageView.tintColor = UIColor(resource: .brandWarning)
        }
    }

    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.applyCardStyle()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.addSubview(badgeImageView)

        messageLabel.font = UIFont(name: "Poppins-Medium", size: 14) ?? .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = UIColor(resource: .brandBlack)
        messageLabel.numberOfLines = 0

        dateLabel.font = UIFont(name: "Poppins-Regular", size: 12) ?? .systemFont(ofSize: 12)
        dateLabel.textColor = UIColor(resource: .brandGray2)
        // The date must never be squeezed out by a long recipe name.
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [badgeView, messageLabel, dateLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Metric.contentSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metric.cardInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metric.cardInset),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metric.horizontalInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metric.horizontalInset),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Metric.contentSpacing),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Metric.contentSpacing),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Metric.contentSpacing),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Metric.contentSpacing),

            // The one fixed size the row needs — the badge is a circle, not content-driven.
            badgeView.widthAnchor.constraint(equalToConstant: Metric.badgeSize),
            badgeView.heightAnchor.constraint(equalToConstant: Metric.badgeSize),

            badgeImageView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalToConstant: Metric.badgeSize / 2),
            badgeImageView.heightAnchor.constraint(equalToConstant: Metric.badgeSize / 2)
        ])
    }
}
