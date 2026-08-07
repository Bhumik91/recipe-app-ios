//
//  ProfileViewController+TableView.swift
//  RecipeApp
//

import UIKit

// MARK: - Data Source
extension ProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Only the Recipes tab has rows; the other two render an empty state instead.
        selectedTab == .recipes ? savedRecipes.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SavedRecipeTableViewCell.reuseID,
            for: indexPath
        ) as? SavedRecipeTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(recipe: savedRecipes[indexPath.row])
        return cell
    }
}

// MARK: - Delegate
extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard savedRecipes.indices.contains(indexPath.row) else { return }
        coordinator?.recipeTapped(id: savedRecipes[indexPath.row].id)
    }
}

// MARK: - Segment Selection
extension ProfileViewController: SegmentedSelectorViewDelegate {

    func segmentedSelectorView(_ view: SegmentedSelectorView, didSelect index: Int) {
        guard let tab = ProfileTab(rawValue: index) else { return }
        selectedTab = tab
        renderTabContent()
    }
}
