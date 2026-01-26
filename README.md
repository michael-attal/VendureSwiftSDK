# VendureSwiftSDK

A modern Swift SDK for interacting with the Vendure e-commerce framework's GraphQL API. Built with Swift 6 and modern concurrency patterns, this SDK provides type-safe access to Vendure APIs with full AnyCodable support for flexible JSON handling.

## Features

- ✅ **Apple Platforms**: Native support for iOS, macOS, watchOS, tvOS, visionOS
- ✅ **Swift 6 Ready**: Built with modern concurrency, actors, and structured concurrency
- ✅ **Type-Safe**: Comprehensive type definitions with automatic Codable synthesis
- ✅ **Modern Swift Patterns**: Uses AnyCodable for flexible JSON, computed properties, and clean APIs
- ✅ **Custom Fields**: Flexible custom field system using `[String: AnyCodable]` dictionaries
- ✅ **Authentication**: Multiple auth strategies with secure token management
- ✅ **Complete API Coverage**: Support for all major Vendure operations (orders, products, customers, etc.)
- ✅ **Error Handling**: Comprehensive error handling with descriptive error types
- ✅ **Extensible**: Clean extension points for project-specific customizations
- ✅ **Vapor Compatible**: Perfect integration with Vapor server-side Swift projects

## Requirements

- **Swift**: 6.0 or later
- **Platforms**: iOS 18.0+, macOS 15.0+, visionOS 2.0+, watchOS 11.0+, tvOS 18.0+
- **Xcode**: 16.0 or later

## Installation

### Swift Package Manager (iOS/Apple Platforms)

Add VendureSwiftSDK to your project using Swift Package Manager:

```swift
// Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [.iOS(.v18), .macOS(.v15), .visionOS(.v2)],
    products: [
        .library(name: "YourTarget", type: .dynamic, targets: ["YourTarget"]),
    ],
    dependencies: [
        .package(url: "https://github.com/michael-attal/VendureSwiftSDK.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: ["VendureSwiftSDK"]
        )
    ]
)
```

### Swift Package Manager

This SDK uses modern Swift patterns including:
- **Automatic Codable synthesis** for clean type definitions
- **AnyCodable** for flexible JSON handling
- **Structured concurrency** with async/await
- **Computed properties** for clean APIs
- **Extension-based customization** for project-specific needs

## Quick Start

### Basic Initialization

```swift
import VendureSwiftSDK

// Initialize with direct token
let vendure = try await VendureSwiftSDK.initialize(
    endpoint: "https://your-vendure-api.com/shop-api",
    token: "your-auth-token"
)

print("Vendure SDK initialized successfully")
```

### Authentication Methods

#### Guest Session (No Authentication Required)
```swift
let vendure = try await VendureSwiftSDK.initialize(
    endpoint: "https://your-vendure-api.com/shop-api",
    useGuestSession: true
)

print("Guest session initialized")
```

#### With Channel Token
```swift
let vendure = try await VendureSwiftSDK.initialize(
    endpoint: "https://your-vendure-api.com/shop-api",
    channelToken: "your-channel-token",
    token: "your-auth-token"
)

print("Vendure initialized with channel token")
```

#### Native Authentication (Username/Password)
```swift
let vendure = try await VendureSwiftSDK.initializeWithNativeAuth(
    endpoint: "https://your-vendure-api.com/shop-api",
    username: "customer@example.com",
    password: "password123"
)

print("Authenticated with native credentials")
```

#### Custom Token Fetcher
```swift
// Define custom token fetcher
let customTokenFetcher: TokenFetcher = { parameters in
    // Your custom authentication logic here
    let apiKey = parameters["apiKey"] as? String ?? ""
    print("Fetching token with API key: \(apiKey)")

    // Return your token
    return "your-custom-token"
}

let vendure = try await VendureSwiftSDK.initializeWithCustomAuth(
    endpoint: "https://your-vendure-api.com/shop-api",
    fetchToken: customTokenFetcher,
    tokenParams: ["apiKey": "your-api-key"]
)

print("Initialized with custom authentication")
```

## Usage Examples

### Order Operations

#### Add Item to Cart
```swift
do {
    let order = try await vendure.order.addItemToOrder(
        productVariantId: "123",
        quantity: 2
    )
    print("Item added to order successfully")
    print("Order code: \(order.code)")
    print("Order total: \(order.total)")
    print("Total items: \(order.totalQuantity)")
} catch VendureError.graphqlError(let messages) {
    print("GraphQL error: \(messages.joined(separator: ", "))")
} catch VendureError.networkError(let message) {
    print("Network error: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

#### Get Active Order
```swift
do {
    let activeOrder = try await vendure.order.getActiveOrder()
    if let order = activeOrder {
        print("Current order code: \(order.code)")
        print("Order state: \(order.state)")
        print("Total items: \(order.totalQuantity)")
    } else {
        print("No active order found")
    }
} catch {
    print("Failed to get active order: \(error)")
}
```

#### Set Shipping Address
```swift
let address = CreateAddressInput(
    streetLine1: "123 Main Street",
    city: "New York",
    postalCode: "10001",
    countryCode: "US"
)

do {
    let order = try await vendure.order.setOrderShippingAddress(input: address)
    print("Shipping address set successfully")
    print("Order state: \(order.state)")
    print("Order code: \(order.code)")
    if let shippingAddress = order.shippingAddress {
        print("Shipping to: \(shippingAddress.streetLine1), \(shippingAddress.city ?? "")")
    }
} catch {
    print("Failed to set shipping address: \(error)")
}
```

#### Add Payment to Order
```swift
let paymentInput = PaymentInput(
    method: "stripe-payment",
    metadata: ["stripe_payment_method": "pm_123456"]
)

do {
    let order = try await vendure.order.addPaymentToOrder(input: paymentInput)
    print("Payment added successfully")
    print("Order state: \(order.state)")
    print("Order completed: \(order.state == "PaymentSettled")")
    if let payments = order.payments {
        print("Total payments: \(payments.count)")
        for payment in payments {
            print("Payment \(payment.id): \(payment.method) - \(payment.state)")
        }
    }
} catch {
    print("Payment failed: \(error)")
}
```

### Catalog Operations

#### Get Products
```swift
let options = ProductListOptions(take: 20)
let productList = try await vendure.catalog.getProducts(options: options)

print("Found \(productList.totalItems) products")
for product in productList.items {
    print("Product: \(product.name) - \(product.slug)")
    print("  Price: \(product.variants.first?.price ?? 0.0)")
    print("  Stock: \(product.variants.first?.stockLevel ?? "Unknown")")
}
```

#### Search Products
```swift
let searchInput = SearchInput(
    term: "electronics",
    take: 10
)

let searchResults = try await vendure.catalog.searchCatalog(input: searchInput)
print("Found \(searchResults.totalItems) products")
```

#### Get Collections
```swift
let collectionList = try await vendure.catalog.getCollections()
print("Found \(collectionList.totalItems) collections")
for collection in collectionList.items {
    print("Collection: \(collection.name) - \(collection.slug)")
    print("  Position: \(collection.position)")
    print("  Is root: \(collection.isRoot)")
}
```

### Customer Operations

#### Get Active Customer
```swift
let customer = try await vendure.customer.getActiveCustomer()
print("Customer: \(customer?.firstName ?? "Anonymous") \(customer?.lastName ?? "")")
```

#### Update Customer
```swift
let updateInput = UpdateCustomerInput(
    firstName: "John",
    lastName: "Doe"
)

let updatedCustomer = try await vendure.customer.updateCustomer(input: updateInput)
```

#### Manage Addresses
```swift
// Create address
let newAddress = CreateAddressInput(
    fullName: "John Doe",
    streetLine1: "456 Oak Avenue",
    city: "San Francisco",
    postalCode: "94105",
    countryCode: "US"
)

let address = try await vendure.customer.createCustomerAddress(input: newAddress)

// Update address
let updateAddress = UpdateAddressInput(
    id: address.id,
    streetLine1: "456 Pine Avenue" // Updated street
)

let updatedAddress = try await vendure.customer.updateCustomerAddress(input: updateAddress)
```

### Authentication Operations

#### Register New Customer
```swift
let registration = RegisterCustomerInput(
    emailAddress: "newcustomer@example.com",
    firstName: "Jane",
    lastName: "Smith",
    password: "securepassword"
)

do {
    let result = try await vendure.auth.registerCustomerAccount(input: registration)
    if result.success {
        print("Customer registered successfully!")
        print("Please check your email for verification")
    } else if let errorCode = result.errorCode {
        print("Registration failed: \(errorCode)")
        if let message = result.message {
            print("Error details: \(message)")
        }
    }
} catch {
    print("Registration error: \(error)")
}
```

#### Login/Logout
```swift
// Login
do {
    let loginResult = try await vendure.auth.login(
        username: "customer@example.com",
        password: "password123",
        rememberMe: true
    )
    
    if let authResult = loginResult.authenticationResult {
        print("Login successful for user: \(authResult.identifier)")
        print("Available channels: \(authResult.channels.count)")
    } else if let errorCode = loginResult.errorCode {
        print("Login failed: \(errorCode)")
        if let message = loginResult.message {
            print("Error details: \(message)")
        }
    }
} catch {
    print("Login error: \(error)")
}

// Logout
do {
    let logoutResult = try await vendure.auth.logout()
    if logoutResult.success {
        print("Logged out successfully")
    }
} catch {
    print("Logout error: \(error)")
}
```

### System Operations

#### Get Available Countries
```swift
let countries = try await vendure.system.getAvailableCountries()
for country in countries {
    print("Country: \(country.name) (\(country.code))")
}
```

### Custom Operations

For advanced use cases, you can execute custom GraphQL operations:

```swift
// Custom Query
let customQuery = """
query MyCustomQuery($id: ID!) {
  product(id: $id) {
    id
    name
    customFields {
      myCustomField
    }
  }
}
"""

struct CustomProductResponse: Codable {
    let id: String
    let name: String
    let customFields: [String: AnyCodable]? // Modern AnyCodable approach
}

let result = try await vendure.custom.query(
    customQuery,
    variables: ["id": "123"],
    responseType: CustomProductResponse.self,
    expectedDataType: "product"
)
```

## Modern Custom Fields with AnyCodable

VendureSwiftSDK uses a modern approach to custom fields with `[String: AnyCodable]?` dictionaries, providing type-safe access while maintaining flexibility for dynamic JSON data.

### Benefits of AnyCodable Approach

- **Type Safety**: Direct access to typed values without JSON parsing
- **Performance**: No JSON serialization/deserialization overhead 
- **Modern Swift**: Uses computed properties and clean APIs
- **Flexible**: Handles any JSON structure with type safety
- **Extensible**: Easy to add project-specific computed properties

### Supported Types

All major Vendure types now include `customFields: [String: AnyCodable]?`:

**Product & Catalog Types:**
- `Product`, `ProductVariant`, `ProductOption`, `ProductOptionGroup`
- `VendureCollection`, `Asset`

**Order & Commerce Types:**
- `Order`, `OrderLine`, `Fulfillment`
- `PaymentMethod`, `ShippingMethod`, `Promotion`

**Customer & System Types:**
- `Customer`, `User`, `CustomerGroup`, `Address`
- `TaxCategory`, `TaxRate`, `Channel`, `Zone`, `Seller`

### Using Custom Fields

The SDK provides multiple ways to access custom field data:

#### Extension Methods (Built-in)
```swift
let product = try await vendure.catalog.getProductById(id: "123")

// Type-safe access using extension methods
if let priority = product.getCustomFieldInt("priority") {
    print("Priority: \(priority)")
}

if let description = product.getCustomFieldString("extendedDescription") {
    print("Description: \(description)")
}

if let isActive = product.getCustomFieldBool("isActive") {
    print("Active: \(isActive)")
}

// Check field existence
if product.hasCustomField("specialOffer") {
    print("Has special offer")
}
```

#### Direct AnyCodable Access
```swift
// Direct dictionary access
if let customFields = product.customFields {
    // Access different types directly
    let rating = customFields["rating"]?.doubleValue ?? 0.0
    let tags = customFields["tags"]?.arrayValue ?? []
    let metadata = customFields["metadata"]?.dictionaryValue ?? [:]
    
    // Handle nested structures
    if let dimensions = customFields["dimensions"]?.dictionaryValue {
        let width = dimensions["width"]?.doubleValue ?? 0.0
        let height = dimensions["height"]?.doubleValue ?? 0.0
        print("Dimensions: \(width) x \(height)")
    }
}
```

#### Project-Specific Extensions
Create your own computed properties for project-specific custom fields:

```swift
// In your app/client module
import VendureSwiftSDK

extension Product {
    /// Access a brand name custom field
    var brandName: String? {
        return getCustomFieldString("brandName")
    }
    
    /// Access loyalty points multiplier
    var loyaltyMultiplier: Double {
        return customFields?["loyaltyMultiplier"]?.doubleValue ?? 1.0
    }
    
    /// Check if the product is a "New Arrival" based on a boolean custom field
    var isNewArrival: Bool {
        return getCustomFieldBool("newArrival") ?? false
    }
}

extension Order {
    /// Access a gift message custom field on the Order
    var giftMessage: String? {
        return getCustomFieldString("giftMessage")
    }
}
```

### Utility Methods

The SDK provides utility methods for working with custom fields:

```swift
// Create custom fields from Any dictionary
let customData: [String: Any] = [
    "rating": 4.5,
    "tags": ["electronics", "mobile"],
    "metadata": ["reviewed": true]
]
let customFields = CustomFieldsUtility.create(customData)

// Update existing custom fields
let updatedFields = CustomFieldsUtility.updateField(
    in: product.customFields,
    key: "lastViewed", 
    value: Date()
)

// Convert to Any dictionary for external APIs
let anyDict = CustomFieldsUtility.toAnyDictionary(product.customFields)
```

## Patterns

This SDK embraces modern Swift development:

- **Swift 6 Concurrency**: Full async/await and structured concurrency support
- **Automatic Codable**: Clean type definitions without manual JSON parsing
- **AnyCodable**: Flexible JSON handling with type safety
- **Computed Properties**: Clean, intuitive APIs
- **Extensions**: Easy customization and project-specific functionality

## Error Handling

```swift
do {
    let products = try await vendure.catalog.getProducts()
    print("Found \(products.totalItems) products")
} catch VendureError.networkError(let message) {
    print("Network error: \(message)")
} catch VendureError.graphqlError(let errors) {
    print("GraphQL errors: \(errors.joined(separator: ", "))")
} catch {
    print("Unexpected error: \(error)")
}
```

## Contributing

Contributions are welcome! This SDK follows modern Swift patterns:

- Use English for all comments and logs
- Embrace Swift 6 concurrency patterns
- Keep type definitions clean with automatic Codable synthesis
- Use AnyCodable for flexible JSON handling
- Create extensions for project-specific functionality

## License

MIT License - see LICENSE file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/michael-attal/VendureSwiftSDK/issues)
- **Documentation**: Inline code documentation
- **Vendure**: [Official Vendure Documentation](https://www.vendure.io/docs/)

---

### Factory Methods

The SDK provides convenient factory methods for common use cases:

```swift
// Extended GraphQL fields
.extendedAssetDetailed(name: "heroImage", applicableTypes: ["Product"])
.extendedRelation(name: "brand", fields: ["id", "name"], applicableTypes: ["Product"])
.extendedScalar(name: "calculatedScore", applicableTypes: ["Product"])

// Native Vendure custom fields
.vendureCustomField(name: "priority", applicableTypes: ["Order"])
.vendureCustomFields(names: ["priority", "notes"], applicableTypes: ["Order"])
```

### Advanced Configuration

For complex use cases, you can use custom GraphQL fragments:

```swift
VendureConfiguration.shared.addCustomField(
    CustomField(
        fieldName: "analytics",
        graphQLFragment: """
        analytics {
            views {
                today
                week
                month
            }
            sales {
                count
                revenue
            }
        }
        """,
        applicableTypes: ["Product"],
        isExtendedField: true
    )
)
```

### Using Custom Fields

Once configured, custom fields are automatically included in all relevant queries:

```swift
// Custom fields are automatically included
let products = try await vendure.catalog.getProducts()
let product = try await vendure.catalog.getProductById(id: "123")

// Access custom fields via modern AnyCodable approach
if product.hasCustomField("priority") {
    if let priority = product.getCustomFieldInt("priority") {
        print("Product priority: \(priority)")
    }
}

if let rating = product.getCustomFieldString("rating") {
    print("Product rating: \(rating)")
}

if let isEnabled = product.getCustomFieldBool("isEnabled") {
    print("Product is enabled: \(isEnabled)")
}

// Direct access to custom fields dictionary
if let customFields = product.customFields {
    print("Custom fields keys: \(customFields.keys.joined(separator: ", "))")
    // Access any field directly with type safety
    let rating = customFields["rating"]?.doubleValue ?? 0.0
    let tags = customFields["tags"]?.arrayValue ?? []
    print("Rating: \(rating), Tags: \(tags.count)")
}

// Access custom fields on other types

// Shipping methods with custom fields
let shippingMethods = try await vendure.order.getEligibleShippingMethods()
for method in shippingMethods {
    // Using modern AnyCodable approach for custom fields
    if let customFields = method.customFields {
        if let maxWeight = customFields["maxWeight"]?.doubleValue {
            print("Max weight: \(maxWeight) kg")
        }
        if let trackingEnabled = customFields["trackingEnabled"]?.boolValue {
            print("Tracking enabled: \(trackingEnabled)")
        }
    }
}

// Payment methods with custom fields
let paymentMethods = try await vendure.order.getEligiblePaymentMethods()
for method in paymentMethods {
    if let customFields = method.customFields {
        if let stripeSettings = customFields["stripeSettings"]?.dictionaryValue {
            print("Stripe configuration: \(stripeSettings.keys.joined(separator: ", "))")
        }
    }
}

// Tax categories with custom fields
let taxCategories = try await vendure.system.getTaxCategories()
for category in taxCategories {
    if let customFields = category.customFields {
        if let taxCode = customFields["taxCode"]?.stringValue {
            print("Tax code: \(taxCode)")
        }
    }
}
```

### Performance Control

You can control whether custom fields are included for performance optimization:

```swift
// Include custom fields (default behavior)
let products = try await vendure.catalog.getProducts(includeCustomFields: true)

// Exclude custom fields for better performance
let fastProducts = try await vendure.catalog.getProducts(includeCustomFields: false)

// Per-operation control
let customer = try await vendure.customer.getActiveCustomer(includeCustomFields: false)
```

### Working with Custom Fields Data

For ease of use, the SDK provides utility methods for working with custom fields JSON:

```swift
// Using built-in extension methods (Product, ProductVariant, VendureCollection)
let product = try await vendure.catalog.getProductById(id: "123")

// Type-safe accessors
if let priority = product.getCustomFieldInt("priority") {
    print("Product priority: \(priority)")
}

if let description = product.getCustomFieldString("extendedDescription") {
    print("Extended description: \(description)")
}

if let isActive = product.getCustomFieldBool("isActive") {
    print("Product is active: \(isActive)")
}

// Check field existence
if product.hasCustomField("specialOffer") {
    print("Product has special offer")
}

// Using CustomFieldsUtility for manual JSON manipulation
import VendureSwiftSDK

// Convert dictionary to JSON string
let customData = ["category": "electronics", "warranty": "2-year"]
let jsonString = CustomFieldsUtility.toJSON(customData)

// Parse JSON string to dictionary
if let parsedFields = CustomFieldsUtility.fromJSON(jsonString ?? "") {
    print("Parsed fields: \(parsedFields)")
}

// Update specific field
let updatedJSON = CustomFieldsUtility.updateField(
    in: product.customFields,
    key: "lastModified",
    value: "2024-01-15"
)
print("Updated custom fields: \(updatedJSON ?? "nil")")

// Remove field
let cleanedJSON = CustomFieldsUtility.removeField(
    from: product.customFields,
    key: "temporaryFlag"
)
```

### Validation and Debugging

```swift
// Get configuration summary
let summary = VendureConfiguration.shared.getConfigurationSummary()
print(summary)

// Check what fields are configured for specific types
let productFields = VendureConfiguration.shared.getCustomFieldsFor(type: "Product")
print("Product custom fields: \(productFields.count)")

// Check if custom fields are configured
if VendureConfiguration.shared.hasCustomFields(for: "Product") {
    print("Product has custom fields configured")
}

// Clear all custom fields (useful for dynamic reconfiguration)
VendureConfiguration.shared.clearCustomFields()
```

### Use Cases

**Loyalty Program Integration**
```swift
// Configure loyalty points for variants
VendureConfiguration.shared.addCustomField(
    .vendureCustomField(name: "loyaltyPoints", applicableTypes: ["ProductVariant"])
)

// Use in your UI
if let points = variant.getCustomFieldInt("loyaltyPoints") {
    print("Earn \(points) points with this purchase!")
}
```

**Admin Dashboard with Analytics**
```swift
// Configure analytics fields
VendureConfiguration.shared.addCustomField(
    .extendedComplexRelation(
        name: "analytics",
        nestedFields: [
            "views": ["today", "week", "month"],
            "sales": ["count", "revenue"]
        ],
        applicableTypes: ["Product"]
    )
)
```

**Multi-tenant Configuration**
```swift
// Different configurations based on context
enum TenantType {
    case fashion, electronics, food
}

func configureTenant(_ type: TenantType) {
    VendureConfiguration.shared.clearCustomFields()

    switch type {
    case .fashion:
        VendureConfiguration.shared.addCustomFields([
            .extendedRelation(name: "brand", fields: ["id", "name", "logo"], applicableTypes: ["Product"]),
            .vendureCustomFields(names: ["size", "color"], applicableTypes: ["ProductVariant"])
        ])
    case .electronics:
        VendureConfiguration.shared.addCustomFields([
            .extendedAssetDetailed(name: "manualPdf", applicableTypes: ["Product"]),
            .vendureCustomFields(names: ["warranty", "specs"], applicableTypes: ["Product"])
        ])
    case .food:
        VendureConfiguration.shared.addCustomFields([
            .vendureCustomFields(names: ["ingredients", "allergens"], applicableTypes: ["Product"])
        ])
    }
}
```

## Vapor Integration

VendureSwiftSDK works seamlessly with Vapor applications:

```swift
import Vapor
import VendureSwiftSDK

func routes(_ app: Application) throws {
    app.get("products") { req async throws -> [Product] in
        let vendure = try await Vendure.initialize(
            endpoint: "https://your-vendure-api.com/shop-api",
            token: "your-server-token"
        )

        let products = try await vendure.catalog.getProducts()
        return products.items
    }

    app.post("cart", "add") { req async throws -> Order in
        let vendure = try await Vendure.initialize(
            endpoint: "https://your-vendure-api.com/shop-api",
            token: req.headers.bearerAuthorization?.token
        )

        struct AddToCartRequest: Content {
            let productVariantId: String
            let quantity: Int
        }

        let addToCart = try req.content.decode(AddToCartRequest.self)

        let result = try await vendure.order.addItemToOrder(
            productVariantId: addToCart.productVariantId,
            quantity: addToCart.quantity
        )

        // Assuming result is an Order (you'd need to handle union types appropriately)
        return result as! Order
    }
}
```

## SwiftUI Integration

VendureSwiftSDK works seamlessly with SwiftUI applications using modern Swift concurrency. Here's a complete example:

```swift
import SwiftUI
import VendureSwiftSDK

@MainActor
struct ECommerceApp: View {
    @State private var vendure: Vendure?
    @State private var products: [CatalogProduct] = []
    @State private var totalProducts = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading products...")
                } else if products.isEmpty {
                    Text("No products found")
                        .foregroundColor(.gray)
                } else {
                    List(products, id: \.id) { product in
                        ProductRow(product: product, vendure: vendure)
                    }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Products")
            .task {
                await initializeAndLoadProducts()
            }
        }
    }

    private func initializeAndLoadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            // Initialize Vendure SDK
            let vendureInstance = try await VendureSwiftSDK.initialize(
                endpoint: "https://demo.vendure.io/shop-api",
                useGuestSession: true
            )
            self.vendure = vendureInstance
            print("Vendure SDK initialized successfully")

            // Load products
            let productList = try await vendureInstance.catalog.getProducts()
            self.products = productList.items
            self.totalProducts = productList.totalItems
            print("Loaded \(productList.items.count) of \(productList.totalItems) products")

        } catch VendureError.networkError(let message) {
            self.errorMessage = "Network error: \(message)"
            print("Network error occurred: \(message)")
        } catch VendureError.graphqlError(let errors) {
            self.errorMessage = "API error: \(errors.joined(separator: ", "))"
            print("GraphQL errors: \(errors)")
        } catch {
            self.errorMessage = "Unexpected error: \(error.localizedDescription)"
            print("Unexpected error: \(error)")
        }

        isLoading = false
    }
}

struct ProductRow: View {
    let product: CatalogProduct
    let vendure: Vendure?
    @State private var isAddingToCart = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if let firstVariant = product.variants.first {
                    Text("Price: $\(firstVariant.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Text("Stock: \(firstVariant.stockLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(isAddingToCart ? "Adding..." : "Add to Cart") {
                Task {
                    await addToCart()
                }
            }
            .disabled(isAddingToCart || vendure == nil || product.variants.isEmpty)
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
    
    private func addToCart() async {
        guard let vendure = vendure,
              let firstVariant = product.variants.first else { 
            print("Cannot add to cart: missing vendure instance or product variant")
            return 
        }
        
        isAddingToCart = true
        
        do {
            let order = try await vendure.order.addItemToOrder(
                productVariantId: firstVariant.id,
                quantity: 1
            )
            print("Added \(product.name) to cart successfully")
            print("Order total: $\(order.total, specifier: "%.2f") (\(order.totalQuantity) items)")
        } catch {
            print("Failed to add \(product.name) to cart: \(error)")
        }
        
        isAddingToCart = false
    }
}

// Usage in your main App file:
struct MyECommerceApp: App {
    var body: some Scene {
        WindowGroup {
            ECommerceApp()
        }
    }
}
```

## Error Handling

The SDK provides comprehensive error handling:

```swift
do {
    let order = try await vendure.order.getActiveOrder()
    print("Active order found: \(order.code)")
    print("Order state: \(order.state)")
    print("Total: $\(order.total, specifier: "%.2f")")
    print("Items: \(order.totalQuantity)")
} catch VendureError.networkError(let message) {
    print("Network error: \(message)")
} catch VendureError.graphqlError(let errors) {
    print("GraphQL errors: \(errors.joined(separator: ", "))")
} catch VendureError.tokenMissing {
    print("Authentication token is missing")
} catch {
    print("Unexpected error: \(error)")
}
```

## Runtime Configuration

You can update authentication and configuration at runtime:

```swift
// Update auth token
try await Vendure.setAuthToken("new-token")

// Update language code
try await Vendure.setLanguageCode("es")

// Update channel token
try await Vendure.setChannelToken("new-channel-token")

// Refresh token (if using token manager)
try await Vendure.refreshToken(["key": "value"])
```

## Server-Side Swift Integration

VendureSwiftSDK works perfectly with server-side Swift frameworks, allowing you to build complete e-commerce backends and APIs:

### Vapor Integration Example

```swift
import Vapor
import VendureSwiftSDK

struct ECommerceService {
    private let vendure: Vendure
    
    init(vendure: Vendure) {
        self.vendure = vendure
    }

    func initialize(endpoint: String, token: String) async throws {
        // Vendure instance is already initialized in init
        print("Vendure SDK ready for server-side use")
    }

    func loadProducts(take: Int = 20) async throws -> [CatalogProduct] {
        let options = ProductListOptions(take: take)
        let productList = try await vendure.catalog.getProducts(options: options)
        print("Loaded \(productList.items.count) of \(productList.totalItems) products")
        return productList.items
    }

    func addToCart(productVariantId: String, quantity: Int) async throws -> Order {
        let order = try await vendure.order.addItemToOrder(
            productVariantId: productVariantId,
            quantity: quantity
        )
        print("Added \(quantity) items to cart")
        return order
    }
}
```

### Building for Server-Side Swift

```bash
# Build for server deployment
swift build -c release

# Run tests
swift test

# Build with Vapor
vapor build --release
```

### Modern Swift Features

- **Swift 6 Concurrency**: Full async/await and structured concurrency support
- **Type Safety**: Concrete types with automatic Codable synthesis
- **Actor Safety**: Thread-safe operations using Swift actors
- **AnyCodable Support**: Flexible JSON handling without manual parsing
- **Clean APIs**: Modern Swift patterns with computed properties and extensions

## Concurrency & Thread Safety

VendureSwiftSDK is built with Swift 6 concurrency in mind:

### Actor-Based Architecture

```swift
// The main Vendure class is an actor
public actor Vendure {
    // All operations are isolated and thread-safe
    public func client() -> GraphQLClient { /* ... */ }
    public func defaultHeaders() async throws -> [String: String] { /* ... */ }
}

// Operations are thread-safe with proper isolation
let vendure = try await VendureSwiftSDK.initialize(/* ... */)
let products = await vendure.catalog.getProducts() // Safe concurrent access
```

### Sendable Parameters

```swift
// Token fetchers use sending parameters for cross-actor safety
let tokenFetcher: TokenFetcher = { (parameters: sending [String: Any]) in
    // Parameters are safely transferred between actors
    return await fetchTokenFromAPI(parameters)
}
```

### Best Practices

1. **Use await**: All SDK operations are async and should be called with `await`
2. **Handle Errors**: Wrap calls in do-catch blocks for proper error handling
3. **Actor Isolation**: Don't store mutable state outside actors
4. **Logging**: Keep print statements for debugging - they provide valuable insights

## Platform Support

| Platform | Minimum Version | Architecture | Status |
|----------|----------------|--------------|--------|
| iOS | 18.0+ | arm64, x86_64 | ✅ Native |
| macOS | 15.0+ | arm64, x86_64 | ✅ Native |
| visionOS | 2.0+ | arm64 | ✅ Native |
| watchOS | 11.0+ | arm64 | ✅ Native |
| tvOS | 18.0+ | arm64, x86_64 | ✅ Native |
| Linux | Ubuntu 20.04+ | x86_64, arm64 | ✅ Server-side |

### Development Requirements

- **Swift**: 6.0+
- **Xcode**: 16.0+ (for Apple platforms)
- **Swift on Server**: Compatible with Vapor 4+, Perfect, Kitura
- **Linux**: Ubuntu 20.04+ for server-side development
- **Docker**: For containerized server deployments

## Requirements

- Swift 6.0 or later
- iOS 18.0+ / macOS 15.0+ / watchOS 11.0+ / tvOS 18.0+ / visionOS 2.0+
- Server-side: Ubuntu 20.04+ for Vapor/server deployment

## Troubleshooting

### iOS/Apple Platforms

**Build Issues:**
```bash
# Clean build folder
rm -rf .build
xcodebuild clean -workspace YourProject.xcworkspace -scheme YourScheme

# Update Swift tools
xcode-select --install
```

**Runtime Issues:**
```swift
// Enable debug logging
import VendureSwiftSDK

// Check if endpoints are reachable
let vendure = try await VendureSwiftSDK.initialize(
    endpoint: "https://your-api.com/shop-api",
    timeout: 30.0 // Increase timeout for slow connections
)
print("SDK initialized successfully")
```

### Server-Side Swift Development

**Setup Issues:**
```bash
# Verify Swift installation
swift --version

# Install Swift on Linux
wget https://swift.org/builds/swift-6.0-release/ubuntu2004/swift-6.0-RELEASE/swift-6.0-RELEASE-ubuntu20.04.tar.gz

# Update Swift tools (macOS)
xcode-select --install
```

**Build Issues:**
```bash
# Clean Swift build
swift package clean

# Rebuild from scratch
swift build --verbose
```

**Common Development Patterns:**

1. **Modern Types**: The SDK uses concrete types with AnyCodable for flexibility
2. **Async/Await**: All operations use structured concurrency
3. **JSON Handling**: Automatic Codable synthesis with AnyCodable support

### Network & API Issues

**Connection Problems:**
```swift
// Test basic connectivity
do {
    let vendure = try await VendureSwiftSDK.initialize(
        endpoint: "https://demo.vendure.io/shop-api",
        useGuestSession: true,
        timeout: 30.0
    )
    print("Connection successful")
} catch VendureError.networkError(let message) {
    print("Network error: \(message)")
} catch VendureError.httpError(let code, let message) {
    print("HTTP \(code): \(message)")
}
```

**Authentication Issues:**
```swift
// Check token validity
do {
    let customer = try await vendure.customer.getActiveCustomer()
    if let customer = customer {
        print("Authenticated as: \(customer.emailAddress)")
    } else {
        print("No authenticated customer")
    }
} catch VendureError.tokenMissing {
    print("Authentication token is missing or expired")
}
```

**Debugging GraphQL Errors:**
```swift
catch VendureError.graphqlError(let errors) {
    print("GraphQL errors occurred:")
    for error in errors {
        print("- \(error)")
    }
    // Check your GraphQL query syntax and field availability
}
```

## Performance Tips

1. **Initialize Once**: Create a single Vendure instance and reuse it
2. **Batch Operations**: Use bulk operations when available
3. **Custom Fields**: Only include custom fields when needed using `includeCustomFields: false`
4. **Caching**: Implement client-side caching for frequently accessed data

## Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature`
3. **Make your changes** following our coding standards:
   - Use English for all comments and logs
   - Keep existing print statements for debugging
   - Follow Swift 6 concurrency patterns
   - Use AnyCodable
4. **Test on all platforms**:
   ```bash
   # Test Apple platforms
   swift test

   # Test server-side Linux
   docker run --rm -v "$PWD":/workspace -w /workspace swift:6.0 swift test
   ```
5. **Submit a pull request**

### Code Style

- **Comments**: Always in English
- **Logging**: Use `print()` statements for debugging
- **Concurrency**: Use `async/await` and actors for thread safety
- **Error Handling**: Comprehensive error handling with descriptive messages
- **Modern Swift**: Leverage Swift 6 features and AnyCodable for clean APIs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- **[Vendure](https://www.vendure.io/)** - The headless e-commerce framework this SDK is built for
- **[Vapor](https://vapor.codes/)** - Server-side Swift framework for building APIs
- **[Vendure Flutter SDK](https://pub.dev/packages/vendure)** - Flutter SDK that inspired this implementation

## Support

- **Documentation**: Inline code documentation and examples
- **Issues**: [GitHub Issues](https://github.com/michael-attal/VendureSwiftSDK/issues)
- **Discussions**: [GitHub Discussions](https://github.com/michael-attal/VendureSwiftSDK/discussions)
- **Vendure Community**: [Vendure Slack](https://vendure.io/slack)

---

**Built with ❤️ for Vendure Swift e-commerce development**

For detailed API documentation, check the inline code comments and the official [Vendure GraphQL API documentation](https://www.vendure.io/docs/graphql-api/).
