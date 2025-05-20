//
//  MainViewModel.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 15.05.2025.
//

import Foundation

protocol MainViewModelDelegate: AnyObject {
    func didFetchEvents()
    func didFailToFetchEvents(with error: Error)
    func didUpdateBetBasket()
    func eventsUpdated()
}

protocol MainViewModelProtocol {
    var delegate: MainViewModelDelegate? { get set }
    var events: [Event] { get }
    var filteredEvents: [Event] { get }
    var betBasket: BetBasket { get }
    
    func fetchEvents()
    func searchEvents(query: String)
    func filterEvents(by query: String)
    func addToBetBasket(eventId: String, eventName: String, outcome: Outcome, marketKey: String, bookmakerTitle: String)
    func removeFromBetBasket(eventId: String)
    func isBetInBasket(eventId: String) -> Bool
    func logEventDetails(event: Event)
    func getBetBasketItemCount() -> Int
    func getBetBasketTotalOdds() -> String
    func getBetItemAt(index: Int) -> BetItem?
    func getEventAt(index: Int) -> Event?
}

final class MainViewModel: MainViewModelProtocol {
    
    private var dataManager: DataManaging
    weak var delegate: MainViewModelDelegate?
    
    private(set) var events: [Event] = []
    private(set) var filteredEvents: [Event] = []
    var betBasket: BetBasket {
        return BetBasket.shared
    }
    
    init(dataManager: DataManaging) {
        self.dataManager = dataManager
        
        // Listen for bet basket updates
        NotificationManager.listen(self, selector: #selector(betBasketUpdated), name: .betBasketUpdated)
    }
    
    @objc private func betBasketUpdated() {
        delegate?.didUpdateBetBasket()
    }
    
    func fetchEvents() {
        dataManager.fetchEvents { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let events):
                self.events = events
                self.filteredEvents = events
                self.delegate?.didFetchEvents()
            case .failure(let error):
                self.delegate?.didFailToFetchEvents(with: error)
            }
        }
    }
    
    func searchEvents(query: String) {
        if query.isEmpty {
            filteredEvents = events
        } else {
            filteredEvents = dataManager.searchEvents(query: query)
        }
        delegate?.didFetchEvents()
    }
    
    func filterEvents(by query: String) {
        if query.isEmpty {
            filteredEvents = events
        } else {
            filteredEvents = events.filter { event in
                return event.homeTeam.lowercased().contains(query.lowercased()) ||
                       event.awayTeam.lowercased().contains(query.lowercased()) ||
                       event.sportTitle.lowercased().contains(query.lowercased())
            }
        }
        delegate?.eventsUpdated()
    }
    
    func addToBetBasket(eventId: String, eventName: String, outcome: Outcome, marketKey: String, bookmakerTitle: String) {
        betBasket.addBet(eventId: eventId, eventName: eventName, outcome: outcome, marketKey: marketKey, bookmakerTitle: bookmakerTitle)
    }
    
    func removeFromBetBasket(eventId: String) {
        betBasket.removeBet(eventId: eventId)
    }
    
    func isBetInBasket(eventId: String) -> Bool {
        return betBasket.items.contains(where: { $0.eventId == eventId })
    }
    
    func logEventDetails(event: Event) {
        FirebaseAnalyticsManager.shared.logEvent(.matchDetailViewed(event: event))
    }
    
    func getBetBasketItemCount() -> Int {
        return betBasket.items.count
    }
    
    func getBetBasketTotalOdds() -> String {
        return betBasket.formattedTotalPrice
    }
    
    func getBetItemAt(index: Int) -> BetItem? {
        guard index >= 0 && index < betBasket.items.count else { return nil }
        return betBasket.items[index]
    }
    
    func getEventAt(index: Int) -> Event? {
        guard index >= 0 && index < filteredEvents.count else { return nil }
        return filteredEvents[index]
    }
    
    deinit {
        NotificationManager.removeObserver(self, name: .betBasketUpdated)
    }
}
