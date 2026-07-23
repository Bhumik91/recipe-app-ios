//
//  RecipeSectionHeaderTableViewCell.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

class RecipeSectionHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    func configure(title: String) {
        titleLabel.text = title
        titleLabel.textColor = UIColor(named: "BrandBlack") ?? .black
    }
}
