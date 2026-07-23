//
//  ProcedureStepsTableViewCell.swift
//  RecipeApp
//

import UIKit

final class ProcedureStepsTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var stepNumberLabel: UILabel!
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var requiredIngredientsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCard()
    }

    private func setupCard() {
        cardView.applyCardStyle()
    }

    func configure(step: StepUIModel) {
        stepNumberLabel.text = "Step \(step.number)"
        instructionLabel.text = step.instruction

        if step.requiredIngredientNames.isEmpty {
            requiredIngredientsLabel.isHidden = true
        } else {
            requiredIngredientsLabel.isHidden = false
            requiredIngredientsLabel.text = "Required ingredients: \(step.requiredIngredientNames.joined(separator: ", "))"
        }
    }
}
