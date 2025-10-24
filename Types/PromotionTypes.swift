import Foundation

// MARK: - Promotion

/// Represents a promotion
public struct Promotion: Codable, Hashable, Identifiable, Sendable {
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
    public let translations: [PromotionTranslation]?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        description: String,
        enabled: Bool,
        conditions: [ConfigurableOperation] = [],
        actions: [ConfigurableOperation] = [],
        couponCode: String? = nil,
        perCustomerUsageLimit: Int? = nil,
        usageLimit: Int? = nil,
        startsAt: Date? = nil,
        endsAt: Date? = nil,
        translations: [PromotionTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
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

    // Helper to create with custom fields dictionary
    public static func withCustomFields(
        id: String,
        name: String,
        description: String,
        enabled: Bool,
        conditions: [ConfigurableOperation] = [],
        actions: [ConfigurableOperation] = [],
        couponCode: String? = nil,
        perCustomerUsageLimit: Int? = nil,
        usageLimit: Int? = nil,
        startsAt: Date? = nil,
        endsAt: Date? = nil,
        translations: [PromotionTranslation] = [],
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> Promotion {
        return Promotion(
            id: id,
            name: name,
            description: description,
            enabled: enabled,
            conditions: conditions,
            actions: actions,
            couponCode: couponCode,
            perCustomerUsageLimit: perCustomerUsageLimit,
            usageLimit: usageLimit,
            startsAt: startsAt,
            endsAt: endsAt,
            translations: translations,
            customFields: customFields,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
