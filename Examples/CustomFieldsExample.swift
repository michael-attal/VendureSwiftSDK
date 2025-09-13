import Foundation
import VendureSwiftSDK

/// Example usage of the VendureSwiftSDK extensible custom fields system
class CustomFieldsExample {
    
    private var vendure: Vendure!
    
    /// Initial custom fields configuration
    func setupCustomFields() {
        print("🔧 Configuring custom fields...")
        
        // Extended GraphQL fields (for USDZ assets, for example)
        VendureConfiguration.shared.addCustomField(
            .extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product", "ProductVariant"])
        )
        
        // Extended relation field for category
        VendureConfiguration.shared.addCustomField(
            .extendedRelation(name: "category", fields: ["id", "name", "slug"], applicableTypes: ["Product"])
        )
        
        // Extended scalar field for a calculated score
        VendureConfiguration.shared.addCustomField(
            .extendedScalar(name: "calculatedScore", applicableTypes: ["Product"])
        )
        
        // Native Vendure custom fields for orders
        VendureConfiguration.shared.addCustomField(
            .vendureCustomFields(names: ["priority", "internalNotes", "source"], applicableTypes: ["Order"])
        )
        
        // Native Vendure custom field for customers
        VendureConfiguration.shared.addCustomField(
            .vendureCustomField(name: "loyaltyLevel", applicableTypes: ["Customer"])
        )
        
        // Custom fields for shipping methods
        VendureConfiguration.shared.addCustomField(
            .vendureCustomFields(names: ["maxWeight", "trackingEnabled", "estimatedDays"], applicableTypes: ["ShippingMethod"])
        )
        
        // Custom fields for payment methods
        VendureConfiguration.shared.addCustomField(
            .vendureCustomFields(names: ["stripeSettings", "processingFee"], applicableTypes: ["PaymentMethod"])
        )
        
        // Custom fields for tax categories
        VendureConfiguration.shared.addCustomField(
            .vendureCustomField(name: "taxCode", applicableTypes: ["TaxCategory"])
        )
        
        // Custom fields for promotions
        VendureConfiguration.shared.addCustomField(
            .vendureCustomFields(names: ["category", "targetAudience"], applicableTypes: ["Promotion"])
        )
        
        // Display configuration
        let summary = VendureConfiguration.shared.getConfigurationSummary()
        print(summary)
        
        print("✅ Custom fields configuration completed")
    }
    
    /// Vendure SDK initialization
    func initializeVendure() async throws {
        vendure = try await Vendure.initialize(
            endpoint: "https://demo.vendure.io/shop-api",
            useGuestSession: true
        )
        
        print("✅ VendureSwiftSDK initialized")
    }
    
    /// Example usage with products and extended fields
    func demonstrateProductsWithExtendedFields() async throws {
        print("\n📦 Fetching products with extended fields...")
        
        // Fetch products (custom fields included automatically)
        let productsList = try await vendure.catalog.getProducts()
        print("Found \(productsList.items.count) products")
        
        guard let firstProduct = productsList.items.first else {
            print("No products found")
            return
        }
        
        // Fetch product detail
        let productDetail = try await vendure.catalog.getProductById(id: firstProduct.id)
        
        print("\n🎯 Analyzing product: \(productDetail.name)")
        
        // Access custom fields via customFields dictionary
        if let customFields = productDetail.customFields {
            print("  🔧 Available custom fields: \(Array(customFields.keys))")
            
            // Access mainUsdzAsset if configured
            if let usdzAssetData = customFields["mainUsdzAsset"]?.value as? [String: Any],
               let assetId = usdzAssetData["id"] as? String,
               let source = usdzAssetData["source"] as? String {
                print("  📱 USDZ asset found: \(source)")
                print("     - Asset ID: \(assetId)")
                if let mimeType = usdzAssetData["mimeType"] as? String {
                    print("     - Type: \(mimeType)")
                }
            }
            
            // Access other custom fields
            if let score = customFields["calculatedScore"]?.value as? Double {
                print("  ⭐ Calculated score: \(score)")
            }
            
            if let priority = customFields["priority"]?.value as? Int {
                print("  🚨 Priority: \(priority)")
            }
        } else {
            print("  ❌ No custom fields available")
        }
        
        // Test with variants
        if let firstVariant = productDetail.variants.first {
            print("\n  🔄 Variant: \(firstVariant.name)")
            
            if let variantCustomFields = firstVariant.customFields {
                print("    🔧 Variant custom fields: \(Array(variantCustomFields.keys))")
                
                // Access USDZ asset from variant if configured
                if let usdzAssetData = variantCustomFields["mainUsdzAsset"]?.value as? [String: Any],
                   let source = usdzAssetData["source"] as? String {
                    print("    📱 Variant USDZ asset: \(source)")
                }
                
                if let size = variantCustomFields["size"]?.value as? String {
                    print("    📏 Size: \(size)")
                }
            }
        }
    }
    
    /// Example usage with orders and native custom fields
    func demonstrateOrdersWithCustomFields() async throws {
        print("\n🛒 Fetching active order...")
        
        // Attempt to fetch active order
        if let activeOrder = try await vendure.order.getActiveOrder() {
            print("Active order found: \(activeOrder.code)")
            
            // Access native Vendure custom fields via customFields dictionary
            if let customFields = activeOrder.customFields {
                print("  🔧 Order custom fields: \(Array(customFields.keys))")
                
                if let priority = customFields["priority"]?.value as? Int {
                    print("  🚨 Priority: \(priority)")
                }
                
                if let notes = customFields["internalNotes"]?.value as? String {
                    print("  📝 Notes: \(notes)")
                }
                
                if let source = customFields["source"]?.value as? String {
                    print("  🌐 Source: \(source)")
                }
                
                // Check existence of other fields
                if customFields["trackingNumber"] != nil {
                    print("  📦 Tracking number available")
                }
            }
            
        } else {
            print("❌ No active order")
        }
    }
    
    /// Example usage with customers
    func demonstrateCustomersWithCustomFields() async throws {
        print("\n👤 Fetching active customer...")
        
        if let customer = try await vendure.customer.getActiveCustomer() {
            print("Customer found: \(customer.firstName) \(customer.lastName)")
            
            // Access native Vendure custom fields via customFields dictionary
            if let customFields = customer.customFields {
                print("  🔧 Customer custom fields: \(Array(customFields.keys))")
                
                if let loyaltyLevel = customFields["loyaltyLevel"]?.value as? String {
                    print("  🏆 Loyalty level: \(loyaltyLevel)")
                }
                
                if let preferences = customFields["preferences"]?.value as? [String: String] {
                    print("  ⚙️ Preferences: \(preferences)")
                }
            }
            
        } else {
            print("❌ No active customer")
        }
    }
    
    /// Example usage with shipping methods and custom fields
    func demonstrateShippingMethodsWithCustomFields() async throws {
        print("\n🚚 Fetching eligible shipping methods...")
        
        do {
            let shippingMethods = try await vendure.order.getEligibleShippingMethods()
            print("Found \(shippingMethods.count) shipping methods")
            
            for method in shippingMethods {
                print("\n  📦 Shipping Method: \(method.name) (\(method.code))")
                
                if let customFields = method.customFields {
                    print("    🔧 Custom fields: \(Array(customFields.keys))")
                    
                    if let maxWeight = customFields["maxWeight"]?.value as? Double {
                        print("    ⚖️ Max weight: \(maxWeight) kg")
                    }
                    
                    if let trackingEnabled = customFields["trackingEnabled"]?.value as? Bool {
                        print("    📍 Tracking enabled: \(trackingEnabled ? "Yes" : "No")")
                    }
                    
                    if let estimatedDays = customFields["estimatedDays"]?.value as? Int {
                        print("    📅 Estimated delivery: \(estimatedDays) days")
                    }
                } else {
                    print("    ❌ No custom fields")
                }
            }
        } catch {
            print("❌ Error fetching shipping methods: \(error)")
        }
    }
    
    /// Example usage with payment methods and custom fields
    func demonstratePaymentMethodsWithCustomFields() async throws {
        print("\n💳 Fetching eligible payment methods...")
        
        do {
            let paymentMethods = try await vendure.order.getEligiblePaymentMethods()
            print("Found \(paymentMethods.count) payment methods")
            
            for method in paymentMethods {
                print("\n  💰 Payment Method: \(method.name) (\(method.code))")
                
                if let customFields = method.customFields {
                    print("    🔧 Custom fields: \(Array(customFields.keys))")
                    
                    if let stripeSettings = customFields["stripeSettings"]?.value as? [String: Any] {
                        print("    🔵 Stripe settings: \(stripeSettings)")
                    }
                    
                    if let processingFee = customFields["processingFee"]?.value as? Double {
                        print("    💰 Processing fee: \(processingFee)%")
                    }
                } else {
                    print("    ❌ No custom fields")
                }
            }
        } catch {
            print("❌ Error fetching payment methods: \(error)")
        }
    }
    
    /// Example usage with system data (tax categories) and custom fields
    func demonstrateSystemTypesWithCustomFields() async throws {
        print("\n🏛️ Fetching system types with custom fields...")
        
        // Note: This would require system operations to be available
        // For demonstration purposes, we'll show the concept
        print("  📊 Tax Categories (demo concept):")
        print("    Would fetch tax categories and access their custom fields")
        print("    Example custom fields: taxCode, description, applicableRegions")
        
        // Promotions example (if available)
        print("\n  🎯 Promotions (demo concept):")
        print("    Would fetch active promotions and access their custom fields")
        print("    Example custom fields: category, targetAudience, marketingChannel")
    }
    
    /// Advanced usage example with custom fields control
    func demonstrateAdvancedUsage() async throws {
        print("\n🔬 Advanced custom fields usage...")
        
        // Fetch products WITHOUT custom fields (for performance)
        let fastProducts = try await vendure.catalog.getProducts(includeCustomFields: false)
        print("Products fetched without custom fields: \(fastProducts.items.count)")
        
        // Fetch specific product WITH custom fields
        if let productId = fastProducts.items.first?.id {
            let detailedProduct = try await vendure.catalog.getProductById(
                id: productId,
                includeCustomFields: true
            )
            print("Detailed product fetched: \(detailedProduct.name)")
        }
        
        // Get configured fields for a specific type
        let productFields = VendureConfiguration.shared.getCustomFieldsFor(type: "Product")
        print("Configured fields for Product (\(productFields.count) fields):")
        productFields.forEach { field in
            let fieldType = field.isExtendedField ? "Extended" : "CustomField"
            print("  - [\(fieldType)] \(field.fieldName)")
        }
        
        // Check if there are custom fields for different types
        let types = ["Product", "ProductVariant", "Order", "Customer", "ShippingMethod", "PaymentMethod", "TaxCategory", "Promotion"]
        for type in types {
            let fields = VendureConfiguration.shared.getCustomFieldsFor(type: type)
            if !fields.isEmpty {
                print("\(type) has \(fields.count) configured fields")
            }
        }
    }
    
    /// Dynamic configuration example by context
    func demonstrateDynamicConfiguration() {
        print("\n🔄 Dynamic configuration based on context...")
        
        // Simulate different usage contexts
        enum AppContext {
            case ecommerce
            case admin
            case analytics
        }
        
        func configureForContext(_ context: AppContext) {
            // Clear current configuration
            VendureConfiguration.shared.clearCustomFields()
            
            switch context {
            case .ecommerce:
                // Configuration for consumer e-commerce app
                VendureConfiguration.shared.addCustomFields([
                    .extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product", "ProductVariant"]),
                    .extendedAsset(name: "heroImage", applicableTypes: ["Product"]),
                    .extendedScalar(name: "rating", applicableTypes: ["Product"]),
                    .vendureCustomField(name: "loyaltyLevel", applicableTypes: ["Customer"])
                ])
                
            case .admin:
                // Configuration for admin dashboard
                VendureConfiguration.shared.addCustomFields([
                    .vendureCustomFields(names: ["status", "featured", "priority"], applicableTypes: ["Product"]),
                    .vendureCustomFields(names: ["priority", "internalNotes", "source"], applicableTypes: ["Order"]),
                    .vendureCustomFields(names: ["maxWeight", "trackingEnabled"], applicableTypes: ["ShippingMethod"]),
                    .vendureCustomFields(names: ["processingFee", "enabled"], applicableTypes: ["PaymentMethod"]),
                    .vendureCustomField(name: "taxCode", applicableTypes: ["TaxCategory"]),
                    .extendedScalar(name: "lastModifiedBy", applicableTypes: ["Product", "Order"])
                ])
                
            case .analytics:
                // Configuration for advanced analytics
                VendureConfiguration.shared.addCustomFields([
                    .extendedComplexRelation(
                        name: "analytics",
                        nestedFields: [
                            "views": ["today", "week", "month"],
                            "sales": ["count", "revenue"]
                        ],
                        applicableTypes: ["Product"]
                    )
                ])
            }
            
            print("Configuration updated for context: \(context)")
            print("Number of configured fields: \(VendureConfiguration.shared.customFields.count)")
        }
        
        // Test different contexts
        configureForContext(.ecommerce)
        configureForContext(.admin)
        configureForContext(.analytics)
    }
    
    /// Main method to run all examples
    func runAllExamples() async {
        do {
            // Initial configuration
            setupCustomFields()
            
            // SDK initialization
            try await initializeVendure()
            
            // Usage examples
            try await demonstrateProductsWithExtendedFields()
            try await demonstrateOrdersWithCustomFields()
            try await demonstrateCustomersWithCustomFields()
            try await demonstrateShippingMethodsWithCustomFields()
            try await demonstratePaymentMethodsWithCustomFields()
            try await demonstrateSystemTypesWithCustomFields()
            try await demonstrateAdvancedUsage()
            
            // Dynamic configuration
            demonstrateDynamicConfiguration()
            
            print("\n✅ All examples executed successfully!")
            
        } catch {
            print("❌ Error during example execution: \(error)")
        }
    }
}

// MARK: - Custom types for the example

struct ProductCategory: Codable {
    let id: String
    let name: String
    let slug: String
}

struct ProductAnalytics: Codable {
    let views: ViewStats
    let sales: SalesStats
}

struct ViewStats: Codable {
    let today: Int
    let week: Int
    let month: Int
}

struct SalesStats: Codable {
    let count: Int
    let revenue: Double
}

// MARK: - Entry point for the example

#if canImport(SwiftUI)
import SwiftUI

@main
struct CustomFieldsExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isLoading = false
    @State private var output = "Press the button to test custom fields"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Fields Example")
                .font(.title)
                .padding()
            
            ScrollView {
                Text(output)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            
            Button("Test custom fields") {
                Task {
                    isLoading = true
                    output = "Running...\n"
                    
                    let example = CustomFieldsExample()
                    await example.runAllExamples()
                    
                    isLoading = false
                    output += "\nCompleted!"
                }
            }
            .disabled(isLoading)
            .padding()
        }
        .padding()
    }
}
#endif

// For command line usage
#if !canImport(SwiftUI)
@main
struct CustomFieldsExampleCLI {
    static func main() async {
        let example = CustomFieldsExample()
        await example.runAllExamples()
    }
}
#endif
