//
//  RequestBuilder.swift
//
//
//  Created by Md Rezaul Karim on 12/28/24.
//

import Foundation

public final class RequestBuilder: NetworkRequest {
    
    private var baseURL: URL
    private var path: String
    private var method: HTTPMethod = .get
    private var headers : [String:String]?
    private var parameters: RequestParameters?
    
    public init(baseURL: URL, path: String) {
        self.baseURL =  baseURL
        self.path = path
         
    }
    @discardableResult
    public func set(method: HTTPMethod) -> Self {
        self.method = method
        return self
    }
    @discardableResult
    public func set(path: String) -> Self {
        self.path = path
        return self
    }
    @discardableResult
    public func set(headers: [String : String]?) -> Self {
        self.headers = headers
        return self
    }
    @discardableResult
    public func set(parameters: RequestParameters) -> Self {
        self.parameters = parameters
        return self
    }
    
    public func build() throws -> URLRequest {
        var url = baseURL.appendingPathComponent(path)
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 50)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        setupBody(urlRequest: &urlRequest)
        return urlRequest
    }
    
    private func setupBody(urlRequest: inout URLRequest) {
        if let parameters = parameters {
            switch parameters {
            case .body(let bodyParam):
                setupRequestBody(parameters: bodyParam, request: &urlRequest)
            case .url(let urlParam):
                setupRequestURLBody(parameters: urlParam, request: &urlRequest)
            }
        }
    }
    
    private func setupRequestBody(parameters: [String: Any]?, request: inout URLRequest) {
        if let parameters = parameters {
            let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = data
            
        }
    }
    
    private func setupRequestURLBody(parameters: [String: String]?, request: inout URLRequest) {
        if let parameters = parameters, let url = request.url,
           var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            request.url = urlComponents.url
        }
    }
}
