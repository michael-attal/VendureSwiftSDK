import Foundation

// MARK: - Address Input
public struct CreateAddressInput: Codable {
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
    public let customFields: [String: AnyCodable]?
    
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
        customFields: [String: AnyCodable]? = nil
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
}

public struct UpdateAddressInput: Codable {
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
    public let customFields: [String: AnyCodable]?
    
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
        customFields: [String: AnyCodable]? = nil
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
}

// MARK: - Customer Input
public struct CreateCustomerInput: Codable {
    public let title: String?
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String?
    public let emailAddress: String
    public let customFields: [String: AnyCodable]?
    
    public init(
        title: String? = nil,
        firstName: String,
        lastName: String,
        phoneNumber: String? = nil,
        emailAddress: String,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.customFields = customFields
    }
}

public struct UpdateCustomerInput: Codable {
    public let title: String?
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let customFields: [String: AnyCodable]?
    
    public init(
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.customFields = customFields
    }
}

// MARK: - Authentication Input
public struct RegisterCustomerInput: Codable {
    public let emailAddress: String
    public let title: String?
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let password: String?
    public let customFields: [String: AnyCodable]?
    
    public init(
        emailAddress: String,
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        password: String? = nil,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.emailAddress = emailAddress
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.password = password
        self.customFields = customFields
    }
}

// MARK: - Payment Input
public struct PaymentInput: Codable {
    public let method: String
    public let metadata: [String: AnyCodable]?
    
    public init(
        method: String,
        metadata: [String: AnyCodable]? = nil
    ) {
        self.method = method
        self.metadata = metadata
    }
}

// MARK: - Order Input
public struct UpdateOrderInput: Codable {
    public let customFields: [String: AnyCodable]?
    
    public init(customFields: [String: AnyCodable]? = nil) {
        self.customFields = customFields
    }
}

// MARK: - Search Input (Moved FacetValueFilterInput to maintain dependency)
public struct FacetValueFilterInput: Codable {
    public let and: String?
    public let or: [String]?
    
    public init(and: String? = nil, or: [String]? = nil) {
        self.and = and
        self.or = or
    }
}


