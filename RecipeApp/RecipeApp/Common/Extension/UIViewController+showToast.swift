//
//  UIViewController+showToast.swift
//  RecipeApp
//

import UIKit
import SwiftMessages

extension UIViewController {
    // Non-blocking error toast — no action button (unlike `showUndoSnackbar`,
    // which needs one) and themed warning-red so it reads as an error at a glance.
    func showToast(with error: NetworkError) {
        showToast(message: error.message, backgroundColor: UIColor(resource: .brandWarning))
    }

    // Non-blocking informational toast, e.g. for not-yet-built features.
    func showToast(message: String) {
        showToast(message: message, backgroundColor: UIColor(resource: .brandPrimary))
    }

    private func showToast(message: String, backgroundColor: UIColor) {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(backgroundColor: backgroundColor, foregroundColor: .white)
        messageView.configureDropShadow()
        messageView.configureContent(body: message)
        messageView.titleLabel?.isHidden = true
        messageView.bodyLabel?.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        messageView.bodyLabel?.textColor = .white
        messageView.button?.isHidden = true

        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .seconds(seconds: 2.5)
        config.dimMode = .none
        config.interactiveHide = true

        SwiftMessages.show(config: config, view: messageView)
    }
}
