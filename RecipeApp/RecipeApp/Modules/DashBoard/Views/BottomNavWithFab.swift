// BottomNavWithFab.swift
import UIKit

/// Bottom navigation bar with a centre notch and an overhanging FAB.
/// A plain `UIView` with Auto Layout buttons — no `UITabBar` subclassing.
final class BottomNavWithFab: UIView {
    // MARK: - Constants
    private enum Metric {
        static let barHeight: CGFloat = 66
        static let fabSize: CGFloat = 60
        /// Gap between the FAB's edge and the notch's edge.
        static let notchMargin: CGFloat = 8
        /// Kept equal to the notch radius so the cutout reads as a clean
        /// semicircle rather than a shallow scoop or an over-deep well.
        static let notchRadius: CGFloat = notchMargin + (fabSize / 2)
        /// Entry/exit curve radius, so the notch flows into the top edge
        /// instead of meeting it at a corner.
        static let filletRadius: CGFloat = 12
        static let centreGap: CGFloat = 96
        static let sidePadding: CGFloat = 12
    }

    // MARK: - Properties
    weak var delegate: BottomNavWithFabDelegate?
    private(set) var selectedIndex: Int = 0

    private let backgroundShapeLayer = CAShapeLayer()
    private let leftStack = UIStackView()
    private let rightStack = UIStackView()
    private let fabButton = UIButton(type: .custom)
    private var itemButtons: [UIButton] = []

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Size
    // Pinned to the container's bottom edge, so our own safeAreaInsets.bottom is the
    // home-indicator inset — no hardcoded device check needed.
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metric.barHeight + safeAreaInsets.bottom)
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBackgroundShape()
    }

    // MARK: - Hit Testing
    // The FAB overhangs the top edge, so taps on its top half would otherwise fall through.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) { return true }
        return fabButton.frame.contains(point)
    }

    // MARK: - Public API
    func configure(tabs: [DashboardTab]) {
        itemButtons.forEach { $0.removeFromSuperview() }
        itemButtons = tabs.enumerated().map { index, tab in makeItemButton(for: tab, index: index) }

        let half = itemButtons.count / 2
        itemButtons.prefix(half).forEach { leftStack.addArrangedSubview($0) }
        itemButtons.suffix(from: half).forEach { rightStack.addArrangedSubview($0) }

        applySelectedAppearance()
    }

    func setSelectedIndex(_ index: Int) {
        guard itemButtons.indices.contains(index) else { return }
        selectedIndex = index
        applySelectedAppearance()
    }
}

// MARK: - Setup
private extension BottomNavWithFab {
    func commonInit() {
        backgroundColor = .clear
        setupBackgroundLayer()
        setupStacks()
        setupFAB()
        setupTraitObservation()
    }

    func setupBackgroundLayer() {
        backgroundShapeLayer.fillColor = resolvedBarColor
        backgroundShapeLayer.shadowColor = UIColor.black.cgColor
        backgroundShapeLayer.shadowOpacity = 0.08
        backgroundShapeLayer.shadowOffset = CGSize(width: 0, height: -2)
        backgroundShapeLayer.shadowRadius = 6
        layer.insertSublayer(backgroundShapeLayer, at: 0)
    }

    func setupStacks() {
        [leftStack, rightStack].forEach { stack in
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.alignment = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stack)
        }

        NSLayoutConstraint.activate([
            leftStack.topAnchor.constraint(equalTo: topAnchor),
            leftStack.heightAnchor.constraint(equalToConstant: Metric.barHeight),
            leftStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.sidePadding),
            leftStack.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -Metric.centreGap / 2),

            rightStack.topAnchor.constraint(equalTo: topAnchor),
            rightStack.heightAnchor.constraint(equalToConstant: Metric.barHeight),
            rightStack.leadingAnchor.constraint(equalTo: centerXAnchor, constant: Metric.centreGap / 2),
            rightStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metric.sidePadding)
        ])
    }

    func setupFAB() {
        fabButton.translatesAutoresizingMaskIntoConstraints = false
        fabButton.backgroundColor = UIColor(resource: .brandPrimary)
        fabButton.tintColor = .white
        fabButton.setImage(UIImage(resource: .icAddFilled), for: .normal)
        fabButton.layer.cornerRadius = Metric.fabSize / 2
        fabButton.layer.shadowColor = UIColor.black.cgColor
        fabButton.layer.shadowOpacity = 0.2
        fabButton.layer.shadowRadius = 8
        fabButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        fabButton.accessibilityLabel = "Add recipe"
        fabButton.accessibilityIdentifier = "bottom_nav_fab"
        fabButton.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)
        addSubview(fabButton)

        NSLayoutConstraint.activate([
            fabButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            fabButton.centerYAnchor.constraint(equalTo: topAnchor),
            fabButton.widthAnchor.constraint(equalToConstant: Metric.fabSize),
            fabButton.heightAnchor.constraint(equalToConstant: Metric.fabSize)
        ])
    }

    // CAShapeLayer fill colours are resolved CGColors — they do not follow
    // trait changes on their own, so repaint on a light/dark switch.
    func setupTraitObservation() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: BottomNavWithFab, _: UITraitCollection) in
            view.backgroundShapeLayer.fillColor = view.resolvedBarColor
        }
    }

    var resolvedBarColor: CGColor {
        UIColor(resource: .brandWhite).resolvedColor(with: traitCollection).cgColor
    }

    func makeItemButton(for tab: DashboardTab, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.setImage(tab.icon.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.accessibilityLabel = tab.accessibilityLabel
        button.accessibilityIdentifier = "bottom_nav_item_\(index)"
        // UITabBar gave us the large content viewer for free at accessibility
        // text sizes; icon-only buttons need it declared.
        button.showsLargeContentViewer = true
        button.largeContentTitle = tab.accessibilityLabel
        button.largeContentImage = tab.icon
        button.addInteraction(UILargeContentViewerInteraction())
        button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
        return button
    }
}

// MARK: - Actions
private extension BottomNavWithFab {
    @objc func itemTapped(_ sender: UIButton) {
        // Report every tap, including a re-tap of the current item — the owner
        // uses that to pop the tab back to its root, the way UITabBarController did.
        delegate?.bottomNav(self, didSelectItemAt: sender.tag)
    }

    @objc func fabTapped() {
        delegate?.bottomNavDidTapFab(self)
    }
}

// MARK: - Appearance
private extension BottomNavWithFab {
    func applySelectedAppearance() {
        for (index, button) in itemButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.tintColor = isSelected ? UIColor(resource: .brandPrimary) : .systemGray
            button.accessibilityTraits = isSelected ? [.button, .selected] : .button
        }
    }

    /// Builds the bar's silhouette with a continuous Bezier curve so the notch flows
    /// into the top edge instead of meeting it as a sharp arc.
    func layoutBackgroundShape() {
        let width = bounds.width
        let height = bounds.height
        let centreX = width / 2
        let notchRadius = Metric.notchRadius
        let fillet = Metric.filletRadius

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))

        // Line to the start of the entry fillet curve
        path.addLine(to: CGPoint(x: centreX - notchRadius - fillet, y: 0))

        // Entry fillet + left half of the cradle dip
        path.addCurve(
            to: CGPoint(x: centreX, y: notchRadius),
            controlPoint1: CGPoint(x: centreX - notchRadius - (fillet / 2), y: 0),
            controlPoint2: CGPoint(x: centreX - notchRadius, y: notchRadius)
        )

        // Right half of the cradle dip + exit fillet
        path.addCurve(
            to: CGPoint(x: centreX + notchRadius + fillet, y: 0),
            controlPoint1: CGPoint(x: centreX + notchRadius, y: notchRadius),
            controlPoint2: CGPoint(x: centreX + notchRadius + (fillet / 2), y: 0)
        )

        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()

        backgroundShapeLayer.path = path.cgPath
        backgroundShapeLayer.frame = bounds
    }
}
