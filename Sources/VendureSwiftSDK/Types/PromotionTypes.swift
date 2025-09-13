import Foundation
import SkipFoundation

// MARK: - Promotion

/// Represents a promotion
public struct Promotion: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
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
    public var customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        conditions = try container.decode([ConfigurableOperation].self, forKey: .conditions)
        actions = try container.decode([ConfigurableOperation].self, forKey: .actions)
        couponCode = try container.decodeIfPresent(String.self, forKey: .couponCode)
        perCustomerUsageLimit = try container.decodeIfPresent(Int.self, forKey: .perCustomerUsageLimit)
        usageLimit = try container.decodeIfPresent(Int.self, forKey: .usageLimit)
        startsAt = try container.decodeIfPresent(Date.self, forKey: .startsAt)
        endsAt = try container.decodeIfPresent(Date.self, forKey: .endsAt)
        translations = try container.decode([PromotionTranslation].self, forKey: .translations)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode existing customFields if present
        customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "Promotion")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, name, description, enabled, conditions, actions, couponCode, perCustomerUsageLimit, usageLimit, startsAt, endsAt, translations, customFields, createdAt, updatedAt
    }
    
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
public struct PromotionTranslation: Codable, Hashable, Sendable {
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
