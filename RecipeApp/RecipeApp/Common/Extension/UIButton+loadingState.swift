//
//  UIButton+loadingState.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import UIKit
extension UIButton {
    func setLoading(_ loading: Bool) {
        self.configuration?.showsActivityIndicator = loading
        self.isEnabled = !loading
    }
}
