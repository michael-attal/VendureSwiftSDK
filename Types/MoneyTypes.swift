import Foundation

/// Represents a monetary amount
public struct Money: Codable, Hashable, Sendable {
    public let value: Double
    public let currencyCode: CurrencyCode

    public init(value: Double, currencyCode: CurrencyCode) {
        self.value = value
        self.currencyCode = currencyCode
    }
}

/// Represents a price range
public struct PriceRange: Codable, Hashable, Sendable {
    public let min: Double
    public let max: Double

    public init(min: Double, max: Double) {
        self.min = min
        self.max = max
    }
}
