import Foundation

// MARK: - GraphQL Query Builder System

/// GraphQL query builder with support for custom fields
public class GraphQLQueryBuilder {
    
    /// Build a GraphQL query to get products
    public static func buildProductQuery(
        includeCustomFields: Bool = true,
        options: ProductListOptions? = nil,
        baseFields: [String] = [
            "id", "name", "slug", "description", "enabled"
        ]
    ) -> String {
        var query = """
        query products($options: ProductListOptions) {
          products(options: $options) {
            items {
        """
        
        // Add the basic fields
        for field in baseFields {
            query += "\n              \(field)"
        }
        
        // Add the basic assets
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
              }
        """
        
        // Inject custom fields
        if includeCustomFields {
            let customFieldsFragment = VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !customFieldsFragment.isEmpty {
                query += "\n              \(customFieldsFragment)"
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
    ) -> String {
        let parameterName = byId ? "id" : "slug"
        let parameterType = byId ? "ID!" : "String!"
        
        var query = """
        query product($\(parameterName): \(parameterType)) {
          product(\(parameterName): $\(parameterName)) {
        """
        
        // Add the basic fields
        for field in baseFields {
            query += "\n            \(field)"
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
              enabled
              featuredAsset {
                id
                preview
                source
              }
        """
        
        // Inject custom fields for ProductVariant
        if includeCustomFields {
            let variantCustomFields = VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n              \(variantCustomFields)"
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
        
        // Injecter les champs personnalisés pour Product
        if includeCustomFields {
            let productCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !productCustomFields.isEmpty {
                query += "\n            \(productCustomFields)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    /// Building a search query with custom fields
    public static func buildSearchQuery(includeCustomFields: Bool = true) -> String {
        var query = """
        query search($input: SearchInput!) {
          search(input: $input) {
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
        """
        
        // For searching, you can include custom fields from SearchResultItem.
        // Note: Custom fields in search are limited according to the Vendure API.
        
        query += """
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
    
    /// Building a GraphQL query to get collections
    public static func buildCollectionQuery(
        includeCustomFields: Bool = true,
        detailed: Bool = false
    ) -> String {
        var query = """
        query collections($options: CollectionListOptions) {
          collections(options: $options) {
            items {
              id
              name
              slug
              description
        """
        
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
            let collectionCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Collection")
            if !collectionCustomFields.isEmpty {
                query += "\n              \(collectionCustomFields)"
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
    ) -> String {
        let parameterName = byId ? "id" : "slug"
        let parameterType = byId ? "ID!" : "String!"
        
        var query = """
        query collection($\(parameterName): \(parameterType)) {
          collection(\(parameterName): $\(parameterName)) {
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
                let variantCustomFields = VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
                if !variantCustomFields.isEmpty {
                    query += "\n                \(variantCustomFields)"
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
            let collectionCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Collection")
            if !collectionCustomFields.isEmpty {
                query += "\n            \(collectionCustomFields)"
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
    public static func buildActiveOrderQuery(includeCustomFields: Bool = true) -> String {
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
            let customerCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Customer")
            if !customerCustomFields.isEmpty {
                query += "\n              \(customerCustomFields)"
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
            let productCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !productCustomFields.isEmpty {
                query += "\n                  \(productCustomFields)"
            }
        }
        
        query += """
                }
        """
        
        // Inject custom fields for ProductVariant into OrderLine
        if includeCustomFields {
            let variantCustomFields = VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n                \(variantCustomFields)"
            }
        }
        
        query += """
              }
            }
        """
        
        // Inject custom fields for Order
        if includeCustomFields {
            let orderCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty {
                query += "\n            \(orderCustomFields)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    /// Build a mutation for addItemToOrder with custom fields
    public static func buildAddItemToOrderMutation(includeCustomFields: Bool = true) -> String {
        var query = """
        mutation addItemToOrder($productVariantId: ID!, $quantity: Int!) {
          addItemToOrder(productVariantId: $productVariantId, quantity: $quantity) {
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
            let variantCustomFields = VendureConfiguration.shared.injectCustomFields(for: "ProductVariant")
            if !variantCustomFields.isEmpty {
                query += "\n                  \(variantCustomFields)"
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
            let orderCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty {
                query += "\n              \(orderCustomFields)"
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
    public static func buildActiveCustomerQuery(includeCustomFields: Bool = true) -> String {
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
        """
        
        // Custom fields are always included for Customer
        query += "\n            customFields"
        
        // Inject extended custom fields for Customer
        if includeCustomFields {
            let customerCustomFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            for field in customerCustomFields {
                query += "\n            \(field.graphQLFragment)"
            }
        }
        
        query += """
          }
        }
        """
        
        return query
    }
    
    /// Build a mutation for updateCustomer with custom fields
    public static func buildUpdateCustomerMutation(includeCustomFields: Bool = true) -> String {
        var query = """
        mutation updateCustomer($input: UpdateCustomerInput!) {
          updateCustomer(input: $input) {
            id
            title
            firstName
            lastName
            phoneNumber
            emailAddress
        """
        
        // Inject customFields and extended fields for Customer
        if includeCustomFields {
            query += "\n            customFields"
            let customerCustomFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            for field in customerCustomFields {
                query += "\n            \(field.graphQLFragment)"
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
extension VendureConfiguration {
    
    // Note: shouldIncludeCustomFields method is defined in CustomFieldConfiguration.swift
    
    /// Get the list of types that have custom fields configured
    public func getTypesWithCustomFields() -> Set<String> {
        let allTypes = Set(customFields.flatMap { $0.applicableTypes })
        return allTypes
    }
    
    /// Verify whether a configuration is valid for production
    public func validateConfiguration() -> [String] {
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
