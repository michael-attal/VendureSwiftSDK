import Foundation

// MARK: - Facet Types

/// Represents a facet for product categorization
public struct Facet: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let isPrivate: Bool
    public let values: [FacetValue]
    public let translations: [FacetTranslation]
    public let customFields: [String: AnyCodable]?
    public let languageCode: LanguageCode
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, code: String, isPrivate: Bool,
                values: [FacetValue] = [], translations: [FacetTranslation] = [],
                customFields: [String: AnyCodable]? = nil, languageCode: LanguageCode,
                createdAt: Date, updatedAt: Date) {
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
    public let facetId: String
    public let translations: [FacetValueTranslation]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, code: String, facet: Facet, facetId: String,
                translations: [FacetValueTranslation] = [], customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
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

// Note: FacetTranslation, FacetValueTranslation, and FacetValueFilterInput are defined in ProductTypes.swift and InputTypes.swift
