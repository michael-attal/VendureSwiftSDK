import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif
#if canImport(SkipModel)
import SkipModel
#endif

/// The main entry point for the VendureSwiftSDK
public struct VendureSwiftSDK {
    /// Current version of the SDK
    public static let version = "1.0.0"
    
    /// Initialize Vendure with endpoint and token
    public static func initialize(
        endpoint: String,
        tokenFetcher: sending TokenFetcher? = nil,
        tokenParams: sending [String: Any]? = nil,
        sessionDuration: TimeInterval = 60 * 60 * 24 * 365,
        token: String? = nil,
        useGuestSession: Bool = false,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await Vendure.initialize(
            endpoint: endpoint,
            tokenFetcher: tokenFetcher,
            tokenParams: tokenParams,
            sessionDuration: sessionDuration,
            token: token,
            useGuestSession: useGuestSession,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
        )
    }
    
    /// Initialize Vendure with native authentication
    public static func initializeWithNativeAuth(
        endpoint: String,
        username: String,
        password: String,
        sessionDuration: TimeInterval = 60 * 60 * 24 * 365,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await Vendure.initializeWithNativeAuth(
            endpoint: endpoint,
            username: username,
            password: password,
            sessionDuration: sessionDuration,
            timeout: timeout
        )
    }
    
    /// Initialize Vendure with Firebase authentication
    public static func initializeWithFirebaseAuth(
        endpoint: String,
        uid: String,
        jwt: String,
        sessionDuration: TimeInterval = 60 * 60,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await Vendure.initializeWithFirebaseAuth(
            endpoint: endpoint,
            uid: uid,
            jwt: jwt,
            sessionDuration: sessionDuration,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
        )
    }
    
    /// Initialize Vendure with custom authentication
    public static func initializeWithCustomAuth(
        endpoint: String,
        fetchToken: sending @escaping TokenFetcher,
        tokenParams: sending [String: Any],
        sessionDuration: TimeInterval = 60 * 60 * 24 * 365,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await Vendure.initializeWithCustomAuth(
            endpoint: endpoint,
            fetchToken: fetchToken,
            tokenParams: tokenParams,
            sessionDuration: sessionDuration,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
        )
    }
}
