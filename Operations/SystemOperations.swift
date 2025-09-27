import Foundation

public actor SystemOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Helper method to execute query and decode FacetList - SKIP compatible
    private func executeFacetListQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> FacetList {
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(FacetList.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode Facet - SKIP compatible
    private func executeFacetQuery(
        _ query: String,
        variablesJSON: String?,
        expectedDataType: String
    ) async throws -> Facet {
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Facet.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode VendureCollection - SKIP compatible
    private func executeVendureCollectionQuery(
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(VendureCollection.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode CollectionList - SKIP compatible
    private func executeSystemCollectionListQuery(
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CollectionList.self, from: extractedData)
    }
    
    /// Helper method to execute query and decode SearchResult - SKIP compatible
    private func executeSystemSearchResultQuery(
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType] else {
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"]))
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(SearchResult.self, from: extractedData)
    }
    
    /// Get available countries
    public func getAvailableCountries() async throws -> [Country] {
        let query = """
        query availableCountries {
          availableCountries {
            id
            code
            name
            enabled
            translations {
              id
              languageCode
              name
            }
          }
        }
        """
        
        // Use queryRaw and decode manually for SKIP compatibility
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: nil
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract availableCountries array from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let countriesArray = responseData["availableCountries"] as? [Any] else {
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid availableCountries response"]))
        }
        
        // Decode each country
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var countries: [Country] = []
        for countryData in countriesArray {
            let itemData = try JSONSerialization.data(withJSONObject: countryData, options: [])
            let country = try decoder.decode(Country.self, from: itemData)
            countries.append(country)
        }
        
        return countries
    }
    
    /// Get facets
    public func getFacets(options: FacetListOptions? = nil) async throws -> FacetList {
        let query = """
        query facets($options: FacetListOptions) {
          facets(options: $options) {
            items {
              id
              name
              code
              isPrivate
              languageCode
              translations {
                id
                languageCode
                name
              }
              values {
                id
                name
                code
                translations {
                  id
                  languageCode
                  name
                }
              }
            }
            totalItems
          }
        }
        """
        
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
        
        return try await executeFacetListQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "facets"
        )
    }
    
    /// Get facet by ID
    public func getFacet(id: String) async throws -> Facet {
        let query = """
        query facet($id: ID!) {
          facet(id: $id) {
            id
            name
            code
            isPrivate
            languageCode
            translations {
              id
              languageCode
              name
            }
            values {
              id
              name
              code
              translations {
                id
                languageCode
                name
              }
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        return try await executeFacetQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "facet"
        )
    }
    
    /// Get collections with parent and children
    public func getCollectionListWithParentChildren(options: VendureCollectionListOptions? = nil) async throws -> CollectionList {
        let query = """
        query collections($options: VendureCollectionListOptions) {
          collections(options: $options) {
            items {
              id
              name
              slug
              description
              parent {
                id
                name
                slug
                parent {
                  id
                  name
                  slug
                }
              }
              children {
                id
                name
                slug
                children {
                  id
                  name
                  slug
                }
              }
              featuredAsset {
                id
                preview
                source
              }
            }
            totalItems
          }
        }
        """
        
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
        
        return try await executeSystemCollectionListQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "collections"
        )
    }
    
    /// Get collection with parent and children
    public func getCollectionWithParentChildren(id: String) async throws -> VendureCollection {
        let query = """
        query collection($id: ID!) {
          collection(id: $id) {
            id
            name
            slug
            description
            parent {
              id
              name
              slug
              parent {
                id
                name
                slug
              }
            }
            children {
              id
              name
              slug
              children {
                id
                name
                slug
              }
            }
            featuredAsset {
              id
              preview
              source
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        return try await executeVendureCollectionQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "collection"
        )
    }
    
    /// Get collection with parent only
    public func getCollectionWithParent(id: String) async throws -> VendureCollection {
        let query = """
        query collection($id: ID!) {
          collection(id: $id) {
            id
            name
            slug
            description
            parent {
              id
              name
              slug
            }
            featuredAsset {
              id
              preview
              source
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        return try await executeVendureCollectionQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "collection"
        )
    }
    
    /// Get collection with children only
    public func getCollectionWithChildren(id: String) async throws -> VendureCollection {
        let query = """
        query collection($id: ID!) {
          collection(id: $id) {
            id
            name
            slug
            description
            children {
              id
              name
              slug
            }
            featuredAsset {
              id
              preview
              source
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        return try await executeVendureCollectionQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "collection"
        )
    }
    
    /// Search catalog
    public func searchCatalog(input: SearchInput) async throws -> SearchResponse {
        let query = """
        query search($input: SearchInput!) {
          search(input: $input) {
            items {
              productId
              productName
              productVariantId
              productVariantName
              sku
              slug
              productAsset {
                id
                preview
                focalPoint {
                  x
                  y
                }
              }
              productVariantAsset {
                id
                preview
                focalPoint {
                  x
                  y
                }
              }
              price {
                ... on PriceRange {
                  min
                  max
                }
                ... on SinglePrice {
                  value
                }
              }
              priceWithTax {
                ... on PriceRange {
                  min
                  max
                }
                ... on SinglePrice {
                  value
                }
              }
              currencyCode
              description
              facetIds
              facetValueIds
              collectionIds
            }
            totalItems
            facetValues {
              count
              facetValue {
                id
                name
                facet {
                  id
                  name
                }
              }
            }
          }
        }
        """
        
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
        
        return try await executeSystemSearchResultQuery(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "search"
        )
    }
}
