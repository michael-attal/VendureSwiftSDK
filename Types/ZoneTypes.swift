import Foundation

// MARK: - Zone types

/// Represents a zone
public struct Zone: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let members: [Region]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        members: [Region] = [],
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a region (country or province)
public final class Region: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let enabled: Bool
    public let parent: Region?
    public let parentId: String?
    public let type: String
    public let translations: [RegionTranslation]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        code: String,
        name: String,
        enabled: Bool,
        parent: Region? = nil,
        parentId: String? = nil,
        type: String,
        translations: [RegionTranslation]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.enabled = enabled
        self.parent = parent
        self.parentId = parentId
        self.type = type
        self.translations = translations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.id == rhs.id
    }
}
