import Foundation

// MARK: - Custom Field Configuration System

/// Protocol for providing custom field configuration
public protocol CustomFieldProvider {
    var fieldName: String { get }
    var graphQLFragment: String { get }
    var applicableTypes: [String] { get } // ["Product", "ProductVariant", "Order", "Customer", "Collection"]
    var isExtendedField: Bool { get } // true for extended GraphQL fields, false for customFields
}

/// Concrete implementation of CustomFieldProvider
public struct CustomField: CustomFieldProvider, Sendable {
    public let fieldName: String
    public let graphQLFragment: String
    public let applicableTypes: [String]
    public let isExtendedField: Bool
    
    public init(fieldName: String, graphQLFragment: String, applicableTypes: [String], isExtendedField: Bool = false) {
        self.fieldName = fieldName
        self.graphQLFragment = graphQLFragment
        self.applicableTypes = applicableTypes
        self.isExtendedField = isExtendedField
    }
}

// MARK: - Factory Methods (SUGAR LAYER)

extension CustomField {
    /// For extended GraphQL fields of type Asset (such as mainUsdzAsset)
    public static func extendedAsset(name: String, applicableTypes: [String]) -> CustomField {
        return CustomField(
            fieldName: name,
            graphQLFragment: "\(name) { id name type mimeType source preview }",
            applicableTypes: applicableTypes,
            isExtendedField: true
        )
    }
    
    /// For extended GraphQL fields of type Asset with custom fields
    public static func extendedAssetDetailed(name: String, applicableTypes: [String]) -> CustomField {
        return CustomField(
            fieldName: name,
            graphQLFragment: """
            \(name) {
              id
              name
              type
              mimeType
              source
              preview
              width
              height
              fileSize
              focalPoint { x y }
              tags { id value }
            }
            """,
            applicableTypes: applicableTypes,
            isExtendedField: true
        )
    }
    
    /// For extended GraphQL relationships
    public static func extendedRelation(name: String, fields: [String] = ["id", "name"], applicableTypes: [String]) -> CustomField {
        let fieldList = fields.joined(separator: " ")
        return CustomField(
            fieldName: name,
            graphQLFragment: "\(name) { \(fieldList) }",
            applicableTypes: applicableTypes,
            isExtendedField: true
        )
    }
    
    /// For extended scalar fields
    public static func extendedScalar(name: String, applicableTypes: [String]) -> CustomField {
        return CustomField(
            fieldName: name,
            graphQLFragment: name,
            applicableTypes: applicableTypes,
            isExtendedField: true
        )
    }
    
    /// For a single native Vendure custom field
    public static func vendureCustomField(name: String, applicableTypes: [String]) -> CustomField {
        return CustomField(
            fieldName: "customFields",
            graphQLFragment: "customFields { \(name) }",
            applicableTypes: applicableTypes,
            isExtendedField: false
        )
    }
    
    /// For several native Vendure custom fields at once
    public static func vendureCustomFields(names: [String], applicableTypes: [String]) -> CustomField {
        let fieldList = names.joined(separator: " ")
        return CustomField(
            fieldName: "customFields",
            graphQLFragment: "customFields { \(fieldList) }",
            applicableTypes: applicableTypes,
            isExtendedField: false
        )
    }
    
    /// For complex relationships with nesting
    public static func extendedComplexRelation(name: String, nestedFields: [String: [String]], applicableTypes: [String]) -> CustomField {
        var fragment = "\(name) {\n"
        for (key, fields) in nestedFields {
            if fields.isEmpty {
                fragment += "  \(key)\n"
            } else {
                fragment += "  \(key) { \(fields.joined(separator: " ")) }\n"
            }
        }
        fragment += "}"
        
        return CustomField(
            fieldName: name,
            graphQLFragment: fragment,
            applicableTypes: applicableTypes,
            isExtendedField: true
        )
    }
}

// MARK: - Global Configuration

/// Global SDK configuration for custom fields
public class VendureConfiguration: @unchecked Sendable {
    nonisolated(unsafe) public static var shared = VendureConfiguration()
    
    private var _customFields: [CustomField] = []
    private let queue = DispatchQueue(label: "vendure.configuration", attributes: .concurrent)
    
    public var customFields: [CustomField] {
        return queue.sync { _customFields }
    }
    
    private init() {}
    
    /// Add a custom field with validation
    public func addCustomField(_ customField: CustomField) {
        queue.async(flags: .barrier) {
            // Basic validation
            guard self.validateFragment(customField.graphQLFragment) else {
                print("Warning: Invalid GraphQL fragment for field '\(customField.fieldName)'")
                return
            }
            
            // Avoid duplicates for customFields
            if !customField.isExtendedField && customField.fieldName == "customFields" {
                // Merge with an existing customFields if possible
                if let existingIndex = self._customFields.firstIndex(where: { field in
                    !field.isExtendedField && 
                    field.fieldName == "customFields" && 
                    Set(field.applicableTypes) == Set(customField.applicableTypes)
                }) {
                    // Replace the existing one
                    self._customFields[existingIndex] = customField
                    return
                }
            }
            
            // Avoid duplicates for extended fields
            if customField.isExtendedField {
                if let existingIndex = self._customFields.firstIndex(where: { field in
                    field.isExtendedField &&
                    field.fieldName == customField.fieldName &&
                    Set(field.applicableTypes) == Set(customField.applicableTypes)
                }) {
                    // Replace the existing one
                    self._customFields[existingIndex] = customField
                    return
                }
            }
            
            self._customFields.append(customField)
        }
    }
    
    /// Add multiple custom fields
    public func addCustomFields(_ customFields: [CustomField]) {
        for field in customFields {
            addCustomField(field)
        }
    }
    
    /// Retrieve all custom fields for a given type
    public func getCustomFieldsFor(type: String) -> [CustomField] {
        return queue.sync {
            return _customFields.filter { $0.applicableTypes.contains(type) }
        }
    }
    
    /// Retrieve only extended fields for a given type
    public func getExtendedFieldsFor(type: String) -> [CustomField] {
        return queue.sync {
            return _customFields.filter { $0.applicableTypes.contains(type) && $0.isExtendedField }
        }
    }
    
    /// Retrieve the Vendure customFields field for a given type
    public func getVendureCustomFieldsFor(type: String) -> CustomField? {
        return queue.sync {
            return _customFields.first { field in
                field.applicableTypes.contains(type) && 
                !field.isExtendedField && 
                field.fieldName == "customFields"
            }
        }
    }
    
    /// Delete all custom fields
    public func clearCustomFields() {
        queue.async(flags: .barrier) {
            self._customFields.removeAll()
        }
    }
    
    /// Delete a specific custom field
    public func removeCustomField(fieldName: String, forTypes types: [String]) {
        queue.async(flags: .barrier) {
            self._customFields.removeAll { field in
                field.fieldName == fieldName && Set(field.applicableTypes) == Set(types)
            }
        }
    }
    
    /// Basic validation of GraphQL fragments
    private func validateFragment(_ fragment: String) -> Bool {
        let trimmed = fragment.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Must not be empty
        guard !trimmed.isEmpty else { return false }
        
        // Must not contain mutations or subscriptions
        let lowercased = trimmed.lowercased()
        guard !lowercased.contains("mutation") && !lowercased.contains("subscription") else { return false }
        
        // Basic validation of braces (simple heuristic)
        let openBraces = trimmed.components(separatedBy: "{").count - 1
        let closeBraces = trimmed.components(separatedBy: "}").count - 1
        guard openBraces == closeBraces else { return false }
        
        return true
    }
}

// MARK: - GraphQL Fragment Injection System

/// Extension to inject custom fields into GraphQL queries
extension VendureConfiguration {
    
    /// Inject custom field fragments for a given type
    public func injectCustomFields(for type: String, includeCustomFields: Bool = true) -> String {
        guard includeCustomFields else { return "" }
        
        let customFields = getCustomFieldsFor(type: type)
        guard !customFields.isEmpty else { return "" }
        
        var fragments: [String] = []
        
        for field in customFields {
            fragments.append(field.graphQLFragment)
        }
        
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
    /// This is used by operations to decide whether to inject custom fields
    public func shouldIncludeCustomFields(for type: String, userRequested: Bool?) -> Bool {
        // If user explicitly requested custom fields
        if let userRequested = userRequested {
            return userRequested
        }
        
        // Default: include custom fields if any are configured for this type
        return hasCustomFields(for: type)
    }
    
    /// Get a summary of the configuration for debugging
    public func getConfigurationSummary() -> String {
        let fields = customFields
        let summary = fields.map { field in
            let typeList = field.applicableTypes.joined(separator: ", ")
            let fieldType = field.isExtendedField ? "Extended" : "CustomField"
            return "[\(fieldType)] \(field.fieldName) -> [\(typeList)]"
        }.joined(separator: "\n")
        
        return """
        VendureConfiguration Summary:
        Total Custom Fields: \(fields.count)
        \(summary.isEmpty ? "No custom fields configured." : summary)
        """
    }
}
