import Foundation

// MARK: List Wrapper (No Generics)

public actor CustomOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Execute a custom GraphQL mutation for Customer
    public func mutateCustomer(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil
    ) async throws -> Customer {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let response = try await client.mutateRaw(
            mutation,
            variables: variables,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let expectedType = expectedDataType {
            return try decodeCustomerWithExpectedType(data, expectedType: expectedType)
        } else {
            return try decoder.decode(Customer.self, from: data)
        }
    }
    
    /// Execute a custom GraphQL query for Customer
    public func queryCustomer(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil
    ) async throws -> Customer? {
        await VendureLogger.shared.log(.info, category: "CustomOps", "Executing custom customer query with expectedDataType: \(expectedDataType ?? "nil")")
        
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let response = try await client.queryRaw(
            query,
            variables: variables,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let expectedType = expectedDataType {
            await VendureLogger.shared.log(.debug, category: "CustomOps", "Extracting data for expectedType: \(expectedType)")
            return try decodeCustomerWithExpectedType(data, expectedType: expectedType)
        } else {
            await VendureLogger.shared.log(.debug, category: "CustomOps", "No expectedDataType specified, using raw data")
            return try decodeOptionalCustomer(data)
        }
    }
    
    /// Execute a raw GraphQL query and return raw response
    public func queryRaw(
        _ query: String,
        variables: [String: AnyCodable]? = nil
    ) async throws -> GraphQLRawResponse {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        return try await client.queryRaw(
            query,
            variables: variables,
            headers: headers
        )
    }
    
    /// Execute a raw GraphQL mutation and return raw response
    public func mutateRaw(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil
    ) async throws -> GraphQLRawResponse {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        return try await client.mutateRaw(
            mutation,
            variables: variables,
            headers: headers
        )
    }
    
    /// Execute a custom GraphQL mutation for Order
    public func mutateOrder(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil
    ) async throws -> Order {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let response = try await client.mutateRaw(
            mutation,
            variables: variables,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let expectedType = expectedDataType {
            return try decodeOrderWithExpectedType(data, expectedType: expectedType)
        } else {
            return try decoder.decode(Order.self, from: data)
        }
    }
    
    /// Execute a custom GraphQL query for Order
    public func queryOrder(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil
    ) async throws -> Order {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let response = try await client.queryRaw(
            query,
            variables: variables,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let expectedType = expectedDataType {
            return try decodeOrderWithExpectedType(data, expectedType: expectedType)
        } else {
            return try decoder.decode(Order.self, from: data)
        }
    }
    
    // MARK: - Helper Methods with Variables Dictionary (for convenience)
    
    /// Convert variables dictionary to JSON string
    public func convertVariablesToJSON(_ variables: [String: String]) throws -> String? {
        guard !variables.isEmpty else { return nil }
        
        let data = try JSONEncoder().encode(variables)
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Concrete decode methods for clean architecture
    
    /// Decode Customer with expected data type
    private func decodeCustomerWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> Customer {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse JSON to navigate to nested data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw VendureError.decodingError(NSError(domain: "CustomOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]))
        }
        
        // First check if we have a GraphQL response wrapper
        var targetObject: Any = jsonObject
        
        // If it's wrapped in a "data" field, unwrap it
        if let dict = jsonObject as? [String: Any], let dataField = dict["data"] {
            targetObject = dataField
        }
        
        // Navigate to the expected type
        let extractedData = extractNestedValue(from: targetObject, path: expectedType)
        
        // Check for ErrorResult
        if let dict = extractedData as? [String: Any],
           let typename = dict["__typename"] as? String,
           typename == "ErrorResult",
           let message = dict["message"] as? String {
            throw VendureError.graphqlError([message])
        }
        
        // Re-encode the extracted data and decode as Customer
        let extractedJsonData = try JSONSerialization.data(withJSONObject: extractedData ?? NSNull(), options: [])
        return try decoder.decode(Customer.self, from: extractedJsonData)
    }
    
    /// Execute a custom GraphQL mutation for TransitionOrderToStateResult
    public func mutateTransitionOrderToStateResult(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil
    ) async throws -> TransitionOrderToStateResult {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let response = try await client.mutateRaw(
            mutation,
            variables: variables,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let expectedType = expectedDataType {
            return try decodeTransitionOrderToStateResultWithExpectedType(data, expectedType: expectedType)
        } else {
            return try decoder.decode(TransitionOrderToStateResult.self, from: data)
        }
    }
    
    /// Execute a custom GraphQL mutation for ActiveOrderResult
    public func mutateActiveOrderResult(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil
    ) async throws -> ActiveOrderResult {
        let client = await vendure.client()
        let headers = try await vendure.defaultHeaders()
        
        let response = try await client.mutateRaw(
            mutation,
            variables: variables,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let expectedType = expectedDataType {
            return try decodeActiveOrderResultWithExpectedType(data, expectedType: expectedType)
        } else {
            return try decoder.decode(ActiveOrderResult.self, from: data)
        }
    }
    
    /// Decode Order with expected data type
    private func decodeOrderWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> Order {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse JSON to navigate to nested data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw VendureError.decodingError(NSError(domain: "CustomOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]))
        }
        
        // First check if we have a GraphQL response wrapper
        var targetObject: Any = jsonObject
        
        // If it's wrapped in a "data" field, unwrap it
        if let dict = jsonObject as? [String: Any], let dataField = dict["data"] {
            targetObject = dataField
        }
        
        // Navigate to the expected type
        let extractedData = extractNestedValue(from: targetObject, path: expectedType)
        
        // Check for ErrorResult
        if let dict = extractedData as? [String: Any],
           let typename = dict["__typename"] as? String,
           typename == "ErrorResult",
           let message = dict["message"] as? String {
            throw VendureError.graphqlError([message])
        }
        
        // Re-encode the extracted data and decode as Order
        let extractedJsonData = try JSONSerialization.data(withJSONObject: extractedData ?? NSNull(), options: [])
        return try decoder.decode(Order.self, from: extractedJsonData)
    }
    
    /// Decode TransitionOrderToStateResult with expected data type
    private func decodeTransitionOrderToStateResultWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> TransitionOrderToStateResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse JSON to navigate to nested data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw VendureError.decodingError(NSError(domain: "CustomOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]))
        }
        
        // First check if we have a GraphQL response wrapper
        var targetObject: Any = jsonObject
        
        // If it's wrapped in a "data" field, unwrap it
        if let dict = jsonObject as? [String: Any], let dataField = dict["data"] {
            targetObject = dataField
        }
        
        // Navigate to the expected type
        let extractedData = extractNestedValue(from: targetObject, path: expectedType)
        
        // Re-encode the extracted data and decode as TransitionOrderToStateResult
        let extractedJsonData = try JSONSerialization.data(withJSONObject: extractedData ?? NSNull(), options: [])
        return try decoder.decode(TransitionOrderToStateResult.self, from: extractedJsonData)
    }
    
    /// Decode ActiveOrderResult with expected data type
    private func decodeActiveOrderResultWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> ActiveOrderResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse JSON to navigate to nested data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw VendureError.decodingError(NSError(domain: "CustomOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]))
        }
        
        // First check if we have a GraphQL response wrapper
        var targetObject: Any = jsonObject
        
        // If it's wrapped in a "data" field, unwrap it
        if let dict = jsonObject as? [String: Any], let dataField = dict["data"] {
            targetObject = dataField
        }
        
        // Navigate to the expected type
        let extractedData = extractNestedValue(from: targetObject, path: expectedType)
        
        // Re-encode the extracted data and decode as ActiveOrderResult
        let extractedJsonData = try JSONSerialization.data(withJSONObject: extractedData ?? NSNull(), options: [])
        return try decoder.decode(ActiveOrderResult.self, from: extractedJsonData)
    }
    
    // MARK: - Private helper methods
    
    /// Helper to decode optional Customer without using nullable class literal
    private func decodeOptionalCustomer(_ data: Data) throws -> Customer? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let wrapper = try decoder.decode(CustomerWrapper.self, from: data)
            return wrapper.customer
        } catch {
            // If that fails, try to decode Customer directly (might return nil on decoding error)
            do {
                let customer = try decoder.decode(Customer.self, from: data)
                return customer
            } catch {
                return nil
            }
        }
    }
    
    private func extractNestedValue(from object: Any, path: String) -> Any? {
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
}

// MARK: - Helper Types
