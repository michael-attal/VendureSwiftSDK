import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif
#if canImport(SkipModel)
import SkipModel
#endif

public actor Vendure {
    nonisolated(unsafe) public static var shared: Vendure?
    
    private let endpoint: URL
    private let baseClient: GraphQLClient
    private var tokenManager: TokenManager?
    private var token: String?
    private var languageCode: String?
    private var channelToken: String?
    private var timeout: TimeInterval
    private let useGuestSession: Bool
    
    // Operation modules
    public private(set) var auth: AuthOperations!
    public private(set) var order: OrderOperations!
    public private(set) var catalog: CatalogOperations!
    public private(set) var customer: CustomerOperations!
    public private(set) var system: SystemOperations!
    public private(set) var custom: CustomOperations!
    
    private init(
        endpoint: URL,
        tokenFetcher: sending TokenFetcher?,
        tokenParams: sending [String: Any]?,
        sessionDuration: TimeInterval,
        token: String?,
        useGuestSession: Bool = false,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10
    ) {
        self.endpoint = endpoint
        self.baseClient = GraphQLClient(endpoint: endpoint, timeout: timeout)
        self.languageCode = languageCode
        self.channelToken = channelToken
        self.timeout = timeout
        self.useGuestSession = useGuestSession
        self.token = token
        if let tokenFetcher = tokenFetcher, let tokenParams = tokenParams {
            self.tokenManager = TokenManager(fetcher: tokenFetcher, parameters: tokenParams, sessionDuration: sessionDuration)
        }
    }
    
    // MARK: - Initialization
    
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
        guard let url = URL(string: endpoint) else {
            throw VendureError.initializationError("Invalid endpoint URL")
        }
        let instance = Vendure(
            endpoint: url,
            tokenFetcher: tokenFetcher,
            tokenParams: tokenParams,
            sessionDuration: sessionDuration,
            token: token,
            useGuestSession: useGuestSession,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
        )
        try await instance.finalizeInitialization(checkConnection: true)
        Vendure.shared = instance
        return instance
    }
    
    public static func initializeWithNativeAuth(
        endpoint: String,
        username: String,
        password: String,
        sessionDuration: TimeInterval = 60 * 60 * 24 * 365,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await initialize(
            endpoint: endpoint,
            tokenFetcher: { params in
                let username = params["username"] as? String ?? ""
                let password = params["password"] as? String ?? ""
                let auth = AuthOperations(GraphQLClient(endpoint: URL(string: endpoint)!, timeout: timeout))
                return try await auth.getToken(username: username, password: password)
            },
            tokenParams: ["username": username, "password": password],
            sessionDuration: sessionDuration
        )
    }
    
    public static func initializeWithFirebaseAuth(
        endpoint: String,
        uid: String,
        jwt: String,
        sessionDuration: TimeInterval = 60 * 60,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await initialize(
            endpoint: endpoint,
            tokenFetcher: { params in
                let uid = params["uid"] as? String ?? ""
                let jwt = params["jwt"] as? String ?? ""
                let auth = AuthOperations(GraphQLClient(endpoint: URL(string: endpoint)!, timeout: timeout))
                return try await auth.getTokenFirebase(uid: uid, jwt: jwt)
            },
            tokenParams: ["uid": uid, "jwt": jwt],
            sessionDuration: sessionDuration,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
        )
    }
    
    public static func initializeWithCustomAuth(
        endpoint: String,
        fetchToken: sending @escaping TokenFetcher,
        tokenParams: sending [String: Any],
        sessionDuration: TimeInterval = 60 * 60 * 24 * 365,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> Vendure {
        return try await initialize(
            endpoint: endpoint,
            tokenFetcher: fetchToken,
            tokenParams: tokenParams,
            sessionDuration: sessionDuration,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
        )
    }
    
    // MARK: - Runtime configuration
    
    public static func setAuthToken(_ token: String) async throws {
        guard let shared = Vendure.shared else {
            throw VendureError.initializationError("Vendure has not been initialized. Call initialize() first.")
        }
        await shared.setToken(token)
    }
    
    public static func setLanguageCode(_ languageCode: String?) async throws {
        guard let shared = Vendure.shared else {
            throw VendureError.initializationError("Vendure has not been initialized. Call initialize() first.")
        }
        await shared.setLanguage(languageCode)
    }
    
    public static func setChannelToken(_ channelToken: String?) async throws {
        guard let shared = Vendure.shared else {
            throw VendureError.initializationError("Vendure has not been initialized. Call initialize() first.")
        }
        await shared.setChannel(channelToken)
    }
    
    public static func refreshToken(_ params: sending [String: Any]? = nil) async throws {
        guard let shared = Vendure.shared else {
            throw VendureError.initializationError("Vendure has not been initialized. Call initialize() first.")
        }
        try await shared._refreshToken(params)
    }
    
    private func setToken(_ token: String) {
        self.token = token
    }
    
    private func setLanguage(_ language: String?) {
        self.languageCode = language
    }
    
    private func setChannel(_ channelToken: String?) {
        self.channelToken = channelToken
    }
    
    private func finalizeInitialization(checkConnection: Bool = false) async throws {
        if !useGuestSession && token == nil && tokenManager == nil {
            throw VendureError.initializationError("Failed to set token in instance")
        }
        
        // Initialize operation modules
        self.auth = AuthOperations(baseClient)
        self.custom = CustomOperations(self)
        self.order = OrderOperations(self)
        self.catalog = CatalogOperations(self)
        self.customer = CustomerOperations(self)
        self.system = SystemOperations(self)
        
        if checkConnection {
            // Simple introspection query to validate connection
            let response: GraphQLResponse<[String: String]> = try await client().query("query { __typename }", responseType: [String: String].self)
            if response.hasErrors {
                throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
            }
        }
    }
    
    // MARK: - Client construction
    
    private func buildEndpointURL() -> URL {
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            return endpoint
        }
        if let languageCode = languageCode {
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "languageCode", value: languageCode))
            components.queryItems = queryItems
        }
        return components.url ?? endpoint
    }
    
    public func client() -> GraphQLClient {
        // Recreate client to reflect possible languageCode URL changes
        return GraphQLClient(endpoint: buildEndpointURL(), timeout: timeout)
    }
    
    public func defaultHeaders() async throws -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        
        // Prefer header for localization if server supports it; languageCode is also in URL
        if let languageCode = languageCode {
            headers["Accept-Language"] = languageCode
        }
        if let channelToken = channelToken {
            headers["vendure-token"] = channelToken
        }
        
        if useGuestSession {
            return headers
        }
        
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        } else if let tm = tokenManager {
            let token = try await tm.getValidToken()
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    /// Refresh token using token manager
    private func _refreshToken(_ params: sending [String: Any]? = nil) async throws {
        guard let tm = tokenManager else {
            throw VendureError.initializationError("No token manager configured")
        }
        try await tm.refreshToken(params)
    }
}

