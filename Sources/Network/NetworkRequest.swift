//
//  NetworkRequest.swift
//
//
//  Created by Md Rezaul Karim on 12/28/24.
//

import Foundation

public protocol NetworkRequest {
    init(baseURL: URL, path: String)
    
    @discardableResult
    func set(method: HTTPMethod) -> Self
    
    @discardableResult
    func set(path: String) -> Self
    
    @discardableResult
    func set(headers: [String: String]?) -> Self
    
    @discardableResult
    func set(parameters: RequestParameters) -> Self
    
    func build() throws -> URLRequest
    
    
}
