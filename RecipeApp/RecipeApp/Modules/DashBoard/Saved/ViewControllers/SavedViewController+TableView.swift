//
//  SavedViewController+TableView.swift
//  RecipeApp
//

import UIKit

// MARK: - Data Source
extension SavedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SavedTableViewCell.reuseID,
            for: indexPath
        ) as? SavedTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(recipe: viewModel.recipes[indexPath.row])
        return cell
    }
}

// MARK: - Delegate
extension SavedViewController: UITableViewDelegate {

    /// Swipe left to delete. The view model holds the recipe for a few seconds so the
    /// snackbar's Undo can put it back.
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, done in
            self?.viewModel.removeRecipe(at: indexPath.row)
            done(true)
        }
        delete.backgroundColor = .brandWarning
        delete.image = UIImage(resource: .icTrashOutlined)

        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarVisibility(for: scrollView)
    }
}

// MARK: - Hide Nav Bar While Scrolling
extension SavedViewController {

    /// Hides the title bar as the user reads down the list, brings it back when they
    /// scroll up or return to the top.
    private func updateNavigationBarVisibility(for scrollView: UIScrollView) {
        // At the top the bar is always visible, whichever way the last swipe went.
        let topOffset = -scrollView.contentInset.top
        guard scrollView.contentOffset.y > topOffset + Scroll.topTolerance else {
            setNavigationBar(hidden: false)
            return
        }

        // Direction of the user's finger. This is 0 once they let go, so the bar holds
        // still during momentum scrolling instead of flickering.
        let velocity = scrollView.panGestureRecognizer.velocity(in: view).y
        if velocity < -Scroll.minVelocity {
            setNavigationBar(hidden: true)      // dragging up = reading further down
        } else if velocity > Scroll.minVelocity {
            setNavigationBar(hidden: false)     // dragging back down
        }
    }

    func setNavigationBar(hidden: Bool) {
        guard navigationController?.isNavigationBarHidden != hidden else { return }
        navigationController?.setNavigationBarHidden(hidden, animated: true)
    }

    private enum Scroll {
        /// How close to the top counts as "at the top".
        static let topTolerance: CGFloat = 8
        /// Ignore slower drags so the bar doesn't twitch.
        static let minVelocity: CGFloat = 50
    }
}
