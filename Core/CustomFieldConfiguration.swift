import Foundation

// MARK: - Custom Field Configuration System

/// Protocol for providing custom field configuration
public protocol CustomFieldProvider {
    var fieldName: String { get }
    var graphQLFragment: String { get }
    var applicableTypes: [String] { get }
    var isExtendedField: Bool { get }
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

// MARK: - Factory Methods

extension CustomField {
    /// For extended GraphQL fields of type Asset
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
    
    /// For a single native Vendure custom field that is an Asset relation
    public static func vendureCustomFieldAsset(name: String, applicableTypes: [String]) -> CustomField {
        return CustomField(
            fieldName: "customFields",
            graphQLFragment: "customFields { \(name) { id name type mimeType source preview } }",
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
