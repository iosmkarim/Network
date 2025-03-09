// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

/// A protocol that defines the requirements for a network manager.
public protocol NetworkProtocol {
    /// Makes a network request and decodes the response into the specified Codable type.
    ///
    /// - Parameters:
    ///   - request: A NetworkRequestProtocol instance to build the URLRequest.
    ///   - type: The expected Codable type.
    /// - Returns: A publisher emitting the decoded data or an APIError.
    func makeRequest<T: Codable>(with request: NetworkRequestProtocol, type: T.Type) throws -> AnyPublisher<T, APIError>
    
    /// Asynchronously makes a network request and decodes the response into the specified Codable type.
    ///
    /// - Parameters:
    ///   - request: A NetworkRequestProtocol instance to build the URLRequest.
    ///   - type: The expected Codable type.
    /// - Returns: The decoded data.
    /// - Throws: An APIError if something goes wrong.
    @available(iOS 15.0, *)
    func makeRequestAsync<T: Codable>(with request: NetworkRequestProtocol, type: T.Type) async throws -> T
}


public class NetworkManager: NetworkProtocol {
    
    public init() { }
    
    // MARK: - Combine Implementation
    
    public func makeRequest<T: Codable>(with request: NetworkRequestProtocol, type: T.Type) -> AnyPublisher<T, APIError> {
        do {
            let request = try request.urlRequest()
            return URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.unknownError("Invalid response type.")
                    }
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        throw APIError.from(statusCode: httpResponse.statusCode)
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    // Handle decoding and APIError directly, while other errors go to unknownError
                    if let decodingError = error as? DecodingError {
                        return .decodingError
                    } else if let apiError = error as? APIError {
                        return apiError
                    } else if let urlError = error as? URLError {
                        // Map URLError to existing APIError cases
                        switch urlError.code {
                        case .timedOut:
                            return .timeoutError
                        case .notConnectedToInternet:
                            return .networkError("No internet connection")
                        case .cannotFindHost, .cannotConnectToHost:
                            return .networkError("Cannot connect to the server")
                        default:
                            return .networkError(urlError.localizedDescription)
                        }
                    } else {
                        return .unknownError(error.localizedDescription)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.urlError).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Async/Await Implementation (iOS 15+)
    
    @available(iOS 15.0, *)
    public func makeRequestAsync<T: Codable>(with request: NetworkRequestProtocol, type: T.Type) async throws -> T {
        // Step 1: Build the URLRequest
        let urlRequest: URLRequest
        do {
            urlRequest = try request.urlRequest()
        } catch {
            throw APIError.urlError // Invalid URL error
        }
        
        // Step 2: Perform the network request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            // Handle various network errors
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    throw APIError.timeoutError // Timeout error
                case .notConnectedToInternet:
                    throw APIError.networkError("No internet connection")
                case .cannotFindHost, .cannotConnectToHost:
                    throw APIError.networkError("Cannot connect to the server")
                case .userAuthenticationRequired:
                    throw APIError.unauthorized // Unauthorized error
                default:
                    throw APIError.networkError(urlError.localizedDescription) // Catch all other network errors
                }
            } else {
                throw APIError.networkError(error.localizedDescription) // Generic network error
            }
        }
        
        // Step 3: Validate the HTTP response status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknownError("Invalid response type.")
        }
        
        // Map HTTP status codes to APIError cases
        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.from(statusCode: httpResponse.statusCode)
        }
        
        // Step 4: Decode the response data
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError // Failed to decode response into the model
        }
    }
}
