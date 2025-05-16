import Foundation
import Firebase

enum AnalyticsEventType {
    case matchDetailViewed(event: Event)
    case addToCart(item: BetItem)
    case removeFromCart(item: BetItem)
    
    var name: String {
        switch self {
        case .matchDetailViewed:
            return "match_detail_viewed"
        case .addToCart:
            return "add_to_cart"
        case .removeFromCart:
            return "remove_from_cart"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .matchDetailViewed(let event):
            return [
                "event_id": event.id,
                "sport_title": event.sportTitle,
                "home_team": event.homeTeam,
                "away_team": event.awayTeam,
                "commence_time": event.commenceTime
            ]
        case .addToCart(let item), .removeFromCart(let item):
            return [
                "event_id": item.eventId,
                "event_name": item.eventName,
                "outcome_name": item.outcome.name,
                "price": item.outcome.price,
                "bookmaker": item.bookmakerTitle,
                "market_key": item.marketKey
            ]
        }
    }
}

final class FirebaseAnalyticsManager {
    static let shared = FirebaseAnalyticsManager()
    
    private init() {}
    
    func logEvent(_ eventType: AnalyticsEventType) {
        Analytics.logEvent(eventType.name, parameters: eventType.parameters)
        print("Event logged: \(eventType.name) \n Parameters: \(eventType.parameters)")
    }
} 
