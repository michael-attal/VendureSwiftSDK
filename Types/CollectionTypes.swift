import Foundation

// MARK: - Collection Types

/// Represents a product collection
public struct VendureCollection: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let description: String
    public let breadcrumbs: [CollectionBreadcrumb]?
    public let position: Int?
    public let isRoot: Bool?
    public let parentId: String?
    public let childrenIds: [String]?
    public let translations: [VendureCollectionTranslation]?
    public let featuredAsset: Asset?
    public let assets: [Asset]?
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        slug: String,
        description: String,
        breadcrumbs: [CollectionBreadcrumb]? = nil,
        position: Int? = nil,
        isRoot: Bool? = nil,
        parentId: String? = nil,
        childrenIds: [String]? = nil,
        translations: [VendureCollectionTranslation]? = nil,
        featuredAsset: Asset? = nil,
        assets: [Asset]? = nil,
        customFields: [String: AnyCodable]? = nil,
        languageCode: LanguageCode? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil)
    {
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

// Note: ConfigurableOperation and VendureCollectionFilterParameter are defined in VendureTypes.swift
