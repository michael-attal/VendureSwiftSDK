import Foundation

// MARK: - Customer Types

/// Represents a customer
public struct Customer: Codable, Hashable, Identifiable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let emailAddress: String
    public let title: String?
    public let phoneNumber: String?
    public let addresses: [Address]?
    public let orders: OrderList?
    public let user: User?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, firstName: String, lastName: String, emailAddress: String,
                title: String? = nil, phoneNumber: String? = nil, addresses: [Address]? = nil,
                orders: OrderList? = nil, user: User? = nil, customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
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
}

/// Order list response
public struct OrderList: Codable, Hashable {
    public let items: [Order]
    public let totalItems: Int
    
    public init(items: [Order], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

/// Represents a user
public struct User: Codable, Hashable, Identifiable {
    public let id: String
    public let identifier: String
    public let verified: Bool
    public let roles: [Role]
    public let lastLogin: Date?
    public let authenticationMethods: [AuthenticationMethod]
    public let customFields: UserCustomFields?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, identifier: String, verified: Bool, roles: [Role] = [],
                lastLogin: Date? = nil, authenticationMethods: [AuthenticationMethod] = [],
                customFields: UserCustomFields? = nil, createdAt: Date, updatedAt: Date) {
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
}

/// User custom fields
public struct UserCustomFields: Codable, Hashable {
    public let customFields: [String: AnyCodable]
    
    public init(customFields: [String: AnyCodable] = [:]) {
        self.customFields = customFields
    }
}

/// Represents a role
public struct Role: Codable, Hashable, Identifiable {
    public let id: String
    public let code: String
    public let description: String
    public let permissions: [Permission]
    public let channels: [Channel]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, code: String, description: String, permissions: [Permission] = [],
                channels: [Channel] = [], createdAt: Date, updatedAt: Date) {
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
public struct AuthenticationMethod: Codable, Hashable, Identifiable {
    public let id: String
    public let strategy: String
    
    public init(id: String, strategy: String) {
        self.id = id
        self.strategy = strategy
    }
}

/// Represents the current user
public struct CurrentUser: Codable, Hashable, Identifiable {
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
public struct CurrentUserChannel: Codable, Hashable, Identifiable {
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
public struct CustomerGroup: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let customers: CustomerList
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, customers: CustomerList, customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.customers = customers
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Customer list response
public struct CustomerList: Codable, Hashable {
    public let items: [Customer]
    public let totalItems: Int
    
    public init(items: [Customer], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

/// Role list response
public struct RoleList: Codable, Hashable {
    public let items: [Role]
    public let totalItems: Int
    
    public init(items: [Role], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}
