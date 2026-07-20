//
//  FieldErrors.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
enum AuthFieldError {
    case userName
    case password
    case name
    case confirmPassword(reason: ConfirmPasswordError)
    case terms
    
    enum ConfirmPasswordError {
        case empty
        case mismatch
    }
}
// MARK: Implemented user friendly message
extension AuthFieldError: DisplayableError {
    var message: String {
        switch self {
        case .userName:
            return "Username cannot be empty."
        case .password:
            return "Password cannot be empty."
        case .name:
            return "Name is required."
        case .terms: 
            return "You must accept the terms and conditions."
        case .confirmPassword(let reason):
            switch reason {
            case .empty: 
                return "Please confirm your password."
            case .mismatch:
                return "Passwords do not match."
            }
        }
    }
}
