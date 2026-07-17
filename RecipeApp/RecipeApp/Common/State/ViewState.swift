//
//  ViewState.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
protocol DisplayableError: Error {
    var message: String { get }
}

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(DisplayableError)
}
