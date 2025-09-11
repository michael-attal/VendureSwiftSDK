import Foundation
#if canImport(SkipModel)
import SkipModel
#endif

// MARK: - Core Types and Enums

/// Currency codes supported by Vendure
public enum CurrencyCode: String, Codable, CaseIterable {
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
public enum LanguageCode: String, Codable, CaseIterable {
    case af, ak, am, ar, `as`, az, be, bg, bm, bn, bo, br, bs, ca, ce, co, cs, cu, cy, da, de, dv, dz, ee, el, en, eo, es, et, eu, fa, ff, fi, fo, fr, fy, ga, gd, gl, gu, gv, ha, he, hi, ho, hr, ht, hu, hy, hz, ia, id, ie, ig, ii, ik, io, `is`, it, iu, ja, jv, ka, kg, ki, kj, kk, kl, km, kn, ko, kr, ks, ku, kv, kw, ky, la, lb, lg, li, ln, lo, lr, ls, lt, lu, lv, mg, mh, mi, mk, ml, mn, mr, ms, mt, my, na, nb, nd, ne, ng, nl, nn, no, nr, nv, ny, oc, oj, om, or, os, pa, pi, pl, ps, pt, qu, rm, rn, ro, ru, rw, sa, sc, sd, se, sg, si, sk, sl, sm, sn, so, sq, sr, ss, st, su, sv, sw, ta, te, tg, th, ti, tk, tl, tn, to, tr, ts, tt, tw, ty, ug, uk, ur, uz, ve, vi, vo, wa, wo, xh, yi, yo, za, zh, zu
}

/// Order types
public enum OrderType: String, Codable, CaseIterable {
    case Regular, Seller, Aggregate
}

/// Sort orders
public enum SortOrder: String, Codable, CaseIterable {
    case ASC, DESC
}

/// Logical operators for filtering
public enum LogicalOperator: String, Codable, CaseIterable {
    case AND, OR
}

/// Permission levels
public enum Permission: String, Codable, CaseIterable {
    case Authenticated, SuperAdmin, Owner, Public, UpdateGlobalSettings, CreateCatalog, ReadCatalog, UpdateCatalog, DeleteCatalog, CreateProduct, ReadProduct, UpdateProduct, DeleteProduct, CreatePromotion, ReadPromotion, UpdatePromotion, DeletePromotion, CreateSettings, ReadSettings, UpdateSettings, DeleteSettings, CreateAdministrator, ReadAdministrator, UpdateAdministrator, DeleteAdministrator, CreateAsset, ReadAsset, UpdateAsset, DeleteAsset, CreateChannel, ReadChannel, UpdateChannel, DeleteChannel, CreateCollection, ReadCollection, UpdateCollection, DeleteCollection, CreateCountry, ReadCountry, UpdateCountry, DeleteCountry, CreateCustomer, ReadCustomer, UpdateCustomer, DeleteCustomer, CreateCustomerGroup, ReadCustomerGroup, UpdateCustomerGroup, DeleteCustomerGroup, CreateFacet, ReadFacet, UpdateFacet, DeleteFacet, CreateOrder, ReadOrder, UpdateOrder, DeleteOrder, CreatePaymentMethod, ReadPaymentMethod, UpdatePaymentMethod, DeletePaymentMethod, CreateShippingMethod, ReadShippingMethod, UpdateShippingMethod, DeleteShippingMethod, CreateTag, ReadTag, UpdateTag, DeleteTag, CreateTaxCategory, ReadTaxCategory, UpdateTaxCategory, DeleteTaxCategory, CreateTaxRate, ReadTaxRate, UpdateTaxRate, DeleteTaxRate, CreateSystem, ReadSystem, UpdateSystem, DeleteSystem, CreateZone, ReadZone, UpdateZone, DeleteZone
}

/// Error codes that can be returned by the API
public enum ErrorCode: String, Codable, CaseIterable {
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
public struct Money: Codable, Hashable {
    public let value: Double
    public let currencyCode: CurrencyCode
    
    public init(value: Double, currencyCode: CurrencyCode) {
        self.value = value
        self.currencyCode = currencyCode
    }
}

/// Represents a price range
public struct PriceRange: Codable, Hashable {
    public let min: Double
    public let max: Double
    
    public init(min: Double, max: Double) {
        self.min = min
        self.max = max
    }
}

/// Represents a date range
public struct DateRange: Codable, Hashable {
    public let start: Date
    public let end: Date
    
    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

/// Represents a coordinate
public struct Coordinate: Codable, Hashable {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/// Represents localized string content
public struct LocalizedString: Codable, Hashable {
    public let languageCode: LanguageCode
    public let value: String
    
    public init(languageCode: LanguageCode, value: String) {
        self.languageCode = languageCode
        self.value = value
    }
}

// MARK: - Asset Types

/// Represents an asset (image, document, etc.)
public struct Asset: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let type: AssetType
    public let fileSize: Int
    public let mimeType: String
    public let width: Int?
    public let height: Int?
    public let source: String
    public let preview: String
    public let focalPoint: Coordinate?
    public let tags: [Tag]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, type: AssetType, fileSize: Int, mimeType: String, 
                width: Int? = nil, height: Int? = nil, source: String, preview: String,
                focalPoint: Coordinate? = nil, tags: [Tag] = [], 
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.type = type
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.width = width
        self.height = height
        self.source = source
        self.preview = preview
        self.focalPoint = focalPoint
        self.tags = tags
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Asset type enumeration
public enum AssetType: String, Codable, CaseIterable {
    case IMAGE, VIDEO, AUDIO, OTHER
}

/// Represents a list of assets with pagination info
public struct AssetList: Codable, Hashable {
    public let items: [Asset]
    public let totalItems: Int
    
    public init(items: [Asset], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

// MARK: - Address Types

/// Represents an address
public struct Address: Codable, Hashable, Identifiable {
    public let id: String
    public let fullName: String?
    public let company: String?
    public let streetLine1: String
    public let streetLine2: String?
    public let city: String?
    public let province: String?
    public let postalCode: String?
    public let country: Country
    public let phoneNumber: String?
    public let defaultShippingAddress: Bool?
    public let defaultBillingAddress: Bool?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, fullName: String? = nil, company: String? = nil, 
                streetLine1: String, streetLine2: String? = nil, city: String? = nil, 
                province: String? = nil, postalCode: String? = nil, country: Country,
                phoneNumber: String? = nil, defaultShippingAddress: Bool? = nil, 
                defaultBillingAddress: Bool? = nil, customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.fullName = fullName
        self.company = company
        self.streetLine1 = streetLine1
        self.streetLine2 = streetLine2
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.country = country
        self.phoneNumber = phoneNumber
        self.defaultShippingAddress = defaultShippingAddress
        self.defaultBillingAddress = defaultBillingAddress
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a country
public struct Country: Codable, Hashable, Identifiable {
    public let id: String
    public let code: String
    public let name: String
    public let enabled: Bool
    public let translations: [CountryTranslation]
    
    public init(id: String, code: String, name: String, enabled: Bool, translations: [CountryTranslation] = []) {
        self.id = id
        self.code = code
        self.name = name
        self.enabled = enabled
        self.translations = translations
    }
}

/// Country translation
public struct CountryTranslation: Codable, Hashable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

// MARK: - Channel and Zone

/// Represents a channel
public struct Channel: Codable, Hashable, Identifiable {
    public let id: String
    public let code: String
    public let token: String
    public let description: String?
    public let defaultLanguageCode: LanguageCode
    public let availableLanguageCodes: [LanguageCode]
    public let defaultCurrencyCode: CurrencyCode
    public let availableCurrencyCodes: [CurrencyCode]
    public let defaultShippingZone: Zone?
    public let defaultTaxZone: Zone?
    public let pricesIncludeTax: Bool
    public let seller: Seller?
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, code: String, token: String, description: String? = nil,
                defaultLanguageCode: LanguageCode, availableLanguageCodes: [LanguageCode],
                defaultCurrencyCode: CurrencyCode, availableCurrencyCodes: [CurrencyCode],
                defaultShippingZone: Zone? = nil, defaultTaxZone: Zone? = nil,
                pricesIncludeTax: Bool, seller: Seller? = nil,
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.code = code
        self.token = token
        self.description = description
        self.defaultLanguageCode = defaultLanguageCode
        self.availableLanguageCodes = availableLanguageCodes
        self.defaultCurrencyCode = defaultCurrencyCode
        self.availableCurrencyCodes = availableCurrencyCodes
        self.defaultShippingZone = defaultShippingZone
        self.defaultTaxZone = defaultTaxZone
        self.pricesIncludeTax = pricesIncludeTax
        self.seller = seller
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a zone
public struct Zone: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let members: [Region]
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, members: [Region] = [], 
                customFields: [String: AnyCodable]? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.members = members
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a region (country or province)
public final class Region: Codable, Hashable, Identifiable {
    public let id: String
    public let code: String
    public let name: String
    public let enabled: Bool
    public let parent: Region?
    public let parentId: String?
    public let type: String
    public let translations: [RegionTranslation]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, code: String, name: String, enabled: Bool, parent: Region? = nil,
                parentId: String? = nil, type: String, translations: [RegionTranslation] = [],
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.code = code
        self.name = name
        self.enabled = enabled
        self.parent = parent
        self.parentId = parentId
        self.type = type
        self.translations = translations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Region translation
public struct RegionTranslation: Codable, Hashable {
    public let languageCode: LanguageCode
    public let name: String
    
    public init(languageCode: LanguageCode, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

/// Represents a seller
public struct Seller: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let customFields: [String: AnyCodable]?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, name: String, customFields: [String: AnyCodable]? = nil,
                createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.customFields = customFields
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - List Types

public struct ProductList: Codable {
    public let items: [Product]
    public let totalItems: Int
    
    public init(items: [Product], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

public struct ProductVariantList: Codable {
    public let items: [ProductVariant]
    public let totalItems: Int
    
    public init(items: [ProductVariant], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

public struct CollectionList: Codable {
    public let items: [Collection]
    public let totalItems: Int
    
    public init(items: [Collection], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

public struct FacetList: Codable {
    public let items: [Facet]
    public let totalItems: Int
    
    public init(items: [Facet], totalItems: Int) {
        self.items = items
        self.totalItems = totalItems
    }
}

// MARK: - List Options

public struct ProductListOptions: Codable {
    public let skip: Int?
    public let take: Int?
    public let sort: ProductSortParameter?
    public let filter: ProductFilterParameter?
    public let filterOperator: LogicalOperator?
    
    public init(skip: Int? = nil, take: Int? = nil, sort: ProductSortParameter? = nil, filter: ProductFilterParameter? = nil, filterOperator: LogicalOperator? = nil) {
        self.skip = skip
        self.take = take
        self.sort = sort
        self.filter = filter
        self.filterOperator = filterOperator
    }
}

public struct CollectionListOptions: Codable {
    public let skip: Int?
    public let take: Int?
    public let sort: CollectionSortParameter?
    public let filter: CollectionFilterParameter?
    public let filterOperator: LogicalOperator?
    public let topLevelOnly: Bool?
    
    public init(skip: Int? = nil, take: Int? = nil, sort: CollectionSortParameter? = nil, filter: CollectionFilterParameter? = nil, filterOperator: LogicalOperator? = nil, topLevelOnly: Bool? = nil) {
        self.skip = skip
        self.take = take
        self.sort = sort
        self.filter = filter
        self.filterOperator = filterOperator
        self.topLevelOnly = topLevelOnly
    }
}

public struct FacetListOptions: Codable {
    public let skip: Int?
    public let take: Int?
    public let sort: FacetSortParameter?
    public let filter: FacetFilterParameter?
    public let filterOperator: LogicalOperator?
    
    public init(skip: Int? = nil, take: Int? = nil, sort: FacetSortParameter? = nil, filter: FacetFilterParameter? = nil, filterOperator: LogicalOperator? = nil) {
        self.skip = skip
        self.take = take
        self.sort = sort
        self.filter = filter
        self.filterOperator = filterOperator
    }
}

// MARK: - Sort Parameters

public struct ProductSortParameter: Codable {
    public let id: SortOrder?
    public let createdAt: SortOrder?
    public let updatedAt: SortOrder?
    public let name: SortOrder?
    public let slug: SortOrder?
    
    public init(id: SortOrder? = nil, createdAt: SortOrder? = nil, updatedAt: SortOrder? = nil, name: SortOrder? = nil, slug: SortOrder? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.slug = slug
    }
}

public struct CollectionSortParameter: Codable {
    public let id: SortOrder?
    public let createdAt: SortOrder?
    public let updatedAt: SortOrder?
    public let name: SortOrder?
    public let slug: SortOrder?
    public let position: SortOrder?
    
    public init(id: SortOrder? = nil, createdAt: SortOrder? = nil, updatedAt: SortOrder? = nil, name: SortOrder? = nil, slug: SortOrder? = nil, position: SortOrder? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.slug = slug
        self.position = position
    }
}

public struct FacetSortParameter: Codable {
    public let id: SortOrder?
    public let createdAt: SortOrder?
    public let updatedAt: SortOrder?
    public let name: SortOrder?
    public let code: SortOrder?
    
    public init(id: SortOrder? = nil, createdAt: SortOrder? = nil, updatedAt: SortOrder? = nil, name: SortOrder? = nil, code: SortOrder? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.code = code
    }
}

// MARK: - Filter Parameters

public struct ProductFilterParameter: Codable {
    public let id: IDOperators?
    public let createdAt: DateOperators?
    public let updatedAt: DateOperators?
    public let languageCode: StringOperators?
    public let name: StringOperators?
    public let slug: StringOperators?
    public let description: StringOperators?
    public let enabled: BooleanOperators?
    
    public init(id: IDOperators? = nil, createdAt: DateOperators? = nil, updatedAt: DateOperators? = nil, languageCode: StringOperators? = nil, name: StringOperators? = nil, slug: StringOperators? = nil, description: StringOperators? = nil, enabled: BooleanOperators? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
        self.enabled = enabled
    }
}

public struct CollectionFilterParameter: Codable {
    public let id: IDOperators?
    public let createdAt: DateOperators?
    public let updatedAt: DateOperators?
    public let languageCode: StringOperators?
    public let name: StringOperators?
    public let slug: StringOperators?
    public let description: StringOperators?
    public let position: NumberOperators?
    public let isRoot: BooleanOperators?
    public let parentId: IDOperators?
    
    public init(id: IDOperators? = nil, createdAt: DateOperators? = nil, updatedAt: DateOperators? = nil, languageCode: StringOperators? = nil, name: StringOperators? = nil, slug: StringOperators? = nil, description: StringOperators? = nil, position: NumberOperators? = nil, isRoot: BooleanOperators? = nil, parentId: IDOperators? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.languageCode = languageCode
        self.name = name
        self.slug = slug
        self.description = description
        self.position = position
        self.isRoot = isRoot
        self.parentId = parentId
    }
}

public struct FacetFilterParameter: Codable {
    public let id: IDOperators?
    public let createdAt: DateOperators?
    public let updatedAt: DateOperators?
    public let languageCode: StringOperators?
    public let name: StringOperators?
    public let code: StringOperators?
    public let isPrivate: BooleanOperators?
    
    public init(id: IDOperators? = nil, createdAt: DateOperators? = nil, updatedAt: DateOperators? = nil, languageCode: StringOperators? = nil, name: StringOperators? = nil, code: StringOperators? = nil, isPrivate: BooleanOperators? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.languageCode = languageCode
        self.name = name
        self.code = code
        self.isPrivate = isPrivate
    }
}

public struct NumberOperators: Codable {
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

public struct NumberRange: Codable {
    public let start: Double
    public let end: Double
    
    public init(start: Double, end: Double) {
        self.start = start
        self.end = end
    }
}

// MARK: - Operation Types

public struct ConfigurableOperation: Codable, Hashable {
    public let code: String
    public let args: [ConfigArg]
    
    public init(code: String, args: [ConfigArg] = []) {
        self.code = code
        self.args = args
    }
}

public struct ConfigArg: Codable, Hashable {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

// MARK: - Filter Operators (continued from SystemOperations)

public struct IDOperators: Codable {
    public let eq: String?
    public let notEq: String?
    public let `in`: [String]?
    public let notIn: [String]?
    
    public init(eq: String? = nil, notEq: String? = nil, `in`: [String]? = nil, notIn: [String]? = nil) {
        self.eq = eq
        self.notEq = notEq
        self.`in` = `in`
        self.notIn = notIn
    }
}

public struct StringOperators: Codable {
    public let eq: String?
    public let notEq: String?
    public let contains: String?
    public let notContains: String?
    public let `in`: [String]?
    public let notIn: [String]?
    public let regex: String?
    
    public init(eq: String? = nil, notEq: String? = nil, contains: String? = nil, notContains: String? = nil, `in`: [String]? = nil, notIn: [String]? = nil, regex: String? = nil) {
        self.eq = eq
        self.notEq = notEq
        self.contains = contains
        self.notContains = notContains
        self.`in` = `in`
        self.notIn = notIn
        self.regex = regex
    }
}

public struct BooleanOperators: Codable {
    public let eq: Bool?
    
    public init(eq: Bool? = nil) {
        self.eq = eq
    }
}

public struct DateOperators: Codable {
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

// MARK: - Tag Types

public struct Tag: Codable, Hashable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let value: String
    
    public init(id: String, createdAt: Date, updatedAt: Date, value: String) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.value = value
    }
}
