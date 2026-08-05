//
//  SegmentedSelectorView.swift
//  RecipeApp
//

import UIKit

@IBDesignable
final class SegmentedSelectorView: UIView {
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var selectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var selectionWidthConstraint: NSLayoutConstraint!

    // MARK: - Constants
    private enum Metric {
        static let animationDuration: TimeInterval = 0.25
        static let selectedFontSize: CGFloat = 15
    }

    // MARK: - Properties
    weak var delegate: SegmentedSelectorViewDelegate?
    private(set) var selectedIndex: Int = 0
    private var titles: [String] = []
    private var buttons: [UIButton] = []

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
        bundle.loadNibNamed("SegmentedSelectorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        contentView.backgroundColor = UIColor(named: "BrandWhite") ?? .white
        selectionView.backgroundColor = UIColor(named: "BrandPrimary") ?? .systemGreen
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
        selectionView.layer.cornerRadius = selectionView.bounds.height / 2
        updateSelectionFrame(animated: false)
    }

    // MARK: - Public API
    func configure(titles: [String]) {
        let preservedSelection = titles.isEmpty ? 0 : min(selectedIndex, titles.count - 1)

        buttons.forEach { $0.removeFromSuperview() }
        self.titles = titles
        buttons = titles.enumerated().map { index, title in makeButton(title: title, index: index) }
        buttons.forEach { stackView.addArrangedSubview($0) }

        selectedIndex = preservedSelection
        applySelectedAppearance(animated: false)
    }

    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard titles.indices.contains(index), index != selectedIndex else { return }
        selectedIndex = index
        applySelectedAppearance(animated: animated)
    }

    // MARK: - Buttons
    private func makeButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = index
        button.accessibilityLabel = title
        button.accessibilityIdentifier = "segment_\(index)"
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        applySelectedAppearance(animated: true)
        delegate?.segmentedSelectorView(self, didSelect: selectedIndex)
    }

    // MARK: - Selection Appearance
    private func applySelectedAppearance(animated: Bool) {
        updateSelectionFrame(animated: animated)
        updateTextColors(animated: animated)
        updateAccessibilityStates()
    }

    private func updateSelectionFrame(animated: Bool) {
        guard !buttons.isEmpty, bounds.width > 0 else { return }
        let segmentWidth = bounds.width / CGFloat(buttons.count)
        selectionLeadingConstraint.constant = segmentWidth * CGFloat(selectedIndex)
        selectionWidthConstraint.constant = segmentWidth

        if animated {
            UIView.animate(withDuration: Metric.animationDuration, delay: 0, options: .curveEaseInOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func updateTextColors(animated: Bool) {
        let selectedColor = UIColor(resource: .brandWhite)
        let unselectedColor = UIColor(resource: .brandGray3)

        let updates = {
            for (index, button) in self.buttons.enumerated() {
                let isSelected = index == self.selectedIndex
                button.setTitleColor(isSelected ? selectedColor : unselectedColor, for: .normal)
                button.titleLabel?.font = UIFont(
                    name: isSelected ? "Poppins-SemiBold" : "Poppins-Medium",
                    size: Metric.selectedFontSize
                ) ?? .systemFont(ofSize: Metric.selectedFontSize, weight: isSelected ? .semibold : .medium)
            }
        }

        if animated {
            UIView.transition(with: stackView, duration: Metric.animationDuration, options: .transitionCrossDissolve, animations: updates)
        } else {
            updates()
        }
    }

    private func updateAccessibilityStates() {
        for (index, button) in buttons.enumerated() {
            button.accessibilityTraits = index == selectedIndex ? [.button, .selected] : .button
        }
    }
}
