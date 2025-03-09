//
//  APIError.swift
//
//
//  Created by Md Rezaul Karim on 12/27/24.
//

import Foundation

public enum APIError: Error {
    
    /// The URL provided is invalid or malformed.
    case urlError
    
    /// The request failed due to an issue with the network connection.
    case networkError(String)
    
    /// The server responded with an unsuccessful status code.
    case serverError(statusCode: Int, message: String?)
    
    /// The response data could not be decoded into the expected model.
    case decodingError
    
    /// The request took too long and timed out.
    case timeoutError
    
    /// The request was unauthorized (e.g. missing or invalid authorization).
    case unauthorized
    
    /// The request resource was not found (HTTP 404).
    case notFound
    
    /// The request failed due to too many requests being made (rate limiting).
    case tooManyRequests
    
    /// An unknown or unexpected error occurred.
    case unknownError(String)
    
    /// Provides a user-friendly error message.
    public var localizedDescription: String {
        switch self {
        case .urlError:
            return "Invalid URL. Please check the request URL."
        case .networkError(let message):
            return "Network error occurred: \(message)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "No additional details")"
        case .decodingError:
            return "Failed to decode response. The data format might have changed or is incorrect."
        case .timeoutError:
            return "The request timed out. Please try again later."
        case .unauthorized:
            return "Unauthorized request. Please check authentication credentials."
        case .notFound:
            return "The requested resource could not be found (404)."
        case .tooManyRequests:
            return "Too many requests. Please slow down and try again later."
        case .unknownError(let message):
            return "An unknown error occurred: \(message)"
        }
    }
    /// Maps an `HTTPURLResponse` status code to a corresponding `APIError`.
    public static func from(statusCode: Int, message: String? = nil) -> APIError {
        switch statusCode {
        case 400: return .serverError(statusCode: 400, message: message ?? "Bad Request")
        case 401: return .unauthorized
        case 403: return .serverError(statusCode: 403, message: message ?? "Forbidden")
        case 404: return .notFound
        case 429: return .tooManyRequests
        case 500...599: return .serverError(statusCode: statusCode, message: message ?? "Server encountered an error")
        default: return .unknownError("Received unexpected status code: \(statusCode)")
        }
    }
}
