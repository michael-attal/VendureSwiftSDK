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
        
        // Display configuration
        let summary = VendureConfiguration.shared.getConfigurationSummary()
        print(summary)
        
        // Configuration validation
        let warnings = VendureConfiguration.shared.validateConfiguration()
        if !warnings.isEmpty {
            print("⚠️ Configuration warnings:")
            warnings.forEach { print("   - \($0)") }
        } else {
            print("✅ Configuration validated successfully")
        }
    }
    
    /// Vendure SDK initialization
    func initializeVendure() async throws {
        vendure = try await VendureSwiftSDK.initialize(
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
        
        // Access extended fields via convenience extensions
        if let usdzAsset = productDetail.mainUsdzAsset {
            print("  📱 USDZ asset found: \(usdzAsset.source)")
            print("     - Type: \(usdzAsset.type)")
            print("     - Size: \(usdzAsset.fileSize) bytes")
        } else {
            print("  ❌ No USDZ asset available")
        }
        
        // Access extended fields via generic methods
        if let score = productDetail.getExtendedScalar("calculatedScore", type: Double.self) {
            print("  ⭐ Calculated score: \(score)")
        }
        
        if let category = productDetail.getExtendedRelation("category", type: ProductCategory.self) {
            print("  📁 Category: \(category.name) (\(category.slug))")
        }
        
        // Check available fields
        let availableFields = productDetail.getAvailableExtendedFields()
        print("  🔧 Available extended fields: \(availableFields)")
        
        // Access native Vendure custom fields
        if let priority = productDetail.getCustomField("priority", type: Int.self) {
            print("  🚨 Priority: \(priority)")
        }
        
        // Test with variants
        if let firstVariant = productDetail.variants.first {
            print("\n  🔄 Variant: \(firstVariant.name)")
            
            if let variantUsdz = firstVariant.mainUsdzAsset {
                print("    📱 Variant USDZ asset: \(variantUsdz.source)")
            }
            
            if let customValue = firstVariant.getCustomField("size", type: String.self) {
                print("    📏 Size: \(customValue)")
            }
        }
    }
    
    /// Example usage with orders and native custom fields
    func demonstrateOrdersWithCustomFields() async throws {
        print("\n🛒 Fetching active order...")
        
        // Attempt to fetch active order
        if let activeOrder = try await vendure.order.getActiveOrder() {
            print("Active order found: \(activeOrder.code)")
            
            // Access native Vendure custom fields
            if let priority = activeOrder.getCustomField("priority", type: Int.self) {
                print("  🚨 Priority: \(priority)")
            }
            
            if let notes = activeOrder.getCustomField("internalNotes", type: String.self) {
                print("  📝 Notes: \(notes)")
            }
            
            if let source = activeOrder.getCustomField("source", type: String.self) {
                print("  🌐 Source: \(source)")
            }
            
            // Check existence of other fields
            if activeOrder.hasCustomField("trackingNumber") {
                print("  📦 Tracking number available")
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
            
            // Access native Vendure custom fields
            if let loyaltyLevel = customer.getCustomField("loyaltyLevel", type: String.self) {
                print("  🏆 Loyalty level: \(loyaltyLevel)")
            }
            
            // Extended fields (if configured)
            if let preferences = customer.getExtendedField("preferences", type: [String: String].self) {
                print("  ⚙️ Preferences: \(preferences)")
            }
            
        } else {
            print("❌ No active customer")
        }
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
        
        // Dynamically check which types have configured fields
        let typesWithFields = VendureConfiguration.shared.getTypesWithCustomFields()
        print("Types with custom fields: \(typesWithFields)")
        
        // Get configured fields for a specific type
        let productFields = VendureConfiguration.shared.getCustomFieldsFor(type: "Product")
        print("Configured fields for Product:")
        productFields.forEach { field in
            let fieldType = field.isExtendedField ? "Extended" : "CustomField"
            print("  - [\(fieldType)] \(field.fieldName)")
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
