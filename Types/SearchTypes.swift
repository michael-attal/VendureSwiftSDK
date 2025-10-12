import Foundation

// MARK: - Search Types

// TODO: Make it generic like PaginatedList

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

/// Type alias for search response
public typealias SearchResponse = SearchResult
