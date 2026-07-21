//
//  ViewState.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
protocol DisplayableError: Error {
    var message: String { get }
    // Whether re-running the action that produced this error is worth offering to the
    // user (e.g. "Try Again"). Defaults to true; conformers override where it isn't
    // (auth/permission/decoding failures a retry can't fix).
    var isRetryable: Bool { get }
}

extension DisplayableError {
    var isRetryable: Bool { true }
}

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(DisplayableError)
}
