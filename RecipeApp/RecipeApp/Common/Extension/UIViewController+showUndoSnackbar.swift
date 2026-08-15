//
//  UIViewController+showUndoSnackbar.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 22/07/26.
//
import UIKit
import SwiftMessages

extension UIViewController {
    // Bottom snackbar with a single action button — duration matches the 3s
    // optimistic-delete window on the ViewModel side so Undo stays available
    // for exactly as long as the pending removal can still be cancelled.
    func showUndoSnackbar(message: String, actionTitle: String = "Undo", onAction: @escaping () -> Void) {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(backgroundColor: UIColor(resource: .brandGray3), foregroundColor: .white)
        messageView.configureDropShadow()
        messageView.configureContent(
            title: nil,
            body: message,
            iconImage: nil,
            iconText: nil,
            buttonImage: nil,
            buttonTitle: actionTitle
        ) { _ in
            onAction()
            SwiftMessages.hide()
        }
        messageView.titleLabel?.isHidden = true
        messageView.bodyLabel?.font = UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        messageView.bodyLabel?.textColor = .white
        messageView.button?.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        messageView.button?.tintColor = UIColor(resource: .brandGray3)
        messageView.button?.setTitleColor(UIColor(resource: .brandPrimary), for: .normal)

        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .seconds(seconds: 3)
        config.dimMode = .none
        config.interactiveHide = true

        SwiftMessages.show(config: config, view: messageView)
    }
}
