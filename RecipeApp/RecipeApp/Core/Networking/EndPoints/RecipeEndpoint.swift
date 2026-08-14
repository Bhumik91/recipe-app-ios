//
//  RecipeEndpoint.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//
import Alamofire
import Foundation

// Moved to Resources/Secrets.plist (gitignored) — read via AppSecrets. Kept commented out pending removal.
//fileprivate let SPOONACULAR_API_KEYS = ["ed46c147ed734413b3b10e16a8fa0b93", "65c419295e3e43509b01d5a7720f3e43", "c2767743e1f54f828fd0f5f5ce1428be",
//    "7355913421ea473d9889c7c50442c78a"]
//fileprivate let INDEX = 3

// TODO: Key rotation scaffolding — only AppSecrets.spoonacularAPIKeys[0] is used; spare keys sit in Secrets.plist.
// Future scope: Implement key rotation on quota exhaustion (402 response) via request interceptors.
// Ref: FallbackRecipeRepository for fallback pattern; consider similar pattern.
enum RecipeEndpoint {
    case search(query: String = "", cuisine: String? = nil, diet: String? = nil, offset: Int = 0, number: Int = 10)
    case bulkDetails(ids: [Int])
    case detail(id: Int)
}

extension RecipeEndpoint: APIEndPoint {
    var baseURL: String { "https://api.spoonacular.com" }
    var path: String {
        switch self {
        case .search: return "/recipes/complexSearch"
        case .bulkDetails: return "/recipes/informationBulk"
        case .detail(let id): return "/recipes/\(id)/information"
        }
    }
    var method: HTTPMethod { .get }
    var queryParameters: [String: String]? {
        var params = ["apiKey": AppSecrets.spoonacularAPIKey]
        switch self {
        case let .search(query, cuisine, diet, offset, number):
            params["query"] = query
            params["offset"] = String(offset)
            params["number"] = String(number)
            params["addRecipeInformation"] = "true"
            if let cuisine, cuisine.lowercased() != "all" {
                params["cuisine"] = cuisine
            }
            if let diet {
                params["diet"] = diet
            }
        case let .bulkDetails(ids):
            params["ids"] = ids.map(String.init).joined(separator: ",")
        case .detail:
            break
        }
        return params
    }
}
