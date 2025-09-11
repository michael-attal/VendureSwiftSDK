import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public typealias TokenFetcher = (_ parameters: [String: Any]) async throws -> String?

public actor TokenManager {
    private let fetcher: TokenFetcher
    private let parameters: [String: Any]
    private let sessionDuration: TimeInterval
    private var cachedToken: String?
    private var tokenExpiry: Date?
    
    public init(
        fetcher: @escaping TokenFetcher,
        parameters: [String: Any],
        sessionDuration: TimeInterval = 86400 // 1 day default
    ) {
        self.fetcher = fetcher
        self.parameters = parameters
        self.sessionDuration = sessionDuration
    }
    
    public func getValidToken() async throws -> String {
        // Check if we have a valid cached token
        if let token = cachedToken,
           let expiry = tokenExpiry,
           Date() < expiry {
            return token
        }
        
        // Fetch a new token
        guard let newToken = try await fetcher(parameters) else {
            throw VendureError.initializationError("Failed to fetch authentication token")
        }
        
        // Cache the new token
        cachedToken = newToken
        tokenExpiry = Date().addingTimeInterval(sessionDuration)
        
        return newToken
    }
    
    public func refreshToken(_ parameters: [String: Any]? = nil) async throws {
        let params = parameters ?? self.parameters
        guard let newToken = try await fetcher(params) else {
            throw VendureError.initializationError("Failed to refresh authentication token")
        }
        
        cachedToken = newToken
        tokenExpiry = Date().addingTimeInterval(sessionDuration)
    }
    
    public func clearToken() {
        cachedToken = nil
        tokenExpiry = nil
    }
}
