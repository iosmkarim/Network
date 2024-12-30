//
//  APIError.swift
//
//
//  Created by Md Rezaul Karim on 12/27/24.
//

import Foundation

public enum APIError: Error {
    case urlError
    case decodingError
    case unknownError(String)
}
