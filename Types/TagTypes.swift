import Foundation

// MARK: - Tag Types

public struct Tag: Codable, Hashable, Sendable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let value: String

    public init(id: String, createdAt: Date, updatedAt: Date, value: String) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.value = value
    }
}
