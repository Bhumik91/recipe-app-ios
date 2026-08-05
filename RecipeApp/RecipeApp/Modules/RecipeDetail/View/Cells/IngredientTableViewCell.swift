//
//  IngredientTableViewCell.swift
//  RecipeApp
//

import UIKit

final class IngredientTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var ingredientImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCard()
    }

    private func setupCard() {
        cardView.applyCardStyle()

        ingredientImageView.layer.cornerRadius = 8
        ingredientImageView.clipsToBounds = true
    }

    func configure(ingredient: IngredientUIModel, baseServings: Int, targetServings: Int) {
        nameLabel.text = ingredient.name
        amountLabel.text = ingredient.displayAmount(baseServings: baseServings, targetServings: targetServings)
        ingredientImageView.loadImage(from: ingredient.imageURL, placeholder: UIImage(named: "ic_default_image"))
    }
}
