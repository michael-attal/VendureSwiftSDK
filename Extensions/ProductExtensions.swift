import Foundation

// MARK: - Product Extensions for mainUsdzAsset (SKIP Compatible)
// NOTE: This extension is for custom Vendure installations that have added mainUsdzAsset field
// If you don't have this custom field in your Vendure backend, these extensions will return nil

/// Simple helper struct for parsing mainUsdzAsset from JSON (SKIP-compatible)
public struct MainUsdzAssetData: Codable, Sendable {
    public let id: String
    public let name: String
    public let mimeType: String
    public let source: String
    public let preview: String
    public let fileSize: Int
    public let width: Int?
    public let height: Int?
    
    public init(id: String, name: String, mimeType: String, source: String, preview: String, fileSize: Int, width: Int? = nil, height: Int? = nil) {
        self.id = id
        self.name = name
        self.mimeType = mimeType
        self.source = source
        self.preview = preview
        self.fileSize = fileSize
        self.width = width
        self.height = height
    }
}

/// Extension to add support for mainUsdzAsset field access
/// This is a CUSTOM extension for Vendure installations with mainUsdzAsset field
/// 
/// NOTE: mainUsdzAsset is now a proper field in Product/ProductVariant, not a computed property.
/// This extension provides helper methods for working with mainUsdzAsset.

// MARK: - Global Helper Functions (SKIP-compatible)

/// Check if an asset is a USDZ/3D/AR asset based on mime type and file extension
public func isUsdzAsset(_ asset: Asset) -> Bool {
    let mimeTypeLower = asset.mimeType.lowercased()
    let sourceLower = asset.source.lowercased()
    
    // Check if it's a 3D model file by MIME type
    if mimeTypeLower.hasPrefix("model/") {
        return true
    }
    
    // Check file extensions for 3D/AR files
    return sourceLower.hasSuffix(".usdz") ||
           sourceLower.hasSuffix(".reality") ||
           sourceLower.hasSuffix(".glb") ||
           sourceLower.hasSuffix(".gltf")
}

/// Create an Asset from MainUsdzAssetData (SKIP-compatible factory function)
public func createAssetFromUsdzData(_ assetData: MainUsdzAssetData) -> Asset {
    return Asset(
        id: assetData.id,
        name: assetData.name,
        type: .BINARY, // Default to BINARY
        fileSize: assetData.fileSize,
        mimeType: assetData.mimeType,
        width: assetData.width,
        height: assetData.height,
        source: assetData.source,
        preview: assetData.preview,
        focalPoint: nil,
        tags: [],
        customFields: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
}

/// Extract mainUsdzAsset from a Product (global function for SKIP compatibility)
public func extractMainUsdzAsset(from product: Product) -> Asset? {
    return product.mainUsdzAsset
}

/// Extract mainUsdzAsset from a ProductVariant (global function for SKIP compatibility)
public func extractMainUsdzAsset(from variant: ProductVariant) -> Asset? {
    return variant.mainUsdzAsset
}
