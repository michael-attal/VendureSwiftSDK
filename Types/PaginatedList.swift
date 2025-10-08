import Foundation

/// Generic paginated list response used across the SDK.
/// Keeps optional limit/skip metadata so client can store the original pagination context.
public struct PaginatedList<Item: Codable & Sendable>: Codable, Sendable {
    // MARK: - Core fields

    /// Returned items for the current page/request.
    public let items: [Item]

    /// Total number of matching items for the query (server-side).
    public let totalItems: Int

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
        hasNextPage: Bool? = nil,
        hasPreviousPage: Bool? = nil,
        limit: Int? = nil,
        skip: Int? = nil
    ) {
        self.items = items
        self.totalItems = totalItems
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
}

/// Generic options for fetching paginated lists of any entity
public struct PaginatedListOptions<Filter: Codable & Sendable, Sort: Codable & Sendable>: Codable, Sendable {
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
