import Foundation

// MARK: - Address Input

// TODO: Make it generic to avoid duplication

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

public struct CreateCustomerInput: Codable, Sendable {
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

public struct UpdateCustomerInput: Codable, Sendable {
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

public struct RegisterCustomerInput: Codable, Sendable {
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

// MARK: - Order Input

public struct UpdateOrderInput: Codable, Sendable {
    public let customFields: [String: AnyCodable]?

    public init(customFields: [String: AnyCodable]? = nil) {
        self.customFields = customFields
    }
}
