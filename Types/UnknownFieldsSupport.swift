import Foundation

// MARK: - Unknown Fields Support for Skip Compatibility
// This allows VendureSwiftSDK to capture and store unknown JSON fields
// during decoding without breaking Skip compatibility rules

/// Raw JSON wrapper that stores a single JSON value as a string
/// Skip-compatible: Codable, Sendable, no generics, immutable
public struct RawJSON: Codable, Sendable, Hashable, Equatable {
    public let jsonString: String
    
    public init(_ jsonString: String) {
        self.jsonString = jsonString
    }
    
    /// Decode this raw JSON to a specific type
    public func decode<T: Codable>(to type: T.Type) -> T? {
        guard let data = jsonString.data(using: .utf8) else {
            print("[UnknownFields] Failed to convert JSON string to data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(type, from: data)
            print("[UnknownFields] ✅ Successfully decoded \(String(describing: type))")
            return result
        } catch {
            print("[UnknownFields] ❌ Failed to decode \(String(describing: type)): \(error)")
            return nil
        }
    }
    
    /// Get as dictionary for inspection
    public var asDictionary: [String: Any]? {
        guard let data = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }
}

/// Container for unknown JSON fields captured during decoding
/// Skip-compatible: Codable, Sendable, immutable storage
public struct UnknownJSONFieldsContainer: Codable, Sendable, Hashable, Equatable {
    private let fields: [String: RawJSON]
    
    public init(_ fields: [String: RawJSON] = [:]) {
        self.fields = fields
    }
    
    /// Access a specific unknown field by key
    public subscript(_ key: String) -> RawJSON? {
        return fields[key]
    }
    
    /// Get all available field names
    public var fieldNames: [String] {
        return Array(fields.keys).sorted()
    }
    
    /// Check if container is empty
    public var isEmpty: Bool {
        return fields.isEmpty
    }
    
    /// Debug print all contained fields
    public func debugPrint() {
        if isEmpty {
            print("[UnknownFields] Container is empty")
        } else {
            print("[UnknownFields] Container has \(fields.count) unknown fields: \(fieldNames)")
            for (key, value) in fields {
                print("[UnknownFields]   \(key): \(String(value.jsonString.prefix(100)))")
            }
        }
    }
}

/// Protocol for types that support unknown JSON fields
/// Skip-compatible: no generics, simple protocol
public protocol UnknownJSONAccessible: Codable, Sendable {
    var unknownFields: UnknownJSONFieldsContainer { get }
}

// MARK: - Decoding Helper Types

/// Dynamic CodingKey for iterating over all JSON keys
/// Top-level struct to respect Skip's "no nested types" rule
public struct DynamicCodingKey: CodingKey, Sendable {
    public let stringValue: String
    public let intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

/// Helper for extracting raw JSON from specific keys during decoding
/// Top-level struct to respect Skip's "no nested types" rule
public struct RawJSONExtractor: Sendable {
    
    /// Extract raw JSON for a specific key from a decoder
    /// Returns the JSON as a string, or nil if extraction fails
    public static func extractRawJSON(from container: KeyedDecodingContainer<DynamicCodingKey>, 
                                      forKey key: DynamicCodingKey) -> String? {
        do {
            // Try to get the raw value
            if let stringValue = try? container.decode(String.self, forKey: key) {
                // If it's already a string, wrap it in quotes to make it valid JSON
                return "\"\(stringValue)\""
            }
            
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return String(intValue)
            }
            
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return String(doubleValue)
            }
            
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                return String(boolValue)
            }
            
            // For complex objects, try to decode as Any and re-encode
            // This is a workaround for Skip compatibility
            if let anyValue = try? container.decode(AnyCodableValue.self, forKey: key) {
                return anyValue.jsonString
            }
            
            return nil
        } catch {
            print("[UnknownFields] Failed to extract raw JSON for key '\(key.stringValue)': \(error)")
            return nil
        }
    }
}

/// Skip-compatible wrapper for Any values during decoding
/// Used internally to capture unknown complex objects
public struct AnyCodableValue: Codable, Sendable {
    let jsonString: String
    
    public init(from decoder: Decoder) throws {
        // Try to capture the raw JSON by re-encoding what we decoded
        let container = try decoder.singleValueContainer()
        
        // Try different types and re-encode to JSON
        if let dict = try? container.decode([String: AnyCodableValue].self) {
            let encoder = JSONEncoder()
            let data = try encoder.encode(dict)
            self.jsonString = String(data: data, encoding: .utf8) ?? "{}"
        } else if let array = try? container.decode([AnyCodableValue].self) {
            let encoder = JSONEncoder()
            let data = try encoder.encode(array)
            self.jsonString = String(data: data, encoding: .utf8) ?? "[]"
        } else if let string = try? container.decode(String.self) {
            self.jsonString = "\"\(string)\""
        } else if let int = try? container.decode(Int.self) {
            self.jsonString = String(int)
        } else if let double = try? container.decode(Double.self) {
            self.jsonString = String(double)
        } else if let bool = try? container.decode(Bool.self) {
            self.jsonString = String(bool)
        } else {
            self.jsonString = "null"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(jsonString)
    }
}