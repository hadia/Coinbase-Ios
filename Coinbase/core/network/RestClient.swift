//
//  RestClient.swift
//  Coinbase
//
//  Created by hadia on 28/05/2022.
//

import Foundation
import Combine

private let ACCESS_TOKEN = "4df59b9b3cf641813894da7b830a562a8d4438e4a262749e2f6421f78963ec31"
/// Provides access to the REST Backend
protocol RestClient {
    /// Retrieves a JSON resource and decodes it
    func get<T: Decodable, E: Endpoint>(_ endpoint: E) -> AnyPublisher<T, Error>
    
    /// Creates some resource by sending a JSON body and returning empty response
    func post<T: Decodable, S: Encodable, E: Endpoint>(_ endpoint: E, using body: S?,using api2FATokenVersion:String?)
    -> AnyPublisher<T, Error>
}

class RestClientImpl: RestClient {
    
    private let session: URLSession
    
    init(sessionConfig: URLSessionConfiguration? = nil) {
        self.session = URLSession(configuration: sessionConfig ?? URLSessionConfiguration.default)
    }
    
    func get<T, E>(_ endpoint: E) -> AnyPublisher<T, Error> where T: Decodable, E: Endpoint {
        startRequest(for: endpoint, method: "GET", jsonBody: nil as String?)
            .tryMap { try $0.parseJson() }
            .eraseToAnyPublisher()
    }
    
    func post<T, S, E>(_ endpoint: E, using body: S?,using api2FATokenVersion:String?=nil as String?)
    -> AnyPublisher<T, Error> where T: Decodable, S: Encodable, E: Endpoint
    {
        startRequest(for: endpoint, method: "POST", jsonBody: body)
            .tryMap { try $0.parseJson() }
//            .catch { error -> AnyPublisher<T, Error> in
//                switch error {
//                case RestClientErrors.noDataReceived:
//                    // API's Post request doesn't return data back even with code 200
//                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
//                default:
//                    return Fail<Void, Error>(error: error).eraseToAnyPublisher()
//                }
//            }
            .eraseToAnyPublisher()
    }
    
    private func startRequest<T: Encodable, S: Endpoint>(for endpoint: S,
                                                         method: String,
                                                         jsonBody: T? = nil,
                                                         api2FATokenVersion:String?=nil)
    -> AnyPublisher<InterimRestResponse, Error> {
        var request: URLRequest
        
        do {
            request = try buildRequest(endpoint: endpoint, method: method, jsonBody: jsonBody ,api2FATokenVersion: api2FATokenVersion)
        } catch {
            print("Failed to create request: \(String(describing: error))")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        print("Starting \(method) request for \(String(describing: request))")
        
        return session.dataTaskPublisher(for: request)
            .mapError { (error: Error) -> Error in
                print("Request failed: \(String(describing: error))")
                return RestClientErrors.requestFailed(error: error)
            }
        // we got a response, lets see what kind of response
            .tryMap { (data: Data, response: URLResponse) in
                let response = response as! HTTPURLResponse
                print("Got response with status code \(response.statusCode) and \(data.count) bytes of data")
                
                if response.statusCode == 400 {
                    throw RestClientErrors.requestFailed(code: response.statusCode)
                }
                return InterimRestResponse(data: data, response: response)
            }.eraseToAnyPublisher()
    }
    
    private func buildRequest<T: Encodable, S: Endpoint>(endpoint: S,
                                                         method: String,
                                                         jsonBody: T?,
                                                         api2FATokenVersion:String?=nil) throws -> URLRequest {
        var request = URLRequest(url: endpoint.url, timeoutInterval: 10)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ACCESS_TOKEN)", forHTTPHeaderField: "Authorization")
        request.setValue("2021-09-07", forHTTPHeaderField: "CB-VERSION")
        
        if let api2FAToken = api2FATokenVersion  {
            request.setValue(api2FAToken, forHTTPHeaderField: "CB-2FA-TOKEN")
        }
       
        // if we got some data, we encode as JSON and put it in the request
        if let body = jsonBody {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw RestClientErrors.jsonDecode(error: error)
            }
        }
        return request
    }
    
    struct InterimRestResponse {
        let data: Data
        let response: HTTPURLResponse
        
        func parseJson<T: Decodable>() throws -> T {
            if data.isEmpty {
                throw RestClientErrors.noDataReceived
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                print("JSON Result: \(result)", String(describing: result))
                return result
            } catch {
                print("Failed to decode JSON: \(error)", String(describing: error))
                throw RestClientErrors.jsonDecode(error: error)
            }
        }
    }
    
}

