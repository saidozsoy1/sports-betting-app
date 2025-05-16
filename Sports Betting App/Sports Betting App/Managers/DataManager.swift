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
    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void)
    func getEventDetails(id: String) -> Event?
    func searchEvents(query: String) -> [Event]
}

final class DataManager: DataManaging {
    private var events: [Event] = []
    
    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        
        let sampleData = """
        [{"id":"77533a66b76f045b06ed0dec7f5fa9aa","sport_key":"tennis_wta_italian_open","sport_title":"WTA Italian Open","commence_time":"2025-05-15T13:28:00Z","home_team":"Jasmine Paolini","away_team":"Peyton Stearns","bookmakers":[{"key":"onexbet","title":"1xBet","last_update":"2025-05-15T13:26:43Z","markets":[{"key":"h2h","last_update":"2025-05-15T13:26:43Z","outcomes":[{"name":"Jasmine Paolini","price":1.4},{"name":"Peyton Stearns","price":3.0}]}]},{"key":"coolbet","title":"Coolbet","last_update":"2025-05-15T13:38:00Z","markets":[{"key":"h2h","last_update":"2025-05-15T13:38:00Z","outcomes":[{"name":"Jasmine Paolini","price":1.6},{"name":"Peyton Stearns","price":2.35}]}]}]},{"id":"51522eed73e0d195a32c2a469438408d","sport_key":"baseball_mlb","sport_title":"MLB","commence_time":"2025-05-15T16:15:00Z","home_team":"Atlanta Braves","away_team":"Washington Nationals","bookmakers":[{"key":"betonlineag","title":"BetOnline.ag","last_update":"2025-05-15T13:39:58Z","markets":[{"key":"h2h","last_update":"2025-05-15T13:39:58Z","outcomes":[{"name":"Atlanta Braves","price":1.48},{"name":"Washington Nationals","price":2.89}]}]}]},{"id":"ac99dd72f8857c704c50e86ce5a73b39","sport_key":"baseball_mlb","sport_title":"MLB","commence_time":"2025-05-15T16:35:00Z","home_team":"Baltimore Orioles","away_team":"Minnesota Twins","bookmakers":[{"key":"betonlineag","title":"BetOnline.ag","last_update":"2025-05-15T13:39:58Z","markets":[{"key":"h2h","last_update":"2025-05-15T13:39:58Z","outcomes":[{"name":"Baltimore Orioles","price":1.79},{"name":"Minnesota Twins","price":2.15}]}]}]}]
        """
        
        do {
            let decoder = JSONDecoder()
            self.events = try decoder.decode([Event].self, from: sampleData.data(using: .utf8)!)
            completion(.success(self.events))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getEventDetails(id: String) -> Event? {
        return events.first(where: { $0.id == id })
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
