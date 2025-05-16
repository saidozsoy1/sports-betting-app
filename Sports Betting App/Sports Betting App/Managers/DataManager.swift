//
//  DataManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import Foundation
import CoreLocation
import MapKit

protocol DataManaging {
    func fetchEvents(completion: @escaping (Result<[Event], NetworkError>) -> Void)
    func searchEvents(query: String) -> [Event]
}

final class DataManager: DataManaging {
    private var events: [Event] = []
    private let serviceManager: ServiceManager
    
    init(serviceManager: ServiceManager = ServiceManager()) {
        self.serviceManager = serviceManager
    }
    
    func fetchEvents(completion: @escaping (Result<[Event], NetworkError>) -> Void) {
        serviceManager.fetchOddsForAllRegions { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let fetchedEvents) = result {
                    self?.events = fetchedEvents
                }
                completion(result)
            }
        }
    }
    
    func searchEvents(query: String) -> [Event] {
        let lowercasedQuery = query.lowercased()
        
        if lowercasedQuery.isEmpty {
            return events
        }
        
        return events.filter { event in
            event.homeTeam.lowercased().contains(lowercasedQuery) ||
            event.awayTeam.lowercased().contains(lowercasedQuery) ||
            event.sportTitle.lowercased().contains(lowercasedQuery)
        }
    }
} 
