// DashboardViewController.swift
import UIKit

/// Custom container replacing `UITabBarController`. Owns the four tab navigation
/// controllers and the bottom nav, using only plain views and child view controllers.
final class DashboardViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: DashboardViewControllerDelegate?
    private(set) var selectedIndex: Int = 0

    private let contentView = UIView()
    private let bottomNav = BottomNavWithFab()
    private var tabControllers: [DashboardNavigationController] = []
    private var isBottomNavHidden = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupContentView()
        setupBottomNav()
        installTab(at: selectedIndex)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateChildSafeAreaInsets()
    }

    // MARK: - Child forwarding
    // Without these the status bar follows this container, not the visible screen.
    override var childForStatusBarStyle: UIViewController? { tabControllers[safe: selectedIndex] }
    override var childForStatusBarHidden: UIViewController? { tabControllers[safe: selectedIndex] }

    // MARK: - Public API
    /// Installs the tab stack. Call once, before the view appears.
    func setTabControllers(_ controllers: [DashboardNavigationController], tabs: [DashboardTab]) {
        tabControllers = controllers
        controllers.forEach { $0.addStackObserver(self) }
        bottomNav.configure(tabs: tabs)
        bottomNav.setSelectedIndex(selectedIndex)

        guard isViewLoaded else { return }
        installTab(at: selectedIndex)
    }

    func selectTab(at index: Int) {
        guard tabControllers.indices.contains(index) else { return }

        // Re-tapping the active tab pops it to root — UITabBarController
        // behaviour that users expect.
        guard index != selectedIndex else {
            tabControllers[index].popToRootViewController(animated: true)
            return
        }

        let previousIndex = selectedIndex
        selectedIndex = index
        bottomNav.setSelectedIndex(index)

        if isViewLoaded {
            removeTab(at: previousIndex)
            installTab(at: index)
        }

        updateBottomNavVisibility(animated: false)
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Setup
private extension DashboardViewController {
    func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupBottomNav() {
        bottomNav.delegate = self
        bottomNav.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomNav)
        NSLayoutConstraint.activate([
            bottomNav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Bottom of the *view*, not the safe area — the bar draws its own
            // background behind the home indicator and pads itself instead.
            bottomNav.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Child containment
private extension DashboardViewController {
    /// Only the selected tab stays installed; the others stay alive in `tabControllers`.
    /// Swapping them out is what keeps `viewWillAppear`/`viewDidAppear` firing on return.
    func installTab(at index: Int) {
        guard let controller = tabControllers[safe: index], controller.parent !== self else { return }

        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        controller.didMove(toParent: self)

        // The bar is a sibling of contentView, but re-assert the order so a
        // freshly added tab can never end up drawn over it.
        view.bringSubviewToFront(bottomNav)
        updateChildSafeAreaInsets()
    }

    func removeTab(at index: Int) {
        guard let controller = tabControllers[safe: index], controller.parent === self else { return }

        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}

// MARK: - Safe area
private extension DashboardViewController {
    /// A custom container gets no automatic bar inset, so lists would scroll under it.
    func updateChildSafeAreaInsets() {
        let overlap = isBottomNavHidden
            ? 0
            : max(0, bottomNav.frame.height - view.safeAreaInsets.bottom)

        for controller in tabControllers where controller.additionalSafeAreaInsets.bottom != overlap {
            controller.additionalSafeAreaInsets.bottom = overlap
        }
    }
}

// MARK: - Bottom nav visibility
private extension DashboardViewController {
    func updateBottomNavVisibility(animated: Bool) {
        let topViewController = tabControllers[safe: selectedIndex]?.topViewController
        let shouldHide = (topViewController as? BottomNavHidable)?.hidesBottomNav ?? false
        setBottomNavHidden(shouldHide, animated: animated)
    }

    func setBottomNavHidden(_ hidden: Bool, animated: Bool) {
        guard hidden != isBottomNavHidden else { return }
        isBottomNavHidden = hidden
        updateChildSafeAreaInsets()

        let apply = { [weak self] in
            guard let self else { return }
            self.bottomNav.transform = hidden
                ? CGAffineTransform(translationX: 0, y: self.bottomNav.frame.height)
                : .identity
            self.bottomNav.alpha = hidden ? 0 : 1
        }

        guard animated else {
            apply()
            return
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) { apply() }
    }
}

// MARK: - BottomNavWithFabDelegate
extension DashboardViewController: BottomNavWithFabDelegate {
    func bottomNav(_ bottomNav: BottomNavWithFab, didSelectItemAt index: Int) {
        selectTab(at: index)
    }

    func bottomNavDidTapFab(_ bottomNav: BottomNavWithFab) {
        delegate?.dashboardViewControllerDidTapAdd(self)
    }
}

// MARK: - NavigationStackObserving
extension DashboardViewController: NavigationStackObserving {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard navigationController === tabControllers[safe: selectedIndex] else { return }
        let shouldHide = (viewController as? BottomNavHidable)?.hidesBottomNav ?? false

        // Ride the push/pop transition so the bar moves in step with the
        // screen, and put it back if an interactive swipe-back is cancelled.
        guard animated, let transition = navigationController.transitionCoordinator else {
            setBottomNavHidden(shouldHide, animated: animated)
            return
        }

        transition.animate(alongsideTransition: { [weak self] _ in
            self?.setBottomNavHidden(shouldHide, animated: false)
        }, completion: { [weak self] context in
            guard context.isCancelled else { return }
            self?.updateBottomNavVisibility(animated: true)
        })
    }
}
