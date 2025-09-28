import Foundation

/// Base class for all Vendure operations
public final class BaseOperations: @unchecked Sendable {
    /// Reference to the GraphQL client
    internal let graphQLClient: GraphQLClient
    
    /// Initialize with GraphQL client
    internal init(_ client: GraphQLClient) {
        self.graphQLClient = client
    }
    
    /// Execute a GraphQL query with typed response - SKIP compatible
    internal func queryCustomer(
        _ queryString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> Customer? {
        let response = try await graphQLClient.queryRaw(
            queryString,
            variablesJSON: variablesJSON,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        
        // Decode as CustomerWrapper to handle nullable Customer - SKIP compatible
        let wrapper = try decoder.decode(CustomerWrapper.self, from: data)
        return wrapper.customer
    }
    
    /// Execute a GraphQL query for CurrentUser - SKIP compatible
    internal func queryCurrentUser(
        _ queryString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> CurrentUser? {
        let response = try await graphQLClient.queryRaw(
            queryString,
            variablesJSON: variablesJSON,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        
        // Decode as CurrentUserWrapper to handle nullable CurrentUser - SKIP compatible
        let wrapper = try decoder.decode(CurrentUserWrapper.self, from: data)
        return wrapper.currentUser
    }
    
    /// Execute a GraphQL query for Channel - SKIP compatible
    internal func queryChannel(
        _ queryString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> Channel {
        let response = try await graphQLClient.queryRaw(
            queryString,
            variablesJSON: variablesJSON,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        return try decoder.decode(Channel.self, from: data)
    }
    
    /// Execute a GraphQL mutation for Customer - SKIP compatible
    internal func mutateCustomer(
        _ mutationString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> Customer {
        let response = try await graphQLClient.mutateRaw(
            mutationString,
            variablesJSON: variablesJSON,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        return try decoder.decode(Customer.self, from: data)
    }
    
    /// Execute a GraphQL mutation for Address - SKIP compatible
    internal func mutateAddress(
        _ mutationString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> Address {
        let response = try await graphQLClient.mutateRaw(
            mutationString,
            variablesJSON: variablesJSON,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        return try decoder.decode(Address.self, from: data)
    }
    
    /// Execute a GraphQL mutation for Success - SKIP compatible
    internal func mutateSuccess(
        _ mutationString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> Success {
        let response = try await graphQLClient.mutateRaw(
            mutationString,
            variablesJSON: variablesJSON,
            headers: headers
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        return try decoder.decode(Success.self, from: data)
    }
    
    /// Execute a GraphQL query and return raw response for error handling
    internal func queryRaw(
        _ queryString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLRawResponse {
        return try await graphQLClient.queryRaw(
            queryString,
            variablesJSON: variablesJSON,
            headers: headers
        )
    }
    
    /// Execute a GraphQL mutation and return raw response for error handling
    internal func mutateRaw(
        _ mutationString: String,
        variablesJSON: String? = nil,
        headers: [String: String] = [:]
    ) async throws -> GraphQLRawResponse {
        return try await graphQLClient.mutateRaw(
            mutationString,
            variablesJSON: variablesJSON,
            headers: headers
        )
    }
    
    /// Helper method to convert variables dictionary to JSON string
    internal func convertVariablesToJSON(_ variables: [String: Encodable]) throws -> String? {
        guard !variables.isEmpty else { return nil }
        
        // Create a dictionary that can be encoded
        var jsonObject: [String: Any] = [:]
        
        for (key, value) in variables {
            // Handle different encodable types
            if let stringValue = value as? String {
                jsonObject[key] = stringValue
            } else if let intValue = value as? Int {
                jsonObject[key] = intValue
            } else if let doubleValue = value as? Double {
                jsonObject[key] = doubleValue
            } else if let boolValue = value as? Bool {
                jsonObject[key] = boolValue
            } else if let arrayValue = value as? [Any] {
                jsonObject[key] = arrayValue
            } else {
                // For complex types, encode to JSON
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(value),
                   let json = try? JSONSerialization.jsonObject(with: data) {
                    jsonObject[key] = json
                }
            }
        }
        
        // Convert to JSON string
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Query and Mutation Result Handling

/// Success response wrapper
public struct Success: Codable, Hashable, Sendable {
    public let success: Bool
    
    public init(success: Bool = true) {
        self.success = success
    }
}

/// Deletion response
public struct DeletionResponse: Codable, Hashable, Sendable {
    public let result: DeletionResult
    public let message: String?
    
    public init(result: DeletionResult, message: String? = nil) {
        self.result = result
        self.message = message
    }
}

/// Deletion result enum
public enum DeletionResult: String, Codable, CaseIterable, Sendable {
    case DELETED, NOT_DELETED
}

// MARK: - Authentication Result Types

/// Authentication result
public struct AuthenticationResult: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let identifier: String
    public let channels: [CurrentUserChannel]
    
    public init(id: String, identifier: String, channels: [CurrentUserChannel] = []) {
        self.id = id
        self.identifier = identifier
        self.channels = channels
    }
}

/// Native authentication result
public struct NativeAuthenticationResult: Codable, Hashable, Sendable {
    public let authenticationResult: AuthenticationResult?
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(authenticationResult: AuthenticationResult? = nil, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.authenticationResult = authenticationResult
        self.errorCode = errorCode
        self.message = message
    }
}

/// Register customer account result
public struct RegisterCustomerAccountResult: Codable, Hashable, Sendable {
    public let success: Bool
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(success: Bool = false, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.success = success
        self.errorCode = errorCode
        self.message = message
    }
}

/// Verify customer account result
public struct VerifyCustomerAccountResult: Codable, Hashable, Sendable {
    public let currentUser: CurrentUser?
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(currentUser: CurrentUser? = nil, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.currentUser = currentUser
        self.errorCode = errorCode
        self.message = message
    }
}

/// Update customer password result
public struct UpdateCustomerPasswordResult: Codable, Hashable, Sendable {
    public let success: Bool
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(success: Bool = false, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.success = success
        self.errorCode = errorCode
        self.message = message
    }
}

/// Request password reset result
public struct RequestPasswordResetResult: Codable, Hashable, Sendable {
    public let success: Bool
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(success: Bool = false, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.success = success
        self.errorCode = errorCode
        self.message = message
    }
}

/// Reset password result
public struct ResetPasswordResult: Codable, Hashable, Sendable {
    public let currentUser: CurrentUser?
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(currentUser: CurrentUser? = nil, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.currentUser = currentUser
        self.errorCode = errorCode
        self.message = message
    }
}

/// Request update customer email address result
public struct RequestUpdateCustomerEmailAddressResult: Codable, Hashable, Sendable {
    public let success: Bool
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(success: Bool = false, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.success = success
        self.errorCode = errorCode
        self.message = message
    }
}

/// Update customer email address result
public struct UpdateCustomerEmailAddressResult: Codable, Hashable, Sendable {
    public let success: Bool
    public let errorCode: ErrorCode?
    public let message: String?
    
    public init(success: Bool = false, errorCode: ErrorCode? = nil, message: String? = nil) {
        self.success = success
        self.errorCode = errorCode
        self.message = message
    }
}

// MARK: - Order Result Types

/// Active order result union
public enum ActiveOrderResult: Codable, Hashable, Sendable {
    case order(Order)
    case noActiveOrderError(NoActiveOrderError)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let order = try? container.decode(Order.self) {
            self = .order(order)
        } else if let error = try? container.decode(NoActiveOrderError.self) {
            self = .noActiveOrderError(error)
        } else {
            throw DecodingError.typeMismatch(ActiveOrderResult.self,
                DecodingError.Context(codingPath: decoder.codingPath,
                debugDescription: "Cannot decode ActiveOrderResult"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .order(let order):
            try container.encode(order)
        case .noActiveOrderError(let error):
            try container.encode(error)
        }
    }
}

/// Add payment to order result union
public enum AddPaymentToOrderResult: Codable, Hashable, Sendable {
    case order(Order)
    case orderPaymentStateError(OrderPaymentStateError)
    case ineligiblePaymentMethodError(IneligiblePaymentMethodError)
    case paymentFailedError(PaymentFailedError)
    case paymentDeclinedError(PaymentDeclinedError)
    case orderStateTransitionError(OrderStateTransitionError)
    case noActiveOrderError(NoActiveOrderError)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let order = try? container.decode(Order.self) {
            self = .order(order)
        } else if let error = try? container.decode(OrderPaymentStateError.self) {
            self = .orderPaymentStateError(error)
        } else if let error = try? container.decode(IneligiblePaymentMethodError.self) {
            self = .ineligiblePaymentMethodError(error)
        } else if let error = try? container.decode(PaymentFailedError.self) {
            self = .paymentFailedError(error)
        } else if let error = try? container.decode(PaymentDeclinedError.self) {
            self = .paymentDeclinedError(error)
        } else if let error = try? container.decode(OrderStateTransitionError.self) {
            self = .orderStateTransitionError(error)
        } else if let error = try? container.decode(NoActiveOrderError.self) {
            self = .noActiveOrderError(error)
        } else {
            throw DecodingError.typeMismatch(AddPaymentToOrderResult.self,
                DecodingError.Context(codingPath: decoder.codingPath,
                debugDescription: "Cannot decode AddPaymentToOrderResult"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .order(let order):
            try container.encode(order)
        case .orderPaymentStateError(let error):
            try container.encode(error)
        case .ineligiblePaymentMethodError(let error):
            try container.encode(error)
        case .paymentFailedError(let error):
            try container.encode(error)
        case .paymentDeclinedError(let error):
            try container.encode(error)
        case .orderStateTransitionError(let error):
            try container.encode(error)
        case .noActiveOrderError(let error):
            try container.encode(error)
        }
    }
}

// MARK: - Wrapper structures for nullable types (SKIP compatibility)

/// Wrapper for nullable Customer to avoid Customer?.self in decode calls
struct CustomerWrapper: Codable, Sendable {
    let customer: Customer?
    
    private enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode from "data" key first, then directly
        if let dataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .data) {
            // Look for activeCustomer key
            if let activeCustomerKey = DynamicCodingKey(stringValue: "activeCustomer") {
                customer = try dataContainer.decodeIfPresent(Customer.self, forKey: activeCustomerKey)
            } else {
                customer = nil
            }
        } else {
            // Fallback: decode directly as Customer
            customer = try? Customer(from: decoder)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dataContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .data)
        if let activeCustomerKey = DynamicCodingKey(stringValue: "activeCustomer") {
            try dataContainer.encodeIfPresent(customer, forKey: activeCustomerKey)
        }
    }
}

/// Wrapper for nullable CurrentUser
struct CurrentUserWrapper: Codable, Sendable {
    let currentUser: CurrentUser?
    
    private enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode from "data" key first, then directly
        if let dataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .data) {
            // Look for me key
            if let meKey = DynamicCodingKey(stringValue: "me") {
                currentUser = try dataContainer.decodeIfPresent(CurrentUser.self, forKey: meKey)
            } else {
                currentUser = nil
            }
        } else {
            // Fallback: decode directly as CurrentUser
            currentUser = try? CurrentUser(from: decoder)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dataContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .data)
        if let meKey = DynamicCodingKey(stringValue: "me") {
            try dataContainer.encodeIfPresent(currentUser, forKey: meKey)
        }
    }
}
