//
//  EndPoints.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Alamofire

protocol APIEndPoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: String]? { get }   // → URL, e.g. ?query=pasta&number=20
    var body: Encodable? { get }                       // → JSON request body, e.g. login credentials
    var requiresAuthToken: Bool { get }
}
//MARK: Adding Default Value
extension APIEndPoint {
    var queryParameters: [String: String]? { nil }
    var body: Encodable? { nil }
    var requiresAuthToken: Bool { false }
}
