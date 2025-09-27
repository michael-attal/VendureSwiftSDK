import Foundation

// MARK: - Address Input
public struct CreateAddressInput: Codable, Sendable {
    public let fullName: String?
    public let company: String?
    public let streetLine1: String
    public let streetLine2: String?
    public let city: String
    public let province: String?
    public let postalCode: String
    public let countryCode: String
    public let phoneNumber: String?
    public let defaultShippingAddress: Bool?
    public let defaultBillingAddress: Bool?
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(
        fullName: String? = nil,
        company: String? = nil,
        streetLine1: String,
        streetLine2: String? = nil,
        city: String,
        province: String? = nil,
        postalCode: String,
        countryCode: String,
        phoneNumber: String? = nil,
        defaultShippingAddress: Bool? = nil,
        defaultBillingAddress: Bool? = nil,
        customFields: String? = nil
    ) {
        self.fullName = fullName
        self.company = company
        self.streetLine1 = streetLine1
        self.streetLine2 = streetLine2
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.defaultShippingAddress = defaultShippingAddress
        self.defaultBillingAddress = defaultBillingAddress
        self.customFields = customFields
    }
    
    // Helper to create from dictionary
    public static func withCustomFields(
        fullName: String? = nil,
        company: String? = nil,
        streetLine1: String,
        streetLine2: String? = nil,
        city: String,
        province: String? = nil,
        postalCode: String,
        countryCode: String,
        phoneNumber: String? = nil,
        defaultShippingAddress: Bool? = nil,
        defaultBillingAddress: Bool? = nil,
        customFieldsDict: [String: Any]? = nil
    ) -> CreateAddressInput {
        var customFieldsJSON: String? = nil
        if let dict = customFieldsDict {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                customFieldsJSON = String(data: data, encoding: .utf8)
            }
        }
        
        return CreateAddressInput(
            fullName: fullName,
            company: company,
            streetLine1: streetLine1,
            streetLine2: streetLine2,
            city: city,
            province: province,
            postalCode: postalCode,
            countryCode: countryCode,
            phoneNumber: phoneNumber,
            defaultShippingAddress: defaultShippingAddress,
            defaultBillingAddress: defaultBillingAddress,
            customFields: customFieldsJSON
        )
    }
}

public struct UpdateAddressInput: Codable, Sendable {
    public let id: String
    public let fullName: String?
    public let company: String?
    public let streetLine1: String?
    public let streetLine2: String?
    public let city: String?
    public let province: String?
    public let postalCode: String?
    public let countryCode: String?
    public let phoneNumber: String?
    public let defaultShippingAddress: Bool?
    public let defaultBillingAddress: Bool?
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(
        id: String,
        fullName: String? = nil,
        company: String? = nil,
        streetLine1: String? = nil,
        streetLine2: String? = nil,
        city: String? = nil,
        province: String? = nil,
        postalCode: String? = nil,
        countryCode: String? = nil,
        phoneNumber: String? = nil,
        defaultShippingAddress: Bool? = nil,
        defaultBillingAddress: Bool? = nil,
        customFields: String? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.company = company
        self.streetLine1 = streetLine1
        self.streetLine2 = streetLine2
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.defaultShippingAddress = defaultShippingAddress
        self.defaultBillingAddress = defaultBillingAddress
        self.customFields = customFields
    }
    
    // Helper to create from dictionary
    public static func withCustomFields(
        id: String,
        fullName: String? = nil,
        company: String? = nil,
        streetLine1: String? = nil,
        streetLine2: String? = nil,
        city: String? = nil,
        province: String? = nil,
        postalCode: String? = nil,
        countryCode: String? = nil,
        phoneNumber: String? = nil,
        defaultShippingAddress: Bool? = nil,
        defaultBillingAddress: Bool? = nil,
        customFieldsDict: [String: Any]? = nil
    ) -> UpdateAddressInput {
        var customFieldsJSON: String? = nil
        if let dict = customFieldsDict {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                customFieldsJSON = String(data: data, encoding: .utf8)
            }
        }
        
        return UpdateAddressInput(
            id: id,
            fullName: fullName,
            company: company,
            streetLine1: streetLine1,
            streetLine2: streetLine2,
            city: city,
            province: province,
            postalCode: postalCode,
            countryCode: countryCode,
            phoneNumber: phoneNumber,
            defaultShippingAddress: defaultShippingAddress,
            defaultBillingAddress: defaultBillingAddress,
            customFields: customFieldsJSON
        )
    }
}

// MARK: - Customer Input
public struct CreateCustomerInput: Codable, Sendable {
    public let title: String?
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String?
    public let emailAddress: String
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(
        title: String? = nil,
        firstName: String,
        lastName: String,
        phoneNumber: String? = nil,
        emailAddress: String,
        customFields: String? = nil
    ) {
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.customFields = customFields
    }
    
    // Helper to create from dictionary
    public static func withCustomFields(
        title: String? = nil,
        firstName: String,
        lastName: String,
        phoneNumber: String? = nil,
        emailAddress: String,
        customFieldsDict: [String: Any]? = nil
    ) -> CreateCustomerInput {
        var customFieldsJSON: String? = nil
        if let dict = customFieldsDict {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                customFieldsJSON = String(data: data, encoding: .utf8)
            }
        }
        
        return CreateCustomerInput(
            title: title,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            emailAddress: emailAddress,
            customFields: customFieldsJSON
        )
    }
}

public struct UpdateCustomerInput: Codable, Sendable {
    public let title: String?
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        customFields: String? = nil
    ) {
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.customFields = customFields
    }
    
    // Helper to create from dictionary
    public static func withCustomFields(
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        customFieldsDict: [String: Any]? = nil
    ) -> UpdateCustomerInput {
        var customFieldsJSON: String? = nil
        if let dict = customFieldsDict {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                customFieldsJSON = String(data: data, encoding: .utf8)
            }
        }
        
        return UpdateCustomerInput(
            title: title,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            customFields: customFieldsJSON
        )
    }
}

// MARK: - Authentication Input
public struct RegisterCustomerInput: Codable, Sendable {
    public let emailAddress: String
    public let title: String?
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let password: String?
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(
        emailAddress: String,
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        password: String? = nil,
        customFields: String? = nil
    ) {
        self.emailAddress = emailAddress
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.password = password
        self.customFields = customFields
    }
    
    // Helper to create from dictionary
    public static func withCustomFields(
        emailAddress: String,
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        password: String? = nil,
        customFieldsDict: [String: Any]? = nil
    ) -> RegisterCustomerInput {
        var customFieldsJSON: String? = nil
        if let dict = customFieldsDict {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                customFieldsJSON = String(data: data, encoding: .utf8)
            }
        }
        
        return RegisterCustomerInput(
            emailAddress: emailAddress,
            title: title,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            password: password,
            customFields: customFieldsJSON
        )
    }
}

// MARK: - Order Input
public struct UpdateOrderInput: Codable, Sendable {
    public let customFields: String? // JSON string instead of [String: AnyCodable]
    
    public init(customFields: String? = nil) {
        self.customFields = customFields
    }
    
    // Helper to create from dictionary
    public static func withCustomFields(customFieldsDict: [String: Any]?) -> UpdateOrderInput {
        var customFieldsJSON: String? = nil
        if let dict = customFieldsDict {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                customFieldsJSON = String(data: data, encoding: .utf8)
            }
        }
        
        return UpdateOrderInput(customFields: customFieldsJSON)
    }
}

// MARK: - Search Input
public struct FacetValueFilterInput: Codable, Sendable {
    public let and: String?
    public let or: [String]?
    
    public init(and: String? = nil, or: [String]? = nil) {
        self.and = and
        self.or = or
    }
}

// MARK: - Additional Helper Extensions

extension CreateAddressInput {
    /// Convert to JSON string for GraphQL variables
    public func toVariablesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension UpdateAddressInput {
    /// Convert to JSON string for GraphQL variables
    public func toVariablesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension CreateCustomerInput {
    /// Convert to JSON string for GraphQL variables
    public func toVariablesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension UpdateCustomerInput {
    /// Convert to JSON string for GraphQL variables
    public func toVariablesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension RegisterCustomerInput {
    /// Convert to JSON string for GraphQL variables
    public func toVariablesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension UpdateOrderInput {
    /// Convert to JSON string for GraphQL variables
    public func toVariablesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}
