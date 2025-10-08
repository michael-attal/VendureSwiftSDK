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
}
