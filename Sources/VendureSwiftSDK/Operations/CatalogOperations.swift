import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public actor CatalogOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Get collections
    public func getCollections(options: CollectionListOptions? = nil) async throws -> CollectionList {
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
              }
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
            totalItems
          }
        }
        """
        
        let variables: [String: Any] = ["options": options as Any]
        return try await vendure.custom.query(query, variables: variables, responseType: CollectionList.self, expectedDataType: "collections")
    }
    
    /// Get collection by ID
    public func getCollectionById(id: String) async throws -> Collection {
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
            }
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
    
    /// Get collection by slug
    public func getCollectionBySlug(slug: String) async throws -> Collection {
        let query = """
        query collection($slug: String!) {
          collection(slug: $slug) {
            id
            name
            slug
            description
            parent {
              id
              name
            }
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
        
        let variables = ["slug": slug]
        return try await vendure.custom.query(query, variables: variables, responseType: Collection.self, expectedDataType: "collection")
    }
    
    /// Get products
    public func getProducts(options: ProductListOptions? = nil) async throws -> ProductList {
        let query = """
        query products($options: ProductListOptions) {
          products(options: $options) {
            items {
              id
              name
              slug
              description
              featuredAsset {
                id
                preview
                source
              }
              variants {
                id
                name
                price
                priceWithTax
                currencyCode
                sku
                stockLevel
              }
            }
            totalItems
          }
        }
        """
        
        // Handle nil options properly to avoid JSONSerialization issues
        let variables: [String: Any]
        if let options = options {
            variables = ["options": options]
        } else {
            variables = [:]
        }
        return try await vendure.custom.query(query, variables: variables, responseType: ProductList.self, expectedDataType: "products")
    }
    
    /// Get product by ID
    public func getProductById(id: String) async throws -> Product {
        let query = """
        query product($id: ID!) {
          product(id: $id) {
            id
            name
            slug
            description
            featuredAsset {
              id
              preview
              source
            }
            variants {
              id
              name
              price
              priceWithTax
              currencyCode
              sku
              stockLevel
            }
          }
        }
        """
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, responseType: Product.self, expectedDataType: "product")
    }
    
    /// Get product by slug
    public func getProductBySlug(slug: String) async throws -> Product {
        let query = """
        query product($slug: String!) {
          product(slug: $slug) {
            id
            name
            slug
            description
            featuredAsset {
              id
              preview
              source
            }
            variants {
              id
              name
              price
              priceWithTax
              currencyCode
              sku
              stockLevel
            }
          }
        }
        """
        
        let variables = ["slug": slug]
        return try await vendure.custom.query(query, variables: variables, responseType: Product.self, expectedDataType: "product")
    }
    
    /// Search catalog
    public func searchCatalog(input: SearchInput) async throws -> SearchResult {
        let query = """
        query search($input: SearchInput!) {
          search(input: $input) {
            items {
              productId
              productName
              productAsset {
                id
                preview
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
              sku
              slug
              collectionIds
              score
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
        return try await vendure.custom.query(query, variables: variables, responseType: SearchResult.self, expectedDataType: "search")
    }
}
