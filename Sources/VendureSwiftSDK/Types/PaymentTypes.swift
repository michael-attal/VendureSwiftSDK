import Foundation
import SkipFoundation

// MARK: - Payment Method

/// Represents a payment method
public struct PaymentMethod: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
    public let id: String
    public let code: String
    public let name: String
    public let description: String
    public let enabled: Bool
    public let checker: ConfigurableOperation?
    public let handler: ConfigurableOperation
    public let translations: [PaymentMethodTranslation]
    public var customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        checker = try container.decodeIfPresent(ConfigurableOperation.self, forKey: .checker)
        handler = try container.decode(ConfigurableOperation.self, forKey: .handler)
        translations = try container.decode([PaymentMethodTranslation].self, forKey: .translations)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode existing customFields if present
        customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "PaymentMethod")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, code, name, description, enabled, checker, handler, translations, customFields, createdAt, updatedAt
    }
    
    public init(id: String, code: String, name: String, description: String, enabled: Bool,
                checker: ConfigurableOperation? = nil, handler: ConfigurableOperation,
                translations: [PaymentMethodTranslation] = [], customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
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

/// Payment method translation
public struct PaymentMethodTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    public let description: String
    
    public init(languageCode: LanguageCode, name: String, description: String) {
        self.languageCode = languageCode
        self.name = name
        self.description = description
    }
}

/// Payment method quote for an order
public struct PaymentMethodQuote: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
    public let id: String
    public let code: String
    public let name: String
    public let description: String
    public let isEligible: Bool
    public let eligibilityMessage: String?
    public var customFields: [String: AnyCodable]?
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        isEligible = try container.decode(Bool.self, forKey: .isEligible)
        eligibilityMessage = try container.decodeIfPresent(String.self, forKey: .eligibilityMessage)
        
        // Decode existing customFields if present
        customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "PaymentMethodQuote")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, code, name, description, isEligible, eligibilityMessage, customFields
    }
    
    public init(id: String, code: String, name: String, description: String,
                isEligible: Bool, eligibilityMessage: String? = nil,
                customFields: [String: AnyCodable]? = nil) {
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
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, total: Double, reason: String? = nil, state: String, 
                items: Double, shipping: Double, adjustment: Double, paymentId: String, 
                metadata: [String: AnyCodable]? = nil, method: String? = nil, 
                createdAt: Date, updatedAt: Date) {
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
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, transactionId: String? = nil, amount: Double, method: String,
                state: PaymentState, errorMessage: String? = nil, metadata: [String: AnyCodable]? = nil,
                refunds: [Refund] = [], createdAt: Date, updatedAt: Date) {
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

// MARK: - Payment Errors

/// Error when payment is declined
public struct PaymentDeclinedError: Codable, Hashable, Error, Sendable {
    public let errorCode: ErrorCode
    public let message: String
    public let paymentErrorMessage: String
    
    public init(errorCode: ErrorCode = .PAYMENT_DECLINED_ERROR, message: String,
                paymentErrorMessage: String) {
        self.errorCode = errorCode
        self.message = message
        self.paymentErrorMessage = paymentErrorMessage
    }
}

/// Error when payment fails
public struct PaymentFailedError: Codable, Hashable, Error, Sendable {
    public let errorCode: ErrorCode
    public let message: String
    public let paymentErrorMessage: String
    
    public init(errorCode: ErrorCode = .PAYMENT_FAILED_ERROR, message: String,
                paymentErrorMessage: String) {
        self.errorCode = errorCode
        self.message = message
        self.paymentErrorMessage = paymentErrorMessage
    }
}

/// Error when payment method is ineligible
public struct IneligiblePaymentMethodError: Codable, Hashable, Error, Sendable {
    public let errorCode: ErrorCode
    public let message: String
    public let eligibilityCheckerMessage: String?
    
    public init(errorCode: ErrorCode = .INELIGIBLE_PAYMENT_METHOD_ERROR, message: String,
                eligibilityCheckerMessage: String? = nil) {
        self.errorCode = errorCode
        self.message = message
        self.eligibilityCheckerMessage = eligibilityCheckerMessage
    }
}
