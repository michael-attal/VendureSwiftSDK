import Foundation

// MARK: - Generic Input Protocol Base

/// Protocol for all creation inputs
public protocol CreateInput: Hashable, Codable, Sendable {}

/// Protocol for all update inputs
public protocol UpdateInput: Hashable, Codable, Sendable {
    var id: String { get }
}

// MARK: - Address Input Types

public struct CreateAddressInput: CreateInput {
    public let fullName: String?
    public let company: String?
    public let streetLine1: String // Required in Vendure
    public let streetLine2: String?
    public let city: String?
    public let province: String?
    public let postalCode: String?
    public let countryCode: String // Required - ISO 2-letter code
    public let phoneNumber: String?
    public let defaultShippingAddress: Bool?
    public let defaultBillingAddress: Bool?
    public let customFields: [String: AnyCodable]?

    public init(
        fullName: String? = nil,
        company: String? = nil,
        streetLine1: String,
        streetLine2: String? = nil,
        city: String? = nil,
        province: String? = nil,
        postalCode: String? = nil,
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

public struct UpdateAddressInput: UpdateInput {
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

// MARK: - Customer Input Types

public struct CreateCustomerInput: CreateInput {
    public let title: String?
    public let firstName: String // Required
    public let lastName: String // Required
    public let phoneNumber: String?
    public let emailAddress: String // Required
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

public struct UpdateCustomerInput: Hashable, Codable, Sendable {
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

public struct RegisterCustomerInput: Hashable, Codable, Sendable {
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

// MARK: - Order Input Types

public struct UpdateOrderInput: Hashable, Codable, Sendable {
    public let customFields: [String: AnyCodable]?

    public init(customFields: [String: AnyCodable]? = nil) {
        self.customFields = customFields
    }
}

public struct AddItemToOrderInput: Hashable, Codable, Sendable {
    public let productVariantId: String
    public let quantity: Int
    public let customFields: [String: AnyCodable]?

    public init(
        productVariantId: String,
        quantity: Int,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.productVariantId = productVariantId
        self.quantity = quantity
        self.customFields = customFields
    }
}

public struct AdjustOrderLineInput: Hashable, Codable, Sendable {
    public let orderLineId: String
    public let quantity: Int
    public let customFields: [String: AnyCodable]?

    public init(
        orderLineId: String,
        quantity: Int,
        customFields: [String: AnyCodable]? = nil
    ) {
        self.orderLineId = orderLineId
        self.quantity = quantity
        self.customFields = customFields
    }
}

public struct RemoveOrderLineInput: Hashable, Codable, Sendable {
    public let orderLineId: String

    public init(orderLineId: String) {
        self.orderLineId = orderLineId
    }
}

public struct ApplyCouponCodeInput: Hashable, Codable, Sendable {
    public let couponCode: String

    public init(couponCode: String) {
        self.couponCode = couponCode
    }
}

// MARK: - Payment Input Types

public struct PaymentInput: Hashable, Codable, Sendable {
    /// Should correspond to the code property of a PaymentMethod
    public let method: String
    /// Arbitrary data passed to PaymentMethodHandler's createPayment()
    public let metadata: [String: AnyCodable]?

    public init(method: String, metadata: [String: AnyCodable]? = nil) {
        self.method = method
        self.metadata = metadata
    }
}

// MARK: - Authentication Input Types

public struct AuthenticationInput: Hashable, Codable, Sendable {
    public let native: NativeAuthInput?

    public init(native: NativeAuthInput? = nil) {
        self.native = native
    }
}

public struct NativeAuthInput: Hashable, Codable, Sendable {
    public let username: String
    public let password: String
    public let rememberMe: Bool?

    public init(username: String, password: String, rememberMe: Bool? = nil) {
        self.username = username
        self.password = password
        self.rememberMe = rememberMe
    }
}

public struct LoginInput: Hashable, Codable, Sendable {
    public let username: String
    public let password: String
    public let rememberMe: Bool?

    public init(username: String, password: String, rememberMe: Bool? = nil) {
        self.username = username
        self.password = password
        self.rememberMe = rememberMe
    }
}

// MARK: - Password Reset Input Types

public struct RequestPasswordResetInput: Hashable, Codable, Sendable {
    public let emailAddress: String

    public init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

public struct ResetPasswordInput: Hashable, Codable, Sendable {
    public let token: String
    public let password: String

    public init(token: String, password: String) {
        self.token = token
        self.password = password
    }
}

public struct UpdateCustomerPasswordInput: Hashable, Codable, Sendable {
    public let currentPassword: String
    public let newPassword: String

    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

// MARK: - Email Update Input Types

public struct RequestUpdateCustomerEmailAddressInput: Hashable, Codable, Sendable {
    public let password: String
    public let newEmailAddress: String

    public init(password: String, newEmailAddress: String) {
        self.password = password
        self.newEmailAddress = newEmailAddress
    }
}

public struct UpdateCustomerEmailAddressInput: Hashable, Codable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

// MARK: - Configuration Input Types

public struct ConfigurableOperationInput: Hashable, Codable, Sendable {
    public let code: String
    public let arguments: [ConfigArgInput]

    public init(code: String, arguments: [ConfigArgInput]) {
        self.code = code
        self.arguments = arguments
    }
}

public struct ConfigArgInput: Hashable, Codable, Sendable {
    public let name: String
    /// JSON stringified representation of the actual value
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

// MARK: - Facet Value Filter Input

public struct FacetValueFilterInput: Hashable, Codable, Sendable {
    public let and: String?
    public let or: [String]?

    public init(and: String? = nil, or: [String]? = nil) {
        self.and = and
        self.or = or
    }
}

// MARK: - Verification Input Types

public struct VerifyCustomerAccountInput: Hashable, Codable, Sendable {
    public let token: String
    public let password: String?

    public init(token: String, password: String? = nil) {
        self.token = token
        self.password = password
    }
}
