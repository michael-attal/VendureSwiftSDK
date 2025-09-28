import Foundation

// MARK: - GraphQL Types

/// GraphQL request structure with type-safe variables
public struct GraphQLRequest<Variables: Codable & Sendable>: Codable, Sendable {
    public let query: String
    public let variables: Variables?
    public let operationName: String?
    
    public init(query: String, variables: Variables? = nil, operationName: String? = nil) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
}

/// GraphQL request with dynamic variables using AnyCodable
public struct GraphQLDynamicRequest: Codable, Sendable {
    public let query: String
    public let variables: [String: AnyCodable]?
    public let operationName: String?
    
    public init(query: String, variables: [String: AnyCodable]? = nil, operationName: String? = nil) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
}

// MARK: - GraphQL Error Types

/// GraphQL error location
public struct GraphQLErrorLocation: Codable, Sendable {
    public let line: Int
    public let column: Int
    
    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

/// GraphQL error structure
public struct GraphQLError: Codable, Error, Sendable {
    public let message: String
    public let locations: [GraphQLErrorLocation]?
    public let path: [String]?
    
    public init(message: String, locations: [GraphQLErrorLocation]? = nil, path: [String]? = nil) {
        self.message = message
        self.locations = locations
        self.path = path
    }
    
    public var description: String {
        return message
    }
}

/// GraphQL response with generics
public struct GraphQLResponse<Data: Codable & Sendable>: Codable, Sendable {
    public let data: Data?
    public let errors: [GraphQLError]?
    
    public var hasErrors: Bool {
        return errors?.isEmpty == false
    }
    
    public var isSuccessful: Bool {
        return !hasErrors && data != nil
    }
    
    public init(data: Data? = nil, errors: [GraphQLError]? = nil) {
        self.data = data
        self.errors = errors
    }
}

/// Raw GraphQL response for dynamic parsing
public struct GraphQLRawResponse: Sendable {
    public let rawData: Data
    public let errors: [GraphQLError]?
    
    public var hasErrors: Bool {
        return errors?.isEmpty == false
    }
    
    /// Get the raw response as string for debugging
    public func responseAsString() -> String? {
        return String(data: rawData, encoding: .utf8)
    }
    
    /// Extract data field as JSON Data
    public func dataAsJSON() -> Data? {
        guard !hasErrors else { return nil }
        return rawData
    }
    
    /// Parse to typed response
    public func parseResponse<T: Codable & Sendable>(as type: T.Type) throws -> GraphQLResponse<T> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(GraphQLResponse<T>.self, from: rawData)
    }
    
    public init(rawData: Data, errors: [GraphQLError]? = nil) {
        self.rawData = rawData
        self.errors = errors
    }
}

// MARK: - Error Response Structure

/// Structure for parsing error responses
struct ErrorOnlyResponse: Decodable {
    let errors: [GraphQLError]?
}

// MARK: - GraphQL Client

/// GraphQL client with type-safe operations
public actor GraphQLClient {
    private let endpoint: URL
    private let session: URLSession
    private let timeout: TimeInterval
    
    public init(endpoint: URL, session: URLSession = .shared, timeout: TimeInterval = 10.0) {
        self.endpoint = endpoint
        self.session = session
        self.timeout = timeout
    }
    
    // MARK: - Type-Safe Query Methods (Primary interface)
    
    /// Execute a type-safe GraphQL query
    public func query<Response: Codable & Sendable, Variables: Codable & Sendable>(
        _ query: String,
        variables: Variables? = nil,
        operationName: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLResponse<Response> {
        let request = GraphQLRequest(query: query, variables: variables, operationName: operationName)
        return try await execute(request: request, headers: headers)
    }
    
    /// Execute a type-safe GraphQL mutation
    public func mutate<Response: Codable & Sendable, Variables: Codable & Sendable>(
        _ mutation: String,
        variables: Variables? = nil,
        operationName: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLResponse<Response> {
        let request = GraphQLRequest(query: mutation, variables: variables, operationName: operationName)
        return try await execute(request: request, headers: headers)
    }
    
    /// Execute a GraphQL query with dynamic variables using AnyCodable
    public func queryDynamic<Response: Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        operationName: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLResponse<Response> {
        let request = GraphQLDynamicRequest(query: query, variables: variables, operationName: operationName)
        return try await executeDynamic(request: request, headers: headers)
    }
    
    /// Execute a GraphQL mutation with dynamic variables using AnyCodable
    public func mutateDynamic<Response: Codable & Sendable>(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        operationName: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLResponse<Response> {
        let request = GraphQLDynamicRequest(query: mutation, variables: variables, operationName: operationName)
        return try await executeDynamic(request: request, headers: headers)
    }
    
    // MARK: - Raw Query Methods (For compatibility)
    
    /// Execute a raw GraphQL query with AnyCodable variables
    public func queryRaw(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLRawResponse {
        let request = GraphQLDynamicRequest(query: query, variables: variables)
        let requestData = try JSONEncoder().encode(request)
        return try await executeRaw(requestBody: requestData, headers: headers)
    }
    
    /// Execute a raw GraphQL mutation with AnyCodable variables
    public func mutateRaw(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLRawResponse {
        let request = GraphQLDynamicRequest(query: mutation, variables: variables)
        let requestData = try JSONEncoder().encode(request)
        return try await executeRaw(requestBody: requestData, headers: headers)
    }
    
    
    // MARK: - Private Execution Methods
    
    /// Execute a type-safe GraphQL request
    private func execute<Response: Codable & Sendable, Variables: Codable & Sendable>(
        request: GraphQLRequest<Variables>,
        headers: [String: String]
    ) async throws -> GraphQLResponse<Response> {
        await VendureLogger.shared.log(.debug, category: "GraphQL", "Executing type-safe query...")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let requestData = try encoder.encode(request)
        
        let rawResponse = try await executeRaw(requestBody: requestData, headers: headers)
        
        // Decode the response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let typedResponse = try decoder.decode(GraphQLResponse<Response>.self, from: rawResponse.rawData)
            return typedResponse
        } catch {
            await VendureLogger.shared.log(.error, category: "GraphQL", "Decoding error: \(error)")
            throw VendureError.decodingError(error)
        }
    }
    
    /// Execute a dynamic GraphQL request with AnyCodable variables
    private func executeDynamic<Response: Codable & Sendable>(
        request: GraphQLDynamicRequest,
        headers: [String: String]
    ) async throws -> GraphQLResponse<Response> {
        await VendureLogger.shared.log(.debug, category: "GraphQL", "Executing dynamic query...")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let requestData = try encoder.encode(request)
        
        let rawResponse = try await executeRaw(requestBody: requestData, headers: headers)
        
        // Decode the response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let typedResponse = try decoder.decode(GraphQLResponse<Response>.self, from: rawResponse.rawData)
            return typedResponse
        } catch {
            await VendureLogger.shared.log(.error, category: "GraphQL", "Decoding error: \(error)")
            throw VendureError.decodingError(error)
        }
    }
    
    /// Execute a raw GraphQL request
    private func executeRaw(
        requestBody: Data,
        headers: [String: String]
    ) async throws -> GraphQLRawResponse {
        await VendureLogger.shared.log(.debug, category: "GraphQL", "Executing raw query...")
        
        // Create URL request
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = timeout
        urlRequest.httpBody = requestBody
        
        // Add custom headers
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Perform the request
        await VendureLogger.shared.log(.debug, category: "HTTP", "Making request to: \(endpoint)")
        let (data, response) = try await session.data(for: urlRequest)
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            await VendureLogger.shared.log(.error, category: "HTTP", "Invalid response type")
            throw VendureError.networkError("Invalid response type")
        }
        
        await VendureLogger.shared.log(.debug, category: "HTTP", "Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            await VendureLogger.shared.log(.error, category: "HTTP", "HTTP error \(httpResponse.statusCode): \(errorMessage)")
            throw VendureError.httpError(httpResponse.statusCode, errorMessage)
        }
        
        await VendureLogger.shared.log(.verbose, category: "Response", "Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert")")
        
        // Parse errors if present
        let errors = parseErrorsFromData(data)
        
        if let errors = errors, !errors.isEmpty {
            await VendureLogger.shared.log(.error, category: "GraphQL", "GraphQL errors: \(errors.map { $0.message })")
        }
        
        return GraphQLRawResponse(rawData: data, errors: errors)
    }
    
    
    /// Parse errors from response data
    private func parseErrorsFromData(_ data: Data) -> [GraphQLError]? {
        do {
            let decoder = JSONDecoder()
            let errorResponse = try decoder.decode(ErrorOnlyResponse.self, from: data)
            return errorResponse.errors
        } catch {
            return nil
        }
    }
    
}

// MARK: - Helper Extensions

extension GraphQLClient {
    
    /// Standard JSON decoder with ISO8601 date strategy
    public static func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    /// Standard JSON encoder with ISO8601 date strategy
    public static func createJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

// MARK: - Example Usage

/// Example login variables with type safety
public struct LoginVariables: Codable, Sendable {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// Example login response with nested user data
public struct LoginResponse: Codable, Sendable {
    public let authenticate: AuthenticationResult
    
    public struct AuthenticationResult: Codable, Sendable {
        public let token: String?
        public let user: User
    }
    
    public struct User: Codable, Sendable {
        public let id: String
        public let email: String
        public let firstName: String?
        public let lastName: String?
        public let verified: Bool
    }
}

/// Example of GraphQL usage:
/// ```swift
/// let client = GraphQLClient(endpoint: URL(string: "https://api.example.com/graphql")!)
/// let variables = LoginVariables(email: "user@example.com", password: "password")
/// 
/// // Type-safe query
/// let response: GraphQLResponse<LoginResponse> = try await client.mutate(
///     "mutation Login($email: String!, $password: String!) { authenticate(input: { email: $email, password: $password }) { token user { id email firstName lastName verified } } }",
///     variables: variables
/// )
/// 
/// if let loginData = response.data {
///     print("Token: \(loginData.authenticate.token ?? "No token")")
///     print("User: \(loginData.authenticate.user.email)")
/// }
/// ```
