import Foundation
@testable import Sports_Betting_App

/// Mock implementation of ApiServiceProtocol for testing
class MockApiService: ApiServiceProtocol {
    private let shouldSucceed: Bool
    private let mockEvents: [Event]
    
    /// Initialize the mock with configuration options
    /// - Parameters:
    ///   - shouldSucceed: If true, requests will succeed, otherwise they'll fail
    ///   - mockEvents: Mock events to return on successful requests
    init(shouldSucceed: Bool = true, mockEvents: [Event] = MockData.createMockRegionEvents()) {
        self.shouldSucceed = shouldSucceed
        self.mockEvents = mockEvents
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        processMockRequest(completion: completion)
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, method: String, parameters: [String: Any]?, completion: @escaping (Result<T, NetworkError>) -> Void) {
        processMockRequest(completion: completion)
    }
    
    func request<T: Decodable>(_ urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        processMockRequest(completion: completion)
    }
    
    func request<T: Decodable>(_ urlString: String, method: String, parameters: [String: Any]?, completion: @escaping (Result<T, NetworkError>) -> Void) {
        processMockRequest(completion: completion)
    }
    
    /// Helper method to create mock responses
    private func processMockRequest<T: Decodable>(completion: @escaping (Result<T, NetworkError>) -> Void) {
        // Simulate network delay for more realistic testing
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            if self.shouldSucceed {
                if let eventsType = [Event].self as? T.Type {
                    // If we expect [Event] type, return our mock events
                    let typedResult = self.mockEvents as! T
                    completion(.success(typedResult))
                } else {
                    // For other types, we don't support mocking yet
                    completion(.failure(.parseError))
                }
            } else {
                completion(.failure(.networkError))
            }
        }
    }
} 