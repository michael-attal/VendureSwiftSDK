import Foundation

public actor Vendure {
    public nonisolated(unsafe) static var shared: Vendure?

    private let endpoint: URL
    private let baseClient: GraphQLClient
    private var tokenManager: TokenManager?
    private var token: String?
    private var defaultLanguageCode: String?
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
        tokenParams: sending[String: Any]?,
        sessionDuration: TimeInterval,
        token: String?,
        useGuestSession: Bool = false,
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10.0
    ) {
        self.endpoint = endpoint
        baseClient = GraphQLClient(endpoint: endpoint, timeout: timeout)
        defaultLanguageCode = languageCode
        self.channelToken = channelToken
        self.timeout = timeout
        self.useGuestSession = useGuestSession
        self.token = token
        if let tokenFetcher = tokenFetcher, let tokenParams = tokenParams {
            tokenManager = TokenManager(fetcher: tokenFetcher, parameters: tokenParams, sessionDuration: sessionDuration)
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
        languageCode: String? = nil,
        channelToken: String? = nil,
        timeout: TimeInterval = 10.0
    ) async throws -> Vendure {
        return try await initialize(
            endpoint: endpoint,
            tokenFetcher: { params in
                let username = params["username"] as? String ?? ""
                let password = params["password"] as? String ?? ""
                let authClient = GraphQLClient(endpoint: URL(string: endpoint)!, timeout: timeout)
                let auth = AuthOperations(authClient)
                return try await auth.getToken(username: username, password: password)
            },
            tokenParams: ["username": username, "password": password],
            sessionDuration: sessionDuration,
            languageCode: languageCode,
            channelToken: channelToken,
            timeout: timeout
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
                let authClient = GraphQLClient(endpoint: URL(string: endpoint)!, timeout: timeout)
                let auth = AuthOperations(authClient)
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

    // This sets the *default* language code for subsequent requests unless overridden
    public static func setDefaultLanguageCode(_ languageCode: String?) async throws {
        guard let shared = Vendure.shared else {
            throw VendureError.initializationError("Vendure has not been initialized. Call initialize() first.")
        }
        await shared.setDefaultLanguage(languageCode)
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

    private func setDefaultLanguage(_ language: String?) {
        defaultLanguageCode = language
    }

    private func setChannel(_ channelToken: String?) {
        self.channelToken = channelToken
    }

    private func finalizeInitialization(checkConnection: Bool = false) async throws {
        if !useGuestSession, token == nil, tokenManager == nil {
            // Try fetching initial token if manager exists
            if let tm = tokenManager {
                _ = try await tm.getValidToken() // Fetches and caches if needed
            } else {
                throw VendureError.initializationError("Authentication token or token manager is required unless using guest session.")
            }
        }

        _auth = AuthOperations(baseClient)
        _custom = CustomOperations(self)
        _order = OrderOperations(self)
        _catalog = CatalogOperations(self)
        _customer = CustomerOperations(self)
        _system = SystemOperations(self)

        if checkConnection {
            // Simple introspection query to validate connection using baseClient
            let response = try await baseClient.queryRaw("query { __typename }")
            if response.hasErrors {
                let messages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
                // Log the detailed errors
                await VendureLogger.shared.log(.error, category: "Initialization", "GraphQL connection check failed: \(messages.joined(separator: "; "))")
                throw VendureError.graphqlError(messages)
            }
            await VendureLogger.shared.log(.info, category: "Initialization", "GraphQL connection check successful.")
        }
    }

    // MARK: - Client & Header construction with Language Override

    /// Builds the endpoint URL, potentially adding the language code query parameter.
    /// - Parameter languageCode: An optional language code to override the default.
    /// - Returns: The constructed URL.
    func buildEndpointURL(languageCode: String? = nil) -> URL {
        // Use the override if provided, otherwise use the instance default
        let codeToUse = languageCode ?? defaultLanguageCode

        guard let effectiveLanguageCode = codeToUse, !effectiveLanguageCode.isEmpty else {
            return endpoint // No language code to add
        }

        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            return endpoint // Should not happen with valid initial URL
        }

        var queryItems = components.queryItems ?? []
        // Avoid adding duplicate languageCode parameters
        if !queryItems.contains(where: { $0.name == "languageCode" }) {
            queryItems.append(URLQueryItem(name: "languageCode", value: effectiveLanguageCode))
            components.queryItems = queryItems
            return components.url ?? endpoint
        }
        return endpoint // Already has languageCode or something went wrong
    }

    /// Creates a GraphQLClient instance configured for a specific request, potentially with a language override.
    /// - Parameter languageCode: An optional language code to override the default for this client instance.
    /// - Returns: A configured GraphQLClient.
    func client(languageCode: String? = nil) -> GraphQLClient {
        // Use the override if provided, otherwise use the instance default
        let url = buildEndpointURL(languageCode: languageCode)
        // Return a potentially new client instance configured with the specific URL
        // If the URL hasn't changed, this might return the same configuration functionally
        return GraphQLClient(endpoint: url, timeout: timeout)
    }

    /// Generates the default headers for a request, potentially adding language and auth headers.
    /// - Parameter languageCode: An optional language code to override the default for the Accept-Language header.
    /// - Returns: A dictionary of HTTP headers.
    /// - Throws: `VendureError.tokenMissing` if authentication is required but no token is available.
    func defaultHeaders(languageCode: String? = nil) async throws -> [String: String] {
        // Use the override if provided, otherwise use the instance default
        let codeToUse = languageCode ?? defaultLanguageCode

        var headers = [
            "Content-Type": "application/json"
        ]

        // Prefer header for localization if server supports it
        if let effectiveLanguageCode = codeToUse, !effectiveLanguageCode.isEmpty {
            headers["Accept-Language"] = effectiveLanguageCode
        }
        if let channelToken = channelToken {
            headers["vendure-token"] = channelToken
        }

        if useGuestSession {
            return headers // No Authorization needed for guest sessions
        }

        // Get the current valid token
        var currentToken: String? = token
        if let tm = tokenManager {
            currentToken = try await tm.getValidToken() // Fetches/refreshes if needed
        }

        guard let validToken = currentToken, !validToken.isEmpty else {
            // Only throw if not using guest session and no token available
            await VendureLogger.shared.log(.error, category: "Auth", "Authentication required, but no valid token available.")
            throw VendureError.tokenMissing
        }

        headers["Authorization"] = "Bearer \(validToken)"
        return headers
    }

    /// Refresh token using token manager
    private func _refreshToken(_ params: sending [String: Any]? = nil) async throws {
        guard let tm = tokenManager else {
            throw VendureError.initializationError("No token manager configured for token refresh")
        }
        try await tm.refreshToken(params)
        await VendureLogger.shared.log(.info, category: "Auth", "Token refresh attempted.")
    }
}
