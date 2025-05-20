import Testing
import Foundation
@testable import Sports_Betting_App

struct ModelTests {
    
    // MARK: - Event Tests
    
    @Test func testEventEquality() {
        // Given
        let outcome = Outcome(name: "Arsenal", price: 1.8)
        let market = Market(key: "h2h", lastUpdate: "2025-05-15T12:00:00Z", outcomes: [outcome])
        let bookmaker = Bookmaker(key: "bookmaker1", title: "Bookmaker 1", lastUpdate: "2025-05-15T12:00:00Z", markets: [market])
        
        // Create two events with the same ID
        let event1 = Event(id: "event1", sportKey: "soccer_epl", sportTitle: "Soccer EPL", commenceTime: "2025-05-20T15:00:00Z", homeTeam: "Arsenal", awayTeam: "Chelsea", bookmakers: [bookmaker])
        
        let event2 = Event(id: "event1", sportKey: "soccer_epl", sportTitle: "Soccer EPL", commenceTime: "2025-05-20T15:00:00Z", homeTeam: "Arsenal", awayTeam: "Chelsea", bookmakers: [bookmaker])
        
        // Create an event with a different ID
        let event3 = Event(id: "event2", sportKey: "soccer_epl", sportTitle: "Soccer EPL", commenceTime: "2025-05-20T15:00:00Z", homeTeam: "Arsenal", awayTeam: "Chelsea", bookmakers: [bookmaker])
        
        // Then
        #expect(event1 == event2)
        #expect(event1 != event3)
    }
    
    @Test func testFormattedDate() {
        // Given
        let outcome = Outcome(name: "Arsenal", price: 1.8)
        let market = Market(key: "h2h", lastUpdate: "2025-05-15T12:00:00Z", outcomes: [outcome])
        let bookmaker = Bookmaker(key: "bookmaker1", title: "Bookmaker 1", lastUpdate: "2025-05-15T12:00:00Z", markets: [market])
        
        // Event with a valid date format
        let event = Event(id: "event1", sportKey: "soccer_epl", sportTitle: "Soccer EPL", commenceTime: "2025-05-20T15:00:00Z", homeTeam: "Arsenal", awayTeam: "Chelsea", bookmakers: [bookmaker])
        
        // Event with an invalid date format
        let eventWithInvalidDate = Event(id: "event2", sportKey: "soccer_epl", sportTitle: "Soccer EPL", commenceTime: "invalid-date", homeTeam: "Arsenal", awayTeam: "Chelsea", bookmakers: [bookmaker])
        
        // Then
        // Valid date should be formatted
        #expect(event.formattedDate != "2025-05-20T15:00:00Z")
        // Format should include month, day and time
        #expect(event.formattedDate.contains("May"))
        #expect(event.formattedDate.contains("20"))
        
        // Invalid date should return the original string
        #expect(eventWithInvalidDate.formattedDate == "invalid-date")
    }
    
    // MARK: - BetBasket Tests
    
    @Test func testBetItemEquality() {
        // Given
        let outcome1 = Outcome(name: "Arsenal", price: 1.8)
        let outcome2 = Outcome(name: "Arsenal", price: 1.8)
        let outcome3 = Outcome(name: "Chelsea", price: 2.1)
        
        // Create two identical bet items
        let betItem1 = BetItem(eventId: "event1", eventName: "Arsenal vs Chelsea", outcome: outcome1, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        let betItem2 = BetItem(eventId: "event1", eventName: "Arsenal vs Chelsea", outcome: outcome2, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        
        // Create a different bet item
        let betItem3 = BetItem(eventId: "event1", eventName: "Arsenal vs Chelsea", outcome: outcome3, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        
        // Then
        #expect(betItem1 == betItem2)
        #expect(betItem1 != betItem3)
    }
    
    @Test func testBetItemFormattedPrice() {
        // Given
        let outcome = Outcome(name: "Arsenal", price: 1.8)
        let betItem = BetItem(eventId: "event1", eventName: "Arsenal vs Chelsea", outcome: outcome, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        
        // Then
        #expect(betItem.formattedPrice == "1.80")
    }
    
    @Test func testBetBasketOperations() {
        // Given
        let betBasket = BetBasket.shared
        
        // Clear the basket to start fresh
        betBasket.clearBasket()
        
        // Initial state
        #expect(betBasket.items.isEmpty)
        
        // Add a bet
        let outcome1 = Outcome(name: "Arsenal", price: 1.8)
        betBasket.addBet(eventId: "event1", eventName: "Arsenal vs Chelsea", outcome: outcome1, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        
        // Check item was added
        #expect(betBasket.items.count == 1)
        #expect(betBasket.items[0].eventId == "event1")
        
        // Add a second bet
        let outcome2 = Outcome(name: "Barcelona", price: 1.5)
        betBasket.addBet(eventId: "event2", eventName: "Barcelona vs Real Madrid", outcome: outcome2, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        
        // Check second item was added
        #expect(betBasket.items.count == 2)
        
        // Try to add a duplicate bet (same event ID)
        let outcome3 = Outcome(name: "Arsenal", price: 2.0) // Different odds
        betBasket.addBet(eventId: "event1", eventName: "Arsenal vs Chelsea", outcome: outcome3, marketKey: "h2h", bookmakerTitle: "Bookmaker 1")
        
        // Check duplicate was not added
        #expect(betBasket.items.count == 2)
        
        // Check total odds calculation
        let expectedTotalPrice = 1.8 * 1.5
        #expect(betBasket.totalPrice == expectedTotalPrice)
        
        // Remove a bet
        betBasket.removeBet(eventId: "event1")
        
        // Check item was removed
        #expect(betBasket.items.count == 1)
        #expect(betBasket.items[0].eventId == "event2")
        
        // Clear the basket
        betBasket.clearBasket()
        
        // Check basket is empty
        #expect(betBasket.items.isEmpty)
    }
    
    // MARK: - Region and MarketType Tests
    
    @Test func testRegionRawValues() {
        // Verify enum raw values match expected values for API
        #expect(Region.us.rawValue == "us")
        #expect(Region.uk.rawValue == "uk")
        #expect(Region.eu.rawValue == "eu")
        #expect(Region.au.rawValue == "au")
    }
    
    @Test func testMarketTypeRawValues() {
        // Verify enum raw values match expected values for API
        #expect(MarketType.h2h.rawValue == "h2h")
        #expect(MarketType.spreads.rawValue == "spreads")
        #expect(MarketType.totals.rawValue == "totals")
    }
    
    @Test func testOddTypeRawValues() {
        // Verify enum raw values match expected values
        #expect(OddType.home.rawValue == "MS1")
        #expect(OddType.away.rawValue == "MS2")
        #expect(OddType.draw.rawValue == "MS0")
    }
} 
