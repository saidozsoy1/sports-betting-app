//
//  ServiceManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

import Foundation

protocol ApiServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Swift.Result<T, NetworkError>) -> Void)
}

// Default implementation to make ApiManager conform to the protocol
extension ApiManager: ApiServiceProtocol {}

class ServiceManager {
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Odds API
    
    func fetchOddsForAllRegions(completion: @escaping (Result<[Event], NetworkError>) -> Void) {
        let group = DispatchGroup()
        var usOdds: [Event]?
        var ukOdds: [Event]?
        var euOdds: [Event]?
        var auOdds: [Event]?
        var error: NetworkError?
        
        LoadingManager.showLoading()
        // US region
        group.enter()
        apiService.request(APIEndpoint.upcomingOdds(region: .us, market: .h2h)) { (result: Result<[Event], NetworkError>) in
            switch result {
            case .success(let events):
                usOdds = events
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        // UK region
        group.enter()
        apiService.request(APIEndpoint.upcomingOdds(region: .uk, market: .h2h)) { (result: Result<[Event], NetworkError>) in
            switch result {
            case .success(let events):
                ukOdds = events
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        // EU region
        group.enter()
        apiService.request(APIEndpoint.upcomingOdds(region: .eu, market: .h2h)) { (result: Result<[Event], NetworkError>) in
            switch result {
            case .success(let events):
                euOdds = events
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        // AU region
        group.enter()
        apiService.request(APIEndpoint.upcomingOdds(region: .au, market: .h2h)) { (result: Result<[Event], NetworkError>) in
            switch result {
            case .success(let events):
                auOdds = events
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var allOdds: [Event] = []
            if let usOdds = usOdds {
                allOdds.append(contentsOf: usOdds)
            }
            if let ukOdds = ukOdds {
                allOdds.append(contentsOf: ukOdds)
            }
            if let euOdds = euOdds {
                allOdds.append(contentsOf: euOdds)
            }
            if let auOdds = auOdds {
                allOdds.append(contentsOf: auOdds)
            }
            LoadingManager.hideLoading()
            completion(.success(allOdds))
        }
    }
}
