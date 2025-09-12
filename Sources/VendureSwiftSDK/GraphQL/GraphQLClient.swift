import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// GraphQL request structure
public struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: Any]?
    let operationName: String?
    
    public init(query: String, variables: [String: Any]? = nil, operationName: String? = nil) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
    
    // Custom encoding to handle Any type in variables
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        try container.encodeIfPresent(operationName, forKey: .operationName)
        
        if let variables = variables {
            let variablesData = try JSONSerialization.data(withJSONObject: variables, options: [])
            let variablesString = String(data: variablesData, encoding: .utf8) ?? "{}"
            try container.encode(variablesString, forKey: .variables)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case query, variables, operationName
    }
}

/// GraphQL response structure
public struct GraphQLResponse<T: Codable>: Codable {
    public let data: T?
    public let errors: [GraphQLError]?
    
    public var hasErrors: Bool {
        return errors?.isEmpty == false
    }
}

/// GraphQL error structure
public struct GraphQLError: Codable, Error {
    public let message: String
    public let locations: [GraphQLErrorLocation]?
    public let path: [String]?
    public let extensions: [String: AnyCodable]?
    
    public var description: String {
        return message
    }
}

/// GraphQL error location
public struct GraphQLErrorLocation: Codable {
    public let line: Int
    public let column: Int
}

/// Helper for encoding/decoding Any values in JSON
public struct AnyCodable: Codable, Hashable, Equatable, @unchecked Sendable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let array = value as? [Any] {
            try container.encode(array.map(AnyCodable.init))
        } else if let dictionary = value as? [String: Any] {
            try container.encode(dictionary.mapValues(AnyCodable.init))
        } else {
            try container.encodeNil()
        }
    }
    
    // MARK: - Hashable implementation
    public func hash(into hasher: inout Hasher) {
        if let bool = value as? Bool {
            hasher.combine(bool)
        } else if let int = value as? Int {
            hasher.combine(int)
        } else if let double = value as? Double {
            hasher.combine(double)
        } else if let string = value as? String {
            hasher.combine(string)
        } else if let array = value as? [Any] {
            hasher.combine(array.count)
        } else if let dictionary = value as? [String: Any] {
            hasher.combine(dictionary.count)
        } else {
            hasher.combine(0)
        }
    }
    
    // MARK: - Equatable implementation
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        if let lhsBool = lhs.value as? Bool, let rhsBool = rhs.value as? Bool {
            return lhsBool == rhsBool
        } else if let lhsInt = lhs.value as? Int, let rhsInt = rhs.value as? Int {
            return lhsInt == rhsInt
        } else if let lhsDouble = lhs.value as? Double, let rhsDouble = rhs.value as? Double {
            return lhsDouble == rhsDouble
        } else if let lhsString = lhs.value as? String, let rhsString = rhs.value as? String {
            return lhsString == rhsString
        } else if lhs.value is NSNull && rhs.value is NSNull {
            return true
        } else {
            return false
        }
    }
}

/// Main GraphQL client for making requests
public actor GraphQLClient {
    private let endpoint: URL
    private let session: URLSession
    private let timeout: TimeInterval
    
    public init(endpoint: URL, session: URLSession = .shared, timeout: TimeInterval = 10) {
        self.endpoint = endpoint
        self.session = session
        self.timeout = timeout
    }
    
    /// Execute a GraphQL query
    public func query<T: Codable>(
        _ query: String,
        variables: [String: Any]? = nil,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        return try await execute(
            GraphQLRequest(query: query, variables: variables),
            headers: headers,
            responseType: responseType
        )
    }
    
    /// Execute a GraphQL mutation
    public func mutate<T: Codable>(
        _ mutation: String,
        variables: [String: Any]? = nil,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        return try await execute(
            GraphQLRequest(query: mutation, variables: variables),
            headers: headers,
            responseType: responseType
        )
    }
    
    /// Execute a raw GraphQL request
    public func execute<T: Codable>(
        _ request: GraphQLRequest,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        await VendureLogger.shared.log(.debug, category: "GraphQL", "Executing query: \(String(request.query.prefix(100)))...")
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = timeout
        
        // Add custom headers
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Convert request to JSON
        let requestData = try encodeRequest(request)
        urlRequest.httpBody = requestData
        
        if let variables = request.variables {
            await VendureLogger.shared.log(.verbose, category: "GraphQL", "Variables: \(variables)")
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
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            await VendureLogger.shared.log(.error, category: "HTTP", "HTTP error \(httpResponse.statusCode): \(errorMessage)")
            throw VendureError.httpError(httpResponse.statusCode, errorMessage)
        }
        
        // Decode GraphQL response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        await VendureLogger.shared.log(.verbose, category: "Decode", "Response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert to string")")
        
        do {
            let result = try decoder.decode(GraphQLResponse<T>.self, from: data)
            await VendureLogger.shared.log(.debug, category: "Decode", "Successfully decoded response")
            return result
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Decoding error: \(error)")
            
            // Try to decode as a general error response
            if let errorResponse = try? decoder.decode(GraphQLResponse<AnyCodable>.self, from: data),
               let errors = errorResponse.errors, !errors.isEmpty {
                await VendureLogger.shared.log(.error, category: "GraphQL", "GraphQL errors: \(errors.map { $0.message })")
                throw VendureError.graphqlError(errors.map { $0.message })
            }
            throw VendureError.decodingError(error)
        }
    }
    
    private func encodeRequest(_ request: GraphQLRequest) throws -> Data {
        // Manual JSON encoding to handle Any type in variables
        var json: [String: Any] = [
            "query": request.query
        ]
        
        if let variables = request.variables {
            json["variables"] = variables
        }
        
        if let operationName = request.operationName {
            json["operationName"] = operationName
        }
        
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}
