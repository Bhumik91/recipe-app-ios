//
//  AuthEndPoint.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Alamofire
enum AuthEndPoint {
    case login(LoginRequest)
    case currentUser
}

extension AuthEndPoint: APIEndPoint {
    var baseURL: String  { "https://dummyjson.com" }

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .currentUser: return "/auth/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login: return .post
        case .currentUser: return .get
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .login(let request): return request
        case .currentUser: return nil
        }
    }

    // /auth/me identifies the user purely from the bearer token — no id in the path.
    var requiresAuthToken: Bool {
        switch self {
        case .login: return false
        case .currentUser: return true
        }
    }
}
