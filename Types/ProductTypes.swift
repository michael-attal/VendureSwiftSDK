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
    public let customFields: [String: AnyCodable]? // Modern AnyCodable approach
    public let createdAt: Date?
    public let updatedAt: Date?
}

/// Represents a product option
public struct ProductOption: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let groupId: String? // Optional - may not be present in all GraphQL responses
    public let group: ProductOptionGroup? // Optional - may not be present in all GraphQL responses
    public let translations: [ProductOptionTranslation]? // Optional
    public let customFields: [String: AnyCodable]?
}

/// Represents a product option group
public struct ProductOptionGroup: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let options: [ProductOption]?
    public let translations: [ProductOptionGroupTranslation]?
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode?
    public let createdAt: Date?
    public let updatedAt: Date?
}

/// Product translation
public struct ProductTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    public let slug: String
    public let description: String
}

/// Product variant translation
public struct ProductVariantTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
}

/// Product option translation
public struct ProductOptionTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
}

/// Product option group translation
public struct ProductOptionGroupTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
}

// MARK: - Search Types

/// Search input for catalog search
public struct SearchInput: Codable, Sendable {
    public let term: String?
    public let facetValueFilters: [FacetValueFilterInput]?
    public let facetValueIds: [String]?
    public let facetValueOperator: LogicalOperator?
    public let collectionId: String?
    public let collectionSlug: String?
    public let groupByProduct: Bool?
    public let skip: Int?
    public let take: Int?
    public let sort: SearchResultSortParameter?
}

/// Search result sort parameter
public struct SearchResultSortParameter: Codable, Sendable {
    public let name: SortOrder?
    public let price: SortOrder?
}

/// Search result
public struct SearchResult: Codable, Hashable, Sendable {
    public let items: [SearchResultItem]
    public let totalItems: Int
    public let facetValues: [FacetValueResult]
}

/// Search result item
public struct SearchResultItem: Codable, Hashable, Identifiable, Sendable {
    public let productId: String
    public let productName: String
    public let productAsset: Asset?
    public let productVariantId: String
    public let productVariantName: String
    public let productVariantAsset: Asset?
    public let price: SearchResultPrice
    public let priceWithTax: SearchResultPrice
    public let currencyCode: CurrencyCode
    public let description: String
    public let slug: String
    public let sku: String
    public let collectionIds: [String]
    public let facetIds: [String]
    public let facetValueIds: [String]
    public let score: Double
    
    public var id: String { productVariantId }
}

/// Search result price (can be single price or range)
public enum SearchResultPrice: Codable, Hashable, Sendable {
    case single(Double)
    case range(min: Double, max: Double)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let singlePrice = try? container.decode(Double.self) {
            self = .single(singlePrice)
        } else {
            let rangeContainer = try decoder.container(keyedBy: CodingKeys.self)
            let min = try rangeContainer.decode(Double.self, forKey: .min)
            let max = try rangeContainer.decode(Double.self, forKey: .max)
            self = .range(min: min, max: max)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .single(let price):
            var container = encoder.singleValueContainer()
            try container.encode(price)
        case .range(let min, let max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(min, forKey: .min)
            try container.encode(max, forKey: .max)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case min, max
    }
}

/// Facet value result from search
public struct FacetValueResult: Codable, Hashable, Sendable {
    public let facetValue: FacetValue
    public let count: Int
}

/// Type alias for search response
public typealias SearchResponse = SearchResult

// MARK: - Simplified Catalog Types (for listing)

/// Simplified asset for catalog listing
public struct CatalogAsset: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let preview: String
    public let source: String
}

/// Simplified product for catalog listing
public struct CatalogProduct: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String
    public let enabled: Bool
    public let featuredAsset: CatalogAsset?
    public let variants: [CatalogProductVariant]
    public let customFields: [String: AnyCodable]? // Modern AnyCodable approach
}

/// Simplified product variant for catalog listing
public struct CatalogProductVariant: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let sku: String
    public let price: Double
    public let priceWithTax: Double
    public let currencyCode: CurrencyCode
    public let stockLevel: String
    public let customFields: [String: AnyCodable]? // Modern AnyCodable approach
}

/// Product list for catalog
public struct CatalogProductList: Codable, Sendable {
    public let items: [CatalogProduct]
    public let totalItems: Int
}

/// Facet translation
public struct FacetTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

/// Facet value translation
public struct FacetValueTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

/// Search result asset
public struct SearchResultAsset: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let preview: String
    public let focalPoint: Coordinate?
    
    public init(id: String, preview: String, focalPoint: Coordinate? = nil) {
        self.id = id
        self.preview = preview
        self.focalPoint = focalPoint
    }
}
