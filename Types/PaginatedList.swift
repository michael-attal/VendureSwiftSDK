import Foundation

/// Generic paginated list response used across the SDK.
/// Keeps optional limit/skip metadata so client can store the original pagination context.
public struct PaginatedList<Item: Hashable & Codable & Sendable>: Hashable, Codable, Sendable {
    // MARK: - Core fields

    /// Returned items for the current page/request.
    public let items: [Item]

    /// Total number of matching items for the query (server-side).
    public let totalItems: Int

    /// Optional total number of pages for the query (server-side), if provided.
    public let totalPages: Int?

    /// Optional current page index (1-based) if provided by the API.
    /// For empty datasets, servers may return 0; we mirror that in derived logic.
    public let currentPage: Int?

    /// Optional flags that some APIs may provide.
    public let hasNextPage: Bool?
    public let hasPreviousPage: Bool?

    // MARK: - Pagination context (optional)

    /// Page size or requested limit (if provided by server or echoed by client).
    public let limit: Int?

    /// Skip/offset used for the request (0-based).
    public let skip: Int?

    // MARK: - Init

    public init(
        items: [Item],
        totalItems: Int,
        totalPages: Int? = nil,
        currentPage: Int? = nil,
        hasNextPage: Bool? = nil,
        hasPreviousPage: Bool? = nil,
        limit: Int? = nil,
        skip: Int? = nil
    ) {
        self.items = items
        self.totalItems = totalItems
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.hasNextPage = hasNextPage
        self.hasPreviousPage = hasPreviousPage
        self.limit = limit
        self.skip = skip
    }

    // MARK: - Derived helpers

    /// Compute whether there is a previous page using available metadata.
    /// Priority: explicit `hasPreviousPage` -> `skip` -> false.
    public var derivedHasPreviousPage: Bool {
        if let explicit = hasPreviousPage { return explicit }
        if let skip = skip { return skip > 0 }
        return false
    }

    /// Compute whether there is a next page using available metadata.
    /// Priority: explicit `hasNextPage` -> (skip + items.count) < totalItems -> false.
    public var derivedHasNextPage: Bool {
        if let explicit = hasNextPage { return explicit }
        if let skip = skip {
            return (skip + items.count) < totalItems
        }
        return false
    }

    /// Compute total pages using available metadata.
    /// Priority:
    /// 1) explicit `totalPages`
    /// 2) `limit` if > 0  -> ceil(totalItems / limit)
    /// 3) `items.count` if > 0 -> ceil(totalItems / items.count)
    /// 4) if `totalItems == 0` -> 0
    /// 5) fallback -> 1
    public var derivedTotalPages: Int {
        if let explicit = totalPages { return explicit }
        guard totalItems > 0 else { return 0 }

        if let limit = limit, limit > 0 {
            return (totalItems + limit - 1) / limit
        }

        let pageSize = items.count
        if pageSize > 0 {
            return (totalItems + pageSize - 1) / pageSize
        }

        // Degenerate fallback: we know there are items overall, but page size is unknown.
        return 1
    }

    /// Compute current page (1-based), clamped to `derivedTotalPages`.
    /// Priority:
    /// 1) explicit `currentPage`
    /// 2) `limit`/`skip`
    /// 3) `items.count`/`skip`
    /// 4) empty -> 0 ; unknown -> 1
    public var derivedCurrentPage: Int {
        let pages = derivedTotalPages
        if let explicit = currentPage {
            let v = max(0, explicit)
            return (pages == 0) ? 0 : min(max(1, v), pages)
        }

        // No explicit page
        if pages == 0 { return 0 }

        let s = max(0, skip ?? 0)

        if let limit = limit, limit > 0 {
            return min((s / limit) + 1, pages)
        }

        let pageSize = items.count
        if pageSize > 0 {
            return min((s / pageSize) + 1, pages)
        }

        // Fallback when we can't infer page size nor skip meaningfully.
        return min(1, pages)
    }
}

/// Generic options for fetching paginated lists of any entity
public struct PaginatedListOptions<Filter: Hashable & Codable & Sendable, Sort: Hashable & Codable & Sendable>: Hashable, Codable, Sendable {
    /// Number of items to skip (for pagination)
    public let skip: Int?

    /// Number of items to fetch (for pagination)
    public let take: Int?

    /// Sorting parameters
    public let sort: Sort?

    /// Filtering parameters
    public let filter: Filter?

    /// Logical operator to apply between filter fields (AND / OR)
    public let filterOperator: LogicalOperator?

    public init(skip: Int? = nil,
                take: Int? = nil,
                sort: Sort? = nil,
                filter: Filter? = nil,
                filterOperator: LogicalOperator? = nil)
    {
        self.skip = skip
        self.take = take
        self.sort = sort
        self.filter = filter
        self.filterOperator = filterOperator
    }
}

// MARK: - Paginated List Options Type Aliases

public typealias CustomerListOptions = PaginatedListOptions<CustomerFilterParameter, CustomerSortParameter>
public typealias OrderListOptions = PaginatedListOptions<OrderFilterParameter, OrderSortParameter>
public typealias ProductListOptions = PaginatedListOptions<ProductFilterParameter, ProductSortParameter>
public typealias ProductVariantListOptions = PaginatedListOptions<ProductVariantFilterParameter, ProductVariantSortParameter>
public typealias VendureCollectionListOptions = PaginatedListOptions<VendureCollectionFilterParameter, VendureCollectionSortParameter>
public typealias FacetListOptions = PaginatedListOptions<FacetFilterParameter, FacetSortParameter>
public typealias FacetValueListOptions = PaginatedListOptions<FacetValueFilterParameter, FacetValueSortParameter>
public typealias AssetListOptions = PaginatedListOptions<AssetFilterParameter, AssetSortParameter>
public typealias PaymentMethodListOptions = PaginatedListOptions<PaymentMethodFilterParameter, PaymentMethodSortParameter>
public typealias ShippingMethodListOptions = PaginatedListOptions<ShippingMethodFilterParameter, ShippingMethodSortParameter>
