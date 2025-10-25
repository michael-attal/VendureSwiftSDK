import Foundation

/// Actor responsible for catalog related queries against Vendure.
/// Uses generic paginated and single-object executors to avoid duplication.
public actor CatalogOperations {
    private let vendure: Vendure

    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }

    // MARK: - Generic executors

    private func executePaginatedQuery<T: Hashable & Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String,
        languageCode: String? = nil
    ) async throws -> PaginatedList<T> {
        // 1. Extract skip and take to reinsert later if needed
        let inputOptions = variables?["options"]?.value.base as? PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >
        let inputSkip: Int? = inputOptions?.skip
        let inputTake: Int? = inputOptions?.take

        // 2. Execute the query
        let response = try await vendure.custom.queryRaw(query, variables: variables, languageCode: languageCode)
        if response.hasErrors {
            let messages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(messages)
        }
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }

        // 3. Extract the relevant part of the JSON ("items" and "totalItems")
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let root = jsonObject as? [String: Any],
              let dataDict = root["data"] as? [String: Any],
              let target = dataDict[expectedDataType] // This should be the object containing items and totalItems
        else {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to find key '\(expectedDataType)' in paginated response data.")
            let responseString = String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data"
            await VendureLogger.shared.log(.verbose, category: "Decode", "Raw Response: \(responseString)")
            throw VendureError.decodingError(
                NSError(domain: "CatalogOperations", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response structure"])
            )
        }

        // 4. Decode the extracted data into PaginatedList (this will likely have nil for pagination fields)
        let extractedData = try JSONSerialization.data(withJSONObject: target, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var decodedList: PaginatedList<T>
        do {
            decodedList = try decoder.decode(PaginatedList<T>.self, from: extractedData)
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode PaginatedList<\(String(describing: T.self))>: \(error)")
            let extractedString = String(data: extractedData, encoding: .utf8) ?? "Invalid UTF-8 data"
            await VendureLogger.shared.log(.verbose, category: "Decode", "Extracted Data: \(extractedString)")
            throw VendureError.decodingError(error)
        }

        // 5. Create a *new* PaginatedList, merging decoded data with input pagination
        //    Use the input skip/take if the decoded ones are nil.
        let finalSkip = decodedList.skip ?? inputSkip
        let finalLimit = decodedList.limit ?? inputTake // Use input 'take' for 'limit'

        // Reconstruct the PaginatedList with the added skip/limit info
        let enrichedList = PaginatedList<T>(
            items: decodedList.items,
            totalItems: decodedList.totalItems,
            totalPages: decodedList.totalPages,
            currentPage: decodedList.currentPage,
            hasNextPage: decodedList.hasNextPage,
            hasPreviousPage: decodedList.hasPreviousPage,
            limit: finalLimit,
            skip: finalSkip
        )

        return enrichedList
    }

    private func executeSingleQuery<T: Hashable & Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String,
        languageCode: String? = nil
    ) async throws -> T {
        let response = try await vendure.custom.queryRaw(query, variables: variables, languageCode: languageCode)
        if response.hasErrors {
            let messages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            // Check for specific "not found" style errors if possible
            if messages.contains(where: { $0.lowercased().contains("not found") || $0.lowercased().contains("no product with") }) {
                await VendureLogger.shared.log(.info, category: "Query", "Received 'not found' error for \(expectedDataType).")
                // Decide: Rethrow as GraphQL error or a more specific "notFound"? Sticking to GraphQL error for now.
            }
            throw VendureError.graphqlError(messages)
        }
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            // Check if 'data' is present but the expected key is null
            if let json = try? JSONSerialization.jsonObject(with: response.rawData) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               dataDict[expectedDataType] is NSNull
            {
                await VendureLogger.shared.log(.info, category: "Query", "Query returned null for key '\(expectedDataType)'. Assuming not found.")
                // Throw a more specific error or let decoding fail naturally? Throwing specific.
                throw VendureError.graphqlError(["\(expectedDataType.capitalized) not found or is null."])
            }
            throw VendureError.noData
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let root = jsonObject as? [String: Any],
              let dataDict = root["data"] as? [String: Any],
              let target = dataDict[expectedDataType]
        else {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to find key '\(expectedDataType)' in single item response data.")
            let responseString = String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data"
            await VendureLogger.shared.log(.verbose, category: "Decode", "Raw Response: \(responseString)")
            throw VendureError.decodingError(
                NSError(domain: "CatalogOperations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response structure"])
            )
        }

        // Handle case where target itself is null (e.g., product not found by slug/id)
        if target is NSNull {
            await VendureLogger.shared.log(.info, category: "Query", "Query returned null for key '\(expectedDataType)'. Assuming not found.")
            throw VendureError.graphqlError(["\(expectedDataType.capitalized) not found or is null."])
        }

        let extractedData = try JSONSerialization.data(withJSONObject: target, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: extractedData)
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode \(String(describing: T.self)): \(error)")
            let extractedString = String(data: extractedData, encoding: .utf8) ?? "Invalid UTF-8 data"
            await VendureLogger.shared.log(.verbose, category: "Decode", "Extracted Data: \(extractedString)")
            throw VendureError.decodingError(error)
        }
    }

    // MARK: - Collections & Products

    public func getCollections(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<VendureCollection> {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildCollectionQuery(includeCustomFields: shouldIncludeCustomFields)
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "collections", languageCode: languageCode)
    }

    public func getCollectionById(
        id: String,
        includeCustomFields: Bool? = nil,
        includeProducts: Bool = false,
        languageCode: String? = nil
    ) async throws -> VendureCollection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        // Also check ProductVariant if includeProducts is true
        let shouldIncludeVariantFields = includeProducts && VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildSingleCollectionQuery(
            byId: true,
            includeCustomFields: shouldIncludeCustomFields,
            includeProducts: includeProducts,
            // Pass variant field flag to builder if necessary
            includeVariantCustomFields: shouldIncludeVariantFields
        )
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        // Pass languageCode to executor
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "collection", languageCode: languageCode)
    }

    public func getCollectionBySlug(
        slug: String,
        includeCustomFields: Bool? = nil,
        includeProducts: Bool = false,
        languageCode: String? = nil
    ) async throws -> VendureCollection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let shouldIncludeVariantFields = includeProducts && VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildSingleCollectionQuery(
            byId: false,
            includeCustomFields: shouldIncludeCustomFields,
            includeProducts: includeProducts,
            includeVariantCustomFields: shouldIncludeVariantFields
        )
        let variables: [String: AnyCodable] = ["slug": AnyCodable(slug)]
        // Pass languageCode to executor
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "collection", languageCode: languageCode)
    }

    public func getProducts(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<Product> {
        let shouldIncludeProdFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let shouldIncludeVarFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildProductQuery(
            includeCustomFields: shouldIncludeProdFields, // For Product level
            includeVariantCustomFields: shouldIncludeVarFields, // For Variant level
            options: options // 'options' parameter is passed here but NOT used in query string building, only for variables.
        )

        let variables: [String: AnyCodable]? = options.map { opt in
            ["options": AnyCodable(opt)]
        }

        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "products", languageCode: languageCode)
    }

    public func getProductById(
        id: String,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Product {
        let shouldIncludeProdFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let shouldIncludeVarFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildSingleProductQuery(
            byId: true,
            includeCustomFields: shouldIncludeProdFields,
            includeVariantCustomFields: shouldIncludeVarFields
        )
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "product", languageCode: languageCode)
    }

    public func getProductBySlug(
        slug: String,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Product {
        let shouldIncludeProdFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let shouldIncludeVarFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildSingleProductQuery(
            byId: false,
            includeCustomFields: shouldIncludeProdFields,
            includeVariantCustomFields: shouldIncludeVarFields
        )
        let variables: [String: AnyCodable] = ["slug": AnyCodable(slug)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "product", languageCode: languageCode)
    }

    public func searchCatalog(
        input: CatalogSearchInput,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> CatalogSearchResult {
        let shouldIncludeProdFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        // Current GraphQLQueryBuilder.buildSearchQuery does NOT include customFields fragments.
        // If needed, the builder would need modification.
        let query = GraphQLQueryBuilder.buildSearchQuery(includeCustomFields: shouldIncludeProdFields)
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "search", languageCode: languageCode)
    }

    // MARK: - Facets

    public func getFacets(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<Facet> {
        let shouldIncludeFacetFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Facet", userRequested: includeCustomFields)
        let shouldIncludeValueFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "FacetValue", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildFacetQuery(
            includeCustomFields: shouldIncludeFacetFields,
            includeValueCustomFields: shouldIncludeValueFields
        )
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "facets", languageCode: languageCode)
    }

    public func getFacetById(
        id: String,
        languageCode: String? = nil
    ) async throws -> Facet {
        let shouldIncludeFacetFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Facet", userRequested: nil)
        let shouldIncludeValueFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "FacetValue", userRequested: nil)

        let query = await GraphQLQueryBuilder.buildSingleFacetQuery(
            includeCustomFields: shouldIncludeFacetFields,
            includeValueCustomFields: shouldIncludeValueFields
        )
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "facet", languageCode: languageCode)
    }

    // MARK: - Assets

    public func getAssets(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil
    ) async throws -> PaginatedList<Asset> {
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Asset", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildAssetQuery(includeCustomFields: shouldIncludeFields)
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "assets")
    }

    public func getAssetById(
        id: String,
        includeCustomFields: Bool? = nil
    ) async throws -> Asset {
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Asset", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleAssetQuery(includeCustomFields: shouldIncludeFields)
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "asset")
    }

    // MARK: - Orders

    public func getOrders(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<Order> {
        await VendureLogger.shared.log(.warning, category: "CatalogOps", "getOrders called on CatalogOperations. Use OrderOperations instead.")
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: nil)
        let query = await GraphQLQueryBuilder.buildOrderQuery(includeCustomFields: shouldIncludeFields)
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "orders", languageCode: languageCode)
    }

    public func getOrderById(id: String, languageCode: String? = nil) async throws -> Order {
        await VendureLogger.shared.log(.warning, category: "CatalogOps", "getOrderById called on CatalogOperations. Use OrderOperations instead.")
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: nil)
        let query = await GraphQLQueryBuilder.buildSingleOrderQuery(includeCustomFields: shouldIncludeFields)
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "order", languageCode: languageCode)
    }

    // MARK: - Customers

    public func getCustomers(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<Customer> {
        await VendureLogger.shared.log(.warning, category: "CatalogOps", "getCustomers called on CatalogOperations. Use CustomerOperations instead.")
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: nil)
        let query = await GraphQLQueryBuilder.buildCustomerQuery(includeCustomFields: shouldIncludeFields)
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        return try await executePaginatedQuery(query, variables: variables, expectedDataType: "customers")
    }

    public func getCustomerById(id: String, languageCode: String? = nil) async throws -> Customer {
        await VendureLogger.shared.log(.warning, category: "CatalogOps", "getCustomerById called on CatalogOperations. Use CustomerOperations instead.")
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: nil)
        let query = await GraphQLQueryBuilder.buildSingleCustomerQuery(includeCustomFields: shouldIncludeFields)
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await executeSingleQuery(query, variables: variables, expectedDataType: "customer")
    }
}

public extension CatalogOperations {
    // MARK: - Deprecated Collection methodds // TODO: Remove it later

    @available(*, deprecated, message: "Use CatalogOperations.getCollections instead")
    func getCollectionListWithParentChildren(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<VendureCollection> {
        let query = """
        query collections($options: CollectionListOptions) { # Keep original GQL type name
          collections(options: $options) {
            items {
              id name slug description
              parent { id name slug parent { id name slug } }
              children { id name slug children { id name slug } }
              featuredAsset { id preview source }
            }
            totalItems
          }
        }
        """
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]

        return try await vendure.custom.queryGeneric(
            query,
            variables: variables,
            expectedDataType: "collections",
            responseType: PaginatedList<VendureCollection>.self,
            languageCode: languageCode
        )
    }

    @available(*, deprecated, message: "Use CatalogOperations.getCollectionById instead")
    func getCollectionWithParentChildren(id: String, languageCode: String? = nil) async throws -> VendureCollection {
        let query = """
        query collection($id: ID!) {
          collection(id: $id) {
            id name slug description
            parent { id name slug parent { id name slug } }
            children { id name slug children { id name slug } }
            featuredAsset { id preview source }
          }
        }
        """
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await vendure.custom.executeQuery(
            query,
            variables: variables,
            expectedDataType: "collection",
            decodeTo: VendureCollection.self,
            languageCode: languageCode
        )
    }

    @available(*, deprecated, message: "Use CatalogOperations.getCollectionById instead")
    func getCollectionWithParent(id: String, languageCode: String? = nil) async throws -> VendureCollection {
        let query = """
        query collection($id: ID!) {
          collection(id: $id) {
            id name slug description
            parent { id name slug }
            featuredAsset { id preview source }
          }
        }
        """
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await vendure.custom.executeQuery(
            query,
            variables: variables,
            expectedDataType: "collection",
            decodeTo: VendureCollection.self,
            languageCode: languageCode
        )
    }

    @available(*, deprecated, message: "Use CatalogOperations.getCollectionById instead")
    func getCollectionWithChildren(id: String, languageCode: String? = nil) async throws -> VendureCollection {
        let query = """
        query collection($id: ID!) {
          collection(id: $id) {
            id name slug description
            children { id name slug }
            featuredAsset { id preview source }
          }
        }
        """
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]
        return try await vendure.custom.executeQuery(
            query,
            variables: variables,
            expectedDataType: "collection",
            decodeTo: VendureCollection.self,
            languageCode: languageCode
        )
    }
}
