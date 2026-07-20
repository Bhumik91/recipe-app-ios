// CustomTabBar.swift
import UIKit

final class CustomTabBar: UITabBar {
    // MARK: - Constants
    private enum Metric {
        static let fabSize: CGFloat = 60
        /// Gap between the FAB's edge and the notch's edge — this is the
        /// "cradle margin" from Android's BottomAppBar. Bigger = more
        /// breathing room visible around the FAB inside the cutout.
        static let notchMargin: CGFloat = 8
        /// How deep the notch dips into the bar. Kept equal to the notch
        /// radius so the cutout reads as a clean semicircle rather than a
        /// shallow scoop or an over-deep well.
        static let notchRadius: CGFloat = notchMargin + (fabSize / 2)
    }

    // MARK: - Properties
    /// Exposed so DashboardTabBarController can attach a target/action.
    /// FAB lives inside the tab bar itself so `hidesBottomBarWhenPushed`
    /// on any pushed child VC hides/shows it automatically, for free.
    let fabButton = UIButton(type: .custom)
    private let backgroundShapeLayer = CAShapeLayer()

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
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        // On first layout (before this view is fully settled in the hierarchy), safeAreaInsets.bottom
        // can read 0 incorrectly. Prefer window's insets since they're available earlier; only fall
        // back to self if window is somehow unavailable. This prevents intermittently-short bars on
        // first layout and rotation on notched devices.
        let bottomInset = window?.safeAreaInsets.bottom ?? safeAreaInsets.bottom
        sizeThatFits.height = 66 + bottomInset
        return sizeThatFits
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
        superview?.setNeedsLayout()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBackgroundShape()
        layoutFAB()

        // Reposition UITabBarButtons to create a gap in the center for the FAB.
        // WARNING: Relies on string-matching "UITabBarButton" (private UIKit class) — fragile.
        // Time constraint: implemented for MVP. Future scope: refactor to a custom container
        // that doesn't depend on private UIKit internals, once core features are stable.
        let buttons = subviews.filter { String(describing: type(of: $0)).contains("UITabBarButton") }
        let tabCount = TabBarItem.allCases.count
        guard buttons.count == tabCount else {
            assertionFailure("CustomTabBar found \(buttons.count) tab bar buttons but TabBarItem defines \(tabCount) tabs. Layout will be incorrect.")
            return
        }

        let sortedButtons = buttons.sorted(by: { $0.frame.minX < $1.frame.minX })
        let width = bounds.width
        let halfCount = tabCount / 2

        // We want a center gap of 96 points for the FAB and notch.
        let centerGap: CGFloat = 96
        let sidePadding: CGFloat = 12
        let totalWidthForButtons = width - (2 * sidePadding) - centerGap
        let buttonWidth = totalWidthForButtons / CGFloat(tabCount)

        // Left side buttons
        for i in 0..<halfCount {
            sortedButtons[i].frame = CGRect(
                x: sidePadding + CGFloat(i) * buttonWidth,
                y: sortedButtons[i].frame.minY,
                width: buttonWidth,
                height: sortedButtons[i].frame.height
            )
        }

        // Right side buttons
        for i in halfCount..<tabCount {
            sortedButtons[i].frame = CGRect(
                x: sidePadding + CGFloat(i) * buttonWidth + centerGap,
                y: sortedButtons[i].frame.minY,
                width: buttonWidth,
                height: sortedButtons[i].frame.height
            )
        }
    }

    // MARK: - Hit Testing
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // fabButton is deliberately positioned OUTSIDE the tab bar's own
        // bounds (it pokes above the top edge). UIKit's default hitTest
        // clips to `bounds`, so without this override taps on the top
        // half of the FAB would silently fall through to whatever is
        // behind the tab bar.
        let pointInFAB = convert(point, to: fabButton)
        if fabButton.bounds.contains(pointInFAB) {
            return fabButton
        }
        return super.hitTest(point, with: event)
    }
}

// MARK: - Setup
private extension CustomTabBar {
    func commonInit() {
        // The bar's own visible surface is now drawn entirely by
        // backgroundShapeLayer (so it can have the curved notch), so the
        // stock UITabBar chrome — background color, hairline border, and
        // default translucency — all need to be switched off, or you'll
        // see a flat white rectangle showing through behind your curve.
        backgroundColor = .clear
        backgroundImage = UIImage()
        shadowImage = UIImage()
        isTranslucent = false

        backgroundShapeLayer.fillColor = UIColor.white.cgColor
        backgroundShapeLayer.shadowColor = UIColor.black.cgColor
        backgroundShapeLayer.shadowOpacity = 0.08
        backgroundShapeLayer.shadowOffset = CGSize(width: 0, height: -2)
        backgroundShapeLayer.shadowRadius = 6
        layer.insertSublayer(backgroundShapeLayer, at: 0)

        setupFAB()
    }

    func setupFAB() {
        fabButton.backgroundColor = UIColor(resource: .brandPrimary)
        fabButton.tintColor = .white
        fabButton.setImage(UIImage(resource: .icAddFilled), for: .normal)
        fabButton.layer.shadowColor = UIColor.black.cgColor
        fabButton.layer.shadowOpacity = 0.2
        fabButton.layer.shadowRadius = 8
        fabButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addSubview(fabButton)
    }
}

// MARK: - Layout Helpers
private extension CustomTabBar {
    func layoutFAB() {
        fabButton.frame = CGRect(
            x: (bounds.width - Metric.fabSize) / 2,
            y: -Metric.fabSize / 2,
            width: Metric.fabSize,
            height: Metric.fabSize
        )
        fabButton.layer.cornerRadius = Metric.fabSize / 2
    }

    /// Builds the bar's silhouette using a smooth, continuous Bezier curve
    /// instead of a sharp circular arc, creating entry and exit fillets
    /// so the notch flows naturally into the top edge.
    func layoutBackgroundShape() {
        let width = bounds.width
        let height = bounds.height
        let centerX = width / 2
        let notchRadius = Metric.notchRadius
        let filletRadius: CGFloat = 12 // entry and exit curves radius for smooth transition

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))

        // Line to the start of the entry fillet curve
        path.addLine(to: CGPoint(x: centerX - notchRadius - filletRadius, y: 0))

        // Entry fillet + Left half of the cradle dip
        path.addCurve(
            to: CGPoint(x: centerX, y: notchRadius),
            controlPoint1: CGPoint(x: centerX - notchRadius - (filletRadius / 2), y: 0),
            controlPoint2: CGPoint(x: centerX - notchRadius, y: notchRadius)
        )

        // Right half of the cradle dip + Exit fillet
        path.addCurve(
            to: CGPoint(x: centerX + notchRadius + filletRadius, y: 0),
            controlPoint1: CGPoint(x: centerX + notchRadius, y: notchRadius),
            controlPoint2: CGPoint(x: centerX + notchRadius + (filletRadius / 2), y: 0)
        )

        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()

        backgroundShapeLayer.path = path.cgPath
        backgroundShapeLayer.frame = bounds
    }
}
