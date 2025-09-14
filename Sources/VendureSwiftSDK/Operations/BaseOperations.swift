import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif
#if canImport(SkipModel)
import SkipModel
#endif

/// Base class for all Vendure operations
public class BaseOperations {
    /// Reference to the GraphQL client
    internal let graphQLClient: GraphQLClient
    
    /// Initialize with GraphQL client
    internal init(_ client: GraphQLClient) {
        self.graphQLClient = client
    }
    
    /// Execute a GraphQL query
    internal func query<T: Codable>(
        _ queryString: String,
        variables: sending [String: Any] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        // Variables contain only JSON-serializable Sendable types
        return try await graphQLClient.query(queryString, variables: variables, responseType: responseType)
    }
    
    /// Execute a GraphQL mutation
    internal func mutate<T: Codable>(
        _ mutationString: String,
        variables: sending [String: Any] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        // Variables contain only JSON-serializable Sendable types
        return try await graphQLClient.query(mutationString, variables: variables, responseType: responseType)
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

