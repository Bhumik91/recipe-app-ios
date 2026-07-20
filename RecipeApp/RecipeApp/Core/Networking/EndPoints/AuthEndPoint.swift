//
//  AuthEndPoint.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Alamofire
enum AuthEndPoint {
    case login(LoginRequest)
}

extension AuthEndPoint: APIEndPoint {
    var baseURL: String  { "https://dummyjson.com" }
    
    var path: String {
        switch self {
        case .login: return "/auth/login"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login: return .post
        }
    }
    
    var body: (any Encodable)? {
        switch self {
        case .login(let request): return request
        }
    }
}
