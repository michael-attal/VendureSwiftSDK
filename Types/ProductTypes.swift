import Foundation

// MARK: - Product Types

/// Represents a product in the catalog
public struct Product: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String
    public let enabled: Bool
    public let featuredAsset: Asset?
    public let assets: [Asset]
    public let variants: [ProductVariant]
    public let optionGroups: [ProductOptionGroup]
    public let facetValues: [FacetValue]?
    public let translations: [ProductTranslation]? // Optional - may not be present in all GraphQL responses
    public let customFields: [String: AnyCodable]? // Modern AnyCodable approach
    public let languageCode: LanguageCode?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        slug: String,
        description: String,
        enabled: Bool,
        featuredAsset: Asset?,
        assets: [Asset],
        variants: [ProductVariant],
        optionGroups: [ProductOptionGroup],
        facetValues: [FacetValue]?,
        translations: [ProductTranslation]?,
        customFields: [String: AnyCodable]?,
        languageCode: LanguageCode?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.enabled = enabled
        self.featuredAsset = featuredAsset
        self.assets = assets
        self.variants = variants
        self.optionGroups = optionGroups
        self.facetValues = facetValues
        self.translations = translations
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a product variant
public struct ProductVariant: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let sku: String
    public let price: Double
    public let priceWithTax: Double
    public let currencyCode: CurrencyCode
    public let enabled: Bool? // Optional - may not be present in all GraphQL responses
    public let stockLevel: String
    public let trackInventory: String?
    public let stockOnHand: Int?
    public let stockAllocated: Int?
    public let outOfStockThreshold: Int?
    public let useGlobalOutOfStockThreshold: Bool?
    public let featuredAsset: Asset?
    public let assets: [Asset]?
    public let options: [ProductOption]?
    public let facetValues: [FacetValue]?
    public let translations: [ProductVariantTranslation]?
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        sku: String,
        price: Double,
        priceWithTax: Double,
        currencyCode: CurrencyCode,
        enabled: Bool?,
        stockLevel: String,
        trackInventory: String?,
        stockOnHand: Int?,
        stockAllocated: Int?,
        outOfStockThreshold: Int?,
        useGlobalOutOfStockThreshold: Bool?,
        featuredAsset: Asset?,
        assets: [Asset]?,
        options: [ProductOption]?,
        facetValues: [FacetValue]?,
        translations: [ProductVariantTranslation]?,
        customFields: [String: AnyCodable]?,
        languageCode: LanguageCode?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.sku = sku
        self.price = price
        self.priceWithTax = priceWithTax
        self.currencyCode = currencyCode
        self.enabled = enabled
        self.stockLevel = stockLevel
        self.trackInventory = trackInventory
        self.stockOnHand = stockOnHand
        self.stockAllocated = stockAllocated
        self.outOfStockThreshold = outOfStockThreshold
        self.useGlobalOutOfStockThreshold = useGlobalOutOfStockThreshold
        self.featuredAsset = featuredAsset
        self.assets = assets
        self.options = options
        self.facetValues = facetValues
        self.translations = translations
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a product option
public struct ProductOption: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let groupId: String?
    public let group: ProductOptionGroup?
    public let translations: [ProductOptionTranslation]?
    public let customFields: [String: AnyCodable]?

    public init(
        id: String,
        code: String,
        name: String,
        groupId: String?,
        group: ProductOptionGroup?,
        translations: [ProductOptionTranslation]?,
        customFields: [String: AnyCodable]?
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.groupId = groupId
        self.group = group
        self.translations = translations
        self.customFields = customFields
    }
}

/// Represents a product option group
public struct ProductOptionGroup: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let options: [ProductOption]?
    public let translations: [ProductOptionGroupTranslation]?
    public let languageCode: LanguageCode?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let customFields: [String: AnyCodable]?

    public init(
        id: String,
        code: String,
        name: String,
        options: [ProductOption]?,
        translations: [ProductOptionGroupTranslation]?,
        languageCode: LanguageCode?,
        createdAt: Date?,
        updatedAt: Date?,
        customFields: [String: AnyCodable]?
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.options = options
        self.translations = translations
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.customFields = customFields
    }
}
