import Foundation
import SkipFoundation

// MARK: - Tax Category

/// Represents a tax category
public struct TaxCategory: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let isDefault: Bool
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, isDefault: Bool = false,
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Tax Rate

/// Represents a tax rate
public struct TaxRate: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let enabled: Bool
    public let value: Double
    public let category: TaxCategory
    public let zone: Zone
    public let customerGroup: CustomerGroup?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, enabled: Bool, value: Double,
                category: TaxCategory, zone: Zone, customerGroup: CustomerGroup? = nil,
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.value = value
        self.category = category
        self.zone = zone
        self.customerGroup = customerGroup
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Tax Line

/// Represents a tax line on an order item
public struct TaxLine: Codable, Hashable {
    public let description: String
    public let taxRate: Double
    
    public init(description: String, taxRate: Double) {
        self.description = description
        self.taxRate = taxRate
    }
}

// MARK: - Order Tax Summary

/// Tax summary for an order
public struct OrderTaxSummary: Codable, Hashable {
    public let description: String
    public let taxRate: Double
    public let taxBase: Double
    public let taxTotal: Double
    
    public init(description: String, taxRate: Double, taxBase: Double, taxTotal: Double) {
        self.description = description
        self.taxRate = taxRate
        self.taxBase = taxBase
        self.taxTotal = taxTotal
    }
}

// MARK: - Tax Lists

/// List of tax rates
public struct TaxRateList: Codable {
    public let items: [TaxRate]
    public let totalItems: Int
    
    public init(items: [TaxRate], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

/// List of tax categories  
public struct TaxCategoryList: Codable {
    public let items: [TaxCategory]
    public let totalItems: Int
    
    public init(items: [TaxCategory], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}
