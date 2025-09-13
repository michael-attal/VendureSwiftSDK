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
    public func getCollections(options: CollectionListOptions? = nil, includeCustomFields: Bool? = nil) async throws -> CollectionList {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildCollectionQuery(includeCustomFields: shouldIncludeCustomFields)
        
        let variables: [String: Any] = ["options": options as Any]
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "collections", responseType: CollectionList.self)
    }
    
    /// Get collection by ID
    public func getCollectionById(id: String, includeCustomFields: Bool? = nil, includeProducts: Bool = false) async throws -> Collection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSingleCollectionQuery(
            byId: true,
            includeCustomFields: shouldIncludeCustomFields,
            includeProducts: includeProducts
        )
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "collection", responseType: Collection.self)
    }
    
    /// Get collection by slug
    public func getCollectionBySlug(slug: String, includeCustomFields: Bool? = nil, includeProducts: Bool = false) async throws -> Collection {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Collection", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSingleCollectionQuery(
            byId: false,
            includeCustomFields: shouldIncludeCustomFields,
            includeProducts: includeProducts
        )
        
        let variables = ["slug": slug]
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "collection", responseType: Collection.self)
    }
    
    /// Get products
    public func getProducts(options: ProductListOptions? = nil, includeCustomFields: Bool? = nil) async throws -> CatalogProductList {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildProductQuery(
            includeCustomFields: shouldIncludeCustomFields,
            options: options
        )
        
        // Handle nil options properly to avoid JSONSerialization issues
        let variables: [String: Any]
        if let options = options {
            variables = ["options": options]
        } else {
            variables = [:]
        }
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "products", responseType: CatalogProductList.self)
    }
    
    /// Get product by ID
    public func getProductById(id: String, includeCustomFields: Bool? = nil) async throws -> Product {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSingleProductQuery(
            byId: true,
            includeCustomFields: shouldIncludeCustomFields
        )
        
        let variables = ["id": id]
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "product", responseType: Product.self)
    }
    
    /// Get product by slug
    public func getProductBySlug(slug: String, includeCustomFields: Bool? = nil) async throws -> Product {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSingleProductQuery(
            byId: false,
            includeCustomFields: shouldIncludeCustomFields
        )
        
        let variables = ["slug": slug]
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "product", responseType: Product.self)
    }
    
    /// Search catalog
    public func searchCatalog(input: SearchInput, includeCustomFields: Bool? = nil) async throws -> SearchResult {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "SearchResult", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildSearchQuery(includeCustomFields: shouldIncludeCustomFields)
        
        let variables = ["input": input]
        return try await vendure.custom.query(query, variables: variables, expectedDataType: "search", responseType: SearchResult.self)
    }
}
