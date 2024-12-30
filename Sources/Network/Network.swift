// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

public protocol NetworkProtocol {
    func makeRequest<T: Codable>(with builder: RequestBuilder, type: T.Type) throws -> AnyPublisher<T, APIError>
}

public class NetworkManager: NetworkProtocol {
    public func makeRequest<T: Codable>(with builder: RequestBuilder, type: T.Type) throws -> AnyPublisher<T, APIError> {
        do {
            let request = try builder.build()
            return URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        throw APIError.unknownError("Bad response")
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error -> APIError in
                    if error is DecodingError {
                        return APIError.decodingError
                    }else if let error = error as? APIError {
                        return error
                    }else{
                        return APIError.unknownError("Unknown error occured")
                    }
                }
                .eraseToAnyPublisher()
        } catch {
           throw APIError.urlError
        }
    }
    
    public init() {
        
    }
}
