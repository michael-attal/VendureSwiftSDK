import Foundation

// MARK: - Generic Custom Field Protocol

/// Protocol for types that support custom fields
public protocol CustomFieldSupport {
    var customFields: [String: AnyCodable]? { get }
}

// MARK: - Generic Custom Field Extensions

extension CustomFieldSupport {
    /// Get a string custom field value
    public func getCustomFieldString(_ name: String) -> String? {
        return customFields?[name]?.stringValue
    }
    
    /// Get an integer custom field value
    public func getCustomFieldInt(_ name: String) -> Int? {
        return customFields?[name]?.intValue
    }
    
    /// Get a boolean custom field value
    public func getCustomFieldBool(_ name: String) -> Bool? {
        return customFields?[name]?.boolValue
    }
    
    /// Get a double custom field value
    public func getCustomFieldDouble(_ name: String) -> Double? {
        return customFields?[name]?.doubleValue
    }
    
    /// Get an array custom field value
    public func getCustomFieldArray(_ name: String) -> [AnyCodable]? {
        return customFields?[name]?.arrayValue
    }
    
    /// Get a dictionary custom field value
    public func getCustomFieldDictionary(_ name: String) -> [String: AnyCodable]? {
        return customFields?[name]?.dictionaryValue
    }
    
    /// Check for the existence of a custom field
    public func hasCustomField(_ name: String) -> Bool {
        return customFields?[name] != nil
    }
    
    /// Check if a field exists and is not null
    public func hasNonNullCustomField(_ name: String) -> Bool {
        guard let field = customFields?[name] else { return false }
        return !field.isNull
    }
    
    /// Get a typed custom field value using AnyCodable's decode method
    public func getCustomField<T: Codable>(_ name: String, type: T.Type) -> T? {
        return customFields?[name]?.decode(type)
    }
    
    /// Get all custom field names
    public var customFieldNames: [String] {
        return customFields?.keys.sorted() ?? []
    }
    
    /// Get all custom fields as a standard [String: Any] dictionary
    public var customFieldsDict: [String: Any] {
        return customFields?.toAnyDictionary() ?? [:]
    }
    
    /// Get custom field with fallback value
    public func getCustomFieldWithFallback<T: Codable>(_ name: String, type: T.Type, fallback: T) -> T {
        return getCustomField(name, type: type) ?? fallback
    }
    
    /// Get string custom field with fallback
    public func getCustomFieldStringWithFallback(_ name: String, fallback: String) -> String {
        return getCustomFieldString(name) ?? fallback
    }
    
    /// Get int custom field with fallback
    public func getCustomFieldIntWithFallback(_ name: String, fallback: Int) -> Int {
        return getCustomFieldInt(name) ?? fallback
    }
    
    /// Get bool custom field with fallback
    public func getCustomFieldBoolWithFallback(_ name: String, fallback: Bool) -> Bool {
        return getCustomFieldBool(name) ?? fallback
    }
    
    /// Get double custom field with fallback
    public func getCustomFieldDoubleWithFallback(_ name: String, fallback: Double) -> Double {
        return getCustomFieldDouble(name) ?? fallback
    }
    
    /// Update/set a custom field value (returns new dictionary for immutable updates)
    public func settingCustomField<T: Codable & Hashable & Sendable>(_ name: String, value: T?) -> [String: AnyCodable] {
        var fields = customFields ?? [:]
        if let value = value {
            fields[name] = AnyCodable(value)
        } else {
            fields.removeValue(forKey: name)
        }
        return fields
    }
    
    /// Filter custom fields by prefix
    public func getCustomFieldsWithPrefix(_ prefix: String) -> [String: AnyCodable] {
        return customFields?.filter { $0.key.hasPrefix(prefix) } ?? [:]
    }
    
    /// Get custom fields matching a pattern
    public func getCustomFieldsMatching(_ pattern: String) -> [String: AnyCodable] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [:] }
        return customFields?.filter { key, _ in
            let range = NSRange(location: 0, length: key.utf16.count)
            return regex.firstMatch(in: key, options: [], range: range) != nil
        } ?? [:]
    }
    
    /// Convert all custom fields to a specific type if possible
    public func getAllCustomFields<T: Codable>(as type: T.Type) -> [String: T] {
        return customFields?.compactMapValues { $0.decode(type) } ?? [:]
    }
}

// MARK: - Protocol Conformance

// Product types
extension Product: CustomFieldSupport {}
extension ProductVariant: CustomFieldSupport {}
extension ProductOption: CustomFieldSupport {}
extension ProductOptionGroup: CustomFieldSupport {}

// Collection types
extension VendureCollection: CustomFieldSupport {}

// Order types
extension Order: CustomFieldSupport {}
extension OrderLine: CustomFieldSupport {}

// Customer types  
extension Customer: CustomFieldSupport {}
extension User: CustomFieldSupport {}
extension CustomerGroup: CustomFieldSupport {}

// Commerce types
extension Promotion: CustomFieldSupport {}

// Facet types
extension Facet: CustomFieldSupport {}
extension FacetValue: CustomFieldSupport {}

// Tax types (if they exist - add more types as needed)
// These will be added individually as we discover the exact type names

// MARK: - Custom Field Utilities

/// Utility for working with custom fields using AnyCodable dictionary
public struct CustomFieldsUtility {
    
    /// Create a custom fields dictionary from key-value pairs
    public static func create(_ fields: [String: Any]) -> [String: AnyCodable] {
        return fields.mapValues { AnyCodable(anyValue: $0) }
    }
    
    /// Update a specific field in the custom fields dictionary
    public static func updateField(in customFields: [String: AnyCodable]?, key: String, value: Any) -> [String: AnyCodable] {
        var fields = customFields ?? [:]
        fields[key] = AnyCodable(anyValue: value)
        return fields
    }
    
    /// Remove a field from the custom fields dictionary
    public static func removeField(from customFields: [String: AnyCodable]?, key: String) -> [String: AnyCodable] {
        var fields = customFields ?? [:]
        fields.removeValue(forKey: key)
        return fields
    }
    
    /// Convert custom fields dictionary to standard [String: Any] dictionary
    public static func toAnyDictionary(_ customFields: [String: AnyCodable]?) -> [String: Any] {
        return customFields?.toAnyDictionary() ?? [:]
    }
    
    /// Get all field names from custom fields
    public static func getAllFieldNames(_ customFields: [String: AnyCodable]?) -> [String] {
        guard let customFields = customFields else { return [] }
        return Array(customFields.keys)
    }
    
    /// Check if a field exists and is not null
    public static func hasNonNullField(_ customFields: [String: AnyCodable]?, key: String) -> Bool {
        guard let field = customFields?[key] else { return false }
        return !field.isNull
    }
}
