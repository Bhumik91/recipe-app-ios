//
//  RecipeEndpoint.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//
import Alamofire
import Foundation

//fileprivate let SPOONACULAR_API_KEY = "c2767743e1f54f828fd0f5f5ce1428be"
//fileprivate let SPOONACULAR_API_KEY = "65c419295e3e43509b01d5a7720f3e43"
fileprivate let SPOONACULAR_API_KEY = "ed46c147ed734413b3b10e16a8fa0b93"

enum RecipeEndpoint {
    case search(query: String = "", cuisine: String? = nil, diet: String? = nil, offset: Int = 0, number: Int = 10)
    case bulkDetails(ids: [Int])
}

extension RecipeEndpoint: APIEndPoint {
    var baseURL: String { "https://api.spoonacular.com" }
    var path: String {
        switch self {
        case .search: return "/recipes/complexSearch"
        case .bulkDetails: return "/recipes/informationBulk"
        }
    }
    var method: HTTPMethod { .get }
    var queryParameters: [String: String]? {
        var params = ["apiKey": SPOONACULAR_API_KEY]
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
        }
        return params
    }
}
