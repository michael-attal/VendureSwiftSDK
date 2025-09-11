import Foundation
import SkipFoundation

// MARK: - Promotion

/// Represents a promotion
public struct Promotion: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let enabled: Bool
    public let conditions: [ConfigurableOperation]
    public let actions: [ConfigurableOperation]
    public let couponCode: String?
    public let perCustomerUsageLimit: Int?
    public let usageLimit: Int?
    public let startsAt: Date?
    public let endsAt: Date?
    public let translations: [PromotionTranslation]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, description: String, enabled: Bool,
                conditions: [ConfigurableOperation] = [], actions: [ConfigurableOperation] = [],
                couponCode: String? = nil, perCustomerUsageLimit: Int? = nil, usageLimit: Int? = nil,
                startsAt: Date? = nil, endsAt: Date? = nil, translations: [PromotionTranslation] = [],
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.enabled = enabled
        self.conditions = conditions
        self.actions = actions
        self.couponCode = couponCode
        self.perCustomerUsageLimit = perCustomerUsageLimit
        self.usageLimit = usageLimit
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.translations = translations
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Promotion translation
public struct PromotionTranslation: Codable, Hashable {
    public let languageCode: LanguageCode
    public let name: String
    public let description: String
    
    public init(languageCode: LanguageCode, name: String, description: String) {
        self.languageCode = languageCode
        self.name = name
        self.description = description
    }
}

// MARK: - Promotion List

/// List of promotions
public struct PromotionList: Codable {
    public let items: [Promotion]
    public let totalItems: Int
    
    public init(items: [Promotion], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

// MARK: - Coupon Code Errors

/// Error when coupon code is expired
public struct CouponCodeExpiredError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let couponCode: String
    
    public init(errorCode: ErrorCode = .COUPON_CODE_EXPIRED_ERROR, message: String, couponCode: String) {
        self.errorCode = errorCode
        self.message = message
        self.couponCode = couponCode
    }
}

/// Error when coupon code is invalid
public struct CouponCodeInvalidError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let couponCode: String
    
    public init(errorCode: ErrorCode = .COUPON_CODE_INVALID_ERROR, message: String, couponCode: String) {
        self.errorCode = errorCode
        self.message = message
        self.couponCode = couponCode
    }
}

/// Error when coupon code usage limit is exceeded
public struct CouponCodeLimitError: Codable, Hashable {
    public let errorCode: ErrorCode
    public let message: String
    public let couponCode: String
    public let limit: Int
    
    public init(errorCode: ErrorCode = .COUPON_CODE_LIMIT_ERROR, message: String,
                couponCode: String, limit: Int) {
        self.errorCode = errorCode
        self.message = message
        self.couponCode = couponCode
        self.limit = limit
    }
}
