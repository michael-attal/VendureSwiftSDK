import Foundation

// MARK: - Asset Types

/// Represents an asset (image, document, etc.)
public struct Asset: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String?
    public let type: AssetType?
    public let fileSize: Int?
    public let mimeType: String?
    public let width: Int?
    public let height: Int?
    public let source: String
    public let preview: String
    public let focalPoint: Coordinate?
    public let tags: [Tag]?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String? = nil,
        type: AssetType? = nil,
        fileSize: Int? = nil,
        mimeType: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        source: String,
        preview: String,
        focalPoint: Coordinate? = nil,
        tags: [Tag]? = nil,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.width = width
        self.height = height
        self.source = source
        self.preview = preview
        self.focalPoint = focalPoint
        self.tags = tags
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Asset type enumeration
public enum AssetType: String, Codable, CaseIterable, Sendable {
    case IMAGE, VIDEO, AUDIO, BINARY, OTHER
}
