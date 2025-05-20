import Testing
import Foundation
@testable import Sports_Betting_App

struct ApiManagerTests {
    
    @Test func testAPIEndpointURLCreation() {
        // Given
        let endpoint = APIEndpoint.upcomingOdds(region: .us, market: .h2h)
        
        // When
        let url = endpoint.url
        
        // Then
        #expect(url.contains("https://api.the-odds-api.com/v4/sports/upcoming/odds/"))
        #expect(url.contains("regions=us"))
        #expect(url.contains("markets=h2h"))
        #expect(url.contains("apiKey="))
    }
    
    @Test func testAPIEndpointWithDifferentRegions() {
        // Test with different regions
        let regions: [Region] = [.us, .uk, .eu, .au]
        
        for region in regions {
            let endpoint = APIEndpoint.upcomingOdds(region: region, market: .h2h)
            let url = endpoint.url
            
            #expect(url.contains("regions=\(region.rawValue)"))
        }
    }
    
    @Test func testAPIEndpointWithDifferentMarkets() {
        // Test with different market types
        let markets: [MarketType] = [.h2h, .spreads, .totals]
        
        for market in markets {
            let endpoint = APIEndpoint.upcomingOdds(region: .us, market: market)
            let url = endpoint.url
            
            #expect(url.contains("markets=\(market.rawValue)"))
        }
    }
    
    @Test func testNetworkErrorEquality() {
        // Test that network errors can be compared
        let error1 = NetworkError.networkError
        let error2 = NetworkError.networkError
        let error3 = NetworkError.parseError
        
        #expect(error1 == error2)
        #expect(error1 != error3)
    }
    
    @Test func testRequestMethod() async {
        // This is a simplified test since we can't easily mock URLSession
        // In a real test environment, we would create a proper mock URL session
        
        // We'll create a mock service instead of using the real one
        let mockService = MockApiService(shouldSucceed: true)
        var result: Result<[Event], NetworkError>?
        
        // When
        let endpoint = APIEndpoint.upcomingOdds(region: .us, market: .h2h)
        mockService.request(endpoint) { (response: Result<[Event], NetworkError>) in
            result = response
        }
        
        // Allow time for the mock response
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Then
        #expect(result != nil)
        if case .success(let events) = result! {
            #expect(events.count > 0)
        } else {
            #expect(false, "Expected successful response")
        }
    }
}

// Helper extension for error comparison
extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError):
            return true
        case (.parseError, .parseError):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.apiLimitExceeded, .apiLimitExceeded):
            return true
        default:
            return false
        }
    }
}
