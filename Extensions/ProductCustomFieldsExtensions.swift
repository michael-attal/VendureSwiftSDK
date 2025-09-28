//
//  ProductCustomFieldsExtensions.swift
//  VendureSwiftSDK
//
//  Skip-compatible extensions for custom fields on Product and ProductVariant
//  These extensions allow accessing custom fields in a type-safe way
//

import Foundation

// MARK: - Skip-Compatible Custom Fields Extensions

/// Skip-compatible extension for Product custom fields access
/// This approach works with both GraphQL extensions and Vendure custom fields
public extension Product {
    
    /// Access mainUsdzAsset from GraphQL extensions or custom fields
    /// Prioritizes GraphQL schema extensions over Vendure custom fields
    var mainUsdzAsset: Asset? {
        // First try to get from unknown fields (GraphQL schema extensions - preferred)
        if let assetData = unknownFields["mainUsdzAsset"] {
            print("[ProductExtension] Found mainUsdzAsset in unknownFields (GraphQL extension)")
            return decodeAssetFromJSON(assetData.jsonString)
        }
        
        // Fallback: try to get from customFields JSON (Vendure custom fields)
        if let customFieldsJSON = customFields,
           let customFieldsData = customFieldsJSON.data(using: .utf8) {
            do {
                if let customFieldsDict = try JSONSerialization.jsonObject(with: customFieldsData) as? [String: Any],
                   let mainUsdzAssetDict = customFieldsDict["mainUsdzAsset"] as? [String: Any] {
                    
                    print("[ProductExtension] Found mainUsdzAsset in customFields (Vendure custom field)")
                    // Convert dictionary back to JSON string for decoding
                    let assetData = try JSONSerialization.data(withJSONObject: mainUsdzAssetDict)
                    let assetJSON = String(data: assetData, encoding: .utf8) ?? ""
                    return decodeAssetFromJSON(assetJSON)
                }
            } catch {
                print("[ProductExtension] Failed to parse customFields JSON for mainUsdzAsset: \(error)")
            }
        }
        
        print("[ProductExtension] mainUsdzAsset not found in unknownFields or customFields")
        return nil
    }
    
    /// Generic method to access any custom field as a typed value
    /// Skip-compatible approach without generics
    func getCustomField<T: Codable>(_ fieldName: String, as type: T.Type) -> T? {
        // Try unknown fields first (GraphQL extensions)
        if let fieldData = unknownFields[fieldName] {
            return decodeValueFromJSON(fieldData.jsonString, as: type)
        }
        
        // Try customFields JSON (Vendure custom fields)
        if let customFieldsJSON = customFields,
           let customFieldsData = customFieldsJSON.data(using: .utf8) {
            do {
                if let customFieldsDict = try JSONSerialization.jsonObject(with: customFieldsData) as? [String: Any],
                   let fieldValue = customFieldsDict[fieldName] {
                    
                    let fieldData = try JSONSerialization.data(withJSONObject: fieldValue)
                    let fieldJSON = String(data: fieldData, encoding: .utf8) ?? ""
                    return decodeValueFromJSON(fieldJSON, as: type)
                }
            } catch {
                print("[ProductExtension] Failed to parse customFields JSON for \(fieldName): \(error)")
            }
        }
        
        return nil
    }
    
    /// Helper method to decode Asset from JSON string
    /// Skip-compatible - no generics, concrete type
    private func decodeAssetFromJSON(_ jsonString: String) -> Asset? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            // Set up date decoding strategy if needed
            decoder.dateDecodingStrategy = .iso8601
            
            let asset = try decoder.decode(Asset.self, from: jsonData)
            return asset
        } catch {
            print("[ProductExtension] Failed to decode Asset from JSON: \(error)")
            return nil
        }
    }
    
    /// Helper method to decode any Codable type from JSON string
    /// Skip-compatible - concrete implementation per type
    private func decodeValueFromJSON<T: Codable>(_ jsonString: String, as type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let value = try decoder.decode(type, from: jsonData)
            return value
        } catch {
            print("[ProductExtension] Failed to decode \(String(describing: type)) from JSON: \(error)")
            return nil
        }
    }
}

/// Skip-compatible extension for ProductVariant custom fields access
public extension ProductVariant {
    
    /// Access mainUsdzAsset from GraphQL extensions or custom fields
    /// Prioritizes GraphQL schema extensions over Vendure custom fields
    var mainUsdzAsset: Asset? {
        // First try to get from unknown fields (GraphQL schema extensions - preferred)
        if let assetData = unknownFields["mainUsdzAsset"] {
            print("[ProductVariantExtension] Found mainUsdzAsset in unknownFields (GraphQL extension)")
            return decodeAssetFromJSON(assetData.jsonString)
        }
        
        // Fallback: try to get from customFields JSON (Vendure custom fields)
        if let customFieldsJSON = customFields,
           let customFieldsData = customFieldsJSON.data(using: .utf8) {
            do {
                if let customFieldsDict = try JSONSerialization.jsonObject(with: customFieldsData) as? [String: Any],
                   let mainUsdzAssetDict = customFieldsDict["mainUsdzAsset"] as? [String: Any] {
                    
                    print("[ProductVariantExtension] Found mainUsdzAsset in customFields (Vendure custom field)")
                    // Convert dictionary back to JSON string for decoding
                    let assetData = try JSONSerialization.data(withJSONObject: mainUsdzAssetDict)
                    let assetJSON = String(data: assetData, encoding: .utf8) ?? ""
                    return decodeAssetFromJSON(assetJSON)
                }
            } catch {
                print("[ProductVariantExtension] Failed to parse customFields JSON for mainUsdzAsset: \(error)")
            }
        }
        
        print("[ProductVariantExtension] mainUsdzAsset not found in unknownFields or customFields")
        return nil
    }
    
    /// Generic method to access any custom field as a typed value
    func getCustomField<T: Codable>(_ fieldName: String, as type: T.Type) -> T? {
        // Try unknown fields first (GraphQL extensions)
        if let fieldData = unknownFields[fieldName] {
            return decodeValueFromJSON(fieldData.jsonString, as: type)
        }
        
        // Try customFields JSON (Vendure custom fields)
        if let customFieldsJSON = customFields,
           let customFieldsData = customFieldsJSON.data(using: .utf8) {
            do {
                if let customFieldsDict = try JSONSerialization.jsonObject(with: customFieldsData) as? [String: Any],
                   let fieldValue = customFieldsDict[fieldName] {
                    
                    let fieldData = try JSONSerialization.data(withJSONObject: fieldValue)
                    let fieldJSON = String(data: fieldData, encoding: .utf8) ?? ""
                    return decodeValueFromJSON(fieldJSON, as: type)
                }
            } catch {
                print("[ProductVariantExtension] Failed to parse customFields JSON for \(fieldName): \(error)")
            }
        }
        
        return nil
    }
    
    /// Helper method to decode Asset from JSON string
    private func decodeAssetFromJSON(_ jsonString: String) -> Asset? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let asset = try decoder.decode(Asset.self, from: jsonData)
            return asset
        } catch {
            print("[ProductVariantExtension] Failed to decode Asset from JSON: \(error)")
            return nil
        }
    }
    
    /// Helper method to decode any Codable type from JSON string
    private func decodeValueFromJSON<T: Codable>(_ jsonString: String, as type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let value = try decoder.decode(type, from: jsonData)
            return value
        } catch {
            print("[ProductVariantExtension] Failed to decode \(String(describing: type)) from JSON: \(error)")
            return nil
        }
    }
}

// MARK: - Skip-Compatible Concrete Type Helpers

/// Concrete extension methods for common custom field types
/// These avoid generics completely for Skip compatibility
public extension Product {
    
    /// Get string custom field value
    func getStringCustomField(_ fieldName: String) -> String? {
        return getCustomField(fieldName, as: String.self)
    }
    
    /// Get integer custom field value  
    func getIntCustomField(_ fieldName: String) -> Int? {
        return getCustomField(fieldName, as: Int.self)
    }
    
    /// Get boolean custom field value
    func getBoolCustomField(_ fieldName: String) -> Bool? {
        return getCustomField(fieldName, as: Bool.self)
    }
    
    /// Get asset custom field value
    func getAssetCustomField(_ fieldName: String) -> Asset? {
        return getCustomField(fieldName, as: Asset.self)
    }
}

public extension ProductVariant {
    
    /// Get string custom field value
    func getStringCustomField(_ fieldName: String) -> String? {
        return getCustomField(fieldName, as: String.self)
    }
    
    /// Get integer custom field value
    func getIntCustomField(_ fieldName: String) -> Int? {
        return getCustomField(fieldName, as: Int.self)
    }
    
    /// Get boolean custom field value
    func getBoolCustomField(_ fieldName: String) -> Bool? {
        return getCustomField(fieldName, as: Bool.self)
    }
    
    /// Get asset custom field value
    func getAssetCustomField(_ fieldName: String) -> Asset? {
        return getCustomField(fieldName, as: Asset.self)
    }
}

// MARK: - Usage Examples in Comments

/*
USAGE EXAMPLES:

1. **Access mainUsdzAsset (works with both approaches):**
```swift
let products = try await vendure.catalog.getProducts()
for product in products.items {
    if let usdzAsset = product.mainUsdzAsset {
        print("Found USDZ asset: \(usdzAsset.source)")
        // Use asset for AR/3D visualization
    }
}
```

2. **Access other custom fields:**
```swift
// String custom field (e.g., spiceLevel)
if let spiceLevel = product.getStringCustomField("spiceLevel") {
    print("Spice level: \(spiceLevel)")
}

// Integer custom field (e.g., preparationTime)
if let prepTime = product.getIntCustomField("preparationTime") {
    print("Preparation time: \(prepTime) minutes")
}

// Boolean custom field (e.g., isVegan)
if let isVegan = product.getBoolCustomField("isVegan") {
    print("Is vegan: \(isVegan)")
}

// Asset custom field (e.g., nutritionLabel)
if let nutritionAsset = product.getAssetCustomField("nutritionLabel") {
    print("Nutrition label: \(nutritionAsset.source)")
}
```

3. **ProductVariant custom fields:**
```swift
for variant in product.variants {
    if let variantUsdzAsset = variant.mainUsdzAsset {
        print("Variant USDZ: \(variantUsdzAsset.source)")
    }
    
    if let size = variant.getStringCustomField("size") {
        print("Variant size: \(size)")
    }
}
```

4. **Generic access (when you need it):**
```swift
// For custom struct types
struct CustomMetadata: Codable {
    let category: String
    let tags: [String]
}

if let metadata = product.getCustomField("metadata", as: CustomMetadata.self) {
    print("Category: \(metadata.category)")
    print("Tags: \(metadata.tags)")
}
```

This approach:
- ✅ **Skip-compatible**: No complex generics, concrete types
- ✅ **Flexible**: Works with both Vendure custom fields and GraphQL extensions
- ✅ **Type-safe**: Provides typed access methods
- ✅ **Generic framework**: VendureSwiftSDK remains generic, your project adds extensions
- ✅ **Maintainable**: Clean separation of concerns
*/