import Foundation

// MARK: - GraphQL Types - SKIP Compatible (No Generics)

/// GraphQL request structure without generics
public struct GraphQLRequest: Codable, Sendable {
    public let query: String
    public let variables: Data?  // JSON Data instead of generic type
    public let operationName: String?
    
    public init(query: String, variables: Data? = nil, operationName: String? = nil) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
    
    public init(query: String, variablesJSON: String? = nil, operationName: String? = nil) {
        self.query = query
        self.variables = variablesJSON?.data(using: .utf8)
        self.operationName = operationName
    }
    
    // Standard Codable conformance for SKIP compatibility
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        query = try container.decode(String.self, forKey: .query)
        operationName = try container.decodeIfPresent(String.self, forKey: .operationName)
        
        // Handle variables as JSON Data
        if let variablesString = try container.decodeIfPresent(String.self, forKey: .variables) {
            variables = variablesString.data(using: .utf8)
        } else {
            variables = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        try container.encodeIfPresent(operationName, forKey: .operationName)
        
        // Encode variables as JSON string directly - SKIP compatible
        if let variables = variables,
           let jsonString = String(data: variables, encoding: .utf8) {
            try container.encode(jsonString, forKey: .variables)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case query, variables, operationName
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

/// Raw GraphQL response for all queries
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

// MARK: - GraphQL Client (SKIP Compatible - No Generics)

/// Main GraphQL client for making requests  
/// All decoding is done externally with concrete types for SKIP compatibility
public actor GraphQLClient {
    private let endpoint: URL
    private let session: URLSession
    private let timeout: TimeInterval
    
    public init(endpoint: URL, session: URLSession = .shared, timeout: TimeInterval = 10.0) {
        self.endpoint = endpoint
        self.session = session
        self.timeout = timeout
    }
    
    // MARK: - Raw Query Methods (Primary interface for SKIP)
    
    /// Execute a raw GraphQL query with JSON string variables
    public func queryRaw(
        _ query: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLRawResponse {
        let requestBody = buildJSONRequestBody(query: query, variablesJSON: variablesJSON)
        return try await executeRaw(requestBody: requestBody, headers: headers)
    }
    
    /// Execute a raw GraphQL mutation with JSON string variables
    public func mutateRaw(
        _ mutation: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLRawResponse {
        let requestBody = buildJSONRequestBody(query: mutation, variablesJSON: variablesJSON)
        return try await executeRaw(requestBody: requestBody, headers: headers)
    }
    
    // MARK: - Private Execution Methods
    
    /// Execute a raw GraphQL request
    private func executeRaw(
        requestBody: String,
        headers: [String: String]
    ) async throws -> GraphQLRawResponse {
        await VendureLogger.shared.log(.debug, category: "GraphQL", "Executing raw query...")
        
        // Create URL request
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = timeout
        urlRequest.httpBody = requestBody.data(using: .utf8)
        
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
    
    /// Build JSON request body as string
    private func buildJSONRequestBody(query: String, variablesJSON: String? = nil) -> String {
        var parts: [String] = []
        
        // Add query
        let escapedQuery = query
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        
        parts.append("\"query\":\"\(escapedQuery)\"")
        
        // Add variables if present
        if let variablesJSON = variablesJSON {
            parts.append("\"variables\":\(variablesJSON)")
        }
        
        return "{\(parts.joined(separator: ","))}"
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

// MARK: - Helper for Response Decoding (SKIP Compatible - No Generics)

extension GraphQLClient {
    
    /// Standard JSON decoding helper for concrete types
    public static func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    /// Extract nested value from object by path
    private static func extractNestedValue(from object: Any, path: String) -> Any? {
        let parts = path.split(separator: ".")
        var current: Any = object
        
        for part in parts {
            if let dict = current as? [String: Any] {
                guard let nextValue = dict[String(part)] else {
                    return nil
                }
                current = nextValue
            } else {
                return nil
            }
        }
        
        return current
    }
    /// Decode a GraphQL response from Data
    /// Caller must specify the concrete type, no generics
    public static func decodeGraphQLResponse(_ data: Data) throws -> (data: Data?, errors: [GraphQLError]?) {
        // Parse the response
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw VendureError.decodingError(NSError(domain: "GraphQL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]))
        }
        
        // Extract data field if present
        var extractedData: Data? = nil
        if let dataField = jsonObject["data"] {
            extractedData = try? JSONSerialization.data(withJSONObject: dataField, options: [])
        }
        
        // Extract errors if present
        var errors: [GraphQLError]? = nil
        if let errorsField = jsonObject["errors"] as? [[String: Any]] {
            let errorsData = try JSONSerialization.data(withJSONObject: errorsField, options: [])
            errors = try? JSONDecoder().decode([GraphQLError].self, from: errorsData)
        }
        
        // Check for errors
        if let errors = errors, !errors.isEmpty {
            throw VendureError.graphqlError(errors.map { $0.message })
        }
        
        guard let responseData = extractedData else {
            throw VendureError.noData
        }
        
        return (data: responseData, errors: errors)
    }
}

// MARK: - Example Usage (Without Protocol/Generics)

/// Example login variables as simple struct
public struct LoginVariables: Codable, Sendable {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    /// Convert to JSON string for GraphQL
    public func toJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

/// Example login response
public struct LoginResponse: Codable, Sendable {
    public let token: String
    public let user: User
    
    public struct User: Codable, Sendable {
        public let id: String
        public let email: String
        public let name: String?
    }
}

// MARK: - Usage Example

/*
 // Create variables
 let variables = LoginVariables(email: "test@example.com", password: "123456")
 let variablesJSON = variables.toJSONString() ?? "{}"
 
 // Execute query
 let response = try await client.queryRaw(
     loginMutation,
     variablesJSON: variablesJSON
 )
 
 // Decode response
 if let data = response.dataAsJSON() {
     let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
     print(loginResponse.token)
 }
 */
