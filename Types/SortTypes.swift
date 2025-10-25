import Foundation

// MARK: - Sort Parameters

/// Generic sort parameter for any entity
public struct SortParameter<Field: Hashable & Codable & Sendable>: Hashable, Codable, Sendable {
    public let id: Field?
    public let createdAt: Field?
    public let updatedAt: Field?
    public let name: Field?
    public let slug: Field?

    // Optional extra fields
    public let extraFields: [String: Field]?

    public init(id: Field? = nil,
                createdAt: Field? = nil,
                updatedAt: Field? = nil,
                name: Field? = nil,
                slug: Field? = nil,
                extraFields: [String: Field]? = nil)
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.slug = slug
        self.extraFields = extraFields
    }
}

public struct NumberOperators: Hashable, Codable, Sendable {
    public let eq: Double?
    public let lt: Double?
    public let lte: Double?
    public let gt: Double?
    public let gte: Double?
    public let between: NumberRange?

    public init(eq: Double? = nil, lt: Double? = nil, lte: Double? = nil, gt: Double? = nil, gte: Double? = nil, between: NumberRange? = nil) {
        self.eq = eq
        self.lt = lt
        self.lte = lte
        self.gt = gt
        self.gte = gte
        self.between = between
    }
}

public struct NumberRange: Hashable, Codable, Sendable {
    public let start: Double
    public let end: Double

    public init(start: Double, end: Double) {
        self.start = start
        self.end = end
    }
}

/// Sort orders
public enum SortOrder: String, Hashable, Codable, CaseIterable, Sendable {
    case ASC, DESC
}

/// Search result sort parameter
public struct SearchResultSortParameter: Hashable, Codable, Sendable {
    public let name: SortOrder?
    public let price: SortOrder?

    public init(name: SortOrder? = nil, price: SortOrder? = nil) {
        self.name = name
        self.price = price
    }
}
