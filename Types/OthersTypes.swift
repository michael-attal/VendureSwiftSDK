import Foundation

// MARK: - Core Types and Enums

/// Order types
public enum OrderType: String, Hashable, Codable, CaseIterable, Sendable {
    case Regular, Seller, Aggregate
}

/// Logical operators for filtering
public enum LogicalOperator: String, Hashable, Codable, CaseIterable, Sendable {
    case AND, OR
}

/// Permission levels
public enum Permission: String, Hashable, Codable, CaseIterable, Sendable {
    case Authenticated, SuperAdmin, Owner, Public, UpdateGlobalSettings, CreateCatalog, ReadCatalog, UpdateCatalog, DeleteCatalog, CreateProduct, ReadProduct, UpdateProduct, DeleteProduct, CreatePromotion, ReadPromotion, UpdatePromotion, DeletePromotion, CreateSettings, ReadSettings, UpdateSettings, DeleteSettings, CreateAdministrator, ReadAdministrator, UpdateAdministrator, DeleteAdministrator, CreateAsset, ReadAsset, UpdateAsset, DeleteAsset, CreateChannel, ReadChannel, UpdateChannel, DeleteChannel, CreateCollection, ReadCollection, UpdateCollection, DeleteCollection, CreateCountry, ReadCountry, UpdateCountry, DeleteCountry, CreateCustomer, ReadCustomer, UpdateCustomer, DeleteCustomer, CreateCustomerGroup, ReadCustomerGroup, UpdateCustomerGroup, DeleteCustomerGroup, CreateFacet, ReadFacet, UpdateFacet, DeleteFacet, CreateOrder, ReadOrder, UpdateOrder, DeleteOrder, CreatePaymentMethod, ReadPaymentMethod, UpdatePaymentMethod, DeletePaymentMethod, CreateShippingMethod, ReadShippingMethod, UpdateShippingMethod, DeleteShippingMethod, CreateTag, ReadTag, UpdateTag, DeleteTag, CreateTaxCategory, ReadTaxCategory, UpdateTaxCategory, DeleteTaxCategory, CreateTaxRate, ReadTaxRate, UpdateTaxRate, DeleteTaxRate, CreateSystem, ReadSystem, UpdateSystem, DeleteSystem, CreateZone, ReadZone, UpdateZone, DeleteZone
}

// MARK: - Base Types

/// Represents a coordinate
public struct Coordinate: Codable, Hashable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

// MARK: - Operation Types

public struct ConfigurableOperation: Codable, Hashable, Sendable {
    public let code: String
    public let args: [ConfigArg]

    public init(code: String, args: [ConfigArg] = []) {
        self.code = code
        self.args = args
    }
}

public struct ConfigArg: Codable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
