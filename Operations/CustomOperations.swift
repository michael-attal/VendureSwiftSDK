import Foundation

public actor CustomOperations {
    private let vendure: Vendure

    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }

    /// Execute a custom GraphQL mutation for Customer
    public func mutateCustomer(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil,
        languageCode: String? = nil
    ) async throws -> Customer {
        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

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
        expectedDataType: String? = nil,
        languageCode: String? = nil
    ) async throws -> Customer? {
        await VendureLogger.shared.log(.info, category: "CustomOps", "Executing custom customer query with expectedDataType: \(expectedDataType ?? "nil"), language: \(languageCode ?? "default")")

        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

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
            // throw VendureError.noData
            // Maybe consider returning nil instead of throwing if no data is not an error here ?
            await VendureLogger.shared.log(.warning, category: "CustomOps", "No data returned for customer query.")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            if let expectedType = expectedDataType {
                await VendureLogger.shared.log(.debug, category: "CustomOps", "Extracting data for expectedType: \(expectedType)")
                return try decodeCustomerWithExpectedType(data, expectedType: expectedType)
            } else {
                await VendureLogger.shared.log(.debug, category: "CustomOps", "No expectedDataType specified, decoding optional customer")
                return try decodeOptionalCustomer(data)
            }
        } catch let decodingError {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode customer response: \(decodingError)")
            // Consider returning nil if decoding fails but response wasn't a GraphQL error
            return nil // Changed from re-throwing
        }
    }

    /// Execute a raw GraphQL query and return raw response
    public func queryRaw(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        languageCode: String? = nil
    ) async throws -> GraphQLRawResponse {
        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

        return try await client.queryRaw(
            query,
            variables: variables,
            headers: headers
        )
    }

    /// Execute a raw GraphQL mutation and return raw response
    public func mutateRaw(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        languageCode: String? = nil
    ) async throws -> GraphQLRawResponse {
        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

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
        expectedDataType: String? = nil,
        languageCode: String? = nil
    ) async throws -> Order {
        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

        let response = try await client.mutateRaw(
            mutation,
            variables: variables,
            headers: headers
        )

        if response.hasErrors {
            // Check for specific error types if possible (like NoActiveOrderError)
            if let firstError = response.errors?.first, firstError.message.contains("NO_ACTIVE_ORDER_ERROR") {
                await VendureLogger.shared.log(.warning, category: "Order", "Attempted mutation on non-existent active order.")
                // Decide: throw specific error or a generic one?
                // For now, rethrow generic GraphQL error
            }
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }

        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            if let expectedType = expectedDataType {
                return try decodeOrderWithExpectedType(data, expectedType: expectedType)
            } else {
                return try decoder.decode(Order.self, from: data)
            }
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode Order response: \(error)")
            throw VendureError.decodingError(error)
        }
    }

    /// Execute a custom GraphQL query for Order
    public func queryOrder(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String? = nil,
        languageCode: String? = nil
    ) async throws -> Order {
        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

        let response = try await client.queryRaw(
            query,
            variables: variables,
            headers: headers
        )

        if response.hasErrors {
            // Check for specific error types if possible
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }

        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            // Check if 'data' field is present but the expected 'order' field is null
            // This might indicate "not found" rather than a true error
            if let json = try? JSONSerialization.jsonObject(with: response.rawData) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               dataDict[expectedDataType ?? "order"] is NSNull
            {
                await VendureLogger.shared.log(.info, category: "Order", "Order query returned null for key '\(expectedDataType ?? "order")'. Assuming not found.")
                // Decide: throw a specific 'notFound' error or return nil?
                // Throwing specific error for consistency, needs handling upstream.
                throw VendureError.graphqlError(["Order with specified criteria not found."]) // Or a more specific error type
            }
            throw VendureError.noData
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            if let expectedType = expectedDataType {
                return try decodeOrderWithExpectedType(data, expectedType: expectedType)
            } else {
                return try decoder.decode(Order.self, from: data)
            }
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode Order response: \(error)")
            throw VendureError.decodingError(error)
        }
    }

    // MARK: - Concrete decode methods for clean architecture

    /// Execute a custom GraphQL query for a generic type T
    public func queryGeneric<T: Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String,
        responseType: T.Type,
        languageCode: String? = nil
    ) async throws -> T {
        await VendureLogger.shared.log(.info, category: "CustomOps", "Executing generic query for type \(String(describing: T.self)) with key '\(expectedDataType)', language: \(languageCode ?? "default")")

        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

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
            // Similar check for null data field
            if let json = try? JSONSerialization.jsonObject(with: response.rawData) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               dataDict[expectedDataType] is NSNull
            {
                await VendureLogger.shared.log(.info, category: "CustomOps", "Generic query returned null for key '\(expectedDataType)'. Assuming not found or empty.")
                // Decide based on context: throw notFound or handle potentially empty results (like PaginatedList)
                // For simplicity, rethrowing; adjust if needed for specific types like lists.
                throw VendureError.graphqlError(["Data for key '\(expectedDataType)' not found or is null."])
            }
            throw VendureError.noData
        }

        do {
            return try decodeGenericWithExpectedType(data, expectedType: expectedDataType, responseType: T.self)
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode generic response for type \(String(describing: T.self)): \(error)")
            throw VendureError.decodingError(error)
        }
    }

    // MARK: - Generic query execution helper

    public func executeQuery<T: Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String,
        decodeTo type: T.Type,
        languageCode: String? = nil
    ) async throws -> T { // Return T, not T?
        return try await vendure.custom.queryGeneric(
            query,
            variables: variables,
            expectedDataType: expectedDataType,
            responseType: T.self,
            languageCode: languageCode
        )
    }

    /// Execute a custom GraphQL mutation for a generic type T
    public func mutateGeneric<T: Codable & Sendable>(
        _ mutation: String,
        variables: [String: AnyCodable]? = nil,
        expectedDataType: String,
        responseType: T.Type,
        languageCode: String? = nil
    ) async throws -> T {
        await VendureLogger.shared.log(.info, category: "CustomOps", "Executing generic mutation for type \(String(describing: T.self)) with key '\(expectedDataType)', language: \(languageCode ?? "default")")

        let client = await vendure.client(languageCode: languageCode)
        let headers = try await vendure.defaultHeaders(languageCode: languageCode)

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
            // Similar check for null data field as in queryGeneric
            if let json = try? JSONSerialization.jsonObject(with: response.rawData) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               dataDict[expectedDataType] is NSNull
            {
                await VendureLogger.shared.log(.info, category: "CustomOps", "Generic mutation returned null for key '\(expectedDataType)'.")
                // Decide based on context, e.g., throw or handle empty result
                throw VendureError.graphqlError(["Mutation result for key '\(expectedDataType)' is null."])
            }
            throw VendureError.noData
        }

        do {
            return try decodeGenericWithExpectedType(data, expectedType: expectedDataType, responseType: T.self)
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode generic mutation response for type \(String(describing: T.self)): \(error)")
            throw VendureError.decodingError(error)
        }
    }

    // --- Private Helper for Generic Decoding ---

    private func decodeGenericWithExpectedType<T: Codable & Sendable>(
        _ data: Data,
        expectedType: String,
        responseType: T.Type
    ) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Parse JSON to navigate to nested data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw VendureError.decodingError(NSError(domain: "CustomOps", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"]))
        }

        // Check if wrapped in "data" field
        var targetObject: Any = jsonObject
        if let dict = jsonObject as? [String: Any], let dataField = dict["data"] {
            targetObject = dataField
        }

        // Navigate to the expected type using the key path
        let extractedData = extractNestedValue(from: targetObject, path: expectedType)

        guard let validExtractedData = extractedData else {
            throw VendureError.decodingError(NSError(domain: "CustomOps", code: 2, userInfo: [NSLocalizedDescriptionKey: "Expected data key '\(expectedType)' not found or is null in response"]))
        }

        // Check for GraphQL ErrorResult structure within the extracted data
        if let dict = validExtractedData as? [String: Any],
           let typename = dict["__typename"] as? String,
           typename.hasSuffix("Error"), // More generic error check
           let message = dict["message"] as? String
        {
            // await VendureLogger.shared.log(.warning, category: "GraphQL", "Received GraphQL error type '\(typename)' within expected data: \(message)")
            throw VendureError.graphqlError([message]) // Or potentially parse errorCode too
        }

        // Re-encode the extracted data and decode as T
        let extractedJsonData = try JSONSerialization.data(withJSONObject: validExtractedData, options: [])
        return try decoder.decode(T.self, from: extractedJsonData)
    }

    /// Decode Customer with expected data type
    private func decodeCustomerWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> Customer {
        try decodeGenericWithExpectedType(data, expectedType: expectedType, responseType: Customer.self)
    }

    /// Decode Order with expected data type
    private func decodeOrderWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> Order {
        try decodeGenericWithExpectedType(data, expectedType: expectedType, responseType: Order.self)
    }

    /// Helper to decode optional Customer without using nullable class literal
    private func decodeOptionalCustomer(_ data: Data) throws -> Customer? {
        // Attempt to decode as CustomerWrapper first
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let wrapper = try? decoder.decode(CustomerWrapper.self, from: data) {
            return wrapper.customer
        }
        // If wrapper fails, try decoding Customer directly (might be null or throw)
        return try? decoder.decode(Customer.self, from: data)
    }

    /// Decode TransitionOrderToStateResult with expected data type
    private func decodeTransitionOrderToStateResultWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> TransitionOrderToStateResult {
        try decodeGenericWithExpectedType(data, expectedType: expectedType, responseType: TransitionOrderToStateResult.self)
    }

    /// Decode ActiveOrderResult with expected data type
    private func decodeActiveOrderResultWithExpectedType(
        _ data: Data,
        expectedType: String
    ) throws -> ActiveOrderResult {
        try decodeGenericWithExpectedType(data, expectedType: expectedType, responseType: ActiveOrderResult.self)
    }

    private func extractNestedValue(from object: Any, path: String) -> Any? {
        let parts = path.split(separator: ".")
        var current: Any? = object // Use optional for safer traversal

        for part in parts {
            if let dict = current as? [String: Any] {
                current = dict[String(part)] // Access dictionary value
            } else if let array = current as? [Any], let index = Int(part), index >= 0, index < array.count {
                current = array[index] // Access array element by index (if path uses numeric index)
            } else {
                return nil // Path segment not found or structure mismatch
            }
            // If current becomes nil at any point, the path is invalid
            guard current != nil else { return nil }
        }

        // Check if the final result is NSNull and return nil in that case
        if current is NSNull {
            return nil
        }

        return current
    }
}
