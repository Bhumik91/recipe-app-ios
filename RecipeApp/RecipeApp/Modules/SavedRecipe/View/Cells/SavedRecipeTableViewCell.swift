//
//  SavedRecipeTableViewCell.swift
//  RecipeApp
//

import UIKit

/// Recipe card: full-bleed image with a dark gradient at the bottom so the title and
/// time stay readable. The bookmark icon is decoration only — removal is by swipe.
final class SavedRecipeTableViewCell: UITableViewCell {

    static let reuseID = "SavedRecipeTableViewCell"

    // MARK: - IBOutlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var bookmarkImageView: UIImageView!

    private var gradientLayer: CAGradientLayer?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        setupCardStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Layers don't auto-layout, so the gradient is resized by hand each pass.
        gradientLayer?.frame = recipeImageView.bounds
        bookmarkImageView.makeCircular()
    }

    // MARK: - Configuration
    func configure(recipe: RecipeUIModel) {
        titleLabel.text = recipe.title
        cookingTimeLabel.text = "\(recipe.readyInMinutes) min"
        recipeImageView.loadImage(from: recipe.imageURL)
    }

    private func setupCardStyle() {
        cardView.applyImageCardStyle(cornerRadius: 16)
        recipeImageView.contentMode = .scaleAspectFill
        gradientLayer = recipeImageView.applyImageCardStyle(cornerRadius: 0, addsGradientOverlay: true)
    }
}
