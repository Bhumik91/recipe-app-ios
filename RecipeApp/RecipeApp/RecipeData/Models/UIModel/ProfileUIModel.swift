//
//  ProfileUIModel.swift
//  RecipeApp
//

/// Screen-ready user details. The display-name fallback matches Android's `bindUser`:
/// "first last", collapsing to the username when both name parts are blank.
struct ProfileUIModel: Equatable {
    let displayName: String
    let userNameHandle: String
    let email: String
    let imageURL: String
}

extension UserDetailsDTO {
    func toUIModel() -> ProfileUIModel {
        let fullName = [firstName, lastName]
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: " ")

        return ProfileUIModel(
            displayName: fullName.isEmpty ? userName : fullName,
            userNameHandle: "@\(userName)",
            email: email,
            imageURL: imageURL
        )
    }
}
