//
//  ApiManager.swift
//  Sports Betting App
//
//  Created by Said Ozsoy on 16.05.2025.
//

import Foundation

enum NetworkError: Error {
    case networkError
    case parseError
    case invalidResponse
    case apiLimitExceeded
}

enum APIEndpoint {
    private static let baseURL = "https://api.the-odds-api.com/v4"
    private static let apiKey = "287627ef3961eb698398f3ae86939463"
    
    case upcomingOdds(region: Region, market: MarketType)
    
    var url: String {
        switch self {
        case .upcomingOdds(let region, let market):
            return "\(APIEndpoint.baseURL)/sports/upcoming/odds/?regions=\(region.rawValue)&markets=\(market.rawValue)&apiKey=\(APIEndpoint.apiKey)"
        }
    }
}

class ApiManager {
    static let shared = ApiManager()
    
    private init() {}
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Swift.Result<T, NetworkError>) -> Void) {
        request(endpoint.url, completion: completion)
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, method: String = "GET", parameters: [String: Any]? = nil, completion: @escaping (Swift.Result<T, NetworkError>) -> Void) {
        request(endpoint.url, method: method, parameters: parameters, completion: completion)
    }
    
    func request<T: Decodable>(_ urlString: String, completion: @escaping (Swift.Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.networkError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.networkError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                completion(.failure(.apiLimitExceeded))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.parseError))
            }
        }
        task.resume()
    }
    
    func request<T: Decodable>(_ urlString: String, method: String = "GET", parameters: [String: Any]? = nil, completion: @escaping (Swift.Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.networkError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters, method != "GET" {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
            } catch {
                completion(.failure(.parseError))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.networkError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                completion(.failure(.apiLimitExceeded))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.parseError))
            }
        }
        task.resume()
    }
}
