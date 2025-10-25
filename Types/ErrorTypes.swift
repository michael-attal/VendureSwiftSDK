import Foundation

// MARK: - Generic Error Wrapper

/// Generic error container for Vendure errors.
/// - `ErrorDetails` contains the specific error fields beyond the standard errorCode and message.
public struct VendureErrorType<ErrorDetails: Codable & Hashable & Sendable>: Codable, Hashable, Sendable, Error {
    /// The error code identifying the type of error
    public let errorCode: ErrorCode

    /// The error message
    public let message: String

    /// The specific error details for this error type
    public let details: ErrorDetails?

    public init(errorCode: ErrorCode, message: String, details: ErrorDetails? = nil) {
        self.errorCode = errorCode
        self.message = message
        self.details = details
    }
}

// MARK: - Convenience Factory Functions

public extension VendureErrorType {
    /// Create an error with just errorCode and message (for EmptyErrorDetails types)
    static func simple(_ errorCode: ErrorCode, _ message: String) -> VendureErrorType<EmptyErrorDetails> {
        return VendureErrorType<EmptyErrorDetails>(errorCode: errorCode, message: message, details: nil)
    }
}

public extension VendureErrorType where ErrorDetails == InsufficientStockDetails {
    static func insufficientStock(
        message: String,
        quantityAvailable: Int,
        order: Order
    ) -> Self {
        return VendureErrorType(
            errorCode: .INSUFFICIENT_STOCK_ERROR,
            message: message,
            details: InsufficientStockDetails(quantityAvailable: quantityAvailable, order: order)
        )
    }
}

public extension VendureErrorType where ErrorDetails == OrderStateTransitionDetails {
    static func stateTransition(
        message: String,
        transitionError: String,
        fromState: String,
        toState: String
    ) -> Self {
        return VendureErrorType(
            errorCode: .ORDER_STATE_TRANSITION_ERROR,
            message: message,
            details: OrderStateTransitionDetails(
                transitionError: transitionError,
                fromState: fromState,
                toState: toState
            )
        )
    }
}

// MARK: - Error Detail Types

/// Empty details for errors that only have errorCode and message
public struct EmptyErrorDetails: Codable, Hashable, Sendable {}

/// Details for insufficient stock errors
public struct InsufficientStockDetails: Codable, Hashable, Sendable {
    public let quantityAvailable: Int
    public let order: Order

    public init(quantityAvailable: Int, order: Order) {
        self.quantityAvailable = quantityAvailable
        self.order = order
    }
}

/// Details for order limit errors
public struct OrderLimitDetails: Codable, Hashable, Sendable {
    public let maxItems: Int

    public init(maxItems: Int) {
        self.maxItems = maxItems
    }
}

/// Details for order state transition errors
public struct OrderStateTransitionDetails: Codable, Hashable, Sendable {
    public let transitionError: String
    public let fromState: String
    public let toState: String

    public init(transitionError: String, fromState: String, toState: String) {
        self.transitionError = transitionError
        self.fromState = fromState
        self.toState = toState
    }
}

/// Details for authentication errors
public struct AuthenticationErrorDetails: Codable, Hashable, Sendable {
    public let authenticationError: String

    public init(authenticationError: String) {
        self.authenticationError = authenticationError
    }
}

/// Details for password validation errors
public struct PasswordValidationDetails: Codable, Hashable, Sendable {
    public let validationErrorMessage: String

    public init(validationErrorMessage: String) {
        self.validationErrorMessage = validationErrorMessage
    }
}

/// Details for guest checkout errors
public struct GuestCheckoutDetails: Codable, Hashable, Sendable {
    public let errorDetail: String

    public init(errorDetail: String) {
        self.errorDetail = errorDetail
    }
}

/// Details for ineligible method errors
public struct IneligibleMethodDetails: Codable, Hashable, Sendable {
    public let eligibilityCheckerMessage: String?

    public init(eligibilityCheckerMessage: String? = nil) {
        self.eligibilityCheckerMessage = eligibilityCheckerMessage
    }
}

/// Details for payment errors
public struct PaymentErrorDetails: Codable, Hashable, Sendable {
    public let paymentErrorMessage: String

    public init(paymentErrorMessage: String) {
        self.paymentErrorMessage = paymentErrorMessage
    }
}

/// Details for coupon code errors
public struct CouponCodeDetails: Codable, Hashable, Sendable {
    public let couponCode: String

    public init(couponCode: String) {
        self.couponCode = couponCode
    }
}

/// Details for coupon code limit errors
public struct CouponCodeLimitDetails: Codable, Hashable, Sendable {
    public let couponCode: String
    public let limit: Int

    public init(couponCode: String, limit: Int) {
        self.couponCode = couponCode
        self.limit = limit
    }
}

/// Error codes that can be returned by the API
public enum ErrorCode: String, Hashable, Codable, CaseIterable, Sendable {
    case UNKNOWN_ERROR
    case MIME_TYPE_ERROR
    case LANGUAGE_NOT_AVAILABLE_ERROR
    case CHANNEL_DEFAULT_LANGUAGE_ERROR
    case SETTLE_PAYMENT_ERROR
    case CANCEL_PAYMENT_ERROR
    case EMPTY_ORDER_LINE_SELECTION_ERROR
    case ITEMS_ALREADY_FULFILLED_ERROR
    case INSUFFICIENT_STOCK_ON_HAND_ERROR
    case MULTIPLE_ORDER_ERROR
    case CANCEL_ACTIVE_ORDER_ERROR
    case PAYMENT_ORDER_MISMATCH_ERROR
    case REFUND_ORDER_STATE_ERROR
    case NOTHING_TO_REFUND_ERROR
    case ALREADY_REFUNDED_ERROR
    case QUANTITY_TOO_GREAT_ERROR
    case REFUND_STATE_TRANSITION_ERROR
    case PAYMENT_STATE_TRANSITION_ERROR
    case FULFILLMENT_STATE_TRANSITION_ERROR
    case ORDER_MODIFICATION_STATE_ERROR
    case NO_CHANGES_SPECIFIED_ERROR
    case PAYMENT_METHOD_MISSING_ERROR
    case REFUND_PAYMENT_ID_MISSING_ERROR
    case MANUAL_PAYMENT_STATE_ERROR
    case PRODUCT_OPTION_IN_USE_ERROR
    case MISSING_CONDITIONS_ERROR
    case NATIVE_AUTH_STRATEGY_ERROR
    case INVALID_CREDENTIALS_ERROR
    case ORDER_STATE_TRANSITION_ERROR
    case EMAIL_ADDRESS_CONFLICT_ERROR
    case GUEST_CHECKOUT_ERROR
    case ORDER_LIMIT_ERROR
    case NEGATIVE_QUANTITY_ERROR
    case INSUFFICIENT_STOCK_ERROR
    case COUPON_CODE_INVALID_ERROR
    case COUPON_CODE_EXPIRED_ERROR
    case COUPON_CODE_LIMIT_ERROR
    case ORDER_MODIFICATION_ERROR
    case INELIGIBLE_SHIPPING_METHOD_ERROR
    case NO_ACTIVE_ORDER_ERROR
    case ORDER_PAYMENT_STATE_ERROR
    case INELIGIBLE_PAYMENT_METHOD_ERROR
    case PAYMENT_FAILED_ERROR
    case PAYMENT_DECLINED_ERROR
    case ALREADY_LOGGED_IN_ERROR
    case MISSING_PASSWORD_ERROR
    case PASSWORD_VALIDATION_ERROR
    case PASSWORD_ALREADY_SET_ERROR
    case VERIFICATION_TOKEN_INVALID_ERROR
    case VERIFICATION_TOKEN_EXPIRED_ERROR
    case IDENTIFIER_CHANGE_TOKEN_INVALID_ERROR
    case IDENTIFIER_CHANGE_TOKEN_EXPIRED_ERROR
    case PASSWORD_RESET_TOKEN_INVALID_ERROR
    case PASSWORD_RESET_TOKEN_EXPIRED_ERROR
    case NOT_VERIFIED_ERROR
}
