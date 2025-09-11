import Foundation
import SkipFoundation

// MARK: - Order Related Errors

/// Error when insufficient stock is available
public struct InsufficientStockError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let quantityAvailable: Int
    public let order: Order
    
    public init(errorCode: ErrorCode = .INSUFFICIENT_STOCK_ERROR, message: String,
                quantityAvailable: Int, order: Order) {
        self.errorCode = errorCode
        self.message = message
        self.quantityAvailable = quantityAvailable
        self.order = order
    }
}

/// Error when order item quantity is negative
public struct NegativeQuantityError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .NEGATIVE_QUANTITY_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when order limit is exceeded
public struct OrderLimitError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let maxItems: Int
    
    public init(errorCode: ErrorCode = .ORDER_LIMIT_ERROR, message: String, maxItems: Int) {
        self.errorCode = errorCode
        self.message = message
        self.maxItems = maxItems
    }
}

/// Error when order modification is attempted incorrectly
public struct OrderModificationError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .ORDER_MODIFICATION_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when order payment state transition is invalid
public struct OrderPaymentStateError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .ORDER_PAYMENT_STATE_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when order state transition is invalid
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

/// Error when no active order exists
public struct NoActiveOrderError: Codable, Hashable, Error {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .NO_ACTIVE_ORDER_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

// MARK: - Authentication Errors

/// Error when invalid credentials are provided
public struct InvalidCredentialsError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let authenticationError: String
    
    public init(errorCode: ErrorCode = .INVALID_CREDENTIALS_ERROR, message: String,
                authenticationError: String) {
        self.errorCode = errorCode
        self.message = message
        self.authenticationError = authenticationError
    }
}

/// Error when user is already logged in
public struct AlreadyLoggedInError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .ALREADY_LOGGED_IN_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when password is missing
public struct MissingPasswordError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .MISSING_PASSWORD_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when password is already set
public struct PasswordAlreadySetError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .PASSWORD_ALREADY_SET_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when password validation fails
public struct PasswordValidationError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let validationErrorMessage: String
    
    public init(errorCode: ErrorCode = .PASSWORD_VALIDATION_ERROR, message: String,
                validationErrorMessage: String) {
        self.errorCode = errorCode
        self.message = message
        self.validationErrorMessage = validationErrorMessage
    }
}

/// Error when password reset token is expired
public struct PasswordResetTokenExpiredError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .PASSWORD_RESET_TOKEN_EXPIRED_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when password reset token is invalid
public struct PasswordResetTokenInvalidError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .PASSWORD_RESET_TOKEN_INVALID_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

// MARK: - Customer Errors

/// Error when email address conflicts with existing account
public struct EmailAddressConflictError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .EMAIL_ADDRESS_CONFLICT_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when customer is not verified
public struct NotVerifiedError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .NOT_VERIFIED_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when verification token is expired
public struct VerificationTokenExpiredError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .VERIFICATION_TOKEN_EXPIRED_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when verification token is invalid
public struct VerificationTokenInvalidError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .VERIFICATION_TOKEN_INVALID_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when identifier change token is expired
public struct IdentifierChangeTokenExpiredError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .IDENTIFIER_CHANGE_TOKEN_EXPIRED_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

/// Error when identifier change token is invalid
public struct IdentifierChangeTokenInvalidError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .IDENTIFIER_CHANGE_TOKEN_INVALID_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}

// MARK: - Guest Checkout Error

/// Error during guest checkout process
public struct GuestCheckoutError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let errorDetail: String
    
    public init(errorCode: ErrorCode = .GUEST_CHECKOUT_ERROR, message: String, errorDetail: String) {
        self.errorCode = errorCode
        self.message = message
        self.errorDetail = errorDetail
    }
}

// MARK: - Native Auth Strategy Error

/// Error with native authentication strategy
public struct NativeAuthStrategyError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    
    public init(errorCode: ErrorCode = .NATIVE_AUTH_STRATEGY_ERROR, message: String) {
        self.errorCode = errorCode
        self.message = message
    }
}
