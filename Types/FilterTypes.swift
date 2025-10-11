import Foundation

// MARK: - Filter Parameters

/// Generic filter parameter for any entity
public struct FilterParameter<Id: Codable & Sendable,
    DateField: Codable & Sendable,
    StringField: Codable & Sendable,
    NumberField: Codable & Sendable,
    BooleanField: Codable & Sendable>: Codable, Sendable
{
    public let id: Id?
    public let createdAt: DateField?
    public let updatedAt: DateField?
    public let languageCode: StringField?
    public let name: StringField?
    public let slug: StringField?
    public let description: StringField?

    // Optional numeric and boolean fields
    public let numberFields: NumberField?
    public let booleanFields: BooleanField?

    // Additional custom fields
    public let extraFields: [String: AnyCodable]?

    public init(id: Id? = nil,
                createdAt: DateField? = nil,
                updatedAt: DateField? = nil,
                languageCode: StringField? = nil,
                name: StringField? = nil,
                slug: StringField? = nil,
                description: StringField? = nil,
                numberFields: NumberField? = nil,
                booleanFields: BooleanField? = nil,
                extraFields: [String: AnyCodable]? = nil)
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
        self.numberFields = numberFields
        self.booleanFields = booleanFields
        self.extraFields = extraFields
    }
}

// MARK: - Filter Operators (continued from SystemOperations)

public struct IDOperators: Codable, Sendable {
    public let eq: String?
    public let notEq: String?
    public let `in`: [String]?
    public let notIn: [String]?

    public init(eq: String? = nil, notEq: String? = nil, in: [String]? = nil, notIn: [String]? = nil) {
        self.eq = eq
        self.notEq = notEq
        self.in = `in`
        self.notIn = notIn
    }
}

public struct StringOperators: Codable, Sendable {
    public let eq: String?
    public let notEq: String?
    public let contains: String?
    public let notContains: String?
    public let `in`: [String]?
    public let notIn: [String]?
    public let regex: String?

    public init(eq: String? = nil, notEq: String? = nil, contains: String? = nil, notContains: String? = nil, in: [String]? = nil, notIn: [String]? = nil, regex: String? = nil) {
        self.eq = eq
        self.notEq = notEq
        self.contains = contains
        self.notContains = notContains
        self.in = `in`
        self.notIn = notIn
        self.regex = regex
    }
}

public struct BooleanOperators: Codable, Sendable {
    public let eq: Bool?

    public init(eq: Bool? = nil) {
        self.eq = eq
    }
}

/// Represents a date range
public struct DateRange: Codable, Hashable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

public struct DateOperators: Codable, Sendable {
    public let eq: Date?
    public let before: Date?
    public let after: Date?
    public let between: DateRange?

    public init(eq: Date? = nil, before: Date? = nil, after: Date? = nil, between: DateRange? = nil) {
        self.eq = eq
        self.before = before
        self.after = after
        self.between = between
    }
}
