import XCTest
@testable import VendureSwiftSDK

final class CustomFieldTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear configuration before each test
        VendureConfiguration.shared.clearCustomFields()
    }
    
    override func tearDown() {
        // Clear after each test to avoid interference
        VendureConfiguration.shared.clearCustomFields()
        super.tearDown()
    }
    
    // MARK: - Tests Factory Methods
    
    func testExtendedAssetFactory() {
        let customField = CustomField.extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product", "ProductVariant"])
        
        XCTAssertEqual(customField.fieldName, "mainUsdzAsset")
        XCTAssertEqual(customField.graphQLFragment, "mainUsdzAsset { id name type mimeType source preview }")
        XCTAssertEqual(customField.applicableTypes, ["Product", "ProductVariant"])
        XCTAssertTrue(customField.isExtendedField)
    }
    
    func testVendureCustomFieldFactory() {
        let customField = CustomField.vendureCustomField(name: "priority", applicableTypes: ["Order"])
        
        XCTAssertEqual(customField.fieldName, "customFields")
        XCTAssertEqual(customField.graphQLFragment, "customFields { priority }")
        XCTAssertEqual(customField.applicableTypes, ["Order"])
        XCTAssertFalse(customField.isExtendedField)
    }
    
    func testAddCustomField() {
        let customField = CustomField.extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product"])
        
        VendureConfiguration.shared.addCustomField(customField)
        
        let configuredFields = VendureConfiguration.shared.customFields
        XCTAssertEqual(configuredFields.count, 1)
        XCTAssertEqual(configuredFields.first?.fieldName, "mainUsdzAsset")
    }
    
    func testGetCustomFieldsForType() {
        let field1 = CustomField.extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product", "ProductVariant"])
        let field2 = CustomField.vendureCustomField(name: "priority", applicableTypes: ["Order"])
        
        VendureConfiguration.shared.addCustomFields([field1, field2])
        
        let productFields = VendureConfiguration.shared.getCustomFieldsFor(type: "Product")
        XCTAssertEqual(productFields.count, 1)
        
        let orderFields = VendureConfiguration.shared.getCustomFieldsFor(type: "Order")
        XCTAssertEqual(orderFields.count, 1)
        XCTAssertEqual(orderFields.first?.fieldName, "customFields")
    }
    
    func testInjectCustomFields() {
        let field1 = CustomField.extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product"])
        let field2 = CustomField.vendureCustomField(name: "priority", applicableTypes: ["Product"])
        
        VendureConfiguration.shared.addCustomFields([field1, field2])
        
        let fragment = VendureConfiguration.shared.injectCustomFields(for: "Product")
        
        XCTAssertTrue(fragment.contains("mainUsdzAsset { id name type mimeType source preview }"))
        XCTAssertTrue(fragment.contains("customFields { priority }"))
    }
    
    func testBuildProductQueryWithCustomFields() {
        let field = CustomField.extendedAsset(name: "mainUsdzAsset", applicableTypes: ["Product"])
        VendureConfiguration.shared.addCustomField(field)
        
        let query = GraphQLQueryBuilder.buildProductQuery(includeCustomFields: true)
        
        XCTAssertTrue(query.contains("products"))
        XCTAssertTrue(query.contains("mainUsdzAsset { id name type mimeType source preview }"))
    }
}
