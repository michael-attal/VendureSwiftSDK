import Foundation

// MARK: - Product Types

/// Represents a product in the catalog
public struct Product: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String
    public let enabled: Bool?
    public let featuredAsset: Asset?
    public let assets: [Asset]?
    public let variants: [ProductVariant]
    public let optionGroups: [ProductOptionGroup]?
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
        enabled: Bool? = nil,
        featuredAsset: Asset? = nil,
        assets: [Asset]? = nil,
        variants: [ProductVariant],
        optionGroups: [ProductOptionGroup]? = nil,
        facetValues: [FacetValue]? = nil,
        translations: [ProductTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil,
        languageCode: LanguageCode? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
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
        enabled: Bool? = nil,
        stockLevel: String,
        trackInventory: String? = nil,
        stockOnHand: Int? = nil,
        stockAllocated: Int? = nil,
        outOfStockThreshold: Int? = nil,
        useGlobalOutOfStockThreshold: Bool? = nil,
        featuredAsset: Asset? = nil,
        assets: [Asset]? = nil,
        options: [ProductOption]? = nil,
        facetValues: [FacetValue]? = nil,
        translations: [ProductVariantTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil,
        languageCode: LanguageCode? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
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
        group: ProductOptionGroup? = nil,
        translations: [ProductOptionTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil
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
        options: [ProductOption]? = nil,
        translations: [ProductOptionGroupTranslation]? = nil,
        languageCode: LanguageCode? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        customFields: [String: AnyCodable]? = nil
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
