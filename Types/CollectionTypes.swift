import Foundation

// MARK: - Collection Types

/// Represents a product collection
public struct VendureCollection: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String
    public let breadcrumbs: [CollectionBreadcrumb]
    public let position: Int
    public let isRoot: Bool
    public let parentId: String?
    public let childrenIds: [String]?
    public let translations: [VendureCollectionTranslation]
    public let featuredAsset: Asset?
    public let assets: [Asset]
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, slug: String, description: String,
                breadcrumbs: [CollectionBreadcrumb] = [], position: Int, isRoot: Bool,
                parentId: String? = nil, childrenIds: [String]? = nil,
                translations: [VendureCollectionTranslation] = [],
                featuredAsset: Asset? = nil, assets: [Asset] = [],
                customFields: [String: AnyCodable]? = nil,
                languageCode: LanguageCode, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.breadcrumbs = breadcrumbs
        self.position = position
        self.isRoot = isRoot
        self.parentId = parentId
        self.childrenIds = childrenIds
        self.translations = translations
        self.featuredAsset = featuredAsset
        self.assets = assets
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Collection breadcrumb
public struct CollectionBreadcrumb: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    
    public init(id: String, name: String, slug: String) {
        self.id = id
        self.name = name
        self.slug = slug
    }
}

/// Collection translation
public struct VendureCollectionTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    public let slug: String
    public let description: String
    
    public init(languageCode: LanguageCode, name: String, slug: String, description: String) {
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
    }
}

// Note: ConfigurableOperation and VendureCollectionFilterParameter are defined in VendureTypes.swift
