//
//  NetworkSessionManager.swift
//  Coinbase
//
//  Created by hadia on 05/06/2022.
//

import Foundation

public protocol NetworkSessionManager {
    typealias Completion = (Data?, URLResponse?, Error?) -> Void
    
    func request(_ request: URLRequest, completion: @escaping Completion)
}

public class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() {}
    
    public func request(_ request: URLRequest, completion: @escaping Completion) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
    }
}
