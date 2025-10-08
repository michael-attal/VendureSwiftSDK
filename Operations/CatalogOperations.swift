import Foundation

/// Actor responsible for catalog related queries against Vendure.
/// Uses generic paginated and single-object executors to avoid duplication.
public actor CatalogOperations {
    private let vendure: Vendure

    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }

    // MARK: - Generic executors

    private func executePaginatedQuery<T: Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> PaginatedList<T> {
        let response = try await vendure.custom.queryRaw(query, variables: variables)
        if response.hasErrors {
            let messages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(messages)
        }
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let root = jsonObject as? [String: Any],
              let dataDict = root["data"] as? [String: Any],
              let target = dataDict[expectedDataType]
        else {
            throw VendureError.decodingError(
                NSError(domain: "CatalogOperations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"])
            )
        }
        let extractedData = try JSONSerialization.data(withJSONObject: target, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PaginatedList<T>.self, from: extractedData)
    }

    private func executeSingleQuery<T: Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> T {
        let response = try await vendure.custom.queryRaw(query, variables: variables)
        if response.hasErrors {
            let messages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(messages)
        }
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let root = jsonObject as? [String: Any],
              let dataDict = root["data"] as? [String: Any],
              let target = dataDict[expectedDataType]
        else {
            throw VendureError.decodingError(
                NSError(domain: "CatalogOperations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"])
            )
        }
        let extractedData = try JSONSerialization.data(withJSONObject: target, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: extractedData)
    }

    // MARK: - Collections & Products

    public func getCollections(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil
    ) async throws -> PaginatedList<VendureCollection> {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildCollectionQuery(includeCustomFields: shouldIncludeCustomFields)
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "collections")
    }

    public func getCollectionById(id: String, includeCustomFields: Bool? = nil, includeProducts: Bool = false) async throws -> VendureCollection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleCollectionQuery(byId: true, includeCustomFields: shouldIncludeCustomFields, includeProducts: includeProducts)
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "collection")
    }

    public func getCollectionBySlug(slug: String, includeCustomFields: Bool? = nil, includeProducts: Bool = false) async throws -> VendureCollection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleCollectionQuery(byId: false, includeCustomFields: shouldIncludeCustomFields, includeProducts: includeProducts)
        let variables: [String: AnyCodable] = ["slug": AnyCodable(slug)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "collection")
    }

    public func getProducts(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil
    ) async throws -> PaginatedList<Product> {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildProductQuery(includeCustomFields: shouldIncludeCustomFields, options: options)
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "products")
    }

    public func getProductById(id: String, includeCustomFields: Bool? = nil) async throws -> Product {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleProductQuery(byId: true, includeCustomFields: shouldIncludeCustomFields)
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "product")
    }

    public func getProductBySlug(slug: String, includeCustomFields: Bool? = nil) async throws -> Product {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleProductQuery(byId: false, includeCustomFields: shouldIncludeCustomFields)
        let variables: [String: AnyCodable] = ["slug": AnyCodable(slug)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "product")
    }

    public func searchCatalog(input: SearchInput, includeCustomFields: Bool? = nil) async throws -> SearchResult {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "SearchResult", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSearchQuery(includeCustomFields: shouldIncludeCustomFields)
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "search")
    }

    // MARK: - Facets

    public func getFacets(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil
    ) async throws -> PaginatedList<Facet> {
        let query = GraphQLQueryBuilder.buildFacetQuery()
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "facets")
    }

    public func getFacetById(id: String) async throws -> Facet {
        let query = GraphQLQueryBuilder.buildSingleFacetQuery()
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "facet")
    }

    // MARK: - Assets

    public func getAssets(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil
    ) async throws -> PaginatedList<Asset> {
        let query = GraphQLQueryBuilder.buildAssetQuery()
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "assets")
    }

    public func getAssetById(id: String) async throws -> Asset {
        let query = GraphQLQueryBuilder.buildSingleAssetQuery()
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "asset")
    }

    // MARK: - Orders // TODO: Move it to Order Operations

    public func getOrders(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil
    ) async throws -> PaginatedList<Order> {
        let query = GraphQLQueryBuilder.buildOrderQuery()
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "orders")
    }

    public func getOrderById(id: String) async throws -> Order {
        let query = GraphQLQueryBuilder.buildSingleOrderQuery()
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "order")
    }

    // MARK: - Customers // TODO: Move it to BaseOperations

    public func getCustomers(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil
    ) async throws -> PaginatedList<Customer> {
        let query = GraphQLQueryBuilder.buildCustomerQuery()
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "customers")
    }

    public func getCustomerById(id: String) async throws -> Customer {
        let query = GraphQLQueryBuilder.buildSingleCustomerQuery()
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "customer")
    }
}
