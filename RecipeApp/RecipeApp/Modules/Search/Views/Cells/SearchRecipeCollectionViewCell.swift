//
//  SearchRecipeCollectionViewCell.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 23/07/26.
//

import UIKit

class SearchRecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var cellContainerView: UIView!

    @IBOutlet private weak var recipeImageView: UIImageView!
    @IBOutlet private weak var recipeNameLabel: UILabel!

    private var imageGradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Shadow on contentView (not the clipped image) so it isn't clipped away too.
        contentView.applyShadow(opacity: 0.08, radius: 6, offset: CGSize(width: 0, height: 2))
        imageGradientLayer = recipeImageView.applyImageCardStyle(cornerRadius: 16, addsGradientOverlay: true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Same reasoning as RecipeDetailViewController: keep the gradient's frame snapped to
        // the image's current bounds so it doesn't lag/interpolate during cell reuse or resize.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageGradientLayer?.frame = recipeImageView.bounds
        CATransaction.commit()
    }

    func configure(recipe: SearchRecipeUIModel) {
        recipeNameLabel.text = recipe.title
        recipeImageView.loadImage(from: recipe.imageURL, placeholder: UIImage(named: "ic_default_image"))
    }
}
