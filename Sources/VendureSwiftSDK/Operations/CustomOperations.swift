import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public actor CustomOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Execute a custom GraphQL mutation
    public func mutate<T: Codable>(
        _ mutation: String,
        variables: [String: Any] = [:],
        responseType: T.Type,
        expectedDataType: String? = nil
    ) async throws -> T {
        let result = try await executeOperation(
            mutation,
            variables: variables,
            isMutation: true,
            expectedDataType: expectedDataType
        )
        
        guard let data = result.data else {
            throw VendureError.networkError("No data returned from mutation")
        }
        
        return try decodeResponse(data, to: responseType)
    }
    
    /// Execute a custom GraphQL query
    public func query<T: Codable>(
        _ query: String,
        variables: [String: Any] = [:],
        responseType: T.Type,
        expectedDataType: String? = nil
    ) async throws -> T {
        let result = try await executeOperation(
            query,
            variables: variables,
            isMutation: false,
            expectedDataType: expectedDataType
        )
        
        guard let data = result.data else {
            throw VendureError.networkError("No data returned from query")
        }
        
        return try decodeResponse(data, to: responseType)
    }
    
    /// Execute a custom GraphQL query that returns a list
    public func queryList<T: Codable>(
        _ query: String,
        variables: [String: Any] = [:],
        responseType: T.Type,
        expectedDataType: String? = nil
    ) async throws -> [T] {
        let result = try await executeOperation(
            query,
            variables: variables,
            isMutation: false,
            expectedDataType: expectedDataType
        )
        
        guard let data = result.data else {
            throw VendureError.networkError("No data returned from queryList")
        }
        
        return try decodeResponseList(data, to: responseType)
    }
    
    /// Execute a custom GraphQL mutation that returns a list
    public func mutateList<T: Codable>(
        _ mutation: String,
        variables: [String: Any] = [:],
        responseType: T.Type,
        expectedDataType: String? = nil
    ) async throws -> [T] {
        let result = try await executeOperation(
            mutation,
            variables: variables,
            isMutation: true,
            expectedDataType: expectedDataType
        )
        
        guard let data = result.data else {
            throw VendureError.networkError("No data returned from mutateList")
        }
        
        return try decodeResponseList(data, to: responseType)
    }
    
    // MARK: - Private Methods
    
    private func executeOperation(
        _ operation: String,
        variables: [String: Any],
        isMutation: Bool,
        expectedDataType: String?
    ) async throws -> GraphQLResponse<AnyCodable> {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let result: GraphQLResponse<AnyCodable>
        if isMutation {
            result = try await client.mutate(operation, variables: variables, headers: headers, responseType: AnyCodable.self)
        } else {
            result = try await client.query(operation, variables: variables, headers: headers, responseType: AnyCodable.self)
        }
        
        if result.hasErrors {
            let errorMessages = result.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        return result
    }
    
    private func extractExpectedData(_ data: Any, expectedDataType: String?) -> Any {
        guard let expectedType = expectedDataType else {
            return data
        }
        
        if expectedType.contains(".") {
            var currentData = data
            let parts = expectedType.split(separator: ".")
            for part in parts {
                if let dict = currentData as? [String: Any] {
                    currentData = dict[String(part)] ?? NSNull()
                } else {
                    return NSNull()
                }
                if currentData is NSNull {
                    return NSNull()
                }
            }
            return currentData
        }
        
        if let dict = data as? [String: Any] {
            return dict[expectedType] ?? NSNull()
        }
        
        return data
    }
    
    private func decodeResponse<T: Codable>(_ data: AnyCodable, to type: T.Type) throws -> T {
        let extractedData = data.value
        
        // Check for ErrorResult pattern
        if let dict = extractedData as? [String: Any],
           let typename = dict["__typename"] as? String,
           typename == "ErrorResult",
           let message = dict["message"] as? String {
            throw VendureError.graphqlError([message])
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: extractedData)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(type, from: jsonData)
    }
    
    private func decodeResponseList<T: Codable>(_ data: AnyCodable, to type: T.Type) throws -> [T] {
        guard let array = data.value as? [Any] else {
            throw VendureError.decodingError(NSError(domain: "CustomOperations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Expected array response"]))
        }
        
        var results: [T] = []
        for item in array {
            let jsonData = try JSONSerialization.data(withJSONObject: item)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(type, from: jsonData)
            results.append(decoded)
        }
        
        return results
    }
}
