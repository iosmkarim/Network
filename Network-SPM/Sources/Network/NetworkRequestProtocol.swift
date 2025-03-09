//
//  NetworkRequestProtocol.swift
//
//
//  Created by Md Rezaul Karim on 12/28/24.
//

import Foundation


public protocol NetworkRequestProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod {get}
    var queryParameters: [URLQueryItem]? { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
    
    func urlRequest() throws -> URLRequest
}

extension NetworkRequestProtocol {
    var headers: [String: String]? {
        return nil
    }

    func urlRequest() throws -> URLRequest {
        //1 work on URL Components

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        
        urlComponents?.path = path.hasPrefix("/") ? path : "/\(path)"
        
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters
        }
        
        /// Construct URLRequest
        guard let url = urlComponents?.url else {
            throw APIError.urlError
        }
        var request = URLRequest(url: url)
        

        request.httpMethod = httpMethod.rawValue
        
        /// Set HTTP body only for non-GET requests
        if httpMethod != .get {
            request.httpBody = body
        }
                
        // header
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)            
        }
        return request
    }
}
