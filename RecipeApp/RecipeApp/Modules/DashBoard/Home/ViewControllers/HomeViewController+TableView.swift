//
//  HomeViewController+TableView.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

// MARK: - UITableView Setup & Delegates
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        mainTableView.delegate = self
        mainTableView.dataSource = self

        mainTableView.backgroundColor = .clear
        mainTableView.separatorStyle = .none
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.keyboardDismissMode = .onDrag

        mainTableView.sectionHeaderHeight = 0
        mainTableView.sectionFooterHeight = 0
        mainTableView.estimatedSectionHeaderHeight = 0
        mainTableView.estimatedSectionFooterHeight = 0

        mainTableView.rowHeight = UITableView.automaticDimension
        mainTableView.estimatedRowHeight = 100

        mainTableView.register(HomeHeaderTableViewCell.self, forCellReuseIdentifier: "HomeHeaderTableViewCell")

        let sectionHeaderCellNib = UINib(nibName: "RecipeSectionHeaderTableViewCell", bundle: nil)
        mainTableView.register(sectionHeaderCellNib, forCellReuseIdentifier: "RecipeSectionHeaderTableViewCell")

        let savedCellNib = UINib(nibName: "SavedRecipesTableViewCell", bundle: nil)
        mainTableView.register(savedCellNib, forCellReuseIdentifier: "SavedRecipesTableViewCell")

        let exploreCellNib = UINib(nibName: "ExploreRecipeTableViewCell", bundle: nil)
        mainTableView.register(exploreCellNib, forCellReuseIdentifier: "ExploreRecipeTableViewCell")
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .exploreRecipes: return exploreRecipes.count
        case .header, .savedHeader, .savedRecipes, .exploreHeader: return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHeaderTableViewCell", for: indexPath) as? HomeHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.embed(headerView)
            return cell

        case .savedHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeSectionHeaderTableViewCell", for: indexPath) as? RecipeSectionHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(title: savedSectionErrorMessage ?? "Saved Recipes")
            return cell

        case .savedRecipes:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRecipesTableViewCell", for: indexPath) as? SavedRecipesTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(recipes: savedRecipes)
            return cell

        case .exploreHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeSectionHeaderTableViewCell", for: indexPath) as? RecipeSectionHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(title: "Explore Recipes")
            return cell

        case .exploreRecipes:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreRecipeTableViewCell", for: indexPath) as? ExploreRecipeTableViewCell else {
                return UITableViewCell()
            }
            let recipe = exploreRecipes[indexPath.row]
            cell.configure(recipe: recipe)
            cell.onBookmarkTapped = { [weak self] in
                self?.viewModel.toggleSaved(dishId: recipe.id)
            }
            return cell
        }
    }

    // MARK: - Pagination
    // Triggers the next explore-recipes page once the user scrolls near the bottom of the
    // table. HomeViewModel.loadNextExplorePage() guards against overlapping/last-page calls.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distanceToBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        guard distanceToBottom < 200 else { return }
        viewModel.loadNextExplorePage()
    }
}

// MARK: - UICollectionView Delegates for Chips Filter
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == headerView.chipsCollectionView {
            return cuisineChips.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == headerView.chipsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipFilterCollectionViewCell", for: indexPath) as? ChipFilterCollectionViewCell else {
                return UICollectionViewCell()
            }
            let chip = cuisineChips[indexPath.item]
            cell.configure(title: chip.label, isSelected: chip.isSelected)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == headerView.chipsCollectionView {
            viewModel.toggleCuisineFilter(cuisineChips[indexPath.item].label)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headerView.chipsCollectionView {
            let title = cuisineChips[indexPath.item].label
            let font = UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
            let width = title.size(withAttributes: [.font: font]).width + 32
            return CGSize(width: max(width, 60), height: 40)
        }
        return .zero
    }
}
