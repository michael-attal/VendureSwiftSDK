import Foundation

// MARK: - Customer Types

/// Represents a customer
public struct Customer: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let emailAddress: String
    public let title: String?
    public let phoneNumber: String?
    public let addresses: [Address]?
    public let orders: [Order]?
    public let user: User?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        firstName: String,
        lastName: String,
        emailAddress: String,
        title: String? = nil,
        phoneNumber: String? = nil,
        addresses: [Address]? = nil,
        orders: [Order]? = nil,
        user: User? = nil,
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.title = title
        self.phoneNumber = phoneNumber
        self.addresses = addresses
        self.orders = orders
        self.user = user
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helper to create with custom fields dictionary
    public static func withCustomFields(
        id: String,
        firstName: String,
        lastName: String,
        emailAddress: String,
        title: String? = nil,
        phoneNumber: String? = nil,
        addresses: [Address]? = nil,
        orders: [Order]? = nil,
        user: User? = nil,
        customFieldsDict: [String: Any]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> Customer {
        let customFields = customFieldsDict != nil ? CustomFieldsUtility.create(customFieldsDict!) : nil

        return Customer(
            id: id,
            firstName: firstName,
            lastName: lastName,
            emailAddress: emailAddress,
            title: title,
            phoneNumber: phoneNumber,
            addresses: addresses,
            orders: orders,
            user: user,
            customFields: customFields,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

/// Represents a user
public struct User: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let identifier: String
    public let verified: Bool
    public let roles: [Role]
    public let lastLogin: Date?
    public let authenticationMethods: [AuthenticationMethod]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        identifier: String,
        verified: Bool,
        roles: [Role] = [],
        lastLogin: Date? = nil,
        authenticationMethods: [AuthenticationMethod] = [],
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.identifier = identifier
        self.verified = verified
        self.roles = roles
        self.lastLogin = lastLogin
        self.authenticationMethods = authenticationMethods
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helper to create with custom fields dictionary
    public static func withCustomFields(
        id: String,
        identifier: String,
        verified: Bool,
        roles: [Role] = [],
        lastLogin: Date? = nil,
        authenticationMethods: [AuthenticationMethod] = [],
        customFieldsDict: [String: Any]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> User {
        let customFields = customFieldsDict != nil ? CustomFieldsUtility.create(customFieldsDict!) : nil

        return User(
            id: id,
            identifier: identifier,
            verified: verified,
            roles: roles,
            lastLogin: lastLogin,
            authenticationMethods: authenticationMethods,
            customFields: customFields,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

/// Represents a role
public struct Role: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let code: String
    public let description: String
    public let permissions: [Permission]
    public let channels: [Channel]
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        code: String,
        description: String,
        permissions: [Permission] = [],
        channels: [Channel] = [],
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.description = description
        self.permissions = permissions
        self.channels = channels
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents an authentication method
public struct AuthenticationMethod: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let strategy: String

    public init(id: String, strategy: String) {
        self.id = id
        self.strategy = strategy
    }
}

/// Represents the current user
public struct CurrentUser: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let identifier: String
    public let channels: [CurrentUserChannel]

    public init(id: String, identifier: String, channels: [CurrentUserChannel] = []) {
        self.id = id
        self.identifier = identifier
        self.channels = channels
    }
}

/// Current user channel
public struct CurrentUserChannel: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let token: String
    public let code: String
    public let permissions: [Permission]

    public init(id: String, token: String, code: String, permissions: [Permission] = []) {
        self.id = id
        self.token = token
        self.code = code
        self.permissions = permissions
    }
}

/// Represents a customer group
public struct CustomerGroup: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let customers: [Customer]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        customers: [Customer],
        customFields: [String: AnyCodable]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.customers = customers
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helper to create with custom fields dictionary
    public static func withCustomFields(
        id: String,
        name: String,
        customers: [Customer],
        customFieldsDict: [String: Any]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> CustomerGroup {
        let customFields = customFieldsDict != nil ? CustomFieldsUtility.create(customFieldsDict!) : nil

        return CustomerGroup(
            id: id,
            name: name,
            customers: customers,
            customFields: customFields,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Extensions for Custom Fields Access

public extension Customer {
    /// Get custom fields as Any dictionary
    func getCustomFields() -> [String: Any] {
        return CustomFieldsUtility.toAnyDictionary(customFields)
    }
}

public extension User {
    /// Get custom fields as Any dictionary
    func getCustomFields() -> [String: Any] {
        return CustomFieldsUtility.toAnyDictionary(customFields)
    }
}

public extension CustomerGroup {
    /// Get custom fields as Any dictionary
    func getCustomFields() -> [String: Any] {
        return CustomFieldsUtility.toAnyDictionary(customFields)
    }
}
