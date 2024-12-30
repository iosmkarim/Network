//
//  RequestProtocol.swift
//
//
//  Created by Md Rezaul Karim on 12/28/24.
//

import Foundation

public protocol RequestProtocol {
    var baseURL: URL { get }
    var path: String {get }
    var method: HTTPMethod { get }
    var headers : [String:String]? { get }
    var parameters: RequestParameters { get }
}
