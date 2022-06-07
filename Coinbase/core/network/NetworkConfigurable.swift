//
//  NetworkConfigurable.swift
//  Coinbase
//
//  Created by hadia on 05/06/2022.
//

import Foundation


public protocol NetworkConfigurable {
    var baseURL: URL { get }
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

public final class DefaultNetworkService {
    public let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    
    public init(config: NetworkConfigurable,
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager()) {
        self.config = config
        self.sessionManager = sessionManager
    }
}


extension DefaultNetworkService: NetworkService {
    public func requestPost<T: Encodable>(endpoint: Requestable, jsonBody: T?,completion: @escaping CompletionHandler) {
        do {
            let request = try endpoint.urlRequestPost(with: config,jsonBody: jsonBody)
            sessionManager.request(request) { data, response, requestError in
                
                if let _ = requestError {
                    var error: NetworkError?
                    if let response = response as? HTTPURLResponse {
                        error = .error(statusCode: response.statusCode, data: data)
                    }
                    if let err = error {
                        completion(.failure(err))
                    }
                    
                } else {
                    completion(.success(data))
                }
            }
        } catch {
            completion(.failure(NetworkError.error(statusCode: -1, data: "URL Error".data(using: .utf8))))
        }
    }
    

    public func requestGet(endpoint: Requestable, completion: @escaping CompletionHandler) {
        
        do {
            let request = try endpoint.urlRequestGet(with: config)
            sessionManager.request(request) { data, response, requestError in
                let response = response as! HTTPURLResponse
                var error: NetworkError?
                print("Got response with status code \(response.statusCode) and \(data?.count) bytes of data")

                if response.statusCode == 400 {
                    error = .error(statusCode: response.statusCode, data: data)
                }

                if let _ = requestError {
                   
                    if let response = response as? HTTPURLResponse {
                        error = .error(statusCode: response.statusCode, data: data)
                    }
                    if let err = error {
                        completion(.failure(err))
                    }
                    
                } else {
                    completion(.success(data))
                }
            }
        } catch {
            completion(.failure(NetworkError.error(statusCode: -1, data: "URL Error".data(using: .utf8))))
        }
    }
}
