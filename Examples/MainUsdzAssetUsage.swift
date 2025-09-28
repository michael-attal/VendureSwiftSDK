import Foundation

/**
 * EXAMPLE: How to use mainUsdzAsset support in your project
 * 
 * This file shows how to integrate mainUsdzAsset support for custom Vendure installations
 * that have added the mainUsdzAsset field using a plugin like the one described below.
 */

/*

STEP 1: Make sure your Vendure backend has the mainUsdzAsset field
========================================================================

Your Vendure backend should have a plugin similar to this:

```typescript
// src/plugins/usdz-assets/usdz-assets.plugin.ts
import { PluginCommonModule, VendurePlugin } from '@vendure/core';
import { gql } from 'graphql-tag';
import { UsdzAssetsResolver, ProductVariantUsdzResolver } from './usdz-assets.resolver';
import { UsdzAssetsService } from './usdz-assets.service';

const shopApiExtensions = gql`
  extend type Product {
    mainUsdzAsset: Asset
  }
  
  extend type ProductVariant {
    mainUsdzAsset: Asset
  }
`;

@VendurePlugin({
  compatibility: '^3.4.0',
  imports: [PluginCommonModule],
  providers: [UsdzAssetsService],
  shopApiExtensions: {
    schema: shopApiExtensions,
    resolvers: [UsdzAssetsResolver, ProductVariantUsdzResolver],
  },
})
export class UsdzAssetsPlugin {}
```

STEP 2: Include MainUsdzAssetSupport.swift in your project
========================================================================

Make sure you include the MainUsdzAssetSupport.swift file in your project.
This file provides optional storage for raw GraphQL JSON data.

STEP 3: Enable raw data capture in your app
========================================================================

In your app initialization (like AppDelegate or App.swift), call:

```swift
import VendureSwiftSDK

@main
struct MyApp: App {
    init() {
        // Enable mainUsdzAsset support
        ProductMainUsdzAssetSupport.enableRawDataCapture()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

STEP 4: Intercept GraphQL responses to capture raw data
========================================================================

You need to capture raw GraphQL response data and store it. This can be done
by creating a custom service layer:

```swift
import VendureSwiftSDK

class CustomVendureService {
    private let vendure: Vendure
    
    init(vendure: Vendure) {
        self.vendure = vendure
    }
    
    func getProductsWithMainUsdzAsset() async throws -> [Product] {
        // Get products using the standard VendureSwiftSDK
        let productList = try await vendure.catalog.getProducts()
        
        // You would need to also get the raw JSON data here
        // This depends on how you've set up your GraphQL queries
        // For example, you could modify the SDK to expose raw responses
        // or use custom GraphQL queries with mainUsdzAsset field
        
        return productList.items
    }
}
```

STEP 5: Use mainUsdzAsset in your UI
========================================================================

```swift
import SwiftUI
import VendureSwiftSDK

struct ProductView: View {
    let product: Product
    
    var body: some View {
        VStack {
            Text(product.name)
            
            // Use the mainUsdzAsset extension
            if let usdzAsset = product.mainUsdzAsset {
                Text("3D Model: \(usdzAsset.name)")
                Text("URL: \(usdzAsset.source)")
                // Use this URL for AR/3D viewing
            } else {
                Text("No 3D model available")
            }
        }
    }
}
```

NOTES:
========================================================================

1. The mainUsdzAsset property will return nil if:
   - Your Vendure backend doesn't have the mainUsdzAsset field
   - MainUsdzAssetSupport.swift is not included in your project
   - Raw data capture is not enabled
   - No USDZ/3D assets are found for the product

2. The extension includes fallback logic that will:
   - First try to get mainUsdzAsset from stored raw GraphQL JSON
   - Then try to parse it from customFields if available
   - Finally infer it from existing assets by looking for 3D file types

3. This approach keeps the core VendureSwiftSDK generic while allowing
   custom extensions for specific Vendure installations.

*/

// Example usage class
public class MainUsdzAssetExample {
    
    @MainActor public static func setupMainUsdzAssetSupport() {
        // Enable raw data capture for mainUsdzAsset support
        ProductMainUsdzAssetSupport.enableRawDataCapture()
        
        print("📱 MainUsdzAsset support is now enabled!")
        print("🔧 Make sure your Vendure backend has the mainUsdzAsset field")
        print("📝 Include MainUsdzAssetSupport.swift in your project")
    }
    
    @MainActor public static func exampleUsage(product: Product) {
        // Example of using the mainUsdzAsset extension
        if let usdzAsset = product.mainUsdzAsset {
            print("✅ Found 3D asset: \(usdzAsset.name)")
            print("🔗 URL: \(usdzAsset.source)")
            print("📏 Size: \(usdzAsset.fileSize) bytes")
            print("🏷️ MIME Type: \(usdzAsset.mimeType)")
        } else {
            print("❌ No 3D asset found for product: \(product.name)")
            print("💡 Check that:")
            print("   1. Your Vendure backend has mainUsdzAsset field")
            print("   2. MainUsdzAssetSupport.swift is included")
            print("   3. Raw data capture is enabled")
            print("   4. The product has USDZ/3D assets")
        }
    }
}