import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public actor SystemOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
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
        
        return try await vendure.custom.queryList(query, responseType: Country.self, expectedDataType: "availableCountries")
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
        
        let variables: [String: Any] = ["options": options as Any]
        return try await vendure.custom.query(query, variables: variables, responseType: FacetList.self, expectedDataType: "facets")
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
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, responseType: Facet.self, expectedDataType: "facet")
    }
    
    /// Get collections with parent and children
    public func getCollectionListWithParentChildren(options: CollectionListOptions? = nil) async throws -> CollectionList {
        let query = """
        query collections($options: CollectionListOptions) {
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
        
        let variables: [String: Any] = ["options": options as Any]
        return try await vendure.custom.query(query, variables: variables, responseType: CollectionList.self, expectedDataType: "collections")
    }
    
    /// Get collection with parent and children
    public func getCollectionWithParentChildren(id: String) async throws -> Collection {
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
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, responseType: Collection.self, expectedDataType: "collection")
    }
    
    /// Get collection with parent only
    public func getCollectionWithParent(id: String) async throws -> Collection {
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
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, responseType: Collection.self, expectedDataType: "collection")
    }
    
    /// Get collection with children only
    public func getCollectionWithChildren(id: String) async throws -> Collection {
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
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, responseType: Collection.self, expectedDataType: "collection")
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
        
        let variables = ["input": input]
        return try await vendure.custom.query(query, variables: variables, responseType: SearchResponse.self, expectedDataType: "search")
    }
}
