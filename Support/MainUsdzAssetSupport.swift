import Foundation

/// Internal storage for raw GraphQL JSON data related to Product and ProductVariant USDZ assets.
/// This class is used by ProductExtensions to retrieve raw JSON for parsing.
///
/// NOTE: Assumes product IDs and product variant IDs are unique across the system
/// to avoid collisions in storage. If not, separate storage mechanisms or
/// combined keys (e.g., "product-<id>" or "variant-<id>") would be needed.
@MainActor final class ProductMainUsdzAssetStorage {
    @MainActor static let shared = ProductMainUsdzAssetStorage()

    private var jsonStorage: [String: String] = [: ]

    private init() {}

    /// Stores raw JSON for a given ID (can be product ID or product variant ID).
    func setJson(id: String, json: String) {
        jsonStorage[id] = json
        print("💾 Stored raw JSON for ID \(id)")
    }

    /// Retrieves raw JSON for a given ID (product ID or product variant ID).
    func getJson(id: String) -> String? {
        return jsonStorage[id]
    }
}

/// Provides support functions for mainUsdzAsset feature.
/// This class primarily enables raw data capture, allowing ProductExtensions to access full GraphQL responses.
public class ProductMainUsdzAssetSupport {
    
    // A flag to indicate if raw data capture is enabled.
    // This flag can be used by other parts of the system to conditionally
    // enable or disable logic that relies on raw data.
    @MainActor private static var _isRawDataCaptureEnabled = false

    /// Enables raw data capture for mainUsdzAsset support.
    /// This should be called early in the app lifecycle (e.g., in AppDelegate or App.swift).
    @MainActor public static func enableRawDataCapture() {
        _isRawDataCaptureEnabled = true
        print("📱 ProductMainUsdzAssetSupport: Raw data capture ENABLED.")
        // Additional setup or configuration can go here if needed.
    }
    
    /// Checks if raw data capture is enabled.
    @MainActor public static func isRawDataCaptureEnabled() -> Bool {
        return _isRawDataCaptureEnabled
    }
}