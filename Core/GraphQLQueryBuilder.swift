import Foundation

// MARK: - GraphQL Query Builder System

/// GraphQL query builder with support for custom fields
public class GraphQLQueryBuilder {
    // MARK: - Helper Methods
    
    /// Helper to handle dollar sign in GraphQL queries for clean architecture
    private static func dollar(_ name: String) -> String {
        return "$" + name
    }
    
    /// Helper to format GraphQL parameter with type
    private static func param(_ name: String, _ type: String) -> String {
        return "\(dollar(name)): \(type)"
    }
    
    /// Helper to format GraphQL argument usage
    private static func arg(_ name: String) -> String {
        return dollar(name)
    }

    // MARK: - Facet Queries

    /// Build a GraphQL query to get facets with paginated generic options
    public static func buildFacetQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "name", "code"]
    ) async -> String {
        var query = "query facets(\(param("options", "FacetListOptions"))) {\n"
        query += "  facets(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }
        if includeCustomFields {
            let customFields = await VendureConfiguration.shared.injectCustomFields(for: "Facet")
            if !customFields.isEmpty {
                query += "\n      \(customFields)"
            }
        }
        query += """
            }
            totalItems
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single facet by ID
    public static func buildSingleFacetQuery(
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "name", "code"]
    ) async -> String {
        var query = "query facet(\(param("id", "ID!"))) {\n"
        query += "  facet(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }
        if includeCustomFields {
            let customFields = await VendureConfiguration.shared.injectCustomFields(for: "Facet")
            if !customFields.isEmpty {
                query += "\n    \(customFields)"
            }
        }
        query += """
          }
        }
        """
        return query
    }

    // MARK: - Asset Queries

    /// Build a GraphQL query to get assets with paginated generic options
    public static func buildAssetQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "name", "type", "preview", "source"]
    ) async -> String {
        var query = "query assets(\(param("options", "AssetListOptions"))) {\n"
        query += "  assets(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }
        if includeCustomFields {
            let customFields = await VendureConfiguration.shared.injectCustomFields(for: "Asset")
            if !customFields.isEmpty {
                query += "\n      \(customFields)"
            }
        }
        query += """
            }
            totalItems
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single asset by ID
    public static func buildSingleAssetQuery(
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "name", "type", "preview", "source"]
    ) async -> String {
        var query = "query asset(\(param("id", "ID!"))) {\n"
        query += "  asset(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }
        if includeCustomFields {
            let customFields = await VendureConfiguration.shared.injectCustomFields(for: "Asset")
            if !customFields.isEmpty {
                query += "\n    \(customFields)"
            }
        }
        query += """
          }
        }
        """
        return query
    }
    
    // MARK: - Order Queries

    /// Build a GraphQL query to get orders with paginated generic options
    public static func buildOrderQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "code", "state", "currencyCode", "total", "totalWithTax", "createdAt", "updatedAt"]
    ) async -> String {
        var query = "query orders(\(param("options", "OrderListOptions"))) {\n"
        query += "  orders(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        // Basic customer block (inject custom fields if requested)
        query += """
              customer {
                id
                firstName
                lastName
                emailAddress
              }
        """

        if includeCustomFields {
            let customerCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Customer")
            if !customerCustomFields.isEmpty {
                query += "\n      \(customerCustomFields)"
            }
        }

        // Addresses
        query += """
              shippingAddress {
                id
                fullName
                company
                streetLine1
                streetLine2
                city
                province
                postalCode
                country
                phoneNumber
              }
              billingAddress {
                id
                fullName
                company
                streetLine1
                streetLine2
                city
                province
                postalCode
                country
                phoneNumber
              }
        """

        // Lines with product/variant info
        query += """
              lines {
                id
                quantity
                linePrice
                linePriceWithTax
                productVariant {
                  id
                  name
                  sku
                  price
                  priceWithTax
                  stockLevel
                  product {
                    id
                    name
                    slug
                  }
                }
              }
        """

        // Inject custom fields for Order if present
        if includeCustomFields {
            let orderCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty {
                query += "\n      \(orderCustomFields)"
            }
        }

        query += """
            }
            totalItems
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single order by ID
    public static func buildSingleOrderQuery(
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "code", "state", "currencyCode", "total", "totalWithTax", "createdAt", "updatedAt", "orderPlacedAt", "totalQuantity"]
    ) async -> String {
        var query = "query order(\(param("id", "ID!"))) {\n"
        query += "  order(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        // Customer with potential custom fields
        query += """
            customer {
              id
              firstName
              lastName
              emailAddress
            }
        """
        if includeCustomFields {
            let customerCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Customer")
            if !customerCustomFields.isEmpty {
                query += "\n    \(customerCustomFields)"
            }
        }

        // Addresses
        query += """
            shippingAddress {
              id
              fullName
              company
              streetLine1
              streetLine2
              city
              province
              postalCode
              country
              phoneNumber
            }
            billingAddress {
              id
              fullName
              company
              streetLine1
              streetLine2
              city
              province
              postalCode
              country
              phoneNumber
            }
        """

        // Lines with more detailed product + variant info
        query += """
            lines {
              id
              quantity
              linePrice
              linePriceWithTax
              productVariant {
                id
                name
                sku
                price
                priceWithTax
                stockLevel
                featuredAsset {
                  id
                  preview
                  source
                }
                product {
                  id
                  name
                  slug
                  description
                }
              }
            }
        """

        // Inject custom fields for Order and Product/ProductVariant if requested
        if includeCustomFields {
            let orderCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty {
                query += "\n    \(orderCustomFields)"
            }

            let productCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !productCustomFields.isEmpty {
                // Place inside product block — safe to add here as fragment inlined
                query += "\n    \(productCustomFields)"
            }

            let variantCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n    \(variantCustomFields)"
            }
        }

        query += """
          }
        }
        """
        return query
    }

    // MARK: - Customer Queries

    /// Build a GraphQL query to get customers with paginated generic options
    public static func buildCustomerQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "firstName", "lastName", "emailAddress", "title"]
    ) async -> String {
        var query = "query customers(\(param("options", "CustomerListOptions"))) {\n"
        query += "  customers(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        // Addresses
        query += """
              addresses {
                id
                fullName
                company
                streetLine1
                streetLine2
                city
                province
                postalCode
                country
                phoneNumber
                defaultShippingAddress
                defaultBillingAddress
              }
        """

        if includeCustomFields {
            // use extended fields helper for customers (if present)
            let customerExtended = await VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            if !customerExtended.isEmpty {
                for field in customerExtended {
                    query += "\n      \(field.graphQLFragment)"
                }
            } else {
                // fallback to injectCustomFields
                let customerCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Customer")
                if !customerCustomFields.isEmpty {
                    query += "\n      \(customerCustomFields)"
                }
            }
        }

        query += """
            }
            totalItems
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single customer by ID
    public static func buildSingleCustomerQuery(
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "title", "firstName", "lastName", "phoneNumber", "emailAddress"]
    ) async -> String {
        var query = "query customer(\(param("id", "ID!"))) {\n"
        query += "  customer(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        // Addresses
        query += """
            addresses {
              id
              fullName
              company
              streetLine1
              streetLine2
              city
              province
              postalCode
              country
              phoneNumber
              defaultShippingAddress
              defaultBillingAddress
            }
        """

        if includeCustomFields {
            let customerExtended = await VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            if !customerExtended.isEmpty {
                for field in customerExtended {
                    query += "\n    \(field.graphQLFragment)"
                }
            } else {
                let customerCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Customer")
                if !customerCustomFields.isEmpty {
                    query += "\n    \(customerCustomFields)"
                }
            }
        }

        query += """
          }
        }
        """
        return query
    }

    // MARK: - Product Queries

    /// Build a GraphQL query to get products
    public static func buildProductQuery(
        includeCustomFields: Bool = true,
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        baseFields: [String] = [
            "id", "name", "slug", "description", "enabled"
        ]
    ) async -> String {
        // Note: GraphQL input type remains `ProductListOptions` in the query string
        // while the Swift-side representation uses the generic `PaginatedListOptions`.
        var query = "query products(\(param("options", "ProductListOptions"))) {\n"
        query += "  products(options: \(arg("options"))) {\n"
        query += "    items {\n"

        // Add the basic fields
        for field in baseFields {
            query += "      \(field)\n"
        }

        // Add the basic assets and variants
        query += """
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
        """

        // Inject custom fields for ProductVariant in catalog query
        if includeCustomFields {
            let variantCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n        \(variantCustomFields)"
            }
        }

        query += """
              }
        """

        // Inject custom fields for Product
        if includeCustomFields {
            let customFieldsFragment = await VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !customFieldsFragment.isEmpty {
                query += "\n      \(customFieldsFragment)"
            }
        }

        query += """
            }
            totalItems
          }
        }
        """

        return query
    }

    /// Build a GraphQL query to get a product by ID or slug
    public static func buildSingleProductQuery(
        byId: Bool = true,
        includeCustomFields: Bool = true,
        baseFields: [String] = [
            "id", "name", "slug", "description", "enabled"
        ]
    ) async -> String {
        let parameterName = byId ? "id" : "slug"
        let parameterType = byId ? "ID!" : "String!"
        
        var query = "query product(\(param(parameterName, parameterType))) {\n"
        query += "  product(\(parameterName): \(arg(parameterName))) {\n"
        
        // Add the basic fields
        for field in baseFields {
            query += "    \(field)\n"
        }
        
        // Add basic assets and detailed variants
        query += """
            featuredAsset {
              id
              preview
              source
              name
              type
              mimeType
            }
            assets {
              id
              preview
              source
              name
              type
              mimeType
            }
            variants {
              id
              name
              price
              priceWithTax
              currencyCode
              sku
              stockLevel
              featuredAsset {
                id
                preview
                source
              }
        """
        
        // Inject custom fields for ProductVariant
        if includeCustomFields {
            let variantCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n      \(variantCustomFields)"
            }
        }
        
        query += """
            }
            optionGroups {
              id
              code
              name
              options {
                id
                code
                name
              }
            }
            facetValues {
              id
              name
              code
              facet {
                id
                name
                code
              }
            }
        """
        
        // Inject custom fields for Product
        if includeCustomFields {
            let productCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !productCustomFields.isEmpty {
                query += "\n    \(productCustomFields)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    // MARK: - Search Queries
    
    /// Building a search query with custom fields with Stellate cache support
    public static func buildSearchQuery(includeCustomFields: Bool = true) -> String {
        var query = "query search(\(param("input", "SearchInput!"))) {\n"
        query += "  search(input: \(arg("input"))) {\n"
        
        if VendureConfiguration.shared.isUsingStellateCache {
            // Add cacheIdentifier for Stellate cache optimization
            query += """
                cacheIdentifier {
                  collectionSlug
                }
            """
        }
        
        query += """
            items {
              productId
              productName
              productAsset {
                id
                preview
              }
              productVariantId
              productVariantName
              productVariantAsset {
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
              currencyCode
              description
              slug
              sku
              collectionIds
              facetIds
              facetValueIds
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
        
        return query
    }
    
    // MARK: - Collection Queries
    
    /// Building a GraphQL query to get collections
    public static func buildCollectionQuery(
        includeCustomFields: Bool = true,
        detailed: Bool = false
    ) async -> String {
        var query = "query collections(\(param("options", "CollectionListOptions"))) {\n"
        query += "  collections(options: \(arg("options"))) {\n"
        query += "    items {\n"
        query += "      id\n"
        query += "      name\n"
        query += "      slug\n"
        query += "      description\n"
        
        if detailed {
            query += """
                  breadcrumbs {
                    id
                    name
                    slug
                  }
                  position
                  isRoot
                  parentId
                
            """
        }
        
        query += """
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
        """
        
        // Inject custom fields for Collection
        if includeCustomFields {
            let collectionCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Collection")
            if !collectionCustomFields.isEmpty {
                query += "\n      \(collectionCustomFields)"
            }
        }
        
        query += """
            }
            totalItems
          }
        }
        """
        
        return query
    }
    
    /// Build a GraphQL query to get a collection by ID or slug
    public static func buildSingleCollectionQuery(
        byId: Bool = true,
        includeCustomFields: Bool = true,
        includeProducts: Bool = false
    ) async -> String {
        let parameterName = byId ? "id" : "slug"
        let parameterType = byId ? "ID!" : "String!"
        
        var query = "query collection(\(param(parameterName, parameterType))) {\n"
        query += "  collection(\(parameterName): \(arg(parameterName))) {\n"
        query += """
            id
            name
            slug
            description
            breadcrumbs {
              id
              name
              slug
            }
            position
            isRoot
            parentId
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
              name
              type
              mimeType
            }
        """
        
        if includeProducts {
            query += """
            
                productVariants {
                  items {
                    id
                    name
                    sku
                    price
                    priceWithTax
                    currencyCode
                    stockLevel
                    product {
                      id
                      name
                      slug
                      featuredAsset {
                        id
                        preview
                        source
                      }
                    }
            """
            
            // Custom fields for ProductVariant in collections
            if includeCustomFields {
                let variantCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
                if !variantCustomFields.isEmpty {
                    query += "\n        \(variantCustomFields)"
                }
            }
            
            query += """
                  }
                  totalItems
                }
            """
        }
        
        // Inject custom fields for Collection
        if includeCustomFields {
            let collectionCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Collection")
            if !collectionCustomFields.isEmpty {
                query += "\n    \(collectionCustomFields)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    // MARK: - Order Queries
    
    /// Build a GraphQL query for getActiveOrder
    public static func buildActiveOrderQuery(includeCustomFields: Bool = true) async -> String {
        var query = """
        query activeOrder {
          activeOrder {
            id
            code
            active
            createdAt
            updatedAt
            orderPlacedAt
            state
            currencyCode
            totalQuantity
            subTotal
            subTotalWithTax
            shipping
            shippingWithTax
            total
            totalWithTax
            customer {
              id
              firstName
              lastName
              emailAddress
        """
        
        // Inject custom fields for Customer in Order
        if includeCustomFields {
            let customerCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Customer")
            if !customerCustomFields.isEmpty {
                query += "\n      \(customerCustomFields)"
            }
        }
        
        query += """
            }
            shippingAddress {
              id
              fullName
              company
              streetLine1
              streetLine2
              city
              province
              postalCode
              country
              phoneNumber
            }
            billingAddress {
              id
              fullName
              company
              streetLine1
              streetLine2
              city
              province
              postalCode
              country
              phoneNumber
            }
            lines {
              id
              quantity
              linePrice
              linePriceWithTax
              productVariant {
                id
                name
                price
                priceWithTax
                sku
                product {
                  id
                  name
                  slug
                  description
        """
        
        // Inject custom fields for Product in OrderLine
        if includeCustomFields {
            let productCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !productCustomFields.isEmpty {
                query += "\n          \(productCustomFields)"
            }
        }
        
        query += """
                }
        """
        
        // Inject custom fields for ProductVariant into OrderLine
        if includeCustomFields {
            let variantCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n        \(variantCustomFields)"
            }
        }
        
        query += """
              }
            }
        """
        
        // Inject custom fields for Order
        if includeCustomFields {
            let orderCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty {
                query += "\n    \(orderCustomFields)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    /// Build a mutation for addItemToOrder with custom fields
    public static func buildAddItemToOrderMutation(includeCustomFields: Bool = true) async -> String {
        var query = "mutation addItemToOrder("
        query += "\(param("productVariantId", "ID!")), "
        query += "\(param("quantity", "Int!"))"
        query += ") {\n"
        query += "  addItemToOrder("
        query += "productVariantId: \(arg("productVariantId")), "
        query += "quantity: \(arg("quantity"))"
        query += ") {\n"
        query += """
            __typename
            ... on Order {
              id
              code
              active
              lines {
                id
                quantity
                linePrice
                linePriceWithTax
                productVariant {
                  id
                  name
                  price
                  priceWithTax
                  sku
        """
        
        // Inject custom fields for ProductVariant
        if includeCustomFields {
            let variantCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n          \(variantCustomFields)"
            }
        }
        
        query += """
                }
              }
              totalQuantity
              subTotal
              subTotalWithTax
              shipping
              shippingWithTax
              total
              totalWithTax
        """
        
        // Inject custom fields for Order
        if includeCustomFields {
            let orderCustomFields = await VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty {
                query += "\n      \(orderCustomFields)"
            }
        }
        
        query += """
            }
            ... on InsufficientStockError {
              errorCode
              message
              quantityAvailable
            }
            ... on NegativeQuantityError {
              errorCode
              message
            }
            ... on OrderLimitError {
              errorCode
              message
              maxItems
            }
          }
        }
        """
        
        return query
    }
    
    // MARK: - Customer Queries
    
    /// Build a GraphQL query for getActiveCustomer
    public static func buildActiveCustomerQuery(includeCustomFields: Bool = true) async -> String {
        var query = """
        query activeCustomer {
          activeCustomer {
            id
            title
            firstName
            lastName
            phoneNumber
            emailAddress
            addresses {
              id
              fullName
              company
              streetLine1
              streetLine2
              city
              province
              postalCode
              country
              phoneNumber
              defaultShippingAddress
              defaultBillingAddress
            }
            customFields
        """
        
        // Inject extended custom fields for Customer
        if includeCustomFields {
            let customerCustomFields = await VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            for field in customerCustomFields {
                query += "\n    \(field.graphQLFragment)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    /// Build a mutation for updateCustomer with custom fields
    public static func buildUpdateCustomerMutation(includeCustomFields: Bool = true) async -> String {
        var query = "mutation updateCustomer(\(param("input", "UpdateCustomerInput!"))) {\n"
        query += "  updateCustomer(input: \(arg("input"))) {\n"
        query += """
            id
            title
            firstName
            lastName
            phoneNumber
            emailAddress
            customFields
        """
        
        // Inject extended fields for Customer
        if includeCustomFields {
            let customerCustomFields = await VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            for field in customerCustomFields {
                query += "\n    \(field.graphQLFragment)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
}

// MARK: - Helper Extensions for Operations

/// Extension to help manage custom fields in operations
public extension VendureConfiguration {
    // Note: shouldIncludeCustomFields method is defined in CustomFieldConfiguration.swift
    
    /// Get the list of types that have custom fields configured
    func getTypesWithCustomFields() -> Set<String> {
        let allTypes = Set(customFields.flatMap { $0.applicableTypes })
        return allTypes
    }
    
    /// Verify whether a configuration is valid for production
    func validateConfiguration() -> [String] {
        var warnings: [String] = []
        
        let fields = customFields
        
        // Check for overly complex fragments
        for field in fields {
            let fragmentLength = field.graphQLFragment.count
            if fragmentLength > 1000 {
                warnings.append("Fragment for '\(field.fieldName)' is very long (\(fragmentLength) chars). Consider simplifying.")
            }
            
            // Check nesting levels
            let nestingLevel = field.graphQLFragment.components(separatedBy: "{").count - 1
            if nestingLevel > 5 {
                warnings.append("Fragment for '\(field.fieldName)' has deep nesting (level \(nestingLevel)). This might impact performance.")
            }
        }
        
        // Check for potential duplicates
        let extendedFields = fields.filter { $0.isExtendedField }
        let fieldNames = extendedFields.map { "\($0.fieldName)-\($0.applicableTypes.joined(separator: ","))" }
        let uniqueNames = Set(fieldNames)
        if fieldNames.count != uniqueNames.count {
            warnings.append("Potential duplicate extended field configurations detected.")
        }
        
        return warnings
    }
}
