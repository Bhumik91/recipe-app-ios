//
//  AppSecrets.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 14/08/26.
//
import Foundation

// Reads Resources/Secrets.plist from the app bundle. That file is gitignored —
// copy Secrets.plist.example to Secrets.plist and fill in your own key.
enum AppSecrets {
    private struct SecretsFile: Decodable {
        let spoonacularAPIKeys: [String]

        enum CodingKeys: String, CodingKey {
            case spoonacularAPIKeys = "SpoonacularAPIKeys"
        }
    }

    static let spoonacularAPIKeys: [String] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let file = try? PropertyListDecoder().decode(SecretsFile.self, from: data),
              !file.spoonacularAPIKeys.isEmpty else {
            fatalError("Secrets.plist is missing, malformed, or has no keys. Copy RecipeApp/Resources/Secrets.plist.example to Secrets.plist and add your Spoonacular API key.")
        }
        return file.spoonacularAPIKeys
    }()

    // The key every request uses today; rotation is future scope (see RecipeEndpoint).
    static var spoonacularAPIKey: String { spoonacularAPIKeys[0] }
}
