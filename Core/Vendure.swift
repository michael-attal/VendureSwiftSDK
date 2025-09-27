import Foundation

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
    
    // Operation modules - Now private with public computed properties
    private var _auth: AuthOperations!
    private var _order: OrderOperations!
    private var _catalog: CatalogOperations!
    private var _customer: CustomerOperations!
    private var _system: SystemOperations!
    private var _custom: CustomOperations!
    
    // Public read-only accessors
    public var auth: AuthOperations { _auth }
    public var order: OrderOperations { _order }
    public var catalog: CatalogOperations { _catalog }
    public var customer: CustomerOperations { _customer }
    public var system: SystemOperations { _system }
    public var custom: CustomOperations { _custom }
    
    private init(
        endpoint: URL,
        tokenFetcher: sending TokenFetcher?,
        tokenParams: sending [String: Any]?,
        sessionDuration: TimeInterval,
        token: String?,
        useGuestSession: Bool = false,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10.0
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
        sessionDuration: TimeInterval = 60.0 * 60.0 * 24.0 * 365.0,
        token: String? = nil,
        useGuestSession: Bool = false,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10.0
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
        sessionDuration: TimeInterval = 60.0 * 60.0 * 24.0 * 365.0,
        timeout: TimeInterval = 10.0
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
        sessionDuration: TimeInterval = 60.0 * 60.0,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10.0
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
        sessionDuration: TimeInterval = 60.0 * 60.0 * 24.0 * 365.0,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10.0
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
        self._auth = AuthOperations(baseClient)
        self._custom = CustomOperations(self)
        self._order = OrderOperations(self)
        self._catalog = CatalogOperations(self)
        self._customer = CustomerOperations(self)
        self._system = SystemOperations(self)
        
        if checkConnection {
            // Simple introspection query to validate connection
            let response = try await client().queryRaw("query { __typename }")
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
