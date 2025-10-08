import Foundation

// MARK: - Address Types

/// Represents an address
public struct Address: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let fullName: String?
    public let company: String?
    public let streetLine1: String
    public let streetLine2: String?
    public let city: String?
    public let province: String?
    public let postalCode: String?
    public let country: Country
    public let phoneNumber: String?
    public let defaultShippingAddress: Bool?
    public let defaultBillingAddress: Bool?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date

    public init(id: String, fullName: String? = nil, company: String? = nil,
                streetLine1: String, streetLine2: String? = nil, city: String? = nil,
                province: String? = nil, postalCode: String? = nil, country: Country,
                phoneNumber: String? = nil, defaultShippingAddress: Bool? = nil,
                defaultBillingAddress: Bool? = nil, customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date)
    {
        self.id = id
        self.fullName = fullName
        self.company = company
        self.streetLine1 = streetLine1
        self.streetLine2 = streetLine2
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.country = country
        self.phoneNumber = phoneNumber
        self.defaultShippingAddress = defaultShippingAddress
        self.defaultBillingAddress = defaultBillingAddress
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a country
public struct Country: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let enabled: Bool
    public let translations: [CountryTranslation]

    public init(id: String, code: String, name: String, enabled: Bool, translations: [CountryTranslation] = []) {
        self.id = id
        self.code = code
        self.name = name
        self.enabled = enabled
        self.translations = translations
    }
}
