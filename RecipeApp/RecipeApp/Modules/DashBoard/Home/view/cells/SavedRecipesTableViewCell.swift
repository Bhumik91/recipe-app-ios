//
//  SavedRecipesTableViewCell.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

// Only ever embedded in the table while HomeViewController's saved-recipes section
// exists (see HomeSection) — this cell has nothing to say about the empty case,
// it just hosts the horizontal collection.
class SavedRecipesTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, RecipeUIModel>!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    // Diffable data source animates inserts/removals/moves within the row itself,
    // so bookmarking a recipe never needs a full collectionView.reloadData().
    func configure(recipes: [RecipeUIModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RecipeUIModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(recipes, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func setupCollectionView() {
        let nib = UINib(nibName: "SavedRecipeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SavedRecipeCollectionViewCell")

        dataSource = UICollectionViewDiffableDataSource<Int, RecipeUIModel>(collectionView: collectionView) { collectionView, indexPath, recipe in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedRecipeCollectionViewCell", for: indexPath) as? SavedRecipeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(recipe: recipe)
            return cell
        }
        collectionView.dataSource = dataSource
    }
}
