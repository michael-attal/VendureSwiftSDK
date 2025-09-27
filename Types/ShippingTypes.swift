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
    public let customFields: String?
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
        customFields: String? = nil,
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
    
    // Custom decoding to handle customFields as JSON string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        self.id = try container.decode(String.self, forKey: .id)
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.fulfillmentHandlerCode = try container.decode(String.self, forKey: .fulfillmentHandlerCode)
        self.checker = try container.decode(ConfigurableOperation.self, forKey: .checker)
        self.calculator = try container.decode(ConfigurableOperation.self, forKey: .calculator)
        self.translations = try container.decode([ShippingMethodTranslation].self, forKey: .translations)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Handle customFields - try to decode as dictionary and convert to JSON string
        if let customFieldsDict = try? container.decodeIfPresent([String: JSONValue].self, forKey: .customFields),
           let jsonData = try? JSONEncoder().encode(customFieldsDict) {
            self.customFields = String(data: jsonData, encoding: .utf8)
        } else {
            self.customFields = try container.decodeIfPresent(String.self, forKey: .customFields)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(fulfillmentHandlerCode, forKey: .fulfillmentHandlerCode)
        try container.encode(checker, forKey: .checker)
        try container.encode(calculator, forKey: .calculator)
        try container.encode(translations, forKey: .translations)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Encode customFields
        if let customFields = customFields {
            // If it's already a JSON string, try to parse and re-encode as dictionary
            if let data = customFields.data(using: .utf8),
               let dict = try? JSONDecoder().decode([String: JSONValue].self, from: data) {
                try container.encode(dict, forKey: .customFields)
            } else {
                try container.encode(customFields, forKey: .customFields)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, code, name, description, fulfillmentHandlerCode, checker, calculator, translations, customFields, createdAt, updatedAt
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
    public let metadata: String? // JSON string instead of [String: AnyCodable]
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(
        id: String,
        price: Double,
        priceWithTax: Double,
        code: String,
        name: String,
        description: String,
        metadata: String? = nil,
        customFields: String? = nil
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
    
    // Custom decoding to handle metadata and customFields as JSON strings
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        self.id = try container.decode(String.self, forKey: .id)
        self.price = try container.decode(Double.self, forKey: .price)
        self.priceWithTax = try container.decode(Double.self, forKey: .priceWithTax)
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        
        // Handle metadata - try to decode as dictionary and convert to JSON string
        if let metadataDict = try? container.decodeIfPresent([String: JSONValue].self, forKey: .metadata),
           let jsonData = try? JSONEncoder().encode(metadataDict) {
            self.metadata = String(data: jsonData, encoding: .utf8)
        } else {
            self.metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        }
        
        // Handle customFields - try to decode as dictionary and convert to JSON string
        if let customFieldsDict = try? container.decodeIfPresent([String: JSONValue].self, forKey: .customFields),
           let jsonData = try? JSONEncoder().encode(customFieldsDict) {
            self.customFields = String(data: jsonData, encoding: .utf8)
        } else {
            self.customFields = try container.decodeIfPresent(String.self, forKey: .customFields)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(price, forKey: .price)
        try container.encode(priceWithTax, forKey: .priceWithTax)
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        
        // Encode metadata
        if let metadata = metadata {
            // If it's already a JSON string, try to parse and re-encode as dictionary
            if let data = metadata.data(using: .utf8),
               let dict = try? JSONDecoder().decode([String: JSONValue].self, from: data) {
                try container.encode(dict, forKey: .metadata)
            } else {
                try container.encode(metadata, forKey: .metadata)
            }
        }
        
        // Encode customFields
        if let customFields = customFields {
            // If it's already a JSON string, try to parse and re-encode as dictionary
            if let data = customFields.data(using: .utf8),
               let dict = try? JSONDecoder().decode([String: JSONValue].self, from: data) {
                try container.encode(dict, forKey: .customFields)
            } else {
                try container.encode(customFields, forKey: .customFields)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, price, priceWithTax, code, name, description, metadata, customFields
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

// MARK: - Helper type for JSON handling

/// Helper enum for handling JSON values in a type-safe way
public enum JSONValue: Codable, Hashable, Sendable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode JSONValue")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}
