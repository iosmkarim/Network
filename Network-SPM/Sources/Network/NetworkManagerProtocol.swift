//
//  File.swift
//  Network
//
//  Created by Md Rezaul Karim on 3/9/25.
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(request: NetworkRequestProtocol, responseType: T.Type) async throws -> T
}
