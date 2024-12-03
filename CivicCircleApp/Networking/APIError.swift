//
//  APIError.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//

import Foundation

enum APIError: Error {
    case invalidCredentials
    case unexpectedStatusCode
    case invalidResponse
    case networkError(String)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials. Please try again."
        case .unexpectedStatusCode:
            return "Unexpected error occurred. Please try again later."
        case .invalidResponse:
            return "Invalid response from the server."
        case .networkError(let message):
            return message
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
