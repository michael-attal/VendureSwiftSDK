import Foundation

// MARK: - Order Types

/// Represents an order
public struct Order: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
    /// An order is active as long as the payment process has not been completed
    public let active: Bool
    public let billingAddress: OrderAddress?
    /// A unique code for the Order
    public let code: String
    /// An array of all coupon codes applied to the Order
    public let couponCodes: [String]
    public let createdAt: Date
    public let currencyCode: CurrencyCode
    public var customFields: [String: AnyCodable]?
    public let customer: Customer?
    public let discounts: [Discount]
    public let fulfillments: [Fulfillment]?
    public let history: HistoryEntryList
    public let id: String
    public let lines: [OrderLine]
    /// The date & time that the Order was placed, i.e. the Customer completed the checkout and the Order is no longer "active"
    public let orderPlacedAt: Date?
    public let payments: [Payment]?
    /// Promotions applied to the order. Only gets populated after the payment process has completed.
    public let promotions: [Promotion]
    public let shipping: Double
    public let shippingAddress: OrderAddress?
    public let shippingLines: [ShippingLine]
    public let shippingWithTax: Double
    public let state: String
    /// The subTotal is the total of all OrderLines in the Order. This figure also includes any Order-level
    /// discounts which have been prorated (proportionally distributed) amongst the items of each OrderLine.
    /// To get a total of all OrderLines which does not account for prorated discounts, use the
    /// sum of `OrderLine.discountedLinePrice` values.
    public let subTotal: Double
    /// Same as subTotal, but inclusive of tax
    public let subTotalWithTax: Double
    /// Surcharges are arbitrary modifications to the Order total which are neither
    /// ProductVariants nor discounts resulting from applied Promotions. For example,
    /// one-off discounts based on customer interaction, or surcharges based on payment methods.
    public let surcharges: [Surcharge]
    /// A summary of the taxes being applied to this Order
    public let taxSummary: [OrderTaxSummary]
    /// Equal to subTotal plus shipping
    public let total: Double
    public let totalQuantity: Int
    /// The final payable amount. Equal to subTotalWithTax plus shippingWithTax
    public let totalWithTax: Double
    public let type: OrderType
    public let updatedAt: Date
    
    public init(active: Bool, billingAddress: OrderAddress? = nil, code: String, couponCodes: [String] = [],
                createdAt: Date, currencyCode: CurrencyCode, customFields: [String: AnyCodable]? = nil,
                customer: Customer? = nil, discounts: [Discount] = [], fulfillments: [Fulfillment]? = nil,
                history: HistoryEntryList, id: String, lines: [OrderLine] = [], orderPlacedAt: Date? = nil,
                payments: [Payment]? = nil, promotions: [Promotion] = [], shipping: Double,
                shippingAddress: OrderAddress? = nil, shippingLines: [ShippingLine] = [], shippingWithTax: Double,
                state: String, subTotal: Double, subTotalWithTax: Double, surcharges: [Surcharge] = [],
                taxSummary: [OrderTaxSummary] = [], total: Double, totalQuantity: Int, totalWithTax: Double,
                type: OrderType, updatedAt: Date) {
        self.active = active
        self.billingAddress = billingAddress
        self.code = code
        self.couponCodes = couponCodes
        self.createdAt = createdAt
        self.currencyCode = currencyCode
        self.customFields = customFields
        self.customer = customer
        self.discounts = discounts
        self.fulfillments = fulfillments
        self.history = history
        self.id = id
        self.lines = lines
        self.orderPlacedAt = orderPlacedAt
        self.payments = payments
        self.promotions = promotions
        self.shipping = shipping
        self.shippingAddress = shippingAddress
        self.shippingLines = shippingLines
        self.shippingWithTax = shippingWithTax
        self.state = state
        self.subTotal = subTotal
        self.subTotalWithTax = subTotalWithTax
        self.surcharges = surcharges
        self.taxSummary = taxSummary
        self.total = total
        self.totalQuantity = totalQuantity
        self.totalWithTax = totalWithTax
        self.type = type
        self.updatedAt = updatedAt
    }
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        self.active = try container.decode(Bool.self, forKey: .active)
        self.billingAddress = try container.decodeIfPresent(OrderAddress.self, forKey: .billingAddress)
        self.code = try container.decode(String.self, forKey: .code)
        self.couponCodes = try container.decode([String].self, forKey: .couponCodes)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.currencyCode = try container.decode(CurrencyCode.self, forKey: .currencyCode)
        self.customer = try container.decodeIfPresent(Customer.self, forKey: .customer)
        self.discounts = try container.decode([Discount].self, forKey: .discounts)
        self.fulfillments = try container.decodeIfPresent([Fulfillment].self, forKey: .fulfillments)
        self.history = try container.decode(HistoryEntryList.self, forKey: .history)
        self.id = try container.decode(String.self, forKey: .id)
        self.lines = try container.decode([OrderLine].self, forKey: .lines)
        self.orderPlacedAt = try container.decodeIfPresent(Date.self, forKey: .orderPlacedAt)
        self.payments = try container.decodeIfPresent([Payment].self, forKey: .payments)
        self.promotions = try container.decode([Promotion].self, forKey: .promotions)
        self.shipping = try container.decode(Double.self, forKey: .shipping)
        self.shippingAddress = try container.decodeIfPresent(OrderAddress.self, forKey: .shippingAddress)
        self.shippingLines = try container.decode([ShippingLine].self, forKey: .shippingLines)
        self.shippingWithTax = try container.decode(Double.self, forKey: .shippingWithTax)
        self.state = try container.decode(String.self, forKey: .state)
        self.subTotal = try container.decode(Double.self, forKey: .subTotal)
        self.subTotalWithTax = try container.decode(Double.self, forKey: .subTotalWithTax)
        self.surcharges = try container.decode([Surcharge].self, forKey: .surcharges)
        self.taxSummary = try container.decode([OrderTaxSummary].self, forKey: .taxSummary)
        self.total = try container.decode(Double.self, forKey: .total)
        self.totalQuantity = try container.decode(Int.self, forKey: .totalQuantity)
        self.totalWithTax = try container.decode(Double.self, forKey: .totalWithTax)
        self.type = try container.decode(OrderType.self, forKey: .type)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode existing customFields if present
        self.customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "Order")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case active, billingAddress, code, couponCodes, createdAt, currencyCode, customFields, customer, discounts, fulfillments, history, id, lines, orderPlacedAt, payments, promotions, shipping, shippingAddress, shippingLines, shippingWithTax, state, subTotal, subTotalWithTax, surcharges, taxSummary, total, totalQuantity, totalWithTax, type, updatedAt
    }
}

/// Represents an order address
public struct OrderAddress: Codable, Hashable, Sendable {
    public let fullName: String?
    public let company: String?
    public let streetLine1: String
    public let streetLine2: String?
    public let city: String?
    public let province: String?
    public let postalCode: String?
    public let country: String?
    public let countryCode: String?
    public let phoneNumber: String?
    
    public init(fullName: String? = nil, company: String? = nil, streetLine1: String,
                streetLine2: String? = nil, city: String? = nil, province: String? = nil,
                postalCode: String? = nil, country: String? = nil, countryCode: String? = nil,
                phoneNumber: String? = nil) {
        self.fullName = fullName
        self.company = company
        self.streetLine1 = streetLine1
        self.streetLine2 = streetLine2
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.country = country
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }
}

/// Represents an order line
public struct OrderLine: Codable, Hashable, Identifiable, Sendable, CustomFieldsDecodable {
    public let id: String
    public let productVariant: ProductVariant
    public let featuredAsset: Asset?
    public let unitPrice: Double
    public let unitPriceWithTax: Double
    public let quantity: Int
    public let linePrice: Double
    public let linePriceWithTax: Double
    public let discountedLinePrice: Double
    public let discountedLinePriceWithTax: Double
    public let discounts: [Discount]
    public let taxLines: [TaxLine]
    public var customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, productVariant: ProductVariant, featuredAsset: Asset? = nil,
                unitPrice: Double, unitPriceWithTax: Double, quantity: Int, linePrice: Double,
                linePriceWithTax: Double, discountedLinePrice: Double, discountedLinePriceWithTax: Double,
                discounts: [Discount] = [], taxLines: [TaxLine] = [], customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.productVariant = productVariant
        self.featuredAsset = featuredAsset
        self.unitPrice = unitPrice
        self.unitPriceWithTax = unitPriceWithTax
        self.quantity = quantity
        self.linePrice = linePrice
        self.linePriceWithTax = linePriceWithTax
        self.discountedLinePrice = discountedLinePrice
        self.discountedLinePriceWithTax = discountedLinePriceWithTax
        self.discounts = discounts
        self.taxLines = taxLines
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Custom decoding to capture extended fields
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode standard fields
        self.id = try container.decode(String.self, forKey: .id)
        self.productVariant = try container.decode(ProductVariant.self, forKey: .productVariant)
        self.featuredAsset = try container.decodeIfPresent(Asset.self, forKey: .featuredAsset)
        self.unitPrice = try container.decode(Double.self, forKey: .unitPrice)
        self.unitPriceWithTax = try container.decode(Double.self, forKey: .unitPriceWithTax)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.linePrice = try container.decode(Double.self, forKey: .linePrice)
        self.linePriceWithTax = try container.decode(Double.self, forKey: .linePriceWithTax)
        self.discountedLinePrice = try container.decode(Double.self, forKey: .discountedLinePrice)
        self.discountedLinePriceWithTax = try container.decode(Double.self, forKey: .discountedLinePriceWithTax)
        self.discounts = try container.decode([Discount].self, forKey: .discounts)
        self.taxLines = try container.decode([TaxLine].self, forKey: .taxLines)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode existing customFields if present
        self.customFields = try container.decodeIfPresent([String: AnyCodable].self, forKey: .customFields)
        
        // Use generic custom fields decoder
        try self.decodeCustomFields(from: decoder, typeName: "OrderLine")
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, productVariant, featuredAsset, unitPrice, unitPriceWithTax, quantity, linePrice, linePriceWithTax, discountedLinePrice, discountedLinePriceWithTax, discounts, taxLines, customFields, createdAt, updatedAt
    }
}

/// Represents a discount
public struct Discount: Codable, Hashable, Identifiable, Sendable {
    public let adjustmentSource: String
    public let type: AdjustmentType
    public let description: String
    public let amount: Double
    public let amountWithTax: Double
    
    public var id: String { adjustmentSource }
    
    public init(adjustmentSource: String, type: AdjustmentType, description: String,
                amount: Double, amountWithTax: Double) {
        self.adjustmentSource = adjustmentSource
        self.type = type
        self.description = description
        self.amount = amount
        self.amountWithTax = amountWithTax
    }
}

/// Adjustment types
public enum AdjustmentType: String, Codable, CaseIterable, Sendable {
    case PROMOTION, DISTRIBUTED_ORDER_PROMOTION, OTHER
}


/// Represents a surcharge
public struct Surcharge: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let description: String
    public let sku: String?
    public let price: Double
    public let priceWithTax: Double
    public let taxRate: Double
    
    public init(id: String, description: String, sku: String? = nil,
                price: Double, priceWithTax: Double, taxRate: Double) {
        self.id = id
        self.description = description
        self.sku = sku
        self.price = price
        self.priceWithTax = priceWithTax
        self.taxRate = taxRate
    }
}



// MARK: - Fulfillment Types

public struct Fulfillment: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let state: String
    public let method: String
    public let trackingCode: String?
    public let lines: [FulfillmentLine]
    public let summary: [FulfillmentLineSummary]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, state: String, method: String, trackingCode: String? = nil,
                lines: [FulfillmentLine] = [], summary: [FulfillmentLineSummary] = [],
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.state = state
        self.method = method
        self.trackingCode = trackingCode
        self.lines = lines
        self.summary = summary
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct FulfillmentLine: Codable, Hashable, Identifiable, Sendable {
    public let orderLineId: String
    public let quantity: Int
    public let orderLine: OrderLine
    
    public var id: String { orderLineId }
    
    public init(orderLineId: String, quantity: Int, orderLine: OrderLine) {
        self.orderLineId = orderLineId
        self.quantity = quantity
        self.orderLine = orderLine
    }
}

public struct FulfillmentLineSummary: Codable, Hashable, Sendable {
    public let orderLine: OrderLine
    public let quantity: Int
    
    public init(orderLine: OrderLine, quantity: Int) {
        self.orderLine = orderLine
        self.quantity = quantity
    }
}

// MARK: - History Types

public struct HistoryEntryList: Codable, Hashable, Sendable {
    public let items: [HistoryEntry]
    public let totalItems: Int
    
    public init(items: [HistoryEntry], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

public struct HistoryEntry: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let type: HistoryEntryType
    public let data: [String: AnyCodable]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, type: HistoryEntryType, data: [String: AnyCodable],
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.type = type
        self.data = data
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum HistoryEntryType: String, Codable, CaseIterable, Sendable {
    case CUSTOMER_REGISTERED, CUSTOMER_VERIFIED, CUSTOMER_DETAIL_UPDATED
    case CUSTOMER_ADDED_TO_GROUP, CUSTOMER_REMOVED_FROM_GROUP
    case CUSTOMER_ADDRESS_CREATED, CUSTOMER_ADDRESS_UPDATED, CUSTOMER_ADDRESS_DELETED
    case CUSTOMER_PASSWORD_UPDATED, CUSTOMER_PASSWORD_RESET_REQUESTED, CUSTOMER_PASSWORD_RESET_VERIFIED
    case CUSTOMER_EMAIL_UPDATE_REQUESTED, CUSTOMER_EMAIL_UPDATE_VERIFIED
    case ORDER_STATE_TRANSITION, ORDER_PAYMENT_TRANSITION, ORDER_FULFILLMENT_TRANSITION
    case ORDER_FULFILLMENT, ORDER_CANCELLATION, ORDER_REFUND_TRANSITION
    case ORDER_FULFILLMENT_STATE_TRANSITION, ORDER_NOTE, ORDER_COUPON_APPLIED, ORDER_COUPON_REMOVED
    case ORDER_MODIFIED
}


// MARK: - Order Operation Result Types

/// Set order shipping method result
public typealias SetOrderShippingMethodResult = Order

/// Update order items result
public typealias UpdateOrderItemsResult = Order

/// Remove order items result
public typealias RemoveOrderItemsResult = Order

/// Set customer for order result
public typealias SetCustomerForOrderResult = Order

/// Apply coupon code result
public typealias ApplyCouponCodeResult = Order

/// Remove coupon code result
public typealias RemoveCouponCodeResult = Order

/// Transition order to state result
public typealias TransitionOrderToStateResult = Order


