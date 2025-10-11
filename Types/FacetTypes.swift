import Foundation

// MARK: - Facet Types

/// Represents a facet for product categorization
public struct Facet: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let isPrivate: Bool?
    public let values: [FacetValue]?
    public let translations: [FacetTranslation]?
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        code: String,
        isPrivate: Bool? = nil,
        values: [FacetValue]? = nil,
        translations: [FacetTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil,
        languageCode: LanguageCode? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.isPrivate = isPrivate
        self.values = values
        self.translations = translations
        self.customFields = customFields
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a facet value for product filtering
public struct FacetValue: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let facet: Facet
    public let facetId: String?
    public let translations: [FacetValueTranslation]?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        code: String,
        facet: Facet,
        facetId: String? = nil,
        translations: [FacetValueTranslation]? = nil,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.facet = facet
        self.facetId = facetId
        self.translations = translations
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Input type for filtering by facet values
public struct FacetValueFilterInput: Codable, Sendable {
    public let and: String?
    public let or: [String]?

    public init(and: String? = nil, or: [String]? = nil) {
        self.and = and
        self.or = or
    }
}
