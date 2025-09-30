//
//  VendureConfiguration.swift
//  project-novacommerce
//
//  Created by Michaël ATTAL on 29/09/2025.
//

import Foundation

/// Global SDK configuration
public class VendureConfiguration: @unchecked Sendable {
    public static let shared = VendureConfiguration()
    
    private var _customFields: [CustomField] = []
    private let lock = NSLock()
    private var _isUsingStellateCache: Bool = false

    public var customFields: [CustomField] {
        lock.lock()
        defer { lock.unlock() }
        return _customFields
    }
    
    public var isUsingStellateCache: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isUsingStellateCache
    }
        
    public func setStellateCache(enabled: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _isUsingStellateCache = enabled
    }
    
    private init() {}
    
    // MARK: - Custom fields Configuration

    /// Add a custom field with validation
    public func addCustomField(_ customField: CustomField) {
        lock.lock()
        defer { lock.unlock() }
        
        // Basic validation
        guard validateFragment(customField.graphQLFragment) else {
            print("Warning: Invalid GraphQL fragment for field '\(customField.fieldName)'")
            return
        }
        
        // Avoid duplicates for customFields
        if !customField.isExtendedField && customField.fieldName == "customFields" {
            if let existingIndex = _customFields.firstIndex(where: { field in
                !field.isExtendedField &&
                field.fieldName == "customFields" &&
                Set(field.applicableTypes) == Set(customField.applicableTypes)
            }) {
                _customFields[existingIndex] = customField
                return
            }
        }
        
        // Avoid duplicates for extended fields
        if customField.isExtendedField {
            if let existingIndex = _customFields.firstIndex(where: { field in
                field.isExtendedField &&
                field.fieldName == customField.fieldName &&
                Set(field.applicableTypes) == Set(customField.applicableTypes)
            }) {
                _customFields[existingIndex] = customField
                return
            }
        }
        
        _customFields.append(customField)
    }
    
    /// Add multiple custom fields
    public func addCustomFields(_ customFields: [CustomField]) {
        for field in customFields {
            addCustomField(field)
        }
    }
    
    /// Retrieve all custom fields for a given type
    public func getCustomFieldsFor(type: String) -> [CustomField] {
        lock.lock()
        defer { lock.unlock() }
        return _customFields.filter { $0.applicableTypes.contains(type) }
    }
    
    /// Retrieve only extended fields for a given type
    public func getExtendedFieldsFor(type: String) -> [CustomField] {
        lock.lock()
        defer { lock.unlock() }
        return _customFields.filter { $0.applicableTypes.contains(type) && $0.isExtendedField }
    }
    
    /// Retrieve the Vendure customFields field for a given type
    public func getVendureCustomFieldsFor(type: String) -> CustomField? {
        lock.lock()
        defer { lock.unlock() }
        return _customFields.first { field in
            field.applicableTypes.contains(type) &&
            !field.isExtendedField &&
            field.fieldName == "customFields"
        }
    }
    
    /// Delete all custom fields
    public func clearCustomFields() {
        lock.lock()
        defer { lock.unlock() }
        _customFields.removeAll()
    }
    
    /// Delete a specific custom field
    public func removeCustomField(fieldName: String, forTypes types: [String]) {
        lock.lock()
        defer { lock.unlock() }
        _customFields.removeAll { field in
            field.fieldName == fieldName && Set(field.applicableTypes) == Set(types)
        }
    }
    
    /// Basic validation of GraphQL fragments
    private func validateFragment(_ fragment: String) -> Bool {
        let trimmed = fragment.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return false }
        
        let lowercased = trimmed.lowercased()
        guard !lowercased.contains("mutation") && !lowercased.contains("subscription") else { return false }
        
        let openBraces = trimmed.components(separatedBy: "{").count - 1
        let closeBraces = trimmed.components(separatedBy: "}").count - 1
        guard openBraces == closeBraces else { return false }
        
        return true
    }
    
    /// Inject custom field fragments for a given type
    public func injectCustomFields(for type: String, includeCustomFields: Bool = true) -> String {
        guard includeCustomFields else { return "" }
        
        let fields = getCustomFieldsFor(type: type)
        guard !fields.isEmpty else { return "" }
        
        let fragments = fields.map { $0.graphQLFragment }
        return fragments.joined(separator: "\n            ")
    }
    
    /// Building a complete GraphQL fragment for a type
    public func buildGraphQLFragment(for type: String, baseFields: [String], includeCustomFields: Bool = true) -> String {
        var allFields = baseFields
        
        if includeCustomFields {
            let customFields = getCustomFieldsFor(type: type)
            let customFragments = customFields.map { $0.graphQLFragment }
            allFields.append(contentsOf: customFragments)
        }
        
        return allFields.joined(separator: "\n            ")
    }
    
    /// Check if a type has custom fields configured
    public func hasCustomFields(for type: String) -> Bool {
        return !getCustomFieldsFor(type: type).isEmpty
    }
    
    /// Determine if custom fields should be included in queries
    public func shouldIncludeCustomFields(for type: String, userRequested: Bool?) -> Bool {
        if let userRequested = userRequested {
            return userRequested
        }
        return hasCustomFields(for: type)
    }
    
    /// Get a summary of the configuration for debugging
    public func getConfigurationSummary() -> String {
        let retrievedFields = customFields
        
        let summary = retrievedFields.map { field in
            let typeList = field.applicableTypes.joined(separator: ", ")
            let fieldType = field.isExtendedField ? "Extended" : "CustomField"
            return "[\(fieldType)] \(field.fieldName) -> [\(typeList)]"
        }.joined(separator: "\n")
        
        return """
        VendureConfiguration Summary:
        Total Custom Fields: \(retrievedFields.count)
        \(summary.isEmpty ? "No custom fields configured." : summary)
        """
    }
    
    // MARK: - AnyCodable Helper Methods
    
    /// Create a custom field value dictionary using AnyCodable for type safety
    public static func createCustomFieldsDict(_ values: [String: any Encodable]) -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]
        for (key, value) in values {
            // Convert Encodable to AnyCodable through JSON serialization for safety
            if let string = value as? String {
                result[key] = AnyCodable(string)
            } else if let int = value as? Int {
                result[key] = AnyCodable(int)
            } else if let double = value as? Double {
                result[key] = AnyCodable(double)
            } else if let bool = value as? Bool {
                result[key] = AnyCodable(bool)
            } else {
                // For complex Encodable types, go through JSON encoding
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(AnyEncodable(value)),
                   let json = try? JSONSerialization.jsonObject(with: data) {
                    result[key] = AnyCodable(anyValue: json)
                } else {
                    result[key] = AnyCodable(anyValue: "")
                }
            }
        }
        return result
    }
    
    /// Convert a custom fields dictionary to AnyCodable format
    public static func toAnyCodable(_ customFields: [String: Any]?) -> [String: AnyCodable]? {
        guard let customFields = customFields else { return nil }
        return customFields.mapValues { AnyCodable(anyValue: $0) }
    }
    
    /// Extract a typed value from AnyCodable custom fields
    public static func extractValue<T>(_ customFields: [String: AnyCodable]?, key: String, type: T.Type) -> T? {
        guard let customFields = customFields else { return nil }
        
        if T.self == String.self {
            return customFields[key]?.stringValue as? T
        } else if T.self == Int.self {
            return customFields[key]?.intValue as? T
        } else if T.self == Double.self {
            return customFields[key]?.doubleValue as? T
        } else if T.self == Bool.self {
            return customFields[key]?.boolValue as? T
        }
        
        return nil
    }
}
