# VendureSwiftSDK

A Swift SDK for interacting with the Vendure e-commerce framework's GraphQL API. This SDK is designed to work seamlessly with both iOS applications and Vapor server-side Swift projects.

## Features

- ✅ **Multi-Platform**: Works on iOS, macOS, watchOS, tvOS, visionOS, and Android (via SKIP.tools)
- ✅ **Vapor Compatible**: Perfect integration with Vapor server-side Swift projects
- ✅ **Modern Async/Await**: Built with Swift's modern async/await and actor patterns
- ✅ **Type-Safe**: Comprehensive type definitions for all Vendure API responses
- ✅ **Authentication Support**: Multiple authentication strategies (native, Firebase, custom)
- ✅ **Complete API Coverage**: Support for all major Vendure operations
- ✅ **Error Handling**: Comprehensive error handling with descriptive error types
- ✅ **Extensible**: Support for custom GraphQL operations
- ✅ **Custom Fields**: Extensible custom fields system for both extended GraphQL fields and native Vendure custom fields
- ✅ **SKIP.tools Compatible**: Cross-platform support for Android development

## Installation

### Swift Package Manager

Add VendureSwiftSDK to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/VendureSwiftSDK.git", from: "1.0.0")
]
```

Add it to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["VendureSwiftSDK"]
    )
]
```

## Quick Start

### Basic Initialization

```swift
import VendureSwiftSDK

// Initialize with token
let vendure = try await VendureSwiftSDK.initialize(
    endpoint: "https://your-vendure-api.com/shop-api",
    token: "your-auth-token"
)
```

### Authentication Methods

#### Native Authentication
```swift
let vendure = try await VendureSwiftSDK.initializeWithNativeAuth(
    endpoint: "https://your-vendure-api.com/shop-api",
    username: "customer@example.com",
    password: "password123",
    sessionDuration: TimeInterval(60 * 60 * 24) // 1 day
)
```

#### Firebase Authentication
```swift
let vendure = try await VendureSwiftSDK.initializeWithFirebaseAuth(
    endpoint: "https://your-vendure-api.com/shop-api",
    uid: "firebase-user-id",
    jwt: "firebase-jwt-token",
    sessionDuration: TimeInterval(60 * 60), // 1 hour
    languageCode: "en",
    channelToken: "your-channel-token"
)
```

#### Custom Authentication
```swift
let vendure = try await VendureSwiftSDK.initializeWithCustomAuth(
    endpoint: "https://your-vendure-api.com/shop-api",
    fetchToken: { params in
        // Your custom token fetching logic
        return try await yourCustomTokenFetcher(params)
    },
    tokenParams: [
        "customParam1": "value1",
        "customParam2": "value2"
    ]
)
```

## Usage Examples

### Order Operations

#### Add Item to Cart
```swift
do {
    let result = try await vendure.order.addItemToOrder(
        productVariantId: "123",
        quantity: 2
    )
    print("Item added to order: \(result)")
} catch {
    print("Error: \(error)")
}
```

#### Get Active Order
```swift
let activeOrder = try await vendure.order.getActiveOrder()
print("Current order: \(activeOrder?.code ?? "No active order")")
```

#### Set Shipping Address
```swift
let address = CreateAddressInput(
    streetLine1: "123 Main Street",
    city: "New York",
    postalCode: "10001",
    countryCode: "US"
)

let result = try await vendure.order.setOrderShippingAddress(input: address)
```

#### Add Payment
```swift
let payment = PaymentInput(
    method: "stripe-payment",
    metadata: ["stripe_payment_method": "pm_123456"]
)

let result = try await vendure.order.addPaymentToOrder(input: payment)
```

### Catalog Operations

#### Get Products
```swift
let options = ProductListOptions(take: 20, skip: 0)
let products = try await vendure.catalog.getProducts(options: options)

for product in products.items {
    print("Product: \(product.name) - \(product.slug)")
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
let collections = try await vendure.catalog.getCollections()
for collection in collections.items {
    print("Collection: \(collection.name)")
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

let result = try await vendure.auth.registerCustomerAccount(input: registration)
```

#### Login/Logout
```swift
// Login
let loginResult = try await vendure.auth.login(
    username: "customer@example.com",
    password: "password123",
    rememberMe: true
)

// Logout
let logoutResult = try await vendure.auth.logout()
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
    let customFields: [String: AnyCodable]?
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

// Access extended GraphQL fields directly
if let usdzAsset = product.mainUsdzAsset {
    let url = URL(string: usdzAsset.source)
    // Load USDZ file for AR
}

// Access extended fields generically
if let rating = product.getExtendedScalar("rating", type: Double.self) {
    print("Product rating: \(rating)")
}

// Access native Vendure custom fields with type safety
if let priority = order.getCustomField("priority", type: Int.self) {
    print("Order priority: \(priority)")
}

// Check if custom fields exist
if product.hasExtendedField("mainUsdzAsset") {
    // Field is available
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

### Validation and Debugging

```swift
// Get configuration summary
let summary = VendureConfiguration.shared.getConfigurationSummary()
print(summary)

// Validate configuration for production
let warnings = VendureConfiguration.shared.validateConfiguration()
for warning in warnings {
    print("Warning: \(warning)")
}

// Check what types have custom fields
let typesWithFields = VendureConfiguration.shared.getTypesWithCustomFields()
print("Types with custom fields: \(typesWithFields)")
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
        let vendure = try await VendureSwiftSDK.initialize(
            endpoint: "https://your-vendure-api.com/shop-api",
            token: "your-server-token"
        )
        
        let products = try await vendure.catalog.getProducts()
        return products.items
    }
    
    app.post("cart", "add") { req async throws -> Order in
        let vendure = try await VendureSwiftSDK.initialize(
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

VendureSwiftSDK works seamlessly with SwiftUI applications. Here's a complete example of customer authentication:

```swift
import SwiftUI
import VendureSwiftSDK

struct CustomerLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var loginResult: String = ""
    @State private var currentCustomer: Customer?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Customer Login")
                .font(.title)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Login") {
                Task {
                    await performLogin()
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            
            if let customer = currentCustomer {
                Text("Welcome, \(customer.firstName) \(customer.lastName)!")
                    .foregroundColor(.green)
            }
            
            if !loginResult.isEmpty {
                Text(loginResult)
                    .foregroundColor(loginResult.contains("Success") ? .green : .red)
            }
        }
        .padding()
    }
    
    private func performLogin() async {
        isLoading = true
        
        do {
            // Initialize with native authentication
            let vendure = try await VendureSwiftSDK.initializeWithNativeAuth(
                endpoint: "https://your-vendure-api.com/shop-api",
                username: email,
                password: password
            )
            
            // Get customer information
            let customer = try await vendure.customer.getActiveCustomer()
            await MainActor.run {
                self.currentCustomer = customer
                self.loginResult = "Login successful!"
            }
            
        } catch {
            await MainActor.run {
                self.loginResult = "Login failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}
```

## Error Handling

The SDK provides comprehensive error handling:

```swift
do {
    let order = try await vendure.order.getActiveOrder()
    // Handle successful response
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

## Thread Safety

All operations are thread-safe thanks to Swift's actor-based concurrency model. The SDK uses actors to ensure safe concurrent access to shared resources.

## Platform Support

- **iOS**: 13.0+
- **macOS**: 13.0+
- **watchOS**: 6.0+
- **tvOS**: 13.0+
- **visionOS**: 1.0+
- **Android**: Via SKIP.tools transpilation
- **Swift**: 5.9+

## Requirements

- Swift 5.9 or later
- iOS 13.0+ / macOS 13.0+ / watchOS 6.0+ / tvOS 13.0+ / visionOS 1.0+
- For Android: SKIP.tools framework

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Related Projects

- [Vendure](https://www.vendure.io/) - The headless e-commerce framework this SDK is built for
- [Vendure Flutter SDK](https://pub.dev/packages/vendure) - The original Flutter SDK that inspired this Swift implementation

---

For more detailed API documentation, please refer to the inline code documentation and the official Vendure GraphQL API documentation.
