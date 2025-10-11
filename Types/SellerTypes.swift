import Foundation

public struct Seller: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
