//
//  UserDetailsDTO.swift
//  RecipeApp
//

/// Raw `GET /auth/me` response. Mirrors Android's `UserDetailsDto`.
struct UserDetailsDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let userName: String
    let imageURL: String

    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email
        case userName = "username"
        case imageURL = "image"
    }
}
