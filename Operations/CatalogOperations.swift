import Foundation

public actor CatalogOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    
    /// Helper method to execute query and decode CollectionList
    private func executeCollectionListQuery(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> CollectionList {
        let response = try await vendure.custom.queryRaw(
            query,
            variables: variables
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract specific data from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "CatalogOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CollectionList.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode VendureCollection
    private func executeCollectionQuery(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> VendureCollection {
        let response = try await vendure.custom.queryRaw(
            query,
            variables: variables
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract specific data from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "CatalogOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(VendureCollection.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode CatalogProductList - Modern approach
    /// Uses AnyCodable for automatic custom field handling
    private func executeCatalogProductListQuery(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> CatalogProductList {
        let response = try await vendure.custom.queryRaw(
            query,
            variables: variables
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract specific data from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "CatalogOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CatalogProductList.self, from: extractedData)
    }
    
    
    /// Helper method to execute query and decode Product
    private func executeProductQuery(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> Product {
        let response = try await vendure.custom.queryRaw(
            query,
            variables: variables
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract specific data from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "CatalogOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Product.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode SearchResult
    private func executeSearchResultQuery(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String
    ) async throws -> SearchResult {
        let response = try await vendure.custom.queryRaw(
            query,
            variables: variables
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract specific data from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "CatalogOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SearchResult.self, from: extractedData)
    }
    
    /// Get collections
    public func getCollections(options: VendureCollectionListOptions? = nil, includeCustomFields: Bool? = nil) async throws -> CollectionList {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildCollectionQuery(includeCustomFields: shouldIncludeCustomFields)
        
        var variables: [String: AnyCodable]? = nil
        if let options = options {
            variables = [
                "options": AnyCodable(anyValue: options)
            ]
        } else {
            variables = [
                "options": AnyCodable(anyValue: nil as String?)
            ]
        }
        
        return try await executeCollectionListQuery(
            query,
            variables: variables,
            expectedDataType: "collections"
        )
    }
    
    /// Get collection by ID
    public func getCollectionById(id: String, includeCustomFields: Bool? = nil, includeProducts: Bool = false) async throws -> VendureCollection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleCollectionQuery(
            byId: true,
            includeCustomFields: shouldIncludeCustomFields,
            includeProducts: includeProducts
        )
        
        let variables: [String: AnyCodable] = [
            "id": AnyCodable(id)
        ]
        
        return try await executeCollectionQuery(
            query,
            variables: variables,
            expectedDataType: "collection"
        )
    }
    
    /// Get collection by slug
    public func getCollectionBySlug(slug: String, includeCustomFields: Bool? = nil, includeProducts: Bool = false) async throws -> VendureCollection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleCollectionQuery(
            byId: false,
            includeCustomFields: shouldIncludeCustomFields,
            includeProducts: includeProducts
        )
        
        let variables: [String: AnyCodable] = [
            "slug": AnyCodable(slug)
        ]
        
        return try await executeCollectionQuery(
            query,
            variables: variables,
            expectedDataType: "collection"
        )
    }
    
    /// Get products
    public func getProducts(options: ProductListOptions? = nil, includeCustomFields: Bool? = nil) async throws -> CatalogProductList {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildProductQuery(
            includeCustomFields: shouldIncludeCustomFields,
            options: options
        )
        
        var variables: [String: AnyCodable]? = nil
        if let options = options {
            variables = [
                "options": AnyCodable(anyValue: options)
            ]
        } else {
            variables = [
                "options": AnyCodable(anyValue: nil as String?)
            ]
        }
        
        return try await executeCatalogProductListQuery(
            query,
            variables: variables,
            expectedDataType: "products"
        )
    }
    
    /// Get product by ID
    public func getProductById(id: String, includeCustomFields: Bool? = nil) async throws -> Product {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleProductQuery(
            byId: true,
            includeCustomFields: shouldIncludeCustomFields
        )
        
        let variables: [String: AnyCodable] = [
            "id": AnyCodable(id)
        ]
        
        return try await executeProductQuery(
            query,
            variables: variables,
            expectedDataType: "product"
        )
    }
    
    /// Get product by slug
    public func getProductBySlug(slug: String, includeCustomFields: Bool? = nil) async throws -> Product {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildSingleProductQuery(
            byId: false,
            includeCustomFields: shouldIncludeCustomFields
        )
        
        let variables: [String: AnyCodable] = [
            "slug": AnyCodable(slug)
        ]
        
        return try await executeProductQuery(
            query,
            variables: variables,
            expectedDataType: "product"
        )
    }
    
    /// Search catalog
    public func searchCatalog(input: SearchInput, includeCustomFields: Bool? = nil) async throws -> SearchResult {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "SearchResult", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSearchQuery(includeCustomFields: shouldIncludeCustomFields)
        
        let variables: [String: AnyCodable] = [
            "input": AnyCodable(anyValue: input)
        ]
        
        return try await executeSearchResultQuery(
            query,
            variables: variables,
            expectedDataType: "search"
        )
    }
}
