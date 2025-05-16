import Foundation

struct BetItem: Equatable {
    let eventId: String
    let eventName: String
    let outcome: Outcome
    let marketKey: String
    let bookmakerTitle: String
    
    var formattedPrice: String {
        return String(format: "%.2f", outcome.price)
    }
    
    static func == (lhs: BetItem, rhs: BetItem) -> Bool {
        return lhs.eventId == rhs.eventId &&
               lhs.eventName == rhs.eventName &&
               lhs.outcome.name == rhs.outcome.name &&
               lhs.outcome.price == rhs.outcome.price &&
               lhs.marketKey == rhs.marketKey &&
               lhs.bookmakerTitle == rhs.bookmakerTitle
    }
}

final class BetBasket {
    static let shared = BetBasket()
    
    private(set) var items: [BetItem] = []
    
    private init() {}
    
    func addBet(eventId: String, eventName: String, outcome: Outcome, marketKey: String, bookmakerTitle: String) {
        let betItem = BetItem(eventId: eventId, eventName: eventName, outcome: outcome, marketKey: marketKey, bookmakerTitle: bookmakerTitle)
        
        // Check if we already have this exact bet
        if !items.contains(where: { $0.eventId == eventId }) {
            items.append(betItem)
            NotificationCenter.default.post(name: Notification.Name("BetBasketUpdated"), object: nil)
            FirebaseAnalyticsManager.shared.logEvent(.addToCart(item: betItem))
        }
    }
    
    func removeBet(eventId: String) {
        if let index = items.firstIndex(where: { $0.eventId == eventId }) {
            let removedItem = items[index]
            items.remove(at: index)
            NotificationCenter.default.post(name: Notification.Name("BetBasketUpdated"), object: nil)
            FirebaseAnalyticsManager.shared.logEvent(.removeFromCart(item: removedItem))
        }
    }
    
    func clearBasket() {
        items.removeAll()
        NotificationCenter.default.post(name: Notification.Name("BetBasketUpdated"), object: nil)
    }
    
    var totalPrice: Double {
        return items.reduce(1.0) { $0 * $1.outcome.price }
    }
    
    var formattedTotalPrice: String {
        return String(format: "%.2f", totalPrice)
    }
    
    var numberOfEvents: Int {
        return items.count
    }
} 
