//
//  SavedRecipeViewController+TableView.swift
//  RecipeApp
//

import UIKit

// MARK: - Data Source
extension SavedRecipeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SavedRecipeTableViewCell.reuseID,
            for: indexPath
        ) as? SavedRecipeTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(recipe: viewModel.recipes[indexPath.row])
        return cell
    }
}

// MARK: - Delegate
extension SavedRecipeViewController: UITableViewDelegate {

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard viewModel.recipes.indices.contains(indexPath.row) else { return }
        coordinator?.recipeTapped(id: viewModel.recipes[indexPath.row].id)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarVisibility(for: scrollView)
    }
}

// MARK: - Hide Nav Bar While Scrolling
extension SavedRecipeViewController {

    /// Hides the title bar as the user reads down the list, brings it back immediately
    /// when they scroll up — driven by the shared `ScrollVisibilityTracker` so the
    /// direction/tolerance logic isn't duplicated per screen.
    private func updateNavigationBarVisibility(for scrollView: UIScrollView) {
        guard let hidden = navBarVisibilityTracker.handle(scrollView: scrollView) else { return }
        setNavigationBar(hidden: hidden)
    }
}

// MARK: - ScrollTrackingBottomNavHost
extension SavedRecipeViewController: ScrollTrackingBottomNavHost {
    var scrollViewDrivingBottomNav: UIScrollView { tableView }
}
