//
//  SavedRecipeCollectionViewCell.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

class SavedRecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var savedCardView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bookmarkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Card styling
        savedCardView.layer.cornerRadius = 18
        savedCardView.backgroundColor = UIColor(named: "BrandPrimary20")
        savedCardView.layer.borderWidth = 1
        savedCardView.layer.borderColor = UIColor(named: "BrandPrimary20")?.cgColor
        
        // Card shadow matching android shadow parameters
        savedCardView.layer.shadowColor = UIColor(named: "BrandGray4")?.cgColor ?? UIColor.gray.cgColor
        savedCardView.layer.shadowOpacity = 0.5
        savedCardView.layer.shadowRadius = 10
        savedCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        savedCardView.layer.masksToBounds = false
        
        // Circular recipe image styling (size is 112x112, radius is 56)
        recipeImageView.layer.cornerRadius = 56
        recipeImageView.clipsToBounds = true
        
        // Circular white background bookmark icon
        bookmarkImageView.layer.cornerRadius = 18
        bookmarkImageView.clipsToBounds = true
        bookmarkImageView.backgroundColor = .white

        // Every card here is already saved, so always show the filled/saved icon.
        bookmarkImageView.image = UIImage(named: "ic_saved")
    }

    func configure(recipe: RecipeUIModel) {
        titleLabel.text = recipe.title
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor(named: "BrandGray1") ?? .darkGray
        
        timeLabel.text = "\(recipe.readyInMinutes) mins"
        timeLabel.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        timeLabel.textColor = UIColor(named: "BrandGray1") ?? .darkGray
        
        recipeImageView.loadImage(from: recipe.imageURL, placeholder: UIImage(named: "ic_default_image"))
    }
}
