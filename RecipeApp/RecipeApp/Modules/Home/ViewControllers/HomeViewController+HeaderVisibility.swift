//
//  HomeViewController+HeaderVisibility.swift
//  RecipeApp
//

import UIKit

// MARK: - Floating Header (greeting / search / chips)
// headerView floats above mainTableView instead of living in it as a row, so it can
// hide as the user reads down and reappear the instant they scroll back up — the same
// tracker-driven behaviour as the bottom nav, kept fully decoupled from it.
extension HomeViewController {
    func setupHeaderOverlay() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.applyShadow()
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.bringSubviewToFront(headerView)
    }

    /// Called from scrollViewDidScroll — pushes every drag through the shared tracker
    /// and only touches the header on the tick its hidden state actually flips.
    func updateHeaderVisibility(for scrollView: UIScrollView) {
        guard let hidden = headerVisibilityTracker.handle(scrollView: scrollView) else { return }
        setHeaderHidden(hidden, animated: true)
    }

    func setHeaderHidden(_ hidden: Bool, animated: Bool) {
        guard hidden != isHeaderHidden else { return }
        isHeaderHidden = hidden

        let apply = { [weak self] in
            guard let self else { return }
            headerView.transform = hidden
                ? CGAffineTransform(translationX: 0, y: -headerView.frame.height)
                : .identity
            headerView.alpha = hidden ? 0 : 1
        }

        guard animated else {
            apply()
            return
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) { apply() }
    }

    /// The table has no row for the header anymore, so it needs a top inset matching
    /// the header's own height to keep the first real row clear of it. Re-derived on
    /// every layout pass (Dynamic Type, rotation) instead of hardcoded.
    func updateTableTopInset() {
        let height = headerView.frame.height
        guard height > 0, mainTableView.contentInset.top != height else { return }

        let wasAtTop = mainTableView.contentOffset.y <= -mainTableView.contentInset.top + 1
        mainTableView.contentInset.top = height
        mainTableView.verticalScrollIndicatorInsets.top = height
        // Keep the list visually anchored instead of jumping when the header's own
        // height changes (first layout, Dynamic Type, rotation).
        if wasAtTop {
            mainTableView.contentOffset.y = -height
        }
    }
}
