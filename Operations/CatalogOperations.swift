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
    /// Manually captures mainUsdzAsset and other unknown fields for Skip compatibility
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
        
        // Extract and process the products list with unknown fields capture
        // First cast targetData to [String: Any] for Skip compatibility
        guard let targetDict = targetData as? [String: Any],
              let itemsData = targetDict["items"] as? [[String: Any]] else {
            throw VendureError.decodingError(NSError(domain: "CatalogOps", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid items array in response"]))
        }
        
        let totalItems = targetDict["totalItems"] as? Int ?? 0
        
        // Process each product to extract unknown fields manually
        var processedItems: [[String: Any]] = []
        for productDict in itemsData {
            let processedItem = await extractUnknownFieldsFromProduct(productDict)
            processedItems.append(processedItem)
        }
        
        // Reconstruct the response with processed items
        let processedTargetData: [String: Any] = [
            "items": processedItems,
            "totalItems": totalItems
        ]
        
        print("[UnknownFields] About to serialize processed data with \(processedItems.count) items")
        
        do {
            let extractedData = try JSONSerialization.data(withJSONObject: processedTargetData, options: [])
            
            // Debug: print a safe preview of the reconstructed JSON
            if let jsonString = String(data: extractedData, encoding: .utf8) {
                let safePreview = String(jsonString.prefix(200)).replacingOccurrences(of: "\n", with: "\\n")
                print("[UnknownFields] Reconstructed JSON preview (200 chars): \(safePreview)...")
                print("[UnknownFields] Total JSON size: \(extractedData.count) bytes")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            print("[UnknownFields] About to decode CatalogProductList from \(extractedData.count) bytes")
            let result = try decoder.decode(CatalogProductList.self, from: extractedData)
            print("[UnknownFields] ✅ Successfully decoded CatalogProductList with \(result.items.count) items")
            return result
        } catch {
            print("[UnknownFields] ❌ Failed to decode CatalogProductList: \(error)")
            if let decodingError = error as? DecodingError {
                print("[UnknownFields] DecodingError details: \(decodingError)")
            }
            throw error
        }
    }
    
    /// Extract unknown fields from a product dictionary and inject them as custom fields
    /// Skip-compatible: uses only basic types and no generics
    private func extractUnknownFieldsFromProduct(_ productDict: [String: Any]) async -> [String: Any] {
        var processedProduct = productDict
        
        print("[UnknownFields] Processing product \(productDict["id"] ?? "unknown") with \(productDict.count) total fields")
        print("[UnknownFields] All fields in product: \(Array(productDict.keys).sorted())")
        
        // Known CatalogProduct fields that should NOT be treated as unknown
        // Based on CatalogProduct struct definition in ProductTypes.swift
        let knownProductFields = Set([
            "id", "name", "slug", "description", "enabled", 
            "featuredAsset", "variants", "customFields"
        ])
        
        print("[UnknownFields] Known fields: \(knownProductFields.sorted())")
        
        // Extract unknown fields from product level
        var unknownProductFields: [String: Any] = [:]
        for (key, value) in productDict {
            let isKnown = knownProductFields.contains(key)
            print("[UnknownFields] Field '\(key)': isKnown=\(isKnown), value=\(type(of: value))")
            
            if !isKnown {
                unknownProductFields[key] = value
                print("[UnknownFields] ✅ Added unknown product field: \(key) = \(String(describing: value).prefix(100))")
            }
        }
        
        // Process variants to extract their unknown fields too
        if let variants = productDict["variants"] as? [[String: Any]] {
            var processedVariants: [[String: Any]] = []
            for variantDict in variants {
                let processedVariant = await extractUnknownFieldsFromVariant(variantDict)
                processedVariants.append(processedVariant)
            }
            processedProduct["variants"] = processedVariants
        }
        
        // If we found unknown fields, encode them as JSON and store in customFields
        if !unknownProductFields.isEmpty {
            do {
                // Try with preferred options first, fallback to basic options if not supported
                var jsonData: Data
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: unknownProductFields, options: [.fragmentsAllowed, .withoutEscapingSlashes])
                } catch {
                    print("[UnknownFields] Fallback: Using basic JSON serialization options")
                    jsonData = try JSONSerialization.data(withJSONObject: unknownProductFields, options: [])
                }
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("[UnknownFields] Serialized unknown fields as JSON (\(jsonData.count) bytes): \(String(jsonString.prefix(100)))...")
                    // Merge with existing customFields if any
                    if let existingCustomFields = processedProduct["customFields"] as? String,
                       !existingCustomFields.isEmpty {
                        // Parse existing custom fields and merge
                        if let existingData = existingCustomFields.data(using: .utf8),
                           let existingDict = try? JSONSerialization.jsonObject(with: existingData) as? [String: Any] {
                            var mergedFields = existingDict
                            for (key, value) in unknownProductFields {
                                mergedFields[key] = value
                            }
                            let mergedData: Data
                            do {
                                mergedData = try JSONSerialization.data(withJSONObject: mergedFields, options: [.fragmentsAllowed, .withoutEscapingSlashes])
                            } catch {
                                mergedData = try JSONSerialization.data(withJSONObject: mergedFields, options: [])
                            }
                            if let mergedString = String(data: mergedData, encoding: .utf8) {
                                processedProduct["customFields"] = mergedString
                            }
                        } else {
                            processedProduct["customFields"] = jsonString
                        }
                    } else {
                        processedProduct["customFields"] = jsonString
                    }
                    print("[UnknownFields] Captured \(unknownProductFields.count) unknown fields for product \(productDict["id"] ?? "unknown")")
                }
            } catch {
                print("[UnknownFields] Failed to serialize unknown fields: \(error)")
            }
        }
        
        // Apply custom field transformation via hook
        // Note: Skip transformer for now due to Sendable requirements
        // Will be applied at the application layer instead
        
        // Add empty unknownFields for CatalogProduct Codable compatibility
        processedProduct["unknownFields"] = ["fieldNames": [], "fields": [:]]
        
        return processedProduct
    }
    
    /// Extract unknown fields from a variant dictionary
    /// Skip-compatible: uses only basic types and no generics
    private func extractUnknownFieldsFromVariant(_ variantDict: [String: Any]) async -> [String: Any] {
        var processedVariant = variantDict
        
        // Known CatalogProductVariant fields that should NOT be treated as unknown
        let knownVariantFields = Set([
            "id", "name", "sku", "price", "priceWithTax", 
            "currencyCode", "stockLevel", "customFields"
        ])
        
        // Extract unknown fields from variant level
        var unknownVariantFields: [String: Any] = [:]
        for (key, value) in variantDict {
            if !knownVariantFields.contains(key) {
                unknownVariantFields[key] = value
                print("[UnknownFields] Found unknown variant field: \(key)")
            }
        }
        
        // If we found unknown fields, encode them as JSON and store in customFields
        if !unknownVariantFields.isEmpty {
            do {
                // Try with preferred options first, fallback to basic options if not supported
                var jsonData: Data
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: unknownVariantFields, options: [.fragmentsAllowed, .withoutEscapingSlashes])
                } catch {
                    jsonData = try JSONSerialization.data(withJSONObject: unknownVariantFields, options: [])
                }
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // Merge with existing customFields if any
                    if let existingCustomFields = processedVariant["customFields"] as? String,
                       !existingCustomFields.isEmpty {
                        // Parse existing custom fields and merge
                        if let existingData = existingCustomFields.data(using: .utf8),
                           let existingDict = try? JSONSerialization.jsonObject(with: existingData) as? [String: Any] {
                            var mergedFields = existingDict
                            for (key, value) in unknownVariantFields {
                                mergedFields[key] = value
                            }
                            let mergedData: Data
                            do {
                                mergedData = try JSONSerialization.data(withJSONObject: mergedFields, options: [.fragmentsAllowed, .withoutEscapingSlashes])
                            } catch {
                                mergedData = try JSONSerialization.data(withJSONObject: mergedFields, options: [])
                            }
                            if let mergedString = String(data: mergedData, encoding: .utf8) {
                                processedVariant["customFields"] = mergedString
                            }
                        } else {
                            processedVariant["customFields"] = jsonString
                        }
                    } else {
                        processedVariant["customFields"] = jsonString
                    }
                    print("[UnknownFields] Captured \(unknownVariantFields.count) unknown fields for variant \(variantDict["id"] ?? "unknown")")
                }
            } catch {
                print("[UnknownFields] Failed to serialize unknown variant fields: \(error)")
            }
        }
        
        // Apply custom field transformation via hook
        // Note: Skip transformer for now due to Sendable requirements
        // Will be applied at the application layer instead
        
        // Add empty unknownFields for CatalogProductVariant Codable compatibility
        processedVariant["unknownFields"] = ["fieldNames": [], "fields": [:]]
        
        return processedVariant
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
