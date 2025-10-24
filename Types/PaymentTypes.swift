import Foundation

// MARK: - Payment Method

/// Represents a payment method
public struct PaymentMethod: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let description: String
    public let enabled: Bool
    public let checker: ConfigurableOperation?
    public let handler: ConfigurableOperation
    public let translations: [PaymentMethodTranslation]?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        code: String,
        name: String,
        description: String,
        enabled: Bool,
        checker: ConfigurableOperation? = nil,
        handler: ConfigurableOperation,
        translations: [PaymentMethodTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.description = description
        self.enabled = enabled
        self.checker = checker
        self.handler = handler
        self.translations = translations
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Payment method quote for an order
public struct PaymentMethodQuote: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let description: String
    public let isEligible: Bool
    public let eligibilityMessage: String?
    public let customFields: [String: AnyCodable]?

    public init(
        id: String,
        code: String,
        name: String,
        description: String,
        isEligible: Bool,
        eligibilityMessage: String? = nil,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.description = description
        self.isEligible = isEligible
        self.eligibilityMessage = eligibilityMessage
        self.customFields = customFields
    }
}

// MARK: - Payment

/// Payment states
public enum PaymentState: String, Codable, CaseIterable, Sendable {
    case created = "Created"
    case authorized = "Authorized"
    case settled = "Settled"
    case cancelled = "Cancelled"
    case declined = "Declined"
    case error = "Error"
}

/// Represents a payment refund
public struct Refund: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let total: Double
    public let reason: String?
    public let state: String
    public let items: Double
    public let shipping: Double
    public let adjustment: Double
    public let paymentId: String
    public let metadata: [String: AnyCodable]?
    public let method: String?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        total: Double,
        reason: String? = nil,
        state: String,
        items: Double,
        shipping: Double,
        adjustment: Double,
        paymentId: String,
        metadata: [String: AnyCodable]? = nil,
        method: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.total = total
        self.reason = reason
        self.state = state
        self.items = items
        self.shipping = shipping
        self.adjustment = adjustment
        self.paymentId = paymentId
        self.metadata = metadata
        self.method = method
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a payment
public struct Payment: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let transactionId: String?
    public let amount: Double
    public let method: String
    public let state: PaymentState
    public let errorMessage: String?
    public let metadata: [String: AnyCodable]?
    public let refunds: [Refund]
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        transactionId: String? = nil,
        amount: Double,
        method: String,
        state: PaymentState,
        errorMessage: String? = nil,
        metadata: [String: AnyCodable]? = nil,
        refunds: [Refund] = [],
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.transactionId = transactionId
        self.amount = amount
        self.method = method
        self.state = state
        self.errorMessage = errorMessage
        self.metadata = metadata
        self.refunds = refunds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Payment Input

/// Input for creating a payment
public struct PaymentInput: Codable, Sendable {
    public let method: String
    public let metadata: [String: AnyCodable]?

    public init(method: String, metadata: [String: AnyCodable]? = nil) {
        self.method = method
        self.metadata = metadata
    }
}
