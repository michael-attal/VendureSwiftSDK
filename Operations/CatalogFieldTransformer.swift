//
//  CatalogFieldTransformer.swift
//  VendureSwiftSDK
//
//  Created by NovaCommerce Integration
//

import Foundation

/// Protocol for transforming catalog fields before decoding - Skip compatible
public protocol CatalogFieldTransformer: Sendable {
    /// Transform product data before decoding into CatalogProduct
    /// - Parameters:
    ///   - productDict: The raw product dictionary from GraphQL
    ///   - unknownFields: Dictionary of fields not recognized by CatalogProduct
    /// - Returns: The modified product dictionary ready for decoding
    func transformProductFields(_ productDict: [String: Any], unknownFields: [String: Any]) -> [String: Any]
    
    /// Transform variant data before decoding into CatalogProductVariant
    /// - Parameters:
    ///   - variantDict: The raw variant dictionary from GraphQL
    ///   - unknownFields: Dictionary of fields not recognized by CatalogProductVariant
    /// - Returns: The modified variant dictionary ready for decoding
    func transformVariantFields(_ variantDict: [String: Any], unknownFields: [String: Any]) -> [String: Any]
}

/// Default implementation that does no transformation
public struct DefaultCatalogFieldTransformer: CatalogFieldTransformer {
    public init() {}
    
    public func transformProductFields(_ productDict: [String: Any], unknownFields: [String: Any]) -> [String: Any] {
        return productDict
    }
    
    public func transformVariantFields(_ variantDict: [String: Any], unknownFields: [String: Any]) -> [String: Any] {
        return variantDict
    }
}

/// Global field transformer instance - can be overridden by applications
@MainActor
public var globalCatalogFieldTransformer: CatalogFieldTransformer = DefaultCatalogFieldTransformer()

/// Function to register a custom field transformer
@MainActor
public func setCatalogFieldTransformer(_ transformer: CatalogFieldTransformer) {
    globalCatalogFieldTransformer = transformer
}
