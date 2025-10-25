import Foundation

// MARK: - Generic Search Types

/// Generic search input with customizable filter and sort types
public struct SearchInput<Filter: Hashable & Codable & Sendable, Sort: Hashable & Codable & Sendable>: Hashable, Codable, Sendable {
    /// Search term/query string
    public let term: String?

    /// Skip for pagination
    public let skip: Int?

    /// Take/limit for pagination
    public let take: Int?

    /// Sorting parameters
    public let sort: Sort?

    /// Filter parameters
    public let filter: Filter?

    /// Logical operator for filter combination
    public let filterOperator: LogicalOperator?

    public init(
        term: String? = nil,
        skip: Int? = nil,
        take: Int? = nil,
        sort: Sort? = nil,
        filter: Filter? = nil,
        filterOperator: LogicalOperator? = nil
    ) {
        self.term = term
        self.skip = skip
        self.take = take
        self.sort = sort
        self.filter = filter
        self.filterOperator = filterOperator
    }
}

/// Generic search result with any item type and optional faceting
public struct SearchResult<Item: Hashable & Codable & Sendable, Facet: Hashable & Codable & Sendable>: Hashable, Codable, Sendable {
    /// Search result items
    public let items: [Item]

    /// Total number of matching items
    public let totalItems: Int

    /// Optional facet results for filtering
    public let facets: [Facet]?

    /// Optional search metadata (score, relevance, etc.)
    public let metadata: SearchMetadata?

    public init(
        items: [Item],
        totalItems: Int,
        facets: [Facet]? = nil,
        metadata: SearchMetadata? = nil
    ) {
        self.items = items
        self.totalItems = totalItems
        self.facets = facets
        self.metadata = metadata
    }
}

/// Search metadata for additional search context
public struct SearchMetadata: Hashable, Codable, Sendable {
    public let queryTime: TimeInterval?
    public let maxScore: Double?
    public let appliedCorrections: [String]?

    public init(
        queryTime: TimeInterval? = nil,
        maxScore: Double? = nil,
        appliedCorrections: [String]? = nil
    ) {
        self.queryTime = queryTime
        self.maxScore = maxScore
        self.appliedCorrections = appliedCorrections
    }
}

// MARK: - Commerce-Specific Search Types

/// Commerce-specific filter for catalog search
public struct CatalogSearchFilter: Hashable, Codable, Sendable {
    public let facetValueFilters: [FacetValueFilterInput]?
    public let facetValueIds: [String]?
    public let facetValueOperator: LogicalOperator?
    public let collectionId: String?
    public let collectionSlug: String?
    public let groupByProduct: Bool?

    public init(
        facetValueFilters: [FacetValueFilterInput]? = nil,
        facetValueIds: [String]? = nil,
        facetValueOperator: LogicalOperator? = nil,
        collectionId: String? = nil,
        collectionSlug: String? = nil,
        groupByProduct: Bool? = nil
    ) {
        self.facetValueFilters = facetValueFilters
        self.facetValueIds = facetValueIds
        self.facetValueOperator = facetValueOperator
        self.collectionId = collectionId
        self.collectionSlug = collectionSlug
        self.groupByProduct = groupByProduct
    }
}

/// Search result item for commerce/catalog
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
    public let customFields: [String: AnyCodable]?

    public var id: String { productVariantId }

    public init(
        productId: String,
        productName: String,
        productAsset: Asset?,
        productVariantId: String,
        productVariantName: String,
        productVariantAsset: Asset?,
        price: SearchResultPrice,
        priceWithTax: SearchResultPrice,
        currencyCode: CurrencyCode,
        description: String,
        slug: String,
        sku: String,
        collectionIds: [String],
        facetIds: [String],
        facetValueIds: [String],
        score: Double,
        customFields: [String: AnyCodable]? = nil
    ) {
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
        self.customFields = customFields
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

    private enum CodingKeys: String, Hashable, CodingKey {
        case min, max
    }
}

/// Facet value result from search
public struct FacetValueResult: Codable, Hashable, Sendable {
    public let facetValue: FacetValue
    public let count: Int
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
