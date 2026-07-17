//
//  SessionManaging.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//

protocol SessionManaging {
    var isLoggedIn: Bool { get }
    var userId: Int { get }
    var userName: String? { get }
    var accessToken: String? { get }
    func saveAuthSession(_ response: LoginResponse)
    func clearSession()
}