import XCTest
@testable import VendureSwiftSDK

final class InputTypesTests: XCTestCase {
    
    // MARK: - Address Input Tests
    
    func testCreateAddressInput() throws {
        let input = CreateAddressInput(
            fullName: "John Smith",
            company: "Acme Corp",
            streetLine1: "123 Main Street",
            streetLine2: "Suite 456",
            city: "New York",
            province: "NY",
            postalCode: "10001",
            countryCode: "US",
            phoneNumber: "+1-555-0123",
            defaultShippingAddress: true,
            defaultBillingAddress: false
        )
        
        XCTAssertEqual(input.fullName, "John Smith")
        XCTAssertEqual(input.company, "Acme Corp")
        XCTAssertEqual(input.streetLine1, "123 Main Street")
        XCTAssertEqual(input.streetLine2, "Suite 456")
        XCTAssertEqual(input.city, "New York")
        XCTAssertEqual(input.province, "NY")
        XCTAssertEqual(input.postalCode, "10001")
        XCTAssertEqual(input.countryCode, "US")
        XCTAssertEqual(input.phoneNumber, "+1-555-0123")
        XCTAssertEqual(input.defaultShippingAddress, true)
        XCTAssertEqual(input.defaultBillingAddress, false)
    }
    
    func testCreateAddressInputMinimal() throws {
        let input = CreateAddressInput(
            streetLine1: "456 Oak Avenue",
            city: "San Francisco",
            postalCode: "94105",
            countryCode: "US"
        )
        
        XCTAssertEqual(input.streetLine1, "456 Oak Avenue")
        XCTAssertEqual(input.city, "San Francisco")
        XCTAssertEqual(input.postalCode, "94105")
        XCTAssertEqual(input.countryCode, "US")
        
        // Optional fields should be nil
        XCTAssertNil(input.fullName)
        XCTAssertNil(input.company)
        XCTAssertNil(input.streetLine2)
        XCTAssertNil(input.province)
        XCTAssertNil(input.phoneNumber)
        XCTAssertNil(input.defaultShippingAddress)
        XCTAssertNil(input.defaultBillingAddress)
    }
    
    func testUpdateAddressInput() throws {
        let input = UpdateAddressInput(
            id: "address-123",
            fullName: "Jane Doe Updated",
            streetLine1: "789 Pine Street",
            city: "Los Angeles",
            postalCode: "90210"
        )
        
        XCTAssertEqual(input.id, "address-123")
        XCTAssertEqual(input.fullName, "Jane Doe Updated")
        XCTAssertEqual(input.streetLine1, "789 Pine Street")
        XCTAssertEqual(input.city, "Los Angeles")
        XCTAssertEqual(input.postalCode, "90210")
    }
    
    func testUpdateAddressInputMinimal() throws {
        let input = UpdateAddressInput(
            id: "address-456",
            streetLine1: "Updated Street"
        )
        
        XCTAssertEqual(input.id, "address-456")
        XCTAssertEqual(input.streetLine1, "Updated Street")
        
        // Other fields should be nil
        XCTAssertNil(input.fullName)
        XCTAssertNil(input.company)
        XCTAssertNil(input.streetLine2)
        XCTAssertNil(input.city)
        XCTAssertNil(input.province)
        XCTAssertNil(input.postalCode)
        XCTAssertNil(input.countryCode)
        XCTAssertNil(input.phoneNumber)
        XCTAssertNil(input.defaultShippingAddress)
        XCTAssertNil(input.defaultBillingAddress)
    }
    
    // MARK: - Customer Input Tests
    
    func testRegisterCustomerInput() throws {
        let input = RegisterCustomerInput(
            emailAddress: "alice@example.com",
            title: "Ms.",
            firstName: "Alice",
            lastName: "Johnson",
            password: "securePassword123"
        )
        
        XCTAssertEqual(input.firstName, "Alice")
        XCTAssertEqual(input.lastName, "Johnson")
        XCTAssertEqual(input.emailAddress, "alice@example.com")
        XCTAssertEqual(input.password, "securePassword123")
        XCTAssertEqual(input.title, "Ms.")
    }
    
    func testRegisterCustomerInputMinimal() throws {
        let input = RegisterCustomerInput(
            emailAddress: "bob@example.com",
            firstName: "Bob",
            lastName: "Smith",
            password: "password456"
        )
        
        XCTAssertEqual(input.firstName, "Bob")
        XCTAssertEqual(input.lastName, "Smith")
        XCTAssertEqual(input.emailAddress, "bob@example.com")
        XCTAssertEqual(input.password, "password456")
        XCTAssertNil(input.title)
    }
    
    func testCreateCustomerInput() throws {
        let input = CreateCustomerInput(
            title: "Dr.",
            firstName: "Sarah",
            lastName: "Wilson",
            phoneNumber: "+1-555-9876",
            emailAddress: "sarah@example.com",
            customFields: ["department": AnyCodable("Research")]
        )
        
        XCTAssertEqual(input.title, "Dr.")
        XCTAssertEqual(input.firstName, "Sarah")
        XCTAssertEqual(input.lastName, "Wilson")
        XCTAssertEqual(input.phoneNumber, "+1-555-9876")
        XCTAssertEqual(input.emailAddress, "sarah@example.com")
        XCTAssertNotNil(input.customFields)
        XCTAssertEqual(input.customFields?["department"]?.value as? String, "Research")
    }
    
    func testUpdateCustomerInput() throws {
        let input = UpdateCustomerInput(
            title: "Mr.",
            firstName: "Michael",
            lastName: "Brown",
            phoneNumber: "+1-555-5432"
        )
        
        XCTAssertEqual(input.title, "Mr.")
        XCTAssertEqual(input.firstName, "Michael")
        XCTAssertEqual(input.lastName, "Brown")
        XCTAssertEqual(input.phoneNumber, "+1-555-5432")
    }
    
    // MARK: - Order Input Tests

    func testUpdateOrderInput() throws {
        let input = UpdateOrderInput(
            customFields: ["gift_message": AnyCodable("Happy Birthday!")]
        )
        
        XCTAssertNotNil(input.customFields)
        XCTAssertEqual(input.customFields?["gift_message"]?.value as? String, "Happy Birthday!")
    }
    
    func testUpdateOrderInputMinimal() throws {
        let input = UpdateOrderInput()
        XCTAssertNil(input.customFields)
    }
    
    // MARK: - Payment Input Tests
    
    func testPaymentInput() throws {
        let metadata: [String: AnyCodable] = [
            "stripe_payment_intent": AnyCodable("pi_123456789"),
            "customer_id": AnyCodable("cus_ABC123"),
            "amount": AnyCodable(2599)
        ]
        
        let input = PaymentInput(
            method: "stripe",
            metadata: metadata
        )
        
        XCTAssertEqual(input.method, "stripe")
        XCTAssertNotNil(input.metadata)
        XCTAssertEqual(input.metadata?["stripe_payment_intent"]?.value as? String, "pi_123456789")
        XCTAssertEqual(input.metadata?["customer_id"]?.value as? String, "cus_ABC123")
        XCTAssertEqual(input.metadata?["amount"]?.value as? Int, 2599)
    }
    
    func testPaymentInputMinimal() throws {
        let input = PaymentInput(
            method: "cash"
        )
        
        XCTAssertEqual(input.method, "cash")
        XCTAssertNil(input.metadata)
    }
    
    // MARK: - Authentication Input Tests
    // MARK: - Search Input Tests
    
    func testSearchInput() throws {
        let input = SearchInput(
            term: "electronics",
            facetValueFilters: [
                FacetValueFilterInput(and: "brand-apple"),
                FacetValueFilterInput(or: ["category-phones"])
            ],
            facetValueIds: ["facet-1", "facet-2"],
            facetValueOperator: LogicalOperator.AND,
            collectionId: "collection-123",
            collectionSlug: "electronics",
            groupByProduct: true,
            skip: 0,
            take: 20,
            sort: SearchResultSortParameter(
                name: .ASC,
                price: .DESC
            )
        )
        
        XCTAssertEqual(input.term, "electronics")
        XCTAssertEqual(input.facetValueFilters?.count, 2)
        XCTAssertEqual(input.facetValueIds, ["facet-1", "facet-2"])
        XCTAssertEqual(input.facetValueOperator, LogicalOperator.AND)
        XCTAssertEqual(input.collectionId, "collection-123")
        XCTAssertEqual(input.collectionSlug, "electronics")
        XCTAssertEqual(input.groupByProduct, true)
        XCTAssertEqual(input.skip, 0)
        XCTAssertEqual(input.take, 20)
        XCTAssertNotNil(input.sort)
        XCTAssertEqual(input.sort?.name, .ASC)
        XCTAssertEqual(input.sort?.price, .DESC)
    }
    
    func testSearchInputMinimal() throws {
        let input = SearchInput(
            term: "books"
        )
        
        XCTAssertEqual(input.term, "books")
        XCTAssertNil(input.facetValueFilters)
        XCTAssertNil(input.facetValueIds)
        XCTAssertNil(input.facetValueOperator)
        XCTAssertNil(input.collectionId)
        XCTAssertNil(input.collectionSlug)
        XCTAssertNil(input.groupByProduct)
        XCTAssertNil(input.skip)
        XCTAssertNil(input.take)
        XCTAssertNil(input.sort)
    }
    
    func testFacetValueFilterInput() throws {
        let andFilter = FacetValueFilterInput(and: "brand-nike")
        XCTAssertEqual(andFilter.and, "brand-nike")
        XCTAssertNil(andFilter.or)
        
        let orFilter = FacetValueFilterInput(or: ["color-red"])
        XCTAssertEqual(orFilter.or, ["color-red"])
        XCTAssertNil(orFilter.and)
    }
    
    // MARK: - List Options Tests
    
    func testProductListOptions() throws {
        let options = ProductListOptions(
            skip: 20,
            take: 10,
            sort: ProductSortParameter(
                name: .ASC,
                slug: .DESC
            ),
            filter: ProductFilterParameter(
                name: StringOperators(contains: "laptop")
            ),
            filterOperator: LogicalOperator.OR
        )
        
        XCTAssertEqual(options.skip, 20)
        XCTAssertEqual(options.take, 10)
        XCTAssertNotNil(options.sort)
        XCTAssertEqual(options.sort?.name, .ASC)
        XCTAssertEqual(options.sort?.slug, .DESC)
        XCTAssertNotNil(options.filter)
        XCTAssertEqual(options.filterOperator, LogicalOperator.OR)
    }
    
    func testCollectionListOptions() throws {
        let options = CollectionListOptions(
            skip: 5,
            take: 25,
            sort: CollectionSortParameter(
                name: .DESC
            ),
            filter: CollectionFilterParameter(
                name: StringOperators(eq: "Featured")
            ),
            filterOperator: LogicalOperator.AND,
            topLevelOnly: true
        )
        
        XCTAssertEqual(options.skip, 5)
        XCTAssertEqual(options.take, 25)
        XCTAssertNotNil(options.sort)
        XCTAssertEqual(options.sort?.name, .DESC)
        XCTAssertNotNil(options.filter)
        XCTAssertEqual(options.filterOperator, LogicalOperator.AND)
        XCTAssertEqual(options.topLevelOnly, true)
    }
    
    // MARK: - Custom Fields Tests
    
    func testAnyCodableInInputs() throws {
        // Test various AnyCodable types in custom fields
        let customFields: [String: AnyCodable] = [
            "string_field": AnyCodable("hello"),
            "int_field": AnyCodable(42),
            "double_field": AnyCodable(3.14),
            "bool_field": AnyCodable(true),
            "array_field": AnyCodable([1, 2, 3]),
            "dict_field": AnyCodable(["nested": "value"])
        ]
        
        let input = CreateCustomerInput(
            title: "Test",
            firstName: "Test",
            lastName: "User", 
            phoneNumber: "123",
            emailAddress: "test@example.com",
            customFields: customFields
        )
        
        XCTAssertNotNil(input.customFields)
        XCTAssertEqual(input.customFields?["string_field"]?.value as? String, "hello")
        XCTAssertEqual(input.customFields?["int_field"]?.value as? Int, 42)
        XCTAssertEqual(input.customFields?["double_field"]?.value as? Double, 3.14)
        XCTAssertEqual(input.customFields?["bool_field"]?.value as? Bool, true)
        
        let arrayField = input.customFields?["array_field"]?.value as? [Int]
        XCTAssertEqual(arrayField, [1, 2, 3])
        
        let dictField = input.customFields?["dict_field"]?.value as? [String: String]
        XCTAssertEqual(dictField?["nested"], "value")
    }
    
    // MARK: - Validation Tests
    
    func testInputValidation() throws {
        // Test that inputs with required fields work correctly
        
        // Address requires at least streetLine1, city, postalCode, countryCode
        let validAddress = CreateAddressInput(
            streetLine1: "Required Street",
            city: "Required City", 
            postalCode: "12345",
            countryCode: "US"
        )
        XCTAssertEqual(validAddress.streetLine1, "Required Street")
        
        // Customer registration requires firstName, lastName, emailAddress, password
        let validRegistration = RegisterCustomerInput(
            emailAddress: "john@example.com", 
            firstName: "John",
            lastName: "Doe",
            password: "password123"
        )
        XCTAssertEqual(validRegistration.firstName, "John")
        
        // Update order only requires customFields
        let validOrderInput = UpdateOrderInput(
            customFields: ["note": AnyCodable("Test order note")]
        )
        XCTAssertNotNil(validOrderInput.customFields)
        XCTAssertEqual(validOrderInput.customFields?["note"]?.value as? String, "Test order note")
    }
    
    // MARK: - Codable Tests
    
    func testInputTypesCodable() throws {
        // Test that input types can be encoded and decoded
        let originalAddress = CreateAddressInput(
            fullName: "Test User",
            streetLine1: "123 Test St",
            city: "Test City",
            postalCode: "12345",
            countryCode: "US"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalAddress)
        
        let decoder = JSONDecoder()
        let decodedAddress = try decoder.decode(CreateAddressInput.self, from: data)
        
        XCTAssertEqual(decodedAddress.fullName, originalAddress.fullName)
        XCTAssertEqual(decodedAddress.streetLine1, originalAddress.streetLine1)
        XCTAssertEqual(decodedAddress.city, originalAddress.city)
        XCTAssertEqual(decodedAddress.postalCode, originalAddress.postalCode)
        XCTAssertEqual(decodedAddress.countryCode, originalAddress.countryCode)
    }
    
    func testSearchInputCodable() throws {
        let originalSearch = SearchInput(
            term: "test product",
            facetValueIds: ["facet-1"],
            collectionId: "collection-1",
            skip: 0,
            take: 10
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSearch)
        
        let decoder = JSONDecoder()
        let decodedSearch = try decoder.decode(SearchInput.self, from: data)
        
        XCTAssertEqual(decodedSearch.term, originalSearch.term)
        XCTAssertEqual(decodedSearch.facetValueIds, originalSearch.facetValueIds)
        XCTAssertEqual(decodedSearch.collectionId, originalSearch.collectionId)
        XCTAssertEqual(decodedSearch.skip, originalSearch.skip)
        XCTAssertEqual(decodedSearch.take, originalSearch.take)
    }
}
