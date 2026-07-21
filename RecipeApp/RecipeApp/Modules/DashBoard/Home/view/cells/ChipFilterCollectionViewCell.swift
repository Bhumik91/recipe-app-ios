//
//  ChipFilterCollectionViewCell.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

class ChipFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chipButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(title: String, isSelected: Bool) {
        var config = chipButton.configuration ?? UIButton.Configuration.filled()
        config.cornerStyle = .fixed
        config.background.cornerRadius = 10
        
        let font = UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        var titleAttr = AttributeContainer()
        titleAttr.font = font
        config.attributedTitle = AttributedString(title, attributes: titleAttr)
        
        // Define primary green color and white from assets
        let primaryGreen = UIColor(named: "BrandPrimary") ?? .systemGreen
        let brandWhite = UIColor(named: "BrandWhite") ?? .white
        
        if isSelected {
            config.background.backgroundColor = primaryGreen
            config.baseForegroundColor = brandWhite
            config.background.strokeColor = brandWhite
            config.background.strokeWidth = 2
        } else {
            config.background.backgroundColor = brandWhite
            config.baseForegroundColor = primaryGreen
            config.background.strokeColor = primaryGreen
            config.background.strokeWidth = 2
        }
        
        chipButton.configuration = config
    }
}
