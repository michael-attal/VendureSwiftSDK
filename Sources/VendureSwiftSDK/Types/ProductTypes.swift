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
    public let facetValues: [FacetValue]
    public let translations: [ProductTranslation]
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, slug: String, description: String, enabled: Bool,
                featuredAsset: Asset? = nil, assets: [Asset] = [], variants: [ProductVariant] = [],
                optionGroups: [ProductOptionGroup] = [], facetValues: [FacetValue] = [],
                translations: [ProductTranslation] = [], customFields: [String: AnyCodable]? = nil,
                languageCode: LanguageCode, createdAt: Date, updatedAt: Date) {
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
    public let enabled: Bool
    public let stockLevel: String
    public let trackInventory: String
    public let stockOnHand: Int
    public let stockAllocated: Int
    public let outOfStockThreshold: Int
    public let useGlobalOutOfStockThreshold: Bool
    public let featuredAsset: Asset?
    public let assets: [Asset]
    public let options: [ProductOption]
    public let facetValues: [FacetValue]
    public let translations: [ProductVariantTranslation]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, sku: String, price: Double, priceWithTax: Double,
                currencyCode: CurrencyCode, enabled: Bool, stockLevel: String, 
                trackInventory: String, stockOnHand: Int, stockAllocated: Int,
                outOfStockThreshold: Int, useGlobalOutOfStockThreshold: Bool,
                featuredAsset: Asset? = nil, assets: [Asset] = [], options: [ProductOption] = [],
                facetValues: [FacetValue] = [], translations: [ProductVariantTranslation] = [],
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a product option
public struct ProductOption: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let groupId: String
    public let group: ProductOptionGroup
    public let translations: [ProductOptionTranslation]
    public let customFields: [String: AnyCodable]?
    
    public init(id: String, code: String, name: String, groupId: String, group: ProductOptionGroup,
                translations: [ProductOptionTranslation] = [], customFields: [String: AnyCodable]? = nil) {
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
    public let options: [ProductOption]
    public let translations: [ProductOptionGroupTranslation]
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, code: String, name: String, options: [ProductOption] = [],
                translations: [ProductOptionGroupTranslation] = [], customFields: [String: AnyCodable]? = nil,
                languageCode: LanguageCode, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.code = code
        self.name = name
        self.options = options
        self.translations = translations
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Product translation
public struct ProductTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    public let slug: String
    public let description: String
    
    public init(languageCode: LanguageCode, name: String, slug: String, description: String) {
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
    }
}

/// Product variant translation
public struct ProductVariantTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

/// Product option translation
public struct ProductOptionTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

/// Product option group translation
public struct ProductOptionGroupTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
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
    
    public init(term: String? = nil, facetValueFilters: [FacetValueFilterInput]? = nil,
                facetValueIds: [String]? = nil, facetValueOperator: LogicalOperator? = nil,
                collectionId: String? = nil, collectionSlug: String? = nil,
                groupByProduct: Bool? = nil, skip: Int? = nil, take: Int? = nil,
                sort: SearchResultSortParameter? = nil) {
        self.term = term
        self.facetValueFilters = facetValueFilters
        self.facetValueIds = facetValueIds
        self.facetValueOperator = facetValueOperator
        self.collectionId = collectionId
        self.collectionSlug = collectionSlug
        self.groupByProduct = groupByProduct
        self.skip = skip
        self.take = take
        self.sort = sort
    }
}

/// Search result sort parameter
public struct SearchResultSortParameter: Codable, Sendable {
    public let name: SortOrder?
    public let price: SortOrder?
    
    public init(name: SortOrder? = nil, price: SortOrder? = nil) {
        self.name = name
        self.price = price
    }
}


/// Search result
public struct SearchResult: Codable, Hashable, Sendable {
    public let items: [SearchResultItem]
    public let totalItems: Int
    public let facetValues: [FacetValueResult]
    
    public init(items: [SearchResultItem], totalItems: Int, facetValues: [FacetValueResult] = []) {
        self.items = items
        self.totalItems = totalItems
        self.facetValues = facetValues
    }
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
    
    public init(productId: String, productName: String, productAsset: Asset? = nil,
                productVariantId: String, productVariantName: String, productVariantAsset: Asset? = nil,
                price: SearchResultPrice, priceWithTax: SearchResultPrice, currencyCode: CurrencyCode,
                description: String, slug: String, sku: String, collectionIds: [String] = [],
                facetIds: [String] = [], facetValueIds: [String] = [], score: Double) {
        self.productId = productId
        self.productName = productName
        self.productAsset = productAsset
        self.productVariantId = productVariantId
        self.productVariantName = productVariantName
        self.productVariantAsset = productVariantAsset
        self.price = price
        self.priceWithTax = priceWithTax
        self.currencyCode = currencyCode
        self.description = description
        self.slug = slug
        self.sku = sku
        self.collectionIds = collectionIds
        self.facetIds = facetIds
        self.facetValueIds = facetValueIds
        self.score = score
    }
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
    
    public init(facetValue: FacetValue, count: Int) {
        self.facetValue = facetValue
        self.count = count
    }
}

/// Type alias for search response
public typealias SearchResponse = SearchResult

// MARK: - Collection Types

/// Represents a collection
public final class Collection: Codable, Hashable, Identifiable, @unchecked Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String
    public let breadcrumbs: [CollectionBreadcrumb]
    public let position: Int
    public let isRoot: Bool
    public let parent: Collection?
    public let parentId: String?
    public let children: [Collection]?
    public let featuredAsset: Asset?
    public let assets: [Asset]
    public let filters: [ConfigurableOperation]
    public let translations: [CollectionTranslation]
    public let productVariants: ProductVariantList
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, slug: String, description: String,
                breadcrumbs: [CollectionBreadcrumb] = [], position: Int, isRoot: Bool,
                parent: Collection? = nil, parentId: String? = nil, children: [Collection]? = nil,
                featuredAsset: Asset? = nil, assets: [Asset] = [], filters: [ConfigurableOperation] = [],
                translations: [CollectionTranslation] = [], productVariants: ProductVariantList,
                customFields: [String: AnyCodable]? = nil, languageCode: LanguageCode,
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.breadcrumbs = breadcrumbs
        self.position = position
        self.isRoot = isRoot
        self.parent = parent
        self.parentId = parentId
        self.children = children
        self.featuredAsset = featuredAsset
        self.assets = assets
        self.filters = filters
        self.translations = translations
        self.productVariants = productVariants
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Collection, rhs: Collection) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Collection breadcrumb
public struct CollectionBreadcrumb: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    
    public init(id: String, name: String, slug: String) {
        self.id = id
        self.name = name
        self.slug = slug
    }
}

/// Collection translation
public struct CollectionTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    public let slug: String
    public let description: String
    
    public init(languageCode: LanguageCode, name: String, slug: String, description: String) {
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
    }
}

// MARK: - Facet Types

/// Represents a facet
public struct Facet: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let isPrivate: Bool
    public let values: [FacetValue]
    public let translations: [FacetTranslation]
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, code: String, isPrivate: Bool, values: [FacetValue] = [],
                translations: [FacetTranslation] = [], customFields: [String: AnyCodable]? = nil,
                languageCode: LanguageCode, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.code = code
        self.isPrivate = isPrivate
        self.values = values
        self.translations = translations
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a facet value
public struct FacetValue: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let facet: Facet
    public let facetId: String
    public let translations: [FacetValueTranslation]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, code: String, facet: Facet, facetId: String,
                translations: [FacetValueTranslation] = [], customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.code = code
        self.facet = facet
        self.facetId = facetId
        self.translations = translations
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
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
