import Foundation

// MARK: - Custom Field Access Helpers (SKIP Compatible)
// Removed generic extended field system for SKIP compatibility
// Using only customFields JSON string parsing with concrete types

extension Product {
    /// Parse custom fields JSON and get a string field
    public func getCustomFieldString(_ name: String) -> String? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? String else {
            return nil
        }
        return value
    }
    
    /// Parse custom fields JSON and get an integer field
    public func getCustomFieldInt(_ name: String) -> Int? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? Int else {
            return nil
        }
        return value
    }
    
    /// Parse custom fields JSON and get a boolean field
    public func getCustomFieldBool(_ name: String) -> Bool? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? Bool else {
            return nil
        }
        return value
    }
    
    /// Check for the existence of a custom field
    public func hasCustomField(_ name: String) -> Bool {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return false
        }
        return json[name] != nil
    }
}

extension ProductVariant {
    /// Parse custom fields JSON and get a string field
    public func getCustomFieldString(_ name: String) -> String? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? String else {
            return nil
        }
        return value
    }
    
    /// Parse custom fields JSON and get an integer field
    public func getCustomFieldInt(_ name: String) -> Int? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? Int else {
            return nil
        }
        return value
    }
    
    /// Parse custom fields JSON and get a boolean field
    public func getCustomFieldBool(_ name: String) -> Bool? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? Bool else {
            return nil
        }
        return value
    }
    
    /// Check for the existence of a custom field
    public func hasCustomField(_ name: String) -> Bool {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return false
        }
        return json[name] != nil
    }
}

extension VendureCollection {
    /// Parse custom fields JSON and get a string field
    public func getCustomFieldString(_ name: String) -> String? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? String else {
            return nil
        }
        return value
    }
    
    /// Parse custom fields JSON and get an integer field
    public func getCustomFieldInt(_ name: String) -> Int? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? Int else {
            return nil
        }
        return value
    }
    
    /// Parse custom fields JSON and get a boolean field
    public func getCustomFieldBool(_ name: String) -> Bool? {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let value = json[name] as? Bool else {
            return nil
        }
        return value
    }
    
    /// Check for the existence of a custom field
    public func hasCustomField(_ name: String) -> Bool {
        guard let customFieldsJSON = self.customFields,
              let data = customFieldsJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return false
        }
        return json[name] != nil
    }
}

// MARK: - Custom Field Utilities (SKIP Compatible)

/// Utility for working with custom fields in JSON format - SKIP compatible
public struct CustomFieldsUtility {
    
    /// Convert a string dictionary to JSON string for custom fields
    public static func toJSON(_ fields: [String: String]) -> String? {
        guard let data = try? JSONEncoder().encode(fields) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Parse JSON string to string dictionary
    public static func fromJSON(_ json: String) -> [String: String]? {
        guard let data = json.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        return dict
    }
    
    /// Update a specific field in the JSON string
    public static func updateField(in jsonString: String?, key: String, value: String) -> String? {
        var fields = fromJSON(jsonString ?? "{}") ?? [:]
        fields[key] = value
        return toJSON(fields)
    }
    
    /// Remove a field from the JSON string
    public static func removeField(from jsonString: String?, key: String) -> String? {
        var fields = fromJSON(jsonString ?? "{}") ?? [:]
        fields.removeValue(forKey: key)
        return toJSON(fields)
    }
}