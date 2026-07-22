//
//  NetworkError.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import Alamofire
import Foundation

enum NetworkError {
    case invalidURL
    case noInternetConnection
    case unauthorized
    case forbidden
    case notFound
    case quotaExceeded
    case serverError(statusCode: Int)
    case decodingFailed
    case requestFailed(message: String)
    case unknown
}
//MARK: Implemented User friendly title and message to show using alert box
extension NetworkError {
    //  Title to show as title of the alert box
    var title: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noInternetConnection:
            return "No Internet Connection"
        case .unauthorized:
            return "Credentials Issue"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .quotaExceeded:
            return "Quota Exceeded"
        case .serverError(statusCode: _):
            return "Server Error"
        case .decodingFailed:
            return "Response Issue"
        case .requestFailed:
            return "Request Error"
        case .unknown:
            return "Unexpected error"
        }
    }
}
// MARK: DisplayError Protocol
extension NetworkError: DisplayableError {
    var message: String {
        switch self {
        case .invalidURL: 
            return "Somthing went wrong. Please try again."
        case .noInternetConnection:
            return "No internet connnection. Please check your network."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .forbidden: 
            return "You don't have permission to do that."
        case .notFound:
            return "Cannot find what you are looking for"
        case .quotaExceeded:
            return "Daily request limit reached. Showing sample recipes instead."
        case .serverError(statusCode: _):
            return "Something went wrong on our end. Please try again later."
        case .decodingFailed: 
            return "Something went wrong while reading the response."
        case .requestFailed(message: let message):
            return message
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
// MARK: Implemented function which maps Alamofire errors with custom errors
extension NetworkError {
    static func map(_ error: AFError) -> NetworkError {
        if let urlError = error.underlyingError as? URLError, urlError.code == .notConnectedToInternet {
            return .noInternetConnection
        }
        switch error.responseCode {
        case 401: return .unauthorized
        case 402: return .quotaExceeded
        case 403: return .forbidden
        case 404: return .notFound
        case .some(let code) where code>=500: return .serverError(statusCode: code)
        default: break
        }
        if error.isResponseSerializationError { return .decodingFailed }
        return .requestFailed(message: error.localizedDescription)
    }
}
