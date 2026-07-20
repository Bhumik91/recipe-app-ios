//
//  LoginRequest.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
struct LoginRequest: Codable {
    let userName: String
    let password: String
    private enum CodingKeys: String, CodingKey {
        case userName = "username"
        case password
    }
}
