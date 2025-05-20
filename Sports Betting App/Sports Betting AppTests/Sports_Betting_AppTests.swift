//
//  Sports_Betting_AppTests.swift
//  Sports Betting AppTests
//
//  Created by Said Ozsoy on 15.05.2025.
//

import Testing
import Foundation
@testable import Sports_Betting_App

struct Sports_Betting_AppTests {
    
    // MARK: - Data Manager Tests
    
    @Test func testDataManagerSearchEvents() throws {
        // Given
        let mockEvents = MockData.createMockEvents()
        let dataManager = MockDataManager(mockEvents: mockEvents)
        
        // When - search for "soccer"
        let soccerResults = dataManager.searchEvents(query: "soccer")
        
        // Then
        #expect(soccerResults.count == 2)
        #expect(soccerResults.allSatisfy { $0.sportTitle.lowercased().contains("soccer") })
        
        // When - search for team
        let teamResults = dataManager.searchEvents(query: "Arsenal")
        
        // Then
        #expect(teamResults.count == 1)
        #expect(teamResults.first?.homeTeam == "Arsenal")
        
        // When - empty search
        let emptyResults = dataManager.searchEvents(query: "")
        
        // Then
        #expect(emptyResults.count == mockEvents.count)
    }
    
    @Test func testDataManagerFetchEvents() async throws {
        // Given
        let mockEvents = MockData.createMockEvents()
        let dataManager = MockDataManager(mockEvents: mockEvents, shouldSucceed: true)
        var fetchedEvents: [Event]?
        
        // When
        dataManager.fetchEvents { result in
            if case .success(let events) = result {
                fetchedEvents = events
            }
        }
        
        // Simulate wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        #expect(fetchedEvents != nil)
        #expect(fetchedEvents?.count == mockEvents.count)
        #expect(fetchedEvents?[0].id == mockEvents[0].id)
    }
    
    @Test func testDataManagerFetchEventsFailure() async throws {
        // Given
        let dataManager = MockDataManager(mockEvents: [], shouldSucceed: false)
        var receivedError: NetworkError?
        
        // When
        dataManager.fetchEvents { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        // Simulate wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        #expect(receivedError != nil)
        #expect(receivedError == .networkError)
    }
    
    // MARK: - Main View Model Tests
    
    @Test func testMainViewModelFetchEvents() async throws {
        // Given
        let mockEvents = MockData.createMockEvents()
        let dataManager = MockDataManager(mockEvents: mockEvents, shouldSucceed: true)
        let viewModel = MainViewModel(dataManager: dataManager)
        let mockDelegate = MockMainViewModelDelegate()
        viewModel.delegate = mockDelegate
        
        var delegateWasCalled = false
        mockDelegate.didFetchEventsClosure = {
            delegateWasCalled = true
        }
        
        // When
        viewModel.fetchEvents()
        
        // Simulate wait for async operation to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        #expect(delegateWasCalled)
        #expect(viewModel.events.count == mockEvents.count)
        #expect(viewModel.filteredEvents.count == mockEvents.count)
    }
    
    @Test func testMainViewModelSearchEvents() throws {
        // Given
        let mockEvents = MockData.createMockEvents()
        let dataManager = MockDataManager(mockEvents: mockEvents)
        let viewModel = MainViewModel(dataManager: dataManager)
        let mockDelegate = MockMainViewModelDelegate()
        viewModel.delegate = mockDelegate
        
        // Önce viewModel.events'i doldurmak için fetchEvents çağırıyoruz
        viewModel.fetchEvents()
        
        var delegateWasCalled = false
        mockDelegate.didFetchEventsClosure = {
            delegateWasCalled = true
        }
        
        // When
        viewModel.searchEvents(query: "Basketball")
        
        // Then
        #expect(delegateWasCalled)
        #expect(viewModel.filteredEvents.count == 1)
        #expect(viewModel.filteredEvents.first?.sportTitle.contains("Basketball") == true)
    }
    
    @Test func testMainViewModelFilterEvents() throws {
        // Given
        let mockEvents = MockData.createMockEvents()
        let dataManager = MockDataManager(mockEvents: mockEvents)
        let viewModel = MainViewModel(dataManager: dataManager)
        let mockDelegate = MockMainViewModelDelegate()
        viewModel.delegate = mockDelegate
        
        viewModel.fetchEvents()
        
        var delegateWasCalled = false
        mockDelegate.eventsUpdatedClosure = {
            delegateWasCalled = true
        }
        
        // When
        viewModel.filterEvents(by: "Lakers")
        
        // Then
        #expect(delegateWasCalled)
        #expect(viewModel.filteredEvents.count == 1)
        #expect(viewModel.filteredEvents.first?.homeTeam.contains("Lakers") == true)
    }
}

// MARK: - Mock Classes

// Mock Data Manager
class MockDataManager: DataManaging {
    private let mockEvents: [Event]
    private let shouldSucceed: Bool
    
    init(mockEvents: [Event], shouldSucceed: Bool = true) {
        self.mockEvents = mockEvents
        self.shouldSucceed = shouldSucceed
    }
    
    func fetchEvents(completion: @escaping (Result<[Event], NetworkError>) -> Void) {
        if shouldSucceed {
            completion(.success(mockEvents))
        } else {
            completion(.failure(.networkError))
        }
    }
    
    func searchEvents(query: String) -> [Event] {
        if query.isEmpty {
            return mockEvents
        }
        
        return mockEvents.filter { event in
            event.homeTeam.lowercased().contains(query.lowercased()) ||
            event.awayTeam.lowercased().contains(query.lowercased()) ||
            event.sportTitle.lowercased().contains(query.lowercased())
        }
    }
}

// Mock Delegate
class MockMainViewModelDelegate: MainViewModelDelegate {
    var didFetchEventsClosure: (() -> Void)?
    var didFailToFetchEventsClosure: ((Error) -> Void)?
    var didUpdateBetBasketClosure: (() -> Void)?
    var eventsUpdatedClosure: (() -> Void)?
    
    func didFetchEvents() {
        didFetchEventsClosure?()
    }
    
    func didFailToFetchEvents(with error: Error) {
        didFailToFetchEventsClosure?(error)
    }
    
    func didUpdateBetBasket() {
        didUpdateBetBasketClosure?()
    }
    
    func eventsUpdated() {
        eventsUpdatedClosure?()
    }
}

// MARK: - Mock Data

enum MockData {
    static func createMockEvents() -> [Event] {
        let outcome1 = Outcome(name: "Arsenal", price: 1.8)
        let outcome2 = Outcome(name: "Chelsea", price: 2.1)
        let outcome3 = Outcome(name: "Draw", price: 3.5)
        
        let market1 = Market(key: "h2h", lastUpdate: "2025-05-15T12:00:00Z", outcomes: [outcome1, outcome2, outcome3])
        let bookmaker1 = Bookmaker(key: "bookmaker1", title: "Bookmaker 1", lastUpdate: "2025-05-15T12:00:00Z", markets: [market1])
        
        let event1 = Event(id: "event1", sportKey: "soccer_epl", sportTitle: "Soccer EPL", commenceTime: "2025-05-20T15:00:00Z", homeTeam: "Arsenal", awayTeam: "Chelsea", bookmakers: [bookmaker1])
        
        let outcome4 = Outcome(name: "Barcelona", price: 1.5)
        let outcome5 = Outcome(name: "Real Madrid", price: 2.7)
        let outcome6 = Outcome(name: "Draw", price: 3.2)
        
        let market2 = Market(key: "h2h", lastUpdate: "2025-05-15T12:00:00Z", outcomes: [outcome4, outcome5, outcome6])
        let bookmaker2 = Bookmaker(key: "bookmaker2", title: "Bookmaker 2", lastUpdate: "2025-05-15T12:00:00Z", markets: [market2])
        
        let event2 = Event(id: "event2", sportKey: "soccer_laliga", sportTitle: "Soccer La Liga", commenceTime: "2025-05-21T19:00:00Z", homeTeam: "Barcelona", awayTeam: "Real Madrid", bookmakers: [bookmaker2])
        
        let outcome7 = Outcome(name: "Lakers", price: 1.9)
        let outcome8 = Outcome(name: "Bulls", price: 1.95)
        
        let market3 = Market(key: "h2h", lastUpdate: "2025-05-15T12:00:00Z", outcomes: [outcome7, outcome8])
        let bookmaker3 = Bookmaker(key: "bookmaker3", title: "Bookmaker 3", lastUpdate: "2025-05-15T12:00:00Z", markets: [market3])
        
        let event3 = Event(id: "event3", sportKey: "basketball_nba", sportTitle: "Basketball NBA", commenceTime: "2025-05-22T23:00:00Z", homeTeam: "Lakers", awayTeam: "Bulls", bookmakers: [bookmaker3])
        
        return [event1, event2, event3]
    }
    
    static func createMockRegionEvents() -> [Event] {
        // Return a smaller set of events for a specific region
        let outcome1 = Outcome(name: "Team1", price: 1.7)
        let outcome2 = Outcome(name: "Team2", price: 2.3)
        let outcome3 = Outcome(name: "Draw", price: 3.2)
        
        let market = Market(key: "h2h", lastUpdate: "2025-05-15T12:00:00Z", outcomes: [outcome1, outcome2, outcome3])
        let bookmaker = Bookmaker(key: "bookmaker", title: "Bookmaker", lastUpdate: "2025-05-15T12:00:00Z", markets: [market])
        
        let event = Event(id: "regionEvent", sportKey: "soccer_league", sportTitle: "Soccer League", commenceTime: "2025-05-20T15:00:00Z", homeTeam: "Team1", awayTeam: "Team2", bookmakers: [bookmaker])
        
        return [event]
    }
}
