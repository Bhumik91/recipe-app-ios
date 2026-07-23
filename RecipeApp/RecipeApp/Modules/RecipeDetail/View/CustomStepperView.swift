//
//  CustomStepperView.swift
//  RecipeApp
//

import UIKit

final class CustomStepperView: UIView {
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var decreaseButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var increaseButton: UIButton!

    // MARK: - Public API
    var onDecrement: (() -> Void)?
    var onIncrement: (() -> Void)?

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
        bundle.loadNibNamed("CustomStepperView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // No trailing anchor: contentView (the capsule) should hug its own content
        // width, not stretch to fill self — self is what gets stretched by the
        // parent stack view's "fill" alignment, leaving the capsule compact and
        // left-aligned inside it.
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        setupContainer()
        setupButtons()
    }

    // The consuming layout only pins this view's top/leading, relying on its own content
    // (the capsule row) to determine its size — same self-sizing approach as SelfSizingTableView.
    override var intrinsicContentSize: CGSize {
        contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    private func setupContainer() {
        contentView.applyImageCardStyle(cornerRadius: 14)
        contentView.backgroundColor = UIColor(resource: .brandWhite)
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(resource: .brandPrimary60).cgColor
    }

    private func setupButtons() {
        decreaseButton.setImage(UIImage(named: "ic_miuns")?.withRenderingMode(.alwaysTemplate), for: .normal)
        increaseButton.setImage(UIImage(named: "ic_add")?.withRenderingMode(.alwaysTemplate), for: .normal)
        decreaseButton.tintColor = UIColor(resource: .brandPrimary)
        increaseButton.tintColor = UIColor(resource: .brandPrimary)

        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)

        decreaseButton.accessibilityLabel = "Decrease servings"
        increaseButton.accessibilityLabel = "Increase servings"
    }

    @objc private func decreaseTapped() {
        onDecrement?()
    }

    @objc private func increaseTapped() {
        onIncrement?()
    }

    // MARK: - Public API
    func configure(servings: Int) {
        countLabel.text = "\(servings)"
        countLabel.accessibilityLabel = "\(servings) servings"
    }
}
