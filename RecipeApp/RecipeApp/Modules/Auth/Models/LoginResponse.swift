//
//  LoginResponse.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
struct LoginResponse: Codable {
    let userId: Int?
    let name: String?
    let accessToken: String?
    let refreshToken: String?
    private enum CodingKeys: String, CodingKey {
        case userId = "id"
        case name = "firstName"
        case accessToken
        case refreshToken
    }
}
