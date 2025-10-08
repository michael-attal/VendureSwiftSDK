import Foundation

// MARK: - Core Types and Enums

/// Currency codes supported by Vendure
public enum CurrencyCode: String, Codable, CaseIterable, Sendable {
    case AED, AFN, ALL, AMD, ANG, AOA, ARS, AUD, AWG, AZN
    case BAM, BBD, BDT, BGN, BHD, BIF, BMD, BND, BOB, BRL, BSD, BTN, BWP, BYN, BZD
    case CAD, CDF, CHF, CLP, CNY, COP, CRC, CUC, CUP, CVE, CZK
    case DJF, DKK, DOP, DZD
    case EGP, ERN, ETB, EUR
    case FJD, FKP
    case GBP, GEL, GHS, GIP, GMD, GNF, GTQ, GYD
    case HKD, HNL, HRK, HTG, HUF
    case IDR, ILS, INR, IQD, IRR, ISK
    case JMD, JOD, JPY
    case KES, KGS, KHR, KMF, KPW, KRW, KWD, KYD, KZT
    case LAK, LBP, LKR, LRD, LSL, LYD
    case MAD, MDL, MGA, MKD, MMK, MNT, MOP, MRU, MUR, MVR, MWK, MXN, MYR, MZN
    case NAD, NGN, NIO, NOK, NPR, NZD
    case OMR
    case PAB, PEN, PGK, PHP, PKR, PLN, PYG
    case QAR
    case RON, RSD, RUB, RWF
    case SAR, SBD, SCR, SDG, SEK, SGD, SHP, SLE, SOS, SRD, STN, SYP, SZL
    case THB, TJS, TMT, TND, TOP, TRY, TTD, TVD, TWD, TZS
    case UAH, UGX, USD, UYU, UZS
    case VES, VND, VUV
    case WST
    case XAF, XCD, XOF, XPF
    case YER
    case ZAR, ZMW, ZWL
}

/// Language codes supported by Vendure
public enum LanguageCode: String, Codable, CaseIterable, Sendable {
    case af, ak, am, ar, `as`, az, be, bg, bm, bn, bo, br, bs, ca, ce, co, cs, cu, cy, da, de, dv, dz, ee, el, en, eo, es, et, eu, fa, ff, fi, fo, fr, fy, ga, gd, gl, gu, gv, ha, he, hi, ho, hr, ht, hu, hy, hz, ia, id, ie, ig, ii, ik, io, `is`, it, iu, ja, jv, ka, kg, ki, kj, kk, kl, km, kn, ko, kr, ks, ku, kv, kw, ky, la, lb, lg, li, ln, lo, lr, ls, lt, lu, lv, mg, mh, mi, mk, ml, mn, mr, ms, mt, my, na, nb, nd, ne, ng, nl, nn, no, nr, nv, ny, oc, oj, om, or, os, pa, pi, pl, ps, pt, qu, rm, rn, ro, ru, rw, sa, sc, sd, se, sg, si, sk, sl, sm, sn, so, sq, sr, ss, st, su, sv, sw, ta, te, tg, th, ti, tk, tl, tn, to, tr, ts, tt, tw, ty, ug, uk, ur, uz, ve, vi, vo, wa, wo, xh, yi, yo, za, zh, zu
}

/// Order types
public enum OrderType: String, Codable, CaseIterable, Sendable {
    case Regular, Seller, Aggregate
}

/// Sort orders
public enum SortOrder: String, Codable, CaseIterable, Sendable {
    case ASC, DESC
}

/// Logical operators for filtering
public enum LogicalOperator: String, Codable, CaseIterable, Sendable {
    case AND, OR
}

/// Permission levels
public enum Permission: String, Codable, CaseIterable, Sendable {
    case Authenticated, SuperAdmin, Owner, Public, UpdateGlobalSettings, CreateCatalog, ReadCatalog, UpdateCatalog, DeleteCatalog, CreateProduct, ReadProduct, UpdateProduct, DeleteProduct, CreatePromotion, ReadPromotion, UpdatePromotion, DeletePromotion, CreateSettings, ReadSettings, UpdateSettings, DeleteSettings, CreateAdministrator, ReadAdministrator, UpdateAdministrator, DeleteAdministrator, CreateAsset, ReadAsset, UpdateAsset, DeleteAsset, CreateChannel, ReadChannel, UpdateChannel, DeleteChannel, CreateCollection, ReadCollection, UpdateCollection, DeleteCollection, CreateCountry, ReadCountry, UpdateCountry, DeleteCountry, CreateCustomer, ReadCustomer, UpdateCustomer, DeleteCustomer, CreateCustomerGroup, ReadCustomerGroup, UpdateCustomerGroup, DeleteCustomerGroup, CreateFacet, ReadFacet, UpdateFacet, DeleteFacet, CreateOrder, ReadOrder, UpdateOrder, DeleteOrder, CreatePaymentMethod, ReadPaymentMethod, UpdatePaymentMethod, DeletePaymentMethod, CreateShippingMethod, ReadShippingMethod, UpdateShippingMethod, DeleteShippingMethod, CreateTag, ReadTag, UpdateTag, DeleteTag, CreateTaxCategory, ReadTaxCategory, UpdateTaxCategory, DeleteTaxCategory, CreateTaxRate, ReadTaxRate, UpdateTaxRate, DeleteTaxRate, CreateSystem, ReadSystem, UpdateSystem, DeleteSystem, CreateZone, ReadZone, UpdateZone, DeleteZone
}

/// Error codes that can be returned by the API
public enum ErrorCode: String, Codable, CaseIterable, Sendable {
    case UNKNOWN_ERROR
    case MIME_TYPE_ERROR
    case LANGUAGE_NOT_AVAILABLE_ERROR
    case CHANNEL_DEFAULT_LANGUAGE_ERROR
    case SETTLE_PAYMENT_ERROR
    case CANCEL_PAYMENT_ERROR
    case EMPTY_ORDER_LINE_SELECTION_ERROR
    case ITEMS_ALREADY_FULFILLED_ERROR
    case INSUFFICIENT_STOCK_ON_HAND_ERROR
    case MULTIPLE_ORDER_ERROR
    case CANCEL_ACTIVE_ORDER_ERROR
    case PAYMENT_ORDER_MISMATCH_ERROR
    case REFUND_ORDER_STATE_ERROR
    case NOTHING_TO_REFUND_ERROR
    case ALREADY_REFUNDED_ERROR
    case QUANTITY_TOO_GREAT_ERROR
    case REFUND_STATE_TRANSITION_ERROR
    case PAYMENT_STATE_TRANSITION_ERROR
    case FULFILLMENT_STATE_TRANSITION_ERROR
    case ORDER_MODIFICATION_STATE_ERROR
    case NO_CHANGES_SPECIFIED_ERROR
    case PAYMENT_METHOD_MISSING_ERROR
    case REFUND_PAYMENT_ID_MISSING_ERROR
    case MANUAL_PAYMENT_STATE_ERROR
    case PRODUCT_OPTION_IN_USE_ERROR
    case MISSING_CONDITIONS_ERROR
    case NATIVE_AUTH_STRATEGY_ERROR
    case INVALID_CREDENTIALS_ERROR
    case ORDER_STATE_TRANSITION_ERROR
    case EMAIL_ADDRESS_CONFLICT_ERROR
    case GUEST_CHECKOUT_ERROR
    case ORDER_LIMIT_ERROR
    case NEGATIVE_QUANTITY_ERROR
    case INSUFFICIENT_STOCK_ERROR
    case COUPON_CODE_INVALID_ERROR
    case COUPON_CODE_EXPIRED_ERROR
    case COUPON_CODE_LIMIT_ERROR
    case ORDER_MODIFICATION_ERROR
    case INELIGIBLE_SHIPPING_METHOD_ERROR
    case NO_ACTIVE_ORDER_ERROR
    case ORDER_PAYMENT_STATE_ERROR
    case INELIGIBLE_PAYMENT_METHOD_ERROR
    case PAYMENT_FAILED_ERROR
    case PAYMENT_DECLINED_ERROR
    case ALREADY_LOGGED_IN_ERROR
    case MISSING_PASSWORD_ERROR
    case PASSWORD_VALIDATION_ERROR
    case PASSWORD_ALREADY_SET_ERROR
    case VERIFICATION_TOKEN_INVALID_ERROR
    case VERIFICATION_TOKEN_EXPIRED_ERROR
    case IDENTIFIER_CHANGE_TOKEN_INVALID_ERROR
    case IDENTIFIER_CHANGE_TOKEN_EXPIRED_ERROR
    case PASSWORD_RESET_TOKEN_INVALID_ERROR
    case PASSWORD_RESET_TOKEN_EXPIRED_ERROR
    case NOT_VERIFIED_ERROR
}

// MARK: - Base Types

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

/// Represents a date range
public struct DateRange: Codable, Hashable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

/// Represents a coordinate
public struct Coordinate: Codable, Hashable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/// Represents localized string content
public struct LocalizedString: Codable, Hashable, Sendable {
    public let languageCode: LanguageCode
    public let value: String

    public init(languageCode: LanguageCode, value: String) {
        self.languageCode = languageCode
        self.value = value
    }
}

// MARK: - Filter Parameters

/// Generic filter parameter for any entity
public struct FilterParameter<Id: Codable & Sendable,
    DateField: Codable & Sendable,
    StringField: Codable & Sendable,
    NumberField: Codable & Sendable,
    BooleanField: Codable & Sendable>: Codable, Sendable
{
    public let id: Id?
    public let createdAt: DateField?
    public let updatedAt: DateField?
    public let languageCode: StringField?
    public let name: StringField?
    public let slug: StringField?
    public let description: StringField?

    // Optional numeric and boolean fields
    public let numberFields: NumberField?
    public let booleanFields: BooleanField?

    // Additional custom fields
    public let extraFields: [String: AnyCodable]?

    public init(id: Id? = nil,
                createdAt: DateField? = nil,
                updatedAt: DateField? = nil,
                languageCode: StringField? = nil,
                name: StringField? = nil,
                slug: StringField? = nil,
                description: StringField? = nil,
                numberFields: NumberField? = nil,
                booleanFields: BooleanField? = nil,
                extraFields: [String: AnyCodable]? = nil)
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
        self.numberFields = numberFields
        self.booleanFields = booleanFields
        self.extraFields = extraFields
    }
}

// MARK: - Sort Parameters

/// Generic sort parameter for any entity
public struct SortParameter<Field: Codable & Sendable>: Codable, Sendable {
    public let id: Field?
    public let createdAt: Field?
    public let updatedAt: Field?
    public let name: Field?
    public let slug: Field?

    // Optional extra fields
    public let extraFields: [String: Field]?

    public init(id: Field? = nil,
                createdAt: Field? = nil,
                updatedAt: Field? = nil,
                name: Field? = nil,
                slug: Field? = nil,
                extraFields: [String: Field]? = nil)
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.slug = slug
        self.extraFields = extraFields
    }
}

public struct NumberOperators: Codable, Sendable {
    public let eq: Double?
    public let lt: Double?
    public let lte: Double?
    public let gt: Double?
    public let gte: Double?
    public let between: NumberRange?

    public init(eq: Double? = nil, lt: Double? = nil, lte: Double? = nil, gt: Double? = nil, gte: Double? = nil, between: NumberRange? = nil) {
        self.eq = eq
        self.lt = lt
        self.lte = lte
        self.gt = gt
        self.gte = gte
        self.between = between
    }
}

public struct NumberRange: Codable, Sendable {
    public let start: Double
    public let end: Double

    public init(start: Double, end: Double) {
        self.start = start
        self.end = end
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

// MARK: - Filter Operators (continued from SystemOperations)

public struct IDOperators: Codable, Sendable {
    public let eq: String?
    public let notEq: String?
    public let `in`: [String]?
    public let notIn: [String]?

    public init(eq: String? = nil, notEq: String? = nil, in: [String]? = nil, notIn: [String]? = nil) {
        self.eq = eq
        self.notEq = notEq
        self.in = `in`
        self.notIn = notIn
    }
}

public struct StringOperators: Codable, Sendable {
    public let eq: String?
    public let notEq: String?
    public let contains: String?
    public let notContains: String?
    public let `in`: [String]?
    public let notIn: [String]?
    public let regex: String?

    public init(eq: String? = nil, notEq: String? = nil, contains: String? = nil, notContains: String? = nil, in: [String]? = nil, notIn: [String]? = nil, regex: String? = nil) {
        self.eq = eq
        self.notEq = notEq
        self.contains = contains
        self.notContains = notContains
        self.in = `in`
        self.notIn = notIn
        self.regex = regex
    }
}

public struct BooleanOperators: Codable, Sendable {
    public let eq: Bool?

    public init(eq: Bool? = nil) {
        self.eq = eq
    }
}

public struct DateOperators: Codable, Sendable {
    public let eq: Date?
    public let before: Date?
    public let after: Date?
    public let between: DateRange?

    public init(eq: Date? = nil, before: Date? = nil, after: Date? = nil, between: DateRange? = nil) {
        self.eq = eq
        self.before = before
        self.after = after
        self.between = between
    }
}
