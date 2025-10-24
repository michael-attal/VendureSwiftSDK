import Foundation

// MARK: - AnyCodable Implementation

/// A type-erased codable value that can represent any JSON value
/// This provides flexible JSON handling with full type safety
public struct AnyCodable: Codable, Hashable, Sendable {
    public let value: AnyHashableSendable
    
    public init<T: Codable & Hashable & Sendable>(_ value: T) {
        self.value = AnyHashableSendable(value)
    }
    
    /// Convenience initializer for Any values (converts to appropriate type)
    public init(anyValue: Any) {
        if let bool = anyValue as? Bool {
            self.init(bool)
        } else if let int = anyValue as? Int {
            self.init(int)
        } else if let double = anyValue as? Double {
            self.init(double)
        } else if let string = anyValue as? String {
            self.init(string)
        } else if let array = anyValue as? [Any] {
            let codableArray = array.map { AnyCodable(anyValue: $0) }
            self.init(codableArray)
        } else if let dict = anyValue as? [String: Any] {
            let codableDict = dict.mapValues { AnyCodable(anyValue: $0) }
            self.init(codableDict)
        } else {
            self.init(AnyCodableNull())
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array)
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary)
        } else {
            self.init(AnyCodableNull())
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

// MARK: - AnyCodable Value Access

public extension AnyCodable {
    /// Access the underlying value as a specific type
    func decode<T: Codable>(_ type: T.Type) -> T? {
        return value.base as? T
    }
    
    /// Convenient accessors for common types
    var stringValue: String? { decode(String.self) }
    var intValue: Int? { decode(Int.self) }
    var doubleValue: Double? { decode(Double.self) }
    var boolValue: Bool? { decode(Bool.self) }
    var arrayValue: [AnyCodable]? { decode([AnyCodable].self) }
    var dictionaryValue: [String: AnyCodable]? { decode([String: AnyCodable].self) }
    
    /// Check if the value is null
    var isNull: Bool { value.base is AnyCodableNull }
}

// MARK: - Custom Subscript Support

public extension AnyCodable {
    /// Dictionary-style access for object values
    subscript(key: String) -> AnyCodable? { dictionaryValue?[key] }
    
    /// Array-style access for array values
    subscript(index: Int) -> AnyCodable? {
        guard let array = arrayValue, index < array.count else { return nil }
        return array[index]
    }
}

// MARK: - Supporting Types

/// A null value that conforms to our required protocols
public struct AnyCodableNull: Codable, Hashable, Sendable {
    public init() {}
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(
                AnyCodableNull.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected null value")
            )
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(0) // Null always hashes to 0
    }
    
    public static func == (lhs: AnyCodableNull, rhs: AnyCodableNull) -> Bool {
        return true // All nulls are equal
    }
}

/// A sendable wrapper for any hashable value
public struct AnyHashableSendable: Codable, Hashable, Sendable {
    public let base: any Hashable & Sendable & Codable
    
    public init<T: Hashable & Sendable & Codable>(_ base: T) {
        self.base = base
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            self.base = bool
        } else if let int = try? container.decode(Int.self) {
            self.base = int
        } else if let double = try? container.decode(Double.self) {
            self.base = double
        } else if let string = try? container.decode(String.self) {
            self.base = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.base = array
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.base = dictionary
        } else {
            // Use a special null marker that conforms to our protocols
            self.base = AnyCodableNull()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try encode(to: &container)
    }
    
    public func encode(to container: inout SingleValueEncodingContainer) throws {
        switch base {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [AnyCodable]:
            try container.encode(array)
        case let dictionary as [String: AnyCodable]:
            try container.encode(dictionary)
        case is AnyCodableNull:
            try container.encodeNil()
        default:
            // Fallback: try to encode as Codable
            if let codable = base as? any Codable {
                try container.encode(AnyEncodable(codable))
            } else {
                try container.encodeNil()
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch base {
        case let bool as Bool:
            hasher.combine(bool)
        case let int as Int:
            hasher.combine(int)
        case let double as Double:
            hasher.combine(double)
        case let string as String:
            hasher.combine(string)
        case let array as [AnyCodable]:
            hasher.combine(array)
        case let dictionary as [String: AnyCodable]:
            hasher.combine(dictionary)
        case is AnyCodableNull:
            hasher.combine(0) // Consistent hash for null
        default:
            hasher.combine(ObjectIdentifier(type(of: base)))
        }
    }
    
    public static func == (lhs: AnyHashableSendable, rhs: AnyHashableSendable) -> Bool {
        switch (lhs.base, rhs.base) {
        case (let lbool as Bool, let rbool as Bool):
            return lbool == rbool
        case (let lint as Int, let rint as Int):
            return lint == rint
        case (let ldouble as Double, let rdouble as Double):
            return ldouble == rdouble
        case (let lstring as String, let rstring as String):
            return lstring == rstring
        case (let larray as [AnyCodable], let rarray as [AnyCodable]):
            return larray == rarray
        case (let ldict as [String: AnyCodable], let rdict as [String: AnyCodable]):
            return ldict == rdict
        case (is AnyCodableNull, is AnyCodableNull):
            return true
        default:
            return false
        }
    }
}

// MARK: - Helper Type for Generic Encoding

public struct AnyEncodable: Encodable {
    public let encodeFunc: (Encoder) throws -> Void
    
    public init(_ value: any Encodable) {
        self.encodeFunc = { encoder in try value.encode(to: encoder) }
    }
    
    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
    
    public init(from decoder: Decoder) throws {
        // This should never be called since we only use this for encoding
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "AnyEncodable should not be decoded")
        )
    }
}

// MARK: - Convenience Extensions

public extension Dictionary where Key == String, Value == AnyCodable {
    /// Convert to a standard [String: Any] dictionary
    func toAnyDictionary() -> [String: Any] {
        return compactMapValues { anyCodable in
            switch anyCodable.value.base {
            case let bool as Bool: return bool
            case let int as Int: return int
            case let double as Double: return double
            case let string as String: return string
            case let array as [AnyCodable]: return array.map { $0.toAnyValue() }
            case let dict as [String: AnyCodable]: return dict.toAnyDictionary()
            case is AnyCodableNull: return nil
            default: return anyCodable.value.base
            }
        }
    }
}

public extension AnyCodable {
    /// Convert to Any value for compatibility
    func toAnyValue() -> Any? {
        switch value.base {
        case let bool as Bool: return bool
        case let int as Int: return int
        case let double as Double: return double
        case let string as String: return string
        case let array as [AnyCodable]: return array.map { $0.toAnyValue() }
        case let dict as [String: AnyCodable]: return dict.toAnyDictionary()
        case is AnyCodableNull: return nil
        default: return value.base
        }
    }
    
    /// Create AnyCodable from Any value
    init(anyValue: Any?) {
        if let value = anyValue {
            switch value {
            case let bool as Bool: self.init(bool)
            case let int as Int: self.init(int)
            case let double as Double: self.init(double)
            case let string as String: self.init(string)
            case let array as [Any]:
                self.init(array.map { AnyCodable(anyValue: $0) })
            case let dict as [String: Any]:
                self.init(dict.mapValues { AnyCodable(anyValue: $0) })
            default: self.init(AnyCodableNull())
            }
        } else {
            self.init(AnyCodableNull())
        }
    }
}
