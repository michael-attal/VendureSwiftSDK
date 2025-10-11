import Foundation

/// Represents a channel
public struct Channel: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let token: String
    public let description: String?
    public let defaultLanguageCode: LanguageCode
    public let availableLanguageCodes: [LanguageCode]
    public let defaultCurrencyCode: CurrencyCode
    public let availableCurrencyCodes: [CurrencyCode]
    public let defaultShippingZone: Zone?
    public let defaultTaxZone: Zone?
    public let pricesIncludeTax: Bool
    public let seller: Seller?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        code: String,
        token: String,
        description: String? = nil,
        defaultLanguageCode: LanguageCode,
        availableLanguageCodes: [LanguageCode],
        defaultCurrencyCode: CurrencyCode,
        availableCurrencyCodes: [CurrencyCode],
        defaultShippingZone: Zone? = nil,
        defaultTaxZone: Zone? = nil,
        pricesIncludeTax: Bool,
        seller: Seller? = nil,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.token = token
        self.description = description
        self.defaultLanguageCode = defaultLanguageCode
        self.availableLanguageCodes = availableLanguageCodes
        self.defaultCurrencyCode = defaultCurrencyCode
        self.availableCurrencyCodes = availableCurrencyCodes
        self.defaultShippingZone = defaultShippingZone
        self.defaultTaxZone = defaultTaxZone
        self.pricesIncludeTax = pricesIncludeTax
        self.seller = seller
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
