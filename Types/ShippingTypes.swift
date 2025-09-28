import Foundation

// MARK: - Shipping Method

/// Represents a shipping method
public struct ShippingMethod: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let name: String
    public let description: String
    public let fulfillmentHandlerCode: String
    public let checker: ConfigurableOperation
    public let calculator: ConfigurableOperation
    public let translations: [ShippingMethodTranslation]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String,
        code: String,
        name: String,
        description: String,
        fulfillmentHandlerCode: String,
        checker: ConfigurableOperation,
        calculator: ConfigurableOperation,
        translations: [ShippingMethodTranslation] = [],
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.description = description
        self.fulfillmentHandlerCode = fulfillmentHandlerCode
        self.checker = checker
        self.calculator = calculator
        self.translations = translations
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Shipping method translation
public struct ShippingMethodTranslation: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let name: String
    public let description: String
    
    public init(languageCode: LanguageCode, name: String, description: String) {
        self.languageCode = languageCode
        self.name = name
        self.description = description
    }
}

/// Shipping method quote for an order
public struct ShippingMethodQuote: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let price: Double
    public let priceWithTax: Double
    public let code: String
    public let name: String
    public let description: String
    public let metadata: [String: AnyCodable]?
    public let customFields: [String: AnyCodable]?
    
    public init(
        id: String,
        price: Double,
        priceWithTax: Double,
        code: String,
        name: String,
        description: String,
        metadata: [String: AnyCodable]? = nil,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.id = id
        self.price = price
        self.priceWithTax = priceWithTax
        self.code = code
        self.name = name
        self.description = description
        self.metadata = metadata
        self.customFields = customFields
    }
}

/// Shipping line in an order
public struct ShippingLine: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let shippingMethod: ShippingMethod
    public let price: Double
    public let priceWithTax: Double
    public let discountedPrice: Double
    public let discountedPriceWithTax: Double
    public let taxLines: [TaxLine]
    
    public init(
        id: String,
        shippingMethod: ShippingMethod,
        price: Double,
        priceWithTax: Double,
        discountedPrice: Double,
        discountedPriceWithTax: Double,
        taxLines: [TaxLine] = []
    ) {
        self.id = id
        self.shippingMethod = shippingMethod
        self.price = price
        self.priceWithTax = priceWithTax
        self.discountedPrice = discountedPrice
        self.discountedPriceWithTax = discountedPriceWithTax
        self.taxLines = taxLines
    }
}

// MARK: - Shipping Lists

/// List of shipping methods
public struct ShippingMethodList: Codable, Sendable {
    public let items: [ShippingMethod]
    public let totalItems: Int
    
    public init(items: [ShippingMethod], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

// MARK: - Shipping Errors

/// Error when shipping method is ineligible
public struct IneligibleShippingMethodError: Codable, Hashable, Sendable {
    public let errorCode: ErrorCode
    public let message: String
    public let eligibilityCheckerMessage: String?
    
    public init(
        errorCode: ErrorCode = .INELIGIBLE_SHIPPING_METHOD_ERROR,
        message: String,
        eligibilityCheckerMessage: String? = nil
    ) {
        self.errorCode = errorCode
        self.message = message
        self.eligibilityCheckerMessage = eligibilityCheckerMessage
    }
}

