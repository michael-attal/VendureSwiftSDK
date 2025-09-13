import Foundation
import SkipFoundation

// MARK: - Shipping Method

/// Represents a shipping method
public struct ShippingMethod: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
    public let id: String
    public let code: String
    public let name: String
    public let description: String
    public let fulfillmentHandlerCode: String
    public let checker: ConfigurableOperation
    public let calculator: ConfigurableOperation
    public let translations: [ShippingMethodTranslation]
    public var customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        fulfillmentHandlerCode = try container.decode(String.self, forKey: .fulfillmentHandlerCode)
        checker = try container.decode(ConfigurableOperation.self, forKey: .checker)
        calculator = try container.decode(ConfigurableOperation.self, forKey: .calculator)
        translations = try container.decode([ShippingMethodTranslation].self, forKey: .translations)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode existing customFields if present
        customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "ShippingMethod")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, code, name, description, fulfillmentHandlerCode, checker, calculator, translations, customFields, createdAt, updatedAt
    }
    
    public init(id: String, code: String, name: String, description: String,
                fulfillmentHandlerCode: String, checker: ConfigurableOperation,
                calculator: ConfigurableOperation, translations: [ShippingMethodTranslation] = [],
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
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
public struct ShippingMethodQuote: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
    public let id: String
    public let price: Double
    public let priceWithTax: Double
    public let code: String
    public let name: String
    public let description: String
    public let metadata: [String: AnyCodable]?
    public var customFields: [String: AnyCodable]?
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        id = try container.decode(String.self, forKey: .id)
        price = try container.decode(Double.self, forKey: .price)
        priceWithTax = try container.decode(Double.self, forKey: .priceWithTax)
        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
        
        // Decode existing customFields if present
        customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "ShippingMethodQuote")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, price, priceWithTax, code, name, description, metadata, customFields
    }
    
    public init(id: String, price: Double, priceWithTax: Double, code: String,
                name: String, description: String, metadata: [String: AnyCodable]? = nil,
                customFields: [String: AnyCodable]? = nil) {
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
    
    public init(id: String, shippingMethod: ShippingMethod, price: Double,
                priceWithTax: Double, discountedPrice: Double, discountedPriceWithTax: Double,
                taxLines: [TaxLine] = []) {
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
    
    public init(errorCode: ErrorCode = .INELIGIBLE_SHIPPING_METHOD_ERROR, message: String,
                eligibilityCheckerMessage: String? = nil) {
        self.errorCode = errorCode
        self.message = message
        self.eligibilityCheckerMessage = eligibilityCheckerMessage
    }
}
