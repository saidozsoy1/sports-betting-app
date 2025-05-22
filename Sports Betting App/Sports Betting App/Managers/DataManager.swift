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
                    // Filter out events that don't have valid odds
                    let filteredEvents = fetchedEvents.filter { event in
                        // Check if the event has at least one bookmaker with valid odds
                        return event.bookmakers.contains { bookmaker in
                            if let h2hMarket = bookmaker.markets.first(where: { $0.key == "h2h" }) {
                                let outcomes = h2hMarket.outcomes
                                
                                // Check if outcomes contain at least home and away odds
                                let hasHomeOdds = outcomes.contains { $0.name == event.homeTeam && $0.price > 0 }
                                let hasAwayOdds = outcomes.contains { $0.name == event.awayTeam && $0.price > 0 }
                                
                                return hasHomeOdds && hasAwayOdds
                            }
                            return false
                        }
                    }
                    
                    self?.events = filteredEvents
                    completion(.success(filteredEvents))
                } else {
                    completion(result)
                }
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
