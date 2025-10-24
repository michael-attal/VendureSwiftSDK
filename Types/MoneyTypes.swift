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
