//
//  ExploreRecipeTableViewCell.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

class ExploreRecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!

    var onBookmarkTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }

    @objc private func bookmarkTapped() {
        onBookmarkTapped?()
    }

    func configure(recipe: RecipeUIModel) {
        titleLabel.text = recipe.title
        timeLabel.text = "\(recipe.readyInMinutes) mins"
        recipeImageView.loadImage(from: recipe.imageURL, placeholder: UIImage(named: "ic_default_image"))
        bookmarkButton.isSelected = recipe.isSaved
    }
}
