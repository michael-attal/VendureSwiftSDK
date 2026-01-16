// VendureSwiftSDK/Core/GraphQLQueryBuilder.swift
import Foundation

// MARK: - GraphQL Query Builder System

/// GraphQL query builder with support for custom fields for primary and nested types.
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

    /// Helper function to conditionally return the translations fragment string
    private static func translationsFragment(
        shouldAddTranslationsFragment: Bool = true,
        allFields: Bool = false,
        contentFieldOnly: Bool = false,
        nameFieldOnly: Bool = false,
        slugFieldOnly: Bool = false,
        descriptionFieldOnly: Bool = false,
        contentNameFieldsOnly: Bool = false,
        contentDescriptionFieldsOnly: Bool = false,
        contentSlugFieldsOnly: Bool = false,
        contentNameDescriptionFieldsOnly: Bool = false,
        contentNameSlugFieldsOnly: Bool = false,
        nameSlugDescriptionFieldsOnly: Bool = false,
        contentNameSlugDescriptionFieldsOnly: Bool = false,
        includeIDField: Bool = false
    ) -> String {
        if shouldAddTranslationsFragment == false {
            return ""
        }

        if allFields {
            return "translations {\(includeIDField ? " id" : "") languageCode name slug description }\n"
        } else if contentFieldOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content }\n"
        } else if nameFieldOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode name }\n"
        } else if slugFieldOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode slug }\n"
        } else if descriptionFieldOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode description }\n"
        } else if contentNameFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content name }\n"
        } else if contentSlugFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content slug }\n"
        } else if contentDescriptionFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content description }\n"
        } else if contentNameDescriptionFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content name description }\n"
        } else if contentNameSlugFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content name slug }\n"
        } else if nameSlugDescriptionFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode name slug description }\n"
        } else if contentNameSlugDescriptionFieldsOnly {
            return "translations {\(includeIDField ? " id" : "") languageCode content name slug description }\n"
        }
        return "translations {\(includeIDField ? " id" : "") languageCode name }\n"
    }

    // MARK: - Facet Queries

    /// Build a GraphQL query to get facets with paginated generic options.
    /// Controls inclusion of custom fields for Facet and nested FacetValue.
    public static func buildFacetQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true, // For Facet
        includeValueCustomFields: Bool = true, // For FacetValue
        baseFields: [String] = ["id", "name", "code", "isPrivate", "languageCode"],
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query facets(\(param("options", "FacetListOptions"))) {\n" // GQL type name
        query += "  facets(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        query += """
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
        """

        query += """
              values {
                id name code
                \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
        """

        // Inject custom fields for FacetValue
        if includeValueCustomFields {
            let valueFields = VendureConfiguration.shared.injectCustomFields(for: "FacetValue")
            if !valueFields.isEmpty { query += "\n        \(valueFields)" }
        }
        query += "      }\n" // Close values block

        // Inject custom fields for Facet
        if includeCustomFields {
            let facetFields = VendureConfiguration.shared.injectCustomFields(for: "Facet")
            if !facetFields.isEmpty { query += "      \(facetFields)\n" }
        }
        query += """
            }
            totalItems
            # Add other PaginatedList fields if needed (e.g., totalPages)
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single facet by ID.
    /// Controls inclusion of custom fields for Facet and nested FacetValue.
    public static func buildSingleFacetQuery(
        includeCustomFields: Bool = true, // For Facet
        includeValueCustomFields: Bool = true, // For FacetValue
        baseFields: [String] = ["id", "name", "code", "isPrivate", "languageCode"],
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query facet(\(param("id", "ID!"))) {\n"
        query += "  facet(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        query += """
            \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
        """

        query += """
            values {
              id name code
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
        """
        // Inject custom fields for FacetValue
        if includeValueCustomFields {
            let valueFields = VendureConfiguration.shared.injectCustomFields(for: "FacetValue")
            if !valueFields.isEmpty { query += "\n        \(valueFields)" }
        }
        query += "      }\n" // Close values block

        // Inject custom fields for Facet
        if includeCustomFields {
            let facetFields = VendureConfiguration.shared.injectCustomFields(for: "Facet")
            if !facetFields.isEmpty { query += "      \(facetFields)\n" }
        }
        query += """
          }
        }
        """
        return query
    }

    // MARK: - Asset Queries

    /// Build a GraphQL query to get assets with paginated generic options.
    public static func buildAssetQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true, // For Asset
        baseFields: [String] = ["id", "name", "type", "mimeType", "width", "height", "fileSize", "source", "preview", "focalPoint { x y }"],
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query assets(\(param("options", "AssetListOptions"))) {\n" // GQL type name
        query += "  assets(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        query += "      tags { id value }\n" // Include tags

        // Inject custom fields for Asset
        if includeCustomFields {
            let customFields = VendureConfiguration.shared.injectCustomFields(for: "Asset")
            if !customFields.isEmpty { query += "      \(customFields)\n" }
        }
        query += """
            }
            totalItems
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single asset by ID.
    public static func buildSingleAssetQuery(
        includeCustomFields: Bool = true, // For Asset
        baseFields: [String] = ["id", "name", "type", "mimeType", "width", "height", "fileSize", "source", "preview", "focalPoint { x y }", "createdAt", "updatedAt"],
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query asset(\(param("id", "ID!"))) {\n"
        query += "  asset(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        query += "    tags { id value }\n" // Include tags

        if includeCustomFields {
            let customFields = VendureConfiguration.shared.injectCustomFields(for: "Asset")
            if !customFields.isEmpty { query += "    \(customFields)\n" }
        }
        query += """
          }
        }
        """
        return query
    }

    // MARK: - Order Queries

    /// Build a GraphQL query to get orders with paginated generic options.
    /// Controls inclusion of custom fields for Order, Customer, OrderLine, ProductVariant, Product.
    public static func buildOrderQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true,
        includeCustomerCustomFields: Bool = true,
        includeLineCustomFields: Bool = true,
        includeVariantCustomFields: Bool = true,
        includeProductCustomFields: Bool = true,
        baseFields: [String] = ["id", "code", "state", "active", "currencyCode", "totalQuantity", "subTotal", "subTotalWithTax", "shipping", "shippingWithTax", "total", "totalWithTax", "createdAt", "updatedAt", "orderPlacedAt"],
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query orders(\(param("options", "OrderListOptions"))) {\n" // GQL type name
        query += "  orders(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        query += """
              couponCodes
              discounts { adjustmentSource type description amount amountWithTax }
              # promotions { id name } # Keep minimal in list view?
              customer {
                id firstName lastName emailAddress title phoneNumber
                \(includeCustomerCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Customer") : "")
              }
              shippingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber }
              billingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber }
              shippingLines { id price priceWithTax shippingMethod { id code name } }
              # payments { id method amount state } # Keep minimal in list view?
              lines {
                id quantity unitPrice unitPriceWithTax linePrice linePriceWithTax discountedLinePrice discountedLinePriceWithTax
                featuredAsset { id preview source }
                productVariant {
                  id name sku price priceWithTax stockLevel
                  featuredAsset { id preview source }
                  # assets { id preview source } # Maybe too verbose for list view
                  options { id code name }
                  product {
                    id name slug
                    featuredAsset { id preview source }
                    \(includeProductCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Product") : "")
                  }
                  \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                }
                \(includeLineCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "OrderLine") : "")
              }
        """

        // Inject custom fields for Order
        if includeCustomFields {
            let orderCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty { query += "      \(orderCustomFields)\n" }
        }

        query += """
            }
            totalItems
          }
        }
        """
        return query
    }

    /// Build a GraphQL query to get a single order by ID or Code.
    /// Controls inclusion of custom fields for Order, Customer, OrderLine, ProductVariant, Product.
    public static func buildSingleOrderQuery(
        byCode: Bool = false, // If true, uses orderByCode(code: $code), else order(id: $id)
        includeCustomFields: Bool = true, // For Order
        includeCustomerCustomFields: Bool = true,
        includeLineCustomFields: Bool = true,
        includeVariantCustomFields: Bool = true,
        includeProductCustomFields: Bool = true,
        baseFields: [String] = ["id", "code", "active", "state", "currencyCode", "totalQuantity", "subTotal", "subTotalWithTax", "shipping", "shippingWithTax", "total", "totalWithTax", "createdAt", "updatedAt", "orderPlacedAt"],
        includeAllTranslations: Bool = false
    ) async -> String {
        let lookupField = byCode ? "code" : "id"
        let lookupType = byCode ? "String!" : "ID!"
        let queryName = byCode ? "orderByCode" : "order"

        var query = "query \(queryName)(\(param(lookupField, lookupType))) {\n"
        query += "  \(queryName)(\(lookupField): \(arg(lookupField))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        query += """
            couponCodes
            discounts { adjustmentSource type description amount amountWithTax }
            fulfillments { id state method trackingCode createdAt lines { orderLineId quantity } } # Added fulfillments
            history(options: { sort: { createdAt: ASC } }) { items { id type createdAt data } totalItems } # Added history
            promotions { id name description couponCode } # More promotion details
            surcharges { id description sku price priceWithTax taxRate } # Added surcharges
            taxSummary { description taxRate taxBase taxTotal } # Added taxSummary
            type # Added order type
            customer {
              id firstName lastName emailAddress title phoneNumber
              \(includeCustomerCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Customer") : "")
            }
            shippingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber countryCode } # Added countryCode
            billingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber countryCode } # Added countryCode
            shippingLines {
              id price priceWithTax discountedPrice discountedPriceWithTax # Added discounted prices
              taxLines { description taxRate } # Added taxLines
              shippingMethod { id code name description } # More shipping method details
            }
            payments {
                id transactionId amount method state errorMessage metadata createdAt updatedAt
                refunds { id total reason state items shipping adjustment paymentId metadata } # Added refunds
            }
            lines {
              id quantity unitPrice unitPriceWithTax linePrice linePriceWithTax discountedLinePrice discountedLinePriceWithTax
              featuredAsset { id preview source name type mimeType } # More asset details
              discounts { adjustmentSource type description amount amountWithTax } # Discounts per line
              taxLines { description taxRate } # TaxLines per line
              productVariant {
                id name sku price priceWithTax currencyCode stockLevel enabled trackInventory stockOnHand stockAllocated outOfStockThreshold useGlobalOutOfStockThreshold
                featuredAsset { id preview source name type mimeType }
                assets { id preview source name type mimeType }
                options { id code name group { id name } } # Include option group
                facetValues { id name code facet { id name } } # Include facet values
                 \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                product {
                  id name slug description enabled
                  featuredAsset { id preview source name type mimeType }
                  assets { id preview source name type mimeType }
                  optionGroups { id name options { id name } }
                  facetValues { id name code facet { id name } }
                  \(includeProductCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Product") : "")
                }
              }
              \(includeLineCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "OrderLine") : "")
            }
        """

        // Inject custom fields for Order
        if includeCustomFields {
            let orderCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Order")
            if !orderCustomFields.isEmpty { query += "    \(orderCustomFields)\n" }
        }

        query += """
          }
        }
        """
        return query
    }

    static func buildAddItemToOrderMutation(
        includeCustomFields: Bool = true, // For Order
        includeVariantCustomFields: Bool = true // For ProductVariant

    ) async -> String {
        var query = """
        mutation addItemToOrder($productVariantId: ID!, $quantity: Int!) {
          addItemToOrder(productVariantId: $productVariantId, quantity: $quantity) {
            __typename
            ... on Order {
              id code active state totalQuantity subTotal subTotalWithTax shipping shippingWithTax total totalWithTax currencyCode
              lines {
                id quantity linePrice linePriceWithTax
                productVariant {
                  id name sku price priceWithTax
                  \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                }
                # Add OrderLine custom fields if needed
              }
              \(includeCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Order") : "")
            }
            ... on InsufficientStockError { errorCode message quantityAvailable order { id } }
            ... on NegativeQuantityError { errorCode message }
            ... on OrderLimitError { errorCode message maxItems }
            ... on OrderModificationError { errorCode message } # Added
            ... on NoActiveOrderError { errorCode message } # Added
          }
        }
        """
        return query
    }

    // Ensure this builder exists and is updated
    static func buildActiveOrderQuery(
        includeCustomFields: Bool = true, // For Order
        includeLineCustomFields: Bool = true,
        includeVariantCustomFields: Bool = true,
        includeProductCustomFields: Bool = true,
        includeCustomerCustomFields: Bool = true
    ) async -> String {
        var query = """
        query activeOrder {
          activeOrder {
            __typename # Important for union type handling
            ... on Order {
                id code active state createdAt updatedAt orderPlacedAt currencyCode
                totalQuantity subTotal subTotalWithTax shipping shippingWithTax total totalWithTax
                couponCodes
                discounts { adjustmentSource type description amount amountWithTax }
                promotions { id name } # Basic promotion info
                customer {
                    id firstName lastName emailAddress title phoneNumber
                    \(includeCustomerCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Customer") : "")
                }
                shippingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber }
                billingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber }
                shippingLines {
                    id price priceWithTax
                    shippingMethod { id code name }
                }
                payments { id method amount state transactionId createdAt }
                lines {
                    id quantity unitPrice unitPriceWithTax linePrice linePriceWithTax discountedLinePrice discountedLinePriceWithTax
                    featuredAsset { id preview source }
                    productVariant {
                        id name sku price priceWithTax stockLevel
                        featuredAsset { id preview source }
                        assets { id preview source }
                        options { id code name }
                        product {
                            id name slug description
                            featuredAsset { id preview source }
                             \(includeProductCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Product") : "")
                        }
                         \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                    }
                     \(includeLineCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "OrderLine") : "")
                }
                 \(includeCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Order") : "")
            }
            ... on NoActiveOrderError { # Handle specific error case
                errorCode
                message
            }
          }
        }
        """
        return query
    }

    // MARK: - Customer Queries

    /// Build a GraphQL query to get customers with paginated generic options.
    /// Controls inclusion of custom fields for Customer and nested Address.
    public static func buildCustomerQuery(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool = true, // For Customer
        includeAddressCustomFields: Bool = true, // For Address
        baseFields: [String] = ["id", "title", "firstName", "lastName", "emailAddress", "phoneNumber", "createdAt", "updatedAt"]
    ) async -> String {
        var query = "query customers(\(param("options", "CustomerListOptions"))) {\n" // GQL type name
        query += "  customers(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        query += """
              user { id identifier verified lastLogin } # Basic user info
              # groups { items { id name } totalItems } # Optional groups
              addresses {
                id fullName company streetLine1 streetLine2 city province postalCode
                country { id code name } # Include country object
                phoneNumber defaultShippingAddress defaultBillingAddress
                \(includeAddressCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Address") : "")
              }
              # orders(options: { take: 5, sort: { createdAt: DESC } }) { items { id code state totalWithTax } totalItems } # Optional recent orders
        """

        // Inject custom fields for Customer
        if includeCustomFields {
            // Prefer extended fields if configured
            let customerExtended = VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            if !customerExtended.isEmpty {
                for field in customerExtended {
                    query += "      \(field.graphQLFragment)\n"
                }
            } else {
                let customerCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Customer")
                if !customerCustomFields.isEmpty { query += "      \(customerCustomFields)\n" }
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

    /// Build a GraphQL query to get a single customer by ID.
    /// Controls inclusion of custom fields for Customer and nested Address.
    public static func buildSingleCustomerQuery(
        includeCustomFields: Bool = true, // For Customer
        includeAddressCustomFields: Bool = true, // For Address
        baseFields: [String] = ["id", "title", "firstName", "lastName", "phoneNumber", "emailAddress", "createdAt", "updatedAt"]
    ) async -> String {
        var query = "query customer(\(param("id", "ID!"))) {\n"
        query += "  customer(id: \(arg("id"))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        query += """
            user {
              id identifier verified lastLogin
              roles { id code description permissions } # Include roles
              authenticationMethods { id strategy } # Include auth methods
              # Add User custom fields if needed
            }
            # groups { items { id name } totalItems } # Optional groups
            addresses {
              id fullName company streetLine1 streetLine2 city province postalCode
              country { id code name enabled } # Include country object with enabled status
              phoneNumber defaultShippingAddress defaultBillingAddress createdAt updatedAt
              \(includeAddressCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Address") : "")
            }
            # orders(options: { take: 10, sort: { createdAt: DESC } }) { items { id code state totalWithTax createdAt } totalItems } # Optional recent orders
        """

        // Inject custom fields for Customer
        if includeCustomFields {
            let customerExtended = VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
            if !customerExtended.isEmpty {
                for field in customerExtended {
                    query += "    \(field.graphQLFragment)\n"
                }
            } else {
                let customerCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Customer")
                if !customerCustomFields.isEmpty { query += "    \(customerCustomFields)\n" }
            }
        }

        query += """
          }
        }
        """
        return query
    }

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
            let customerCustomFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
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
            let customerCustomFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "Customer")
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

    // MARK: - Product Queries

    /// Build a GraphQL query to get products.
    /// Controls inclusion of custom fields for Product and nested ProductVariant.
    public static func buildProductQuery(
        includeCustomFields: Bool = true, // For Product
        includeVariantCustomFields: Bool = true, // For Variant
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        baseFields: [String] = ["id", "name", "slug", "description", "enabled", "createdAt", "updatedAt"],
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query products(\(param("options", "ProductListOptions"))) {\n" // GQL type name
        query += "  products(options: \(arg("options"))) {\n"
        query += "    items {\n"
        for field in baseFields {
            query += "      \(field)\n"
        }

        query += """
              languageCode # Added languageCode
              featuredAsset { id preview source name type mimeType }
              assets { id preview source name type mimeType }
              optionGroups { id name options { id name } } # Added option groups
              facetValues { id name code facet { id name } } # Added facet values
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameSlugDescriptionFieldsOnly: true))
              variants {
                id name sku price priceWithTax currencyCode stockLevel # enabled
                # stockOnHand stockAllocated trackInventory # Added inventory fields
                featuredAsset { id preview source name type mimeType }
                assets { id preview source name type mimeType }
                options { id code name }
                facetValues { id name code facet { id name } }
                \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
                \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
              }
        """

        // Inject custom fields for Product
        if includeCustomFields {
            let customFieldsFragment = VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !customFieldsFragment.isEmpty { query += "      \(customFieldsFragment)\n" }
        }

        query += """
            }
            totalItems
          }
        }
        """

        return query
    }

    /// Build a GraphQL query to get a product by ID or slug.
    /// Controls inclusion of custom fields for Product and nested ProductVariant.
    public static func buildSingleProductQuery(
        byId: Bool = true,
        includeCustomFields: Bool = true, // For Product
        includeVariantCustomFields: Bool = true, // For Variant
        baseFields: [String] = ["id", "name", "slug", "description", "enabled", "createdAt", "updatedAt"],
        includeAllTranslations: Bool = false
    ) async -> String {
        let parameterName = byId ? "id" : "slug"
        let parameterType = byId ? "ID!" : "String!"

        var query = "query product(\(param(parameterName, parameterType))) {\n"
        query += "  product(\(parameterName): \(arg(parameterName))) {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        query += """
            languageCode # Added languageCode
            featuredAsset { id name type fileSize mimeType width height source preview focalPoint { x y } tags { id value } createdAt updatedAt } # Detailed Asset
            assets { id name type fileSize mimeType width height source preview focalPoint { x y } tags { id value } createdAt updatedAt } # Detailed Asset
            optionGroups {
              id code name createdAt updatedAt languageCode
              options { id code name groupId \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true)) } # Include translations
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
            }
            facetValues {
              id name code createdAt updatedAt facetId
              facet { id name code isPrivate }
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
            }
            \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameSlugDescriptionFieldsOnly: true))
            variants {
              id name sku price priceWithTax currencyCode stockLevel enabled createdAt updatedAt languageCode
              stockOnHand stockAllocated trackInventory outOfStockThreshold useGlobalOutOfStockThreshold # Added inventory fields
              featuredAsset { id name type fileSize mimeType width height source preview focalPoint { x y } tags { id value } createdAt updatedAt } # Detailed Asset
              assets { id name type fileSize mimeType width height source preview focalPoint { x y } tags { id value } createdAt updatedAt } # Detailed Asset
              options {
                id code name groupId
                group { id name } # Include group object
                \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
              }
              facetValues {
                id name code facet { id name }
                \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
              }
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameFieldOnly: true))
              \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
            }
        """

        // Inject custom fields for Product
        if includeCustomFields {
            let productCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Product")
            if !productCustomFields.isEmpty { query += "\n    \(productCustomFields)" }
        }

        query += """
          }
        }
        """
        return query
    }

    // MARK: - Search Queries

    /// Building a search query with Stellate cache support.
    /// Does not currently include custom fields in SearchResultItem.
    public static func buildSearchQuery(includeCustomFields: Bool = false) -> String {
        var query = "query search(\(param("input", "SearchInput!"))) {\n"
        query += "  search(input: \(arg("input"))) {\n"
        // ... (Stellate cacheIdentifier logic) ...
        if VendureConfiguration.shared.isUsingStellateCache { query += "    cacheIdentifier { collectionSlug }\n" }
        query += """
            items {
              productId productName productVariantId productVariantName sku slug description currencyCode score
              productAsset { id preview focalPoint { x y } }
              productVariantAsset { id preview focalPoint { x y } }
              price { ... on PriceRange { min max } ... on SinglePrice { value } }
              priceWithTax { ... on PriceRange { min max } ... on SinglePrice { value } }
              collectionIds facetIds facetValueIds
            }
            totalItems
            facetValues {
              count
              facetValue { id name facet { id name } }
            }
          }
        }
        """
        // Note: If includeCustomFields is true, this query doesn't actually add them for search results.
        // The SearchResultItem type would need `customFields: [String: AnyCodable]?` and the query adapted.
        if includeCustomFields {
            Task { await VendureLogger.shared.log(.warning, category: "GraphQL", "buildSearchQuery was called with includeCustomFields=true, but SearchResultItem does not currently support custom fields in this query.") }
        }
        return query
    }

    // MARK: - Collection Queries

    /// Building a GraphQL query to get collections.
    /// Controls inclusion of custom fields for Collection and potentially nested ProductVariants.
    public static func buildCollectionQuery(
        includeCustomFields: Bool = true, // For Collection
        includeVariantCustomFields: Bool = true, // For ProductVariant if products included (though not standard)
        detailed: Bool = false,
        includeProducts: Bool = false, // Add flag to include products (not standard in basic list)
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = "query collections(\(param("options", "CollectionListOptions"))) {\n" // GQL type name
        query += "  collections(options: \(arg("options"))) {\n"
        query += "    items {\n"
        query += "      id name slug description languageCode createdAt updatedAt\n" // Added fields

        if detailed {
            query += """
                  breadcrumbs { id name slug }
                  position isRoot parentId
            """
        }

        query += """
              parent { id name slug } # Include slug
              children { id name slug } # Include slug
              featuredAsset { id preview source name type mimeType } # More detail
              assets { id preview source name type mimeType } # Added assets field
              \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameSlugDescriptionFieldsOnly: true))
        """

        // Optional: Include product variants if requested (might be heavy for a list)
        if includeProducts {
            await VendureLogger.shared.log(.warning, category: "GraphQL", "Including product variants in collection list query can be performance intensive.")
            query += """

                productVariants(options: { take: 5 }) { # Limit included variants
                  items {
                    id name sku price priceWithTax currencyCode stockLevel
                    product { id name slug featuredAsset { id preview } }
                    \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                  }
                  totalItems
                }
            """
        }

        // Inject custom fields for Collection
        if includeCustomFields {
            let collectionCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Collection")
            if !collectionCustomFields.isEmpty { query += "      \(collectionCustomFields)\n" }
        }

        query += """
            }
            totalItems
          }
        }
        """

        return query
    }

    /// Build a GraphQL query to get a collection by ID or slug.
    /// Controls inclusion of custom fields for Collection and nested ProductVariants.
    public static func buildSingleCollectionQuery(
        byId: Bool = true,
        includeCustomFields: Bool = true, // For Collection
        includeProducts: Bool = false,
        includeVariantCustomFields: Bool = true, // For ProductVariant if products included
        includeAllTranslations: Bool = false
    ) async -> String {
        let parameterName = byId ? "id" : "slug"
        let parameterType = byId ? "ID!" : "String!"

        var query = "query collection(\(param(parameterName, parameterType))) {\n"
        query += "  collection(\(parameterName): \(arg(parameterName))) {\n"
        query += """
            id name slug description languageCode createdAt updatedAt # Added fields
            breadcrumbs { id name slug }
            position isRoot parentId # Added isRoot
            parent { id name slug } # Include slug
            children { id name slug } # Include slug
            featuredAsset { id name type fileSize mimeType width height source preview focalPoint { x y } tags { id value } } # Detailed Asset
            assets { id name type fileSize mimeType width height source preview focalPoint { x y } tags { id value } } # Detailed Asset
            \(translationsFragment(shouldAddTranslationsFragment: includeAllTranslations, nameSlugDescriptionFieldsOnly: true))
        """

        if includeProducts {
            query += """

                productVariants(options: { take: 50 }) { # Allow more variants on single view
                  items {
                    id name sku price priceWithTax currencyCode stockLevel enabled # Added enabled
                    featuredAsset { id preview source }
                    assets { id preview source }
                    options { id code name }
                    product {
                      id name slug description enabled # Added enabled
                      featuredAsset { id preview source }
                      # Add product custom fields if needed
                    }
                    \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                  }
                  totalItems
                }
            """
        }

        // Inject custom fields for Collection
        if includeCustomFields {
            let collectionCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Collection")
            if !collectionCustomFields.isEmpty { query += "    \(collectionCustomFields)\n" }
        }

        query += """
          }
        }
        """
        return query
    }

    // MARK: - Channel Queries

    /// Build a GraphQL query to get the active channel.
    /// Controls inclusion of custom fields for Channel.
    public static func buildActiveChannelQuery(
        includeCustomFields: Bool = true,
        baseFields: [String] = ["id", "code", "token", "currencyCode", "defaultLanguageCode", "availableLanguageCodes", "pricesIncludeTax"]
    ) async -> String {
        var query = "query activeChannel {\n"
        query += "  activeChannel {\n"
        for field in baseFields {
            query += "    \(field)\n"
        }

        // Inject custom fields for Channel
        if includeCustomFields {
            let channelCustomFields = VendureConfiguration.shared.injectCustomFields(for: "Channel")
            if !channelCustomFields.isEmpty { query += "    \(channelCustomFields)\n" }
        }

        query += """
          }
        }
        """
        return query
    }

    // MARK: - Order Mutations

    // Add builders for other mutations like adjustOrderLine, removeOrderLine etc. if needed,
    // controlling custom field inclusion in their response payloads similarly. Example:

    /// Build a mutation for adjustOrderLine, controlling custom fields in the response Order.
    public static func buildAdjustOrderLineMutation(
        includeCustomFields: Bool = true, // For Order
        includeLineCustomFields: Bool = true,
        includeVariantCustomFields: Bool = true,
        includeAllTranslations: Bool = false
    ) async -> String {
        var query = """
        mutation adjustOrderLine($orderLineId: ID!, $quantity: Int!) {
          adjustOrderLine(orderLineId: $orderLineId, quantity: $quantity) {
            __typename
            ... on Order {
              id code state totalQuantity subTotal subTotalWithTax total totalWithTax # Totals
              lines {
                id quantity linePrice linePriceWithTax
                productVariant { id name sku price priceWithTax # Name might be localized
                     \(includeVariantCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                 }
                  \(includeLineCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "OrderLine") : "")
              }
               \(includeCustomFields ? VendureConfiguration.shared.injectCustomFields(for: "Order") : "")
            }
            ... on InsufficientStockError { errorCode message quantityAvailable order { id } }
            ... on NegativeQuantityError { errorCode message }
            ... on OrderModificationError { errorCode message }
            ... on OrderLimitError { errorCode message maxItems }
            ... on NoActiveOrderError { errorCode message }
          }
        }
        """
        return query
    }
}
