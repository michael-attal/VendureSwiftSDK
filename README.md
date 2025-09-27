# VendureSwiftSDK

A modern Swift SDK for interacting with the Vendure e-commerce framework's GraphQL API. This SDK is designed to work seamlessly across Apple platforms (iOS, macOS, watchOS, tvOS, visionOS) and Android through SKIP.tools transpilation.

## Features

- ✅ **Cross-Platform**: Native iOS, macOS, watchOS, tvOS, visionOS support + Android via SKIP.tools
- ✅ **Swift 6 Ready**: Built with modern concurrency, actors, and `sending` parameters
- ✅ **Type-Safe**: Comprehensive type definitions for all Vendure API responses
- ✅ **Skip Compatible**: Generics-free architecture optimized for Swift-to-Kotlin transpilation
- ✅ **Modern Authentication**: Multiple auth strategies with secure token management
- ✅ **Complete API Coverage**: Support for all major Vendure operations (orders, products, customers, etc.)
- ✅ **Robust Error Handling**: Comprehensive error handling with descriptive error types
- ✅ **Custom Fields**: Extensible system for both GraphQL extensions and native Vendure custom fields
- ✅ **Logging & Debugging**: Built-in logging system for development and production
- ✅ **Vapor Compatible**: Perfect integration with Vapor server-side Swift projects

## Requirements

- **Swift**: 6.0 or later
- **Platforms**: iOS 18.0+, macOS 15.0+, visionOS 2.0+, watchOS 11.0+, tvOS 18.0+
- **Android**: Via SKIP.tools (requires Skip toolchain)
- **Xcode**: 16.0 or later
- **Android Studio**: Koala or later (for Android development)

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

### Skip.tools Setup (for Android Support)

1. **Install Skip toolchain:**
```bash
brew install skip-tools/skip/skip
```

2. **Configure your Package.swift for Skip:**
```swift
// swift-tools-version: 6.0
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [.iOS(.v18), .macOS(.v15), .visionOS(.v2)],
    products: [
        .library(name: "YourTarget", type: .dynamic, targets: ["YourTarget"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.6.21"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "1.0.0"),
        .package(url: "https://github.com/michael-attal/VendureSwiftSDK.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                "VendureSwiftSDK",
                .product(name: "SkipFoundation", package: "skip-foundation")
            ],
            plugins: [
                .plugin(name: "skipstone", package: "skip")
            ]
        )
    ]
)
```

3. **Add Skip configuration file at `Sources/YourTarget/Skip/skip.yml`:**
```yaml
# Configuration file for https://skip.tools project
# Kotlin dependencies can be configured here if needed
```

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
let options = ProductListOptions(take: 20, skip: 0)
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
    let customFields: String? // JSON string for Skip compatibility
}

let result = try await vendure.custom.query(
    customQuery,
    variables: ["id": "123"],
    responseType: CustomProductResponse.self,
    expectedDataType: "product"
)
```

## Custom Fields

VendureSwiftSDK supports an extensible custom fields system that allows you to dynamically add custom fields to all GraphQL queries. The system supports both **Extended GraphQL Fields** (added via Vendure plugins) and **Native Vendure Custom Fields** (configured in vendure-config.ts).

> **🔄 Skip.tools Compatibility**: Custom fields are stored as JSON strings rather than typed objects to ensure full compatibility with Skip's Swift-to-Kotlin transpilation. This approach provides the same functionality while maintaining cross-platform compatibility.

### Supported Types

The following types include a `customFields: String?` property that stores custom field data as JSON for Skip.tools compatibility:

**Product & Catalog Types:**
- `Product` - includes extension methods (`getCustomFieldString`, `getCustomFieldInt`, etc.)
- `ProductVariant` - includes extension methods
- `ProductOption`
- `ProductOptionGroup`
- `VendureCollection` - includes extension methods
- `Asset`

**Order & Commerce Types:**
- `Order`
- `OrderLine`
- `PaymentMethod`
- `ShippingMethod`
- `Promotion`

**Customer & Auth Types:**
- `Customer`
- `Address`

**System & Tax Types:**
- `TaxCategory`
- `TaxRate`
- `Channel`

> **💡 Type-Safe Extensions**: `Product`, `ProductVariant`, and `VendureCollection` include convenient extension methods like `getCustomFieldString()`, `getCustomFieldInt()`, `getCustomFieldBool()`, and `hasCustomField()` for easy access to custom field values.

### Configuration

Configure custom fields at application startup:

```swift
import VendureSwiftSDK

// Configure custom fields at app startup
func configureCustomFields() {
    // Extended GraphQL fields (from Vendure plugins)
    VendureConfiguration.shared.addCustomField(
        .extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product", "ProductVariant"])
    )

    VendureConfiguration.shared.addCustomField(
        .extendedRelation(name: "category", fields: ["id", "name", "slug"], applicableTypes: ["Product"])
    )

    VendureConfiguration.shared.addCustomField(
        .extendedScalar(name: "rating", applicableTypes: ["Product"])
    )

    // Native Vendure custom fields
    VendureConfiguration.shared.addCustomField(
        .vendureCustomFields(names: ["priority", "notes"], applicableTypes: ["Order"])
    )

    VendureConfiguration.shared.addCustomField(
        .vendureCustomField(name: "loyaltyLevel", applicableTypes: ["Customer"])
    )

    // Custom fields for other types
    VendureConfiguration.shared.addCustomField(
        .vendureCustomFields(names: ["maxWeight", "trackingEnabled"], applicableTypes: ["ShippingMethod"])
    )

    VendureConfiguration.shared.addCustomField(
        .vendureCustomField(name: "taxCode", applicableTypes: ["TaxCategory"])
    )

    VendureConfiguration.shared.addCustomField(
        .vendureCustomFields(names: ["stripeSettings", "enabled"], applicableTypes: ["PaymentMethod"])
    )
}
```

### Factory Methods

The SDK provides convenient factory methods for common use cases:

```swift
// Extended GraphQL fields
.extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product"])
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

// Access custom fields via JSON string parsing (Skip-compatible)
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

// Access raw JSON string if needed
if let customFieldsJSON = product.customFields {
    print("Raw custom fields JSON: \(customFieldsJSON)")
    // Parse manually for complex structures
    if let data = customFieldsJSON.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        // Handle complex nested data
        print("Parsed custom fields: \(json)")
    }
}

// Note: Typed extensions like .mainUsdzAsset are provided by client modules
// that import VendureSwiftSDK and add specific functionality

// Access custom fields on other types

// Shipping methods with custom fields
let shippingMethods = try await vendure.order.getEligibleShippingMethods()
for method in shippingMethods {
    // Using JSON parsing for custom fields (Skip-compatible)
    if let customFieldsJSON = method.customFields,
       let data = customFieldsJSON.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        
        if let maxWeight = json["maxWeight"] as? Double {
            print("Max weight: \(maxWeight) kg")
        }
        if let trackingEnabled = json["trackingEnabled"] as? Bool {
            print("Tracking enabled: \(trackingEnabled)")
        }
    }
}

// Payment methods with custom fields
let paymentMethods = try await vendure.order.getEligiblePaymentMethods()
for method in paymentMethods {
    if let customFieldsJSON = method.customFields,
       let data = customFieldsJSON.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        
        if let stripeSettings = json["stripeSettings"] as? [String: Any] {
            print("Stripe configuration: \(stripeSettings)")
        }
    }
}

// Tax categories with custom fields
let taxCategories = try await vendure.system.getTaxCategories()
for category in taxCategories {
    if let customFieldsJSON = category.customFields,
       let data = customFieldsJSON.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        
        if let taxCode = json["taxCode"] as? String {
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

### Working with Custom Fields Data (Skip-Compatible)

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

**E-commerce with AR (Augmented Reality)**
```swift
// Configure USDZ assets for AR
VendureConfiguration.shared.addCustomField(
    .extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product", "ProductVariant"])
)

// Use in your AR implementation
if let usdzAsset = product.mainUsdzAsset {
    // Initialize ARKit with USDZ model
    let url = URL(string: usdzAsset.source)
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
            .extendedAsset(name: "manualPdf", applicableTypes: ["Product"]),
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

## Skip.tools Android Development

VendureSwiftSDK is fully compatible with Skip.tools, allowing you to write your e-commerce logic once in Swift and deploy to both iOS and Android.

### Android Usage Example

The same Swift code you write for iOS works on Android through Skip's transpilation:

```swift
// This Swift code works on both iOS and Android
import VendureSwiftSDK

struct ECommerceService {
    private var vendure: Vendure?

    mutating func initialize() async throws {
        self.vendure = try await VendureSwiftSDK.initialize(
            endpoint: "https://demo.vendure.io/shop-api",
            useGuestSession: true
        )
        print("Vendure SDK initialized for cross-platform use")
    }

    func loadProducts() async throws -> [CatalogProduct] {
        guard let vendure = vendure else {
            throw VendureError.initializationError("SDK not initialized")
        }
        
        let productList = try await vendure.catalog.getProducts()
        print("Loaded \(productList.items.count) of \(productList.totalItems) products")
        return productList.items
    }

    func addToCart(productVariantId: String, quantity: Int) async throws {
        guard let vendure = vendure else {
            throw VendureError.initializationError("SDK not initialized")
        }

        let order = try await vendure.order.addItemToOrder(
            productVariantId: productVariantId,
            quantity: quantity
        )
        print("Added \(quantity) items to cart")
    }
}
```

### Building for Android

```bash
# Build Android AAR
swift skip build android

# Run Android tests
swift skip test android

# Open Android Studio
swift skip open android
```

### Skip Compatibility Notes

- **No Generics**: The SDK avoids generics for optimal Skip transpilation
- **Concrete Types**: All API responses use concrete types rather than generic wrappers
- **Actor Safety**: Swift actors are transpiled to Kotlin coroutines
- **Sendable Support**: `sending` parameters ensure thread safety across platforms
- **JSON Handling**: Uses standard JSON serialization compatible with both Swift and Kotlin

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
4. **Logging**: Keep print statements for debugging (they're preserved in both Swift and Kotlin)

## Platform Support

| Platform | Minimum Version | Architecture | Status |
|----------|----------------|--------------|--------|
| iOS | 18.0+ | arm64, x86_64 | ✅ Native |
| macOS | 15.0+ | arm64, x86_64 | ✅ Native |
| visionOS | 2.0+ | arm64 | ✅ Native |
| watchOS | 11.0+ | arm64 | ✅ Native |
| tvOS | 18.0+ | arm64, x86_64 | ✅ Native |
| Android | API 24+ | arm64-v8a, x86_64 | ✅ Skip.tools |

### Development Requirements

- **Swift**: 6.0+
- **Xcode**: 16.0+ (for Apple platforms)
- **Android Studio**: Koala+ (for Android development)
- **Skip Tools**: Latest (for Android transpilation)
- **Kotlin**: 2.0+ (managed by Skip)

## Requirements

- Swift 5.9 or later
- iOS 13.0+ / macOS 13.0+ / watchOS 6.0+ / tvOS 13.0+ / visionOS 1.0+
- For Android: SKIP.tools framework

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

### Android/Skip Development

**Setup Issues:**
```bash
# Verify Skip installation
skip --version

# Update Skip tools
brew upgrade skip-tools/skip/skip

# Clean Skip cache
rm -rf ~/.skip
```

**Build Issues:**
```bash
# Clean Android build
swift skip clean android

# Rebuild from scratch
swift skip build android --verbose
```

**Common Skip Compatibility Issues:**

1. **Generic Types**: The SDK avoids generics - use concrete types in your code
2. **Async/Await**: All async operations work the same on Android through Skip
3. **JSON Decoding**: Use the provided `JSONDecoder()` extensions for compatibility

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
   - Ensure Skip compatibility (no generics)
4. **Test on both platforms**:
   ```bash
   # Test iOS
   swift test

   # Test Android via Skip
   swift skip test android
   ```
5. **Submit a pull request**

### Code Style

- **Comments**: Always in English
- **Logging**: Use `print()` statements for debugging (preserved in Kotlin)
- **Concurrency**: Use `async/await` and actors
- **Error Handling**: Comprehensive error handling with descriptive messages
- **Skip Compatibility**: Avoid generics, use concrete types

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- **[Vendure](https://www.vendure.io/)** - The headless e-commerce framework this SDK is built for
- **[Skip.tools](https://skip.tools/)** - Swift-to-Kotlin transpilation framework
- **[Vendure Flutter SDK](https://pub.dev/packages/vendure)** - Flutter SDK that inspired this implementation

## Support

- **Documentation**: Inline code documentation and examples
- **Issues**: [GitHub Issues](https://github.com/michael-attal/VendureSwiftSDK/issues)
- **Discussions**: [GitHub Discussions](https://github.com/michael-attal/VendureSwiftSDK/discussions)
- **Vendure Community**: [Vendure Slack](https://vendure.io/slack)

---

**Built with ❤️ for cross-platform e-commerce development**

For detailed API documentation, check the inline code comments and the official [Vendure GraphQL API documentation](https://www.vendure.io/docs/graphql-api/).
