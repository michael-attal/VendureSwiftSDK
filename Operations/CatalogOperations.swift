import Foundation

public actor CatalogOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Helper method to execute query and decode CollectionList - SKIP compatible
    private func executeCollectionListQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> CollectionList {
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: variablesJSON
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
    
    /// Helper method to execute query and decode VendureCollection - SKIP compatible
    private func executeCollectionQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> VendureCollection {
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: variablesJSON
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
    
    /// Helper method to execute query and decode CatalogProductList - SKIP compatible
    private func executeCatalogProductListQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> CatalogProductList {
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: variablesJSON
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
    
    /// Helper method to execute query and decode Product - SKIP compatible
    private func executeProductQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> Product {
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: variablesJSON
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
    
    /// Helper method to execute query and decode SearchResult - SKIP compatible
    private func executeSearchResultQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> SearchResult {
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: variablesJSON
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
        
        var variablesJSON: String? = nil
        if let options = options {
            let encoder = JSONEncoder()
            encoder.outputFormatting = []
            if let optionsData = try? encoder.encode(options),
               let optionsJSONString = String(data: optionsData, encoding: .utf8) {
                variablesJSON = """
                {
                    "options": \(optionsJSONString)
                }
                """
            }
        } else {
            variablesJSON = """
            {
                "options": null
            }
            """
        }
        
        return try await executeCollectionListQuery(
            query,
            variablesJSON: variablesJSON,
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
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        return try await executeCollectionQuery(
            query,
            variablesJSON: variablesJSON,
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
        
        let variablesJSON = """
        {
            "slug": "\(slug)"
        }
        """
        
        return try await executeCollectionQuery(
            query,
            variablesJSON: variablesJSON,
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
        
        var variablesJSON: String? = nil
        if let options = options {
            let encoder = JSONEncoder()
            encoder.outputFormatting = []
            if let optionsData = try? encoder.encode(options),
               let optionsJSONString = String(data: optionsData, encoding: .utf8) {
                variablesJSON = """
                {
                    "options": \(optionsJSONString)
                }
                """
            }
        } else {
            variablesJSON = """
            {
                "options": null
            }
            """
        }
        
        return try await executeCatalogProductListQuery(
            query,
            variablesJSON: variablesJSON,
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
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        return try await executeProductQuery(
            query,
            variablesJSON: variablesJSON,
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
        
        let variablesJSON = """
        {
            "slug": "\(slug)"
        }
        """
        
        return try await executeProductQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "product"
        )
    }
    
    /// Search catalog
    public func searchCatalog(input: SearchInput, includeCustomFields: Bool? = nil) async throws -> SearchResult {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "SearchResult", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSearchQuery(includeCustomFields: shouldIncludeCustomFields)
        
        // Convert SearchInput to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        let inputData = try encoder.encode(input)
        let inputJSON = String(data: inputData, encoding: .utf8) ?? "{}"
        
        let variablesJSON = """
        {
            "input": \(inputJSON)
        }
        """
        
        return try await executeSearchResultQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "search"
        )
    }
}
