//
//  NetworkManager.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Foundation
import Combine

protocol NetworkRequest {
    var request: URLRequest { get }
    static func builder(path: String, _ params: [String: String]) -> Self
}

protocol NetworkProtocol {
    associatedtype Request: NetworkRequest
    static var baseUrl: String { get }
}

/**
 NetworkManager: A struct conform NetworkProtocol for abstruction of baseurl and request.
 baseurl: Is needed
 Request: Build request with query params(if any), appends path with baseURL and must not be nil(!)
 executeTask(T)(: :): Accessible by outside only, execute task, decode and respone back with T or Error
 */

struct NetworkManager: NetworkProtocol {
    typealias Error = JPHError
    
    /// Protocol
    static var baseUrl: String {
        return "https://jsonplaceholder.typicode.com"
    }
    
    struct Request: NetworkRequest {
        var request: URLRequest
        
        private init(with request: URLRequest) {
            self.request = request
        }
        
        static func builder(path: String, _ params: [String : String]) -> Request {
            var component = URLComponents(string: NetworkManager.baseUrl)!
            component.path = "/" + path
            component.queryItems = params.map { URLQueryItem(name: $0, value: "\($1)") }
            /// Failed if url is invalid (so, !)
            return Request(with: URLRequest(url: component.url!))
        }
    }
    
    /// Accessible by outside, respone back with T or Error
    static func executeTask<T: Decodable>(path: String, _ params: [String: String]? = nil) -> AnyPublisher<T, JPHError> {
        return executeAndDecode(for: Request.builder(path: path, params ?? [:]).request, decoder: JSONDecoder())
    }
}


///
///
/// Keeping seperate from outside as service classes don't need to know about
fileprivate extension NetworkManager {
    /// Decode the executed responses to send back Passthrough publisher as we don't need to keep previous state. Othweise, generate error.
    static func executeAndDecode<Item, Decoder>(for request: URLRequest, decoder: Decoder) -> AnyPublisher<Item, JPHError> where Item: Decodable, Decoder: TopLevelDecoder, Decoder.Input == Data {
        let publisher = PassthroughSubject<Item, JPHError>()
        asyncTask(request) { (result: Result<Data, JPHError>) in
            switch result {
            case .success(let data):
                if let item = try? decoder.decode(Item.self, from: data) {
                    publisher.send(item)
                    publisher.send(completion: .finished)
                } else {
                    publisher.send(completion: .failure(JPHError.decodeError))
                }
            case .failure(let error):
                publisher.send(completion: .failure(error))
            }
        }
        return publisher.eraseToAnyPublisher()
    }
    
    /// Perform actual task(async over global queue) to provide data it's caller
    static func asyncTask(_ request: URLRequest, completion: @escaping (Result<Data, JPHError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    completion(.success(data))
                } else if let error = error {
                    completion(.failure(JPHError.unknown(error)))
                }
            }.resume()
        }
    }
}

