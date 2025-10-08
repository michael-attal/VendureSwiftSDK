import Foundation

public actor SystemOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    // MARK: - Generic query execution helper
    
    private func executeQuery<T: Decodable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String,
        decodeTo type: T.Type
    ) async throws -> T {
        let response = try await vendure.custom.queryRaw(query, variables: variables)
        
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
              let targetData = responseData[expectedDataType]
        else {
            throw VendureError.decodingError(
                NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) response"])
            )
        }
        
        let extractedData = try JSONSerialization.data(withJSONObject: targetData, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: extractedData)
    }
    
    // MARK: - Countries
    
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
        
        let response = try await vendure.custom.queryRaw(query, variables: nil)
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
              let countriesArray = responseData["availableCountries"] as? [Any]
        else {
            throw VendureError.decodingError(
                NSError(domain: "SystemOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid availableCountries response"])
            )
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try countriesArray.map { itemData in
            let data = try JSONSerialization.data(withJSONObject: itemData, options: [])
            return try decoder.decode(Country.self, from: data)
        }
    }
    
    // MARK: - Facets
    
    public func getFacets(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil
    ) async throws -> PaginatedList<Facet> {
        let query = """
        query facets($options: PaginatedListOptions) {
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
        
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        
        return try await executeQuery(
            query,
            variables: variables,
            expectedDataType: "facets",
            decodeTo: PaginatedList<Facet>.self
        )
    }
    
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
        
        return try await executeQuery(
            query,
            variables: ["id": AnyCodable(id)],
            expectedDataType: "facet",
            decodeTo: Facet.self
        )
    }
    
    // MARK: - Collections
    
    public func getCollectionListWithParentChildren(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil
    ) async throws -> PaginatedList<VendureCollection> {
        let query = """
        query collections($options: PaginatedListOptions) {
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
        
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]
        
        return try await executeQuery(
            query,
            variables: variables,
            expectedDataType: "collections",
            decodeTo: PaginatedList<VendureCollection>.self
        )
    }
    
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
        return try await executeQuery(
            query,
            variables: ["id": AnyCodable(id)],
            expectedDataType: "collection",
            decodeTo: VendureCollection.self
        )
    }
    
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
        return try await executeQuery(
            query,
            variables: ["id": AnyCodable(id)],
            expectedDataType: "collection",
            decodeTo: VendureCollection.self
        )
    }
    
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
        return try await executeQuery(
            query,
            variables: ["id": AnyCodable(id)],
            expectedDataType: "collection",
            decodeTo: VendureCollection.self
        )
    }
    
    // MARK: - Search
    
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
                focalPoint { x y }
              }
              productVariantAsset {
                id
                preview
                focalPoint { x y }
              }
              price {
                ... on PriceRange { min max }
                ... on SinglePrice { value }
              }
              priceWithTax {
                ... on PriceRange { min max }
                ... on SinglePrice { value }
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
        
        return try await executeQuery(
            query,
            variables: ["input": AnyCodable(anyValue: input)],
            expectedDataType: "search",
            decodeTo: SearchResponse.self
        )
    }
}
