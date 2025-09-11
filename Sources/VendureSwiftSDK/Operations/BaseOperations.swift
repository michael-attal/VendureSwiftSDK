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
        variables: [String: Any] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        return try await graphQLClient.query(queryString, variables: variables, responseType: responseType)
    }
    
    /// Execute a GraphQL mutation
    internal func mutate<T: Codable>(
        _ mutationString: String,
        variables: [String: Any] = [:],
        responseType: T.Type
    ) async throws -> GraphQLResponse<T> {
        return try await graphQLClient.query(mutationString, variables: variables, responseType: responseType)
    }
}


// MARK: - Query and Mutation Result Handling

/// Success response wrapper
public struct Success: Codable, Hashable {
    public let success: Bool
    
    public init(success: Bool = true) {
        self.success = success
    }
}

/// Deletion response
public struct DeletionResponse: Codable, Hashable {
    public let result: DeletionResult
    public let message: String?
    
    public init(result: DeletionResult, message: String? = nil) {
        self.result = result
        self.message = message
    }
}

/// Deletion result enum
public enum DeletionResult: String, Codable, CaseIterable {
    case DELETED, NOT_DELETED
}

// MARK: - Authentication Result Types

/// Authentication result
public struct AuthenticationResult: Codable, Hashable, Identifiable {
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
public struct NativeAuthenticationResult: Codable, Hashable {
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
public struct RegisterCustomerAccountResult: Codable, Hashable {
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
public struct VerifyCustomerAccountResult: Codable, Hashable {
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
public struct UpdateCustomerPasswordResult: Codable, Hashable {
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
public struct RequestPasswordResetResult: Codable, Hashable {
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
public struct ResetPasswordResult: Codable, Hashable {
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
public struct RequestUpdateCustomerEmailAddressResult: Codable, Hashable {
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
public struct UpdateCustomerEmailAddressResult: Codable, Hashable {
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
public enum ActiveOrderResult: Codable, Hashable {
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
public enum AddPaymentToOrderResult: Codable, Hashable {
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

// MARK: - Error Types

/// No active order error
public struct NoActiveOrderError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .NO_ACTIVE_ORDER_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Order payment state error
public struct OrderPaymentStateError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .ORDER_PAYMENT_STATE_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Ineligible payment method error
public struct IneligiblePaymentMethodError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    public let eligibilityCheckerMessage: String?
    
    public init(errorCode: ErrorCode = .INELIGIBLE_PAYMENT_METHOD_ERROR, message: String, eligibilityCheckerMessage: String? = nil) {
        self.errorCode = errorCode
        self.message = message
        self.eligibilityCheckerMessage = eligibilityCheckerMessage
    }
}

/// Payment failed error
public struct PaymentFailedError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    public let paymentErrorMessage: String
    
    public init(errorCode: ErrorCode = .PAYMENT_FAILED_ERROR, message: String, paymentErrorMessage: String) {
        self.errorCode = errorCode
        self.message = message
        self.paymentErrorMessage = paymentErrorMessage
    }
}

/// Payment declined error
public struct PaymentDeclinedError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    public let paymentErrorMessage: String
    
    public init(errorCode: ErrorCode = .PAYMENT_DECLINED_ERROR, message: String, paymentErrorMessage: String) {
        self.errorCode = errorCode
        self.message = message
        self.paymentErrorMessage = paymentErrorMessage
    }
}

/// Order state transition error
public struct OrderStateTransitionError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    public let transitionError: String
    public let fromState: String
    public let toState: String
    
    public init(errorCode: ErrorCode = .ORDER_STATE_TRANSITION_ERROR, message: String, 
                transitionError: String, fromState: String, toState: String) {
        self.errorCode = errorCode
        self.message = message
        self.transitionError = transitionError
        self.fromState = fromState
        self.toState = toState
    }
}
