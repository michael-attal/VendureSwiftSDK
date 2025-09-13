import Foundation

// MARK: - Protocol for accessing extended fields

/// Protocol for accessing extended fields in a typed manner
public protocol ExtendedFieldAccess {
    /// Get an extended field by name
    func getExtendedField<T>(_ name: String, type: T.Type) -> T?
    
    /// Check if an extended field exists
    func hasExtendedField(_ name: String) -> Bool
    
    /// Get all extended fields configured for this type
    func getAvailableExtendedFields() -> [String]
}

// MARK: - Internal container for extended field data

/// Internal container for storing decoded extended field data
internal class ExtendedFieldContainer {
    private var data: [String: Any] = [:]
    private let lock = NSLock()
    
    func set(_ value: Any, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        data[key] = value
    }
    
    func get<T>(_ key: String, type: T.Type) -> T? {
        lock.lock()
        defer { lock.unlock() }
        return data[key] as? T
    }
    
    func has(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return data[key] != nil
    }
    
    func allKeys() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(data.keys)
    }
}

// MARK: - Extensions for Core Types

extension Product: ExtendedFieldAccess {
    /// Private container for extended fields (using objc/runtime would be ideal, but let's keep it simple)
    private static var extendedFieldContainers: [String: ExtendedFieldContainer] = [:]
    private static var containerLock = NSLock()
    
    private var extendedFieldContainer: ExtendedFieldContainer {
        Product.containerLock.lock()
        defer { Product.containerLock.unlock() }
        
        if let container = Product.extendedFieldContainers[self.id] {
            return container
        } else {
            let container = ExtendedFieldContainer()
            Product.extendedFieldContainers[self.id] = container
            return container
        }
    }
    
    /// Define an extended field (used internally during JSON decoding)
    public func setExtendedField<T>(_ name: String, value: T) {
        extendedFieldContainer.set(value, forKey: name)
    }
    
    /// Get an extended typed field
    public func getExtendedField<T>(_ name: String, type: T.Type) -> T? {
        return extendedFieldContainer.get(name, type: type)
    }
    
    /// Check for the existence of an extended field
    public func hasExtendedField(_ name: String) -> Bool {
        return extendedFieldContainer.has(name)
    }
    
    /// Get the list of available extended fields configured for Product
    public func getAvailableExtendedFields() -> [String] {
        let configuredFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "Product")
        return configuredFields.map { $0.fieldName }
    }
}

extension ProductVariant: ExtendedFieldAccess {
    private static var extendedFieldContainers: [String: ExtendedFieldContainer] = [:]
    private static var containerLock = NSLock()
    
    private var extendedFieldContainer: ExtendedFieldContainer {
        ProductVariant.containerLock.lock()
        defer { ProductVariant.containerLock.unlock() }
        
        if let container = ProductVariant.extendedFieldContainers[self.id] {
            return container
        } else {
            let container = ExtendedFieldContainer()
            ProductVariant.extendedFieldContainers[self.id] = container
            return container
        }
    }
    
    public func setExtendedField<T>(_ name: String, value: T) {
        extendedFieldContainer.set(value, forKey: name)
    }
    
    public func getExtendedField<T>(_ name: String, type: T.Type) -> T? {
        return extendedFieldContainer.get(name, type: type)
    }
    
    public func hasExtendedField(_ name: String) -> Bool {
        return extendedFieldContainer.has(name)
    }
    
    public func getAvailableExtendedFields() -> [String] {
        let configuredFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "ProductVariant")
        return configuredFields.map { $0.fieldName }
    }
}

extension Collection: ExtendedFieldAccess {
    private static var extendedFieldContainers: [String: ExtendedFieldContainer] = [:]
    private static var containerLock = NSLock()
    
    private var extendedFieldContainer: ExtendedFieldContainer {
        Collection.containerLock.lock()
        defer { Collection.containerLock.unlock() }
        
        if let container = Collection.extendedFieldContainers[self.id] {
            return container
        } else {
            let container = ExtendedFieldContainer()
            Collection.extendedFieldContainers[self.id] = container
            return container
        }
    }
    
    public func setExtendedField<T>(_ name: String, value: T) {
        extendedFieldContainer.set(value, forKey: name)
    }
    
    public func getExtendedField<T>(_ name: String, type: T.Type) -> T? {
        return extendedFieldContainer.get(name, type: type)
    }
    
    public func hasExtendedField(_ name: String) -> Bool {
        return extendedFieldContainer.has(name)
    }
    
    public func getAvailableExtendedFields() -> [String] {
        let configuredFields = VendureConfiguration.shared.getExtendedFieldsFor(type: "Collection")
        return configuredFields.map { $0.fieldName }
    }
}

// MARK: - Convenient Extensions for Common Use Cases

extension Product {
    /// Typed access to the mainUsdzAsset field (example of use)
    public var mainUsdzAsset: Asset? {
        return getExtendedField("mainUsdzAsset", type: Asset.self)
    }
    
    /// Helper to get an extended asset by name
    public func getExtendedAsset(_ fieldName: String) -> Asset? {
        return getExtendedField(fieldName, type: Asset.self)
    }
    
    /// Helper for obtaining an extended scalar field
    public func getExtendedScalar<T>(_ fieldName: String, type: T.Type) -> T? {
        return getExtendedField(fieldName, type: type)
    }
    
    /// Helper for obtaining an extended relationship field
    public func getExtendedRelation<T>(_ fieldName: String, type: T.Type) -> T? {
        return getExtendedField(fieldName, type: type)
    }
}

extension ProductVariant {
    /// Example for ProductVariant
    public var mainUsdzAsset: Asset? {
        return getExtendedField("mainUsdzAsset", type: Asset.self)
    }
    
    public func getExtendedAsset(_ fieldName: String) -> Asset? {
        return getExtendedField(fieldName, type: Asset.self)
    }
    
    public func getExtendedScalar<T>(_ fieldName: String, type: T.Type) -> T? {
        return getExtendedField(fieldName, type: type)
    }
}

extension Collection {
    /// Helper for collections
    public func getExtendedAsset(_ fieldName: String) -> Asset? {
        return getExtendedField(fieldName, type: Asset.self)
    }
    
    public func getExtendedScalar<T>(_ fieldName: String, type: T.Type) -> T? {
        return getExtendedField(fieldName, type: type)
    }
}

// MARK: - Custom Field Access Helpers

extension Product {
    /// Easy access to Vendure's native custom fields
    public func getCustomField<T>(_ name: String, type: T.Type) -> T? {
        guard let customFields = self.customFields,
              let anyCodableValue = customFields[name] else {
            return nil
        }
        return anyCodableValue.value as? T
    }
    
    /// Check for the existence of a custom field
    public func hasCustomField(_ name: String) -> Bool {
        return customFields?[name] != nil
    }
}

extension ProductVariant {
    public func getCustomField<T>(_ name: String, type: T.Type) -> T? {
        guard let customFields = self.customFields,
              let anyCodableValue = customFields[name] else {
            return nil
        }
        return anyCodableValue.value as? T
    }
    
    public func hasCustomField(_ name: String) -> Bool {
        return customFields?[name] != nil
    }
}

extension Collection {
    public func getCustomField<T>(_ name: String, type: T.Type) -> T? {
        guard let customFields = self.customFields,
              let anyCodableValue = customFields[name] else {
            return nil
        }
        return anyCodableValue.value as? T
    }
    
    public func hasCustomField(_ name: String) -> Bool {
        return customFields?[name] != nil
    }
}

// MARK: - JSON Decoder Extension to automatically populate extended fields

/// Extension to automatically populate extended fields during JSON decoding
public class ExtendedFieldJSONDecoder: JSONDecoder {
    
    public override init() {
        super.init()
        // Configuration for date decoding if necessary
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            if let date = formatter.date(from: string) {
                return date
            }
            
            // Fallback for other formats
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: string) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
        })
    }
    
    /// Decode with automatic population of extended fields
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let result = try super.decode(type, from: data)
        
        // Populate extended fields if the object supports them
        if let extendedFieldAccessObject = result as? ExtendedFieldAccess {
            try populateExtendedFields(for: extendedFieldAccessObject, from: data, type: type)
        }
        
        return result
    }
    
    private func populateExtendedFields<T>(for object: ExtendedFieldAccess, from data: Data, type: T.Type) throws {
        // Get the string type for the configuration
        let typeString = String(describing: type).replacingOccurrences(of: ".Type", with: "")
        
        // Get the configured extended fields
        let extendedFields = VendureConfiguration.shared.getExtendedFieldsFor(type: typeString)
        
        guard !extendedFields.isEmpty else { return }
        
        // Parse the JSON to extract the extended fields
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            for field in extendedFields {
                if let fieldValue = json[field.fieldName] {
                    // Here, ideally, we should type according to the type of field configured.
                    // For simplicity, we store the raw value.
                    if let product = object as? Product {
                        product.setExtendedField(field.fieldName, value: fieldValue)
                    } else if let variant = object as? ProductVariant {
                        variant.setExtendedField(field.fieldName, value: fieldValue)
                    } else if let collection = object as? Collection {
                        collection.setExtendedField(field.fieldName, value: fieldValue)
                    }
                }
            }
        }
    }
}
