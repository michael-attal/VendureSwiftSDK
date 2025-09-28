import Foundation

// MARK: - MainUsdzAsset Support via Unknown Fields System
// This file provides mainUsdzAsset access for Vendure products and variants
// using the new unknown fields capture system.

/// Protocol for types that have customFields access
/// Skip-compatible: simple protocol without constraints
protocol CustomFieldsAccessible {
    var customFields: String? { get }
}

// MARK: - CustomFieldsAccessible Conformance
// Make all relevant product types conform to CustomFieldsAccessible

extension Product: CustomFieldsAccessible {}
extension ProductVariant: CustomFieldsAccessible {}
extension CatalogProduct: CustomFieldsAccessible {}
extension CatalogProductVariant: CustomFieldsAccessible {}

/// Represents a mainUsdzAsset custom field from Vendure
/// Skip-compatible: Codable, Sendable, no complex types
public struct MainUsdzAsset: Codable, Sendable {
    public let id: String
    public let name: String
    public let type: AssetType
    public let fileSize: Int
    public let mimeType: String
    public let width: Int?
    public let height: Int?
    public let source: String
    public let preview: String
    
    public init(id: String, name: String, type: AssetType, fileSize: Int, mimeType: String, 
                width: Int? = nil, height: Int? = nil, source: String, preview: String) {
        self.id = id
        self.name = name
        self.type = type
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.width = width
        self.height = height
        self.source = source
        self.preview = preview
    }
}

// MARK: - Extensions for UnknownJSONAccessible Types

/// Extension to provide mainUsdzAsset access to any type that supports unknown fields
public extension UnknownJSONAccessible {
    /// Access to mainUsdzAsset via unknown fields or customFields
    /// This automatically decodes the mainUsdzAsset from captured unknown JSON fields
    /// Skip-compatible: checks both unknownFields and customFields for maximum compatibility
    var mainUsdzAsset: MainUsdzAsset? {
        // First try unknownFields (preferred method)
        if !unknownFields.isEmpty, let rawJSON = unknownFields["mainUsdzAsset"] {
            print("[MainUsdzAsset] Found mainUsdzAsset in unknownFields")
            let result = rawJSON.decode(to: MainUsdzAsset.self)
            if result != nil {
                print("[MainUsdzAsset] ✅ Successfully decoded mainUsdzAsset from unknownFields")
                return result
            } else {
                print("[MainUsdzAsset] ❌ Failed to decode mainUsdzAsset from unknownFields")
                print("[MainUsdzAsset] Raw JSON content: \(rawJSON.jsonString)")
            }
        }
        
        // Fallback: check customFields (where manual extraction stores unknown fields)
        if let customFieldsAccess = self as? CustomFieldsAccessible,
           let customFieldsString = customFieldsAccess.customFields,
           !customFieldsString.isEmpty,
           let data = customFieldsString.data(using: .utf8) {
            do {
                if let customFieldsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let mainUsdzAssetDict = customFieldsDict["mainUsdzAsset"] as? [String: Any] {
                    print("[MainUsdzAsset] Found mainUsdzAsset in customFields")
                    let assetData = try JSONSerialization.data(withJSONObject: mainUsdzAssetDict)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(MainUsdzAsset.self, from: assetData)
                    print("[MainUsdzAsset] ✅ Successfully decoded mainUsdzAsset from customFields")
                    return result
                }
            } catch {
                print("[MainUsdzAsset] ❌ Error parsing customFields for mainUsdzAsset: \(error)")
            }
        }
        
        print("[MainUsdzAsset] ❌ No mainUsdzAsset found in unknownFields or customFields")
        return nil
    }
    
    /// Check if this entity has a mainUsdzAsset
    /// Skip-compatible: checks both unknownFields and customFields
    var hasMainUsdzAsset: Bool {
        // Check unknownFields first
        if unknownFields["mainUsdzAsset"] != nil {
            return true
        }
        
        // Check customFields as fallback
        if let customFieldsAccess = self as? CustomFieldsAccessible,
           let customFieldsString = customFieldsAccess.customFields,
           !customFieldsString.isEmpty,
           let data = customFieldsString.data(using: .utf8) {
            do {
                if let customFieldsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    return customFieldsDict["mainUsdzAsset"] != nil
                }
            } catch {
                // Ignore parsing errors
            }
        }
        
        return false
    }
    
    /// Get mainUsdzAsset as a dictionary for inspection
    var mainUsdzAssetDictionary: [String: Any]? {
        return unknownFields["mainUsdzAsset"]?.asDictionary
    }
    
    /// Debug print all unknown fields for inspection
    func debugUnknownFields() {
        print("[MainUsdzAsset] Debugging unknown fields:")
        unknownFields.debugPrint()
    }
}

// MARK: - Convenience Extensions for Product and ProductVariant

/// Specific extension for Product to provide convenient mainUsdzAsset access
public extension Product {
    /// Check if this product has AR/3D support via mainUsdzAsset
    var supportsAR: Bool {
        return hasMainUsdzAsset && mainUsdzAsset?.mimeType.contains("model") == true
    }
    
    /// Get the mainUsdzAsset URL for AR display
    var arAssetURL: String? {
        return mainUsdzAsset?.source
    }
}

/// Specific extension for ProductVariant to provide convenient mainUsdzAsset access
public extension ProductVariant {
    /// Check if this variant has AR/3D support via mainUsdzAsset
    var supportsAR: Bool {
        return hasMainUsdzAsset && mainUsdzAsset?.mimeType.contains("model") == true
    }
    
    /// Get the mainUsdzAsset URL for AR display
    var arAssetURL: String? {
        return mainUsdzAsset?.source
    }
}

// MARK: - Legacy Support for Debugging
// These functions help debug the transition from old to new system

/// Debug helper to check both old and new systems
public struct MainUsdzAssetDebugger {
    
    /// Compare old storage system with new unknown fields system
    @MainActor public static func debugProduct(_ product: Product) {
        print("=== MainUsdzAsset Debug for Product \(product.id) ===")
        
        // New system via unknown fields
        print("Unknown fields system:")
        print("  - Has mainUsdzAsset: \(product.hasMainUsdzAsset)")
        print("  - Available unknown fields: \(product.unknownFields.fieldNames)")
        if let asset = product.mainUsdzAsset {
            print("  - Asset ID: \(asset.id)")
            print("  - Asset name: \(asset.name)")
            print("  - Asset source: \(asset.source)")
            print("  - Asset mimeType: \(asset.mimeType)")
        }
        
        print("=== End Debug ===")
    }
    
    /// Compare old storage system with new unknown fields system
    @MainActor public static func debugProductVariant(_ variant: ProductVariant) {
        print("=== MainUsdzAsset Debug for ProductVariant \(variant.id) ===")
        
        // New system via unknown fields
        print("Unknown fields system:")
        print("  - Has mainUsdzAsset: \(variant.hasMainUsdzAsset)")
        print("  - Available unknown fields: \(variant.unknownFields.fieldNames)")
        if let asset = variant.mainUsdzAsset {
            print("  - Asset ID: \(asset.id)")
            print("  - Asset name: \(asset.name)")
            print("  - Asset source: \(asset.source)")
            print("  - Asset mimeType: \(asset.mimeType)")
        }
        
        print("=== End Debug ===")
    }
}