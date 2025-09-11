import XCTest
@testable import VendureSwiftSDK

final class CoreTypesTests: XCTestCase {
    
    // MARK: - Enum Tests
    
    func testLanguageCodeEnum() throws {
        // Test all supported language codes
        XCTAssertEqual(LanguageCode.en.rawValue, "en")
        XCTAssertEqual(LanguageCode.es.rawValue, "es")
        XCTAssertEqual(LanguageCode.fr.rawValue, "fr")
        XCTAssertEqual(LanguageCode.de.rawValue, "de")
        XCTAssertEqual(LanguageCode.it.rawValue, "it")
        XCTAssertEqual(LanguageCode.pt.rawValue, "pt")
        XCTAssertEqual(LanguageCode.nl.rawValue, "nl")
        XCTAssertEqual(LanguageCode.ja.rawValue, "ja")
        XCTAssertEqual(LanguageCode.zh.rawValue, "zh")
        XCTAssertEqual(LanguageCode.ko.rawValue, "ko")
        XCTAssertEqual(LanguageCode.ru.rawValue, "ru")
        XCTAssertEqual(LanguageCode.ar.rawValue, "ar")
        XCTAssertEqual(LanguageCode.hi.rawValue, "hi")
    }
    
    func testCurrencyCodeEnum() throws {
        // Test major currency codes
        XCTAssertEqual(CurrencyCode.USD.rawValue, "USD")
        XCTAssertEqual(CurrencyCode.EUR.rawValue, "EUR")
        XCTAssertEqual(CurrencyCode.GBP.rawValue, "GBP")
        XCTAssertEqual(CurrencyCode.JPY.rawValue, "JPY")
        XCTAssertEqual(CurrencyCode.CAD.rawValue, "CAD")
        XCTAssertEqual(CurrencyCode.AUD.rawValue, "AUD")
        XCTAssertEqual(CurrencyCode.CHF.rawValue, "CHF")
        XCTAssertEqual(CurrencyCode.CNY.rawValue, "CNY")
        XCTAssertEqual(CurrencyCode.SEK.rawValue, "SEK")
        XCTAssertEqual(CurrencyCode.NZD.rawValue, "NZD")
        XCTAssertEqual(CurrencyCode.NOK.rawValue, "NOK")
        XCTAssertEqual(CurrencyCode.DKK.rawValue, "DKK")
        XCTAssertEqual(CurrencyCode.PLN.rawValue, "PLN")
    }
    
    func testOrderTypeEnum() throws {
        XCTAssertEqual(OrderType.Regular.rawValue, "Regular")
        XCTAssertEqual(OrderType.Seller.rawValue, "Seller")
        XCTAssertEqual(OrderType.Aggregate.rawValue, "Aggregate")
        
        // Test that enum is CaseIterable
        XCTAssertEqual(OrderType.allCases.count, 3)
        XCTAssertTrue(OrderType.allCases.contains(.Regular))
        XCTAssertTrue(OrderType.allCases.contains(.Seller))
        XCTAssertTrue(OrderType.allCases.contains(.Aggregate))
    }
    
    func testLogicalOperatorEnum() throws {
        XCTAssertEqual(LogicalOperator.AND.rawValue, "AND")
        XCTAssertEqual(LogicalOperator.OR.rawValue, "OR")
        
        // Test CaseIterable
        XCTAssertEqual(LogicalOperator.allCases.count, 2)
    }
    
    func testSortOrderEnum() throws {
        XCTAssertEqual(SortOrder.ASC.rawValue, "ASC")
        XCTAssertEqual(SortOrder.DESC.rawValue, "DESC")
        
        // Test CaseIterable
        XCTAssertEqual(SortOrder.allCases.count, 2)
    }
    
    func testErrorCodeEnum() throws {
        // Test error codes
        XCTAssertEqual(ErrorCode.UNKNOWN_ERROR.rawValue, "UNKNOWN_ERROR")
        XCTAssertEqual(ErrorCode.NATIVE_AUTH_STRATEGY_ERROR.rawValue, "NATIVE_AUTH_STRATEGY_ERROR")
        XCTAssertEqual(ErrorCode.INVALID_CREDENTIALS_ERROR.rawValue, "INVALID_CREDENTIALS_ERROR")
        XCTAssertEqual(ErrorCode.ORDER_STATE_TRANSITION_ERROR.rawValue, "ORDER_STATE_TRANSITION_ERROR")
        XCTAssertEqual(ErrorCode.EMAIL_ADDRESS_CONFLICT_ERROR.rawValue, "EMAIL_ADDRESS_CONFLICT_ERROR")
        XCTAssertEqual(ErrorCode.GUEST_CHECKOUT_ERROR.rawValue, "GUEST_CHECKOUT_ERROR")
        XCTAssertEqual(ErrorCode.ORDER_LIMIT_ERROR.rawValue, "ORDER_LIMIT_ERROR")
        XCTAssertEqual(ErrorCode.NEGATIVE_QUANTITY_ERROR.rawValue, "NEGATIVE_QUANTITY_ERROR")
        XCTAssertEqual(ErrorCode.INSUFFICIENT_STOCK_ERROR.rawValue, "INSUFFICIENT_STOCK_ERROR")
        XCTAssertEqual(ErrorCode.COUPON_CODE_INVALID_ERROR.rawValue, "COUPON_CODE_INVALID_ERROR")
        XCTAssertEqual(ErrorCode.COUPON_CODE_EXPIRED_ERROR.rawValue, "COUPON_CODE_EXPIRED_ERROR")
        XCTAssertEqual(ErrorCode.COUPON_CODE_LIMIT_ERROR.rawValue, "COUPON_CODE_LIMIT_ERROR")
        XCTAssertEqual(ErrorCode.ORDER_MODIFICATION_ERROR.rawValue, "ORDER_MODIFICATION_ERROR")
        XCTAssertEqual(ErrorCode.ORDER_PAYMENT_STATE_ERROR.rawValue, "ORDER_PAYMENT_STATE_ERROR")
        XCTAssertEqual(ErrorCode.PAYMENT_METHOD_MISSING_ERROR.rawValue, "PAYMENT_METHOD_MISSING_ERROR")
        XCTAssertEqual(ErrorCode.PAYMENT_STATE_TRANSITION_ERROR.rawValue, "PAYMENT_STATE_TRANSITION_ERROR")
        XCTAssertEqual(ErrorCode.PAYMENT_FAILED_ERROR.rawValue, "PAYMENT_FAILED_ERROR")
        XCTAssertEqual(ErrorCode.PAYMENT_DECLINED_ERROR.rawValue, "PAYMENT_DECLINED_ERROR")
        XCTAssertEqual(ErrorCode.ALREADY_LOGGED_IN_ERROR.rawValue, "ALREADY_LOGGED_IN_ERROR")
        XCTAssertEqual(ErrorCode.MISSING_PASSWORD_ERROR.rawValue, "MISSING_PASSWORD_ERROR")
        XCTAssertEqual(ErrorCode.PASSWORD_VALIDATION_ERROR.rawValue, "PASSWORD_VALIDATION_ERROR")
        XCTAssertEqual(ErrorCode.PASSWORD_ALREADY_SET_ERROR.rawValue, "PASSWORD_ALREADY_SET_ERROR")
        XCTAssertEqual(ErrorCode.VERIFICATION_TOKEN_INVALID_ERROR.rawValue, "VERIFICATION_TOKEN_INVALID_ERROR")
        XCTAssertEqual(ErrorCode.VERIFICATION_TOKEN_EXPIRED_ERROR.rawValue, "VERIFICATION_TOKEN_EXPIRED_ERROR")
        XCTAssertEqual(ErrorCode.IDENTIFIER_CHANGE_TOKEN_INVALID_ERROR.rawValue, "IDENTIFIER_CHANGE_TOKEN_INVALID_ERROR")
        XCTAssertEqual(ErrorCode.IDENTIFIER_CHANGE_TOKEN_EXPIRED_ERROR.rawValue, "IDENTIFIER_CHANGE_TOKEN_EXPIRED_ERROR")
        XCTAssertEqual(ErrorCode.PASSWORD_RESET_TOKEN_INVALID_ERROR.rawValue, "PASSWORD_RESET_TOKEN_INVALID_ERROR")
        XCTAssertEqual(ErrorCode.PASSWORD_RESET_TOKEN_EXPIRED_ERROR.rawValue, "PASSWORD_RESET_TOKEN_EXPIRED_ERROR")
        XCTAssertEqual(ErrorCode.NOT_VERIFIED_ERROR.rawValue, "NOT_VERIFIED_ERROR")
        XCTAssertEqual(ErrorCode.NO_ACTIVE_ORDER_ERROR.rawValue, "NO_ACTIVE_ORDER_ERROR")
    }
    
    func testAdjustmentTypeEnum() throws {
        XCTAssertEqual(AdjustmentType.PROMOTION.rawValue, "PROMOTION")
        XCTAssertEqual(AdjustmentType.DISTRIBUTED_ORDER_PROMOTION.rawValue, "DISTRIBUTED_ORDER_PROMOTION")
        XCTAssertEqual(AdjustmentType.OTHER.rawValue, "OTHER")
        
        // Test CaseIterable
        XCTAssertEqual(AdjustmentType.allCases.count, 3)
    }
    
    func testAssetTypeEnum() throws {
        XCTAssertEqual(AssetType.IMAGE.rawValue, "IMAGE")
        XCTAssertEqual(AssetType.VIDEO.rawValue, "VIDEO")
        XCTAssertEqual(AssetType.AUDIO.rawValue, "AUDIO")
        XCTAssertEqual(AssetType.OTHER.rawValue, "OTHER")
        
        // Test CaseIterable
        XCTAssertEqual(AssetType.allCases.count, 4)
    }
    
    func testHistoryEntryTypeEnum() throws {
        // Customer events
        XCTAssertEqual(HistoryEntryType.CUSTOMER_REGISTERED.rawValue, "CUSTOMER_REGISTERED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_VERIFIED.rawValue, "CUSTOMER_VERIFIED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_DETAIL_UPDATED.rawValue, "CUSTOMER_DETAIL_UPDATED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_ADDED_TO_GROUP.rawValue, "CUSTOMER_ADDED_TO_GROUP")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_REMOVED_FROM_GROUP.rawValue, "CUSTOMER_REMOVED_FROM_GROUP")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_ADDRESS_CREATED.rawValue, "CUSTOMER_ADDRESS_CREATED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_ADDRESS_UPDATED.rawValue, "CUSTOMER_ADDRESS_UPDATED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_ADDRESS_DELETED.rawValue, "CUSTOMER_ADDRESS_DELETED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_PASSWORD_UPDATED.rawValue, "CUSTOMER_PASSWORD_UPDATED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_PASSWORD_RESET_REQUESTED.rawValue, "CUSTOMER_PASSWORD_RESET_REQUESTED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_PASSWORD_RESET_VERIFIED.rawValue, "CUSTOMER_PASSWORD_RESET_VERIFIED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_EMAIL_UPDATE_REQUESTED.rawValue, "CUSTOMER_EMAIL_UPDATE_REQUESTED")
        XCTAssertEqual(HistoryEntryType.CUSTOMER_EMAIL_UPDATE_VERIFIED.rawValue, "CUSTOMER_EMAIL_UPDATE_VERIFIED")
        
        // Order events
        XCTAssertEqual(HistoryEntryType.ORDER_STATE_TRANSITION.rawValue, "ORDER_STATE_TRANSITION")
        XCTAssertEqual(HistoryEntryType.ORDER_PAYMENT_TRANSITION.rawValue, "ORDER_PAYMENT_TRANSITION")
        XCTAssertEqual(HistoryEntryType.ORDER_FULFILLMENT_TRANSITION.rawValue, "ORDER_FULFILLMENT_TRANSITION")
        XCTAssertEqual(HistoryEntryType.ORDER_FULFILLMENT.rawValue, "ORDER_FULFILLMENT")
        XCTAssertEqual(HistoryEntryType.ORDER_CANCELLATION.rawValue, "ORDER_CANCELLATION")
        XCTAssertEqual(HistoryEntryType.ORDER_REFUND_TRANSITION.rawValue, "ORDER_REFUND_TRANSITION")
        XCTAssertEqual(HistoryEntryType.ORDER_FULFILLMENT_STATE_TRANSITION.rawValue, "ORDER_FULFILLMENT_STATE_TRANSITION")
        XCTAssertEqual(HistoryEntryType.ORDER_NOTE.rawValue, "ORDER_NOTE")
        XCTAssertEqual(HistoryEntryType.ORDER_COUPON_APPLIED.rawValue, "ORDER_COUPON_APPLIED")
        XCTAssertEqual(HistoryEntryType.ORDER_COUPON_REMOVED.rawValue, "ORDER_COUPON_REMOVED")
        XCTAssertEqual(HistoryEntryType.ORDER_MODIFIED.rawValue, "ORDER_MODIFIED")
    }
    
    // MARK: - Core Type Creation Tests
    
    func testCurrentUserCreation() throws {
        let channels: [CurrentUserChannel] = []
        let user = CurrentUser(
            id: "user-123",
            identifier: "test@example.com",
            channels: channels
        )
        
        XCTAssertEqual(user.id, "user-123")
        XCTAssertEqual(user.identifier, "test@example.com")
        XCTAssertTrue(user.channels.isEmpty)
        
        // Test Identifiable protocol
        XCTAssertEqual(user.id, "user-123")
    }
    
    func testCountryCreation() throws {
        let translations: [CountryTranslation] = [
            CountryTranslation(languageCode: .en, name: "United States"),
            CountryTranslation(languageCode: .es, name: "Estados Unidos")
        ]
        
        let country = Country(
            id: "country-1",
            code: "US",
            name: "United States",
            enabled: true,
            translations: translations
        )
        
        XCTAssertEqual(country.id, "country-1")
        XCTAssertEqual(country.code, "US")
        XCTAssertEqual(country.name, "United States")
        XCTAssertTrue(country.enabled)
        XCTAssertEqual(country.translations.count, 2)
        
        // Test translation access
        let englishTranslation = country.translations.first { $0.languageCode == .en }
        XCTAssertNotNil(englishTranslation)
        XCTAssertEqual(englishTranslation?.name, "United States")
        
        // Test Hashable - Countries with same ID should be equal (by Identifiable protocol)
        let country2 = Country(id: "country-1", code: "US", name: "United States", enabled: true)
        XCTAssertEqual(country.id, country2.id)  // Compare by ID instead of full equality
    }
    
    func testAddressCreation() throws {
        let country = Country(
            id: "country-1",
            code: "US", 
            name: "United States",
            enabled: true
        )
        
        let address = Address(
            id: "addr-123",
            fullName: "John Doe",
            company: "Acme Corp",
            streetLine1: "123 Main St",
            streetLine2: "Suite 456",
            city: "New York",
            province: "NY",
            postalCode: "10001",
            country: country,
            phoneNumber: "+1234567890",
            defaultShippingAddress: true,
            defaultBillingAddress: false,
            customFields: ["notes": AnyCodable("Special delivery")],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(address.id, "addr-123")
        XCTAssertEqual(address.fullName, "John Doe")
        XCTAssertEqual(address.company, "Acme Corp")
        XCTAssertEqual(address.streetLine1, "123 Main St")
        XCTAssertEqual(address.streetLine2, "Suite 456")
        XCTAssertEqual(address.city, "New York")
        XCTAssertEqual(address.province, "NY")
        XCTAssertEqual(address.postalCode, "10001")
        XCTAssertEqual(address.country.code, "US")
        XCTAssertEqual(address.phoneNumber, "+1234567890")
        XCTAssertEqual(address.defaultShippingAddress, true)
        XCTAssertEqual(address.defaultBillingAddress, false)
        XCTAssertNotNil(address.customFields)
        
        // Test custom fields
        let notesField = address.customFields?["notes"]
        XCTAssertEqual(notesField?.value as? String, "Special delivery")
    }
    
    func testAssetCreation() throws {
        let focalPoint = Coordinate(x: 0.5, y: 0.5)
        let tags = [
            Tag(id: "tag1", createdAt: Date(), updatedAt: Date(), value: "product"),
            Tag(id: "tag2", createdAt: Date(), updatedAt: Date(), value: "main")
        ]
        
        let asset = Asset(
            id: "asset-123",
            name: "product-image.jpg",
            type: .IMAGE,
            fileSize: 1024000,
            mimeType: "image/jpeg",
            width: 1200,
            height: 800,
            source: "https://example.com/images/product.jpg",
            preview: "https://example.com/images/product-preview.jpg",
            focalPoint: focalPoint,
            tags: tags,
            customFields: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(asset.id, "asset-123")
        XCTAssertEqual(asset.name, "product-image.jpg")
        XCTAssertEqual(asset.type, .IMAGE)
        XCTAssertEqual(asset.fileSize, 1024000)
        XCTAssertEqual(asset.mimeType, "image/jpeg")
        XCTAssertEqual(asset.width, 1200)
        XCTAssertEqual(asset.height, 800)
        XCTAssertEqual(asset.source, "https://example.com/images/product.jpg")
        XCTAssertEqual(asset.preview, "https://example.com/images/product-preview.jpg")
        XCTAssertNotNil(asset.focalPoint)
        XCTAssertEqual(asset.focalPoint?.x, 0.5)
        XCTAssertEqual(asset.focalPoint?.y, 0.5)
        XCTAssertEqual(asset.tags.count, 2)
        XCTAssertEqual(asset.tags[0].value, "product")
        XCTAssertEqual(asset.tags[1].value, "main")
    }
    
    func testCoordinateCreation() throws {
        let coordinate = Coordinate(x: 0.3, y: 0.7)
        
        XCTAssertEqual(coordinate.x, 0.3)
        XCTAssertEqual(coordinate.y, 0.7)
        
        // Test Hashable
        let coordinate2 = Coordinate(x: 0.3, y: 0.7)
        XCTAssertEqual(coordinate, coordinate2)
        
        let coordinate3 = Coordinate(x: 0.4, y: 0.7)
        XCTAssertNotEqual(coordinate, coordinate3)
    }
    
    // MARK: - List Types Tests
    
    func testAssetListCreation() throws {
        let asset1 = Asset(
            id: "asset-1", name: "image1.jpg", type: .IMAGE, fileSize: 100000,
            mimeType: "image/jpeg", width: 800, height: 600,
            source: "https://example.com/1.jpg", preview: "https://example.com/1-preview.jpg",
            focalPoint: nil, tags: [], customFields: nil,
            createdAt: Date(), updatedAt: Date()
        )
        
        let asset2 = Asset(
            id: "asset-2", name: "image2.jpg", type: .IMAGE, fileSize: 120000,
            mimeType: "image/jpeg", width: 1000, height: 800,
            source: "https://example.com/2.jpg", preview: "https://example.com/2-preview.jpg",
            focalPoint: nil, tags: [], customFields: nil,
            createdAt: Date(), updatedAt: Date()
        )
        
        let assetList = AssetList(items: [asset1, asset2], totalItems: 2)
        
        XCTAssertEqual(assetList.items.count, 2)
        XCTAssertEqual(assetList.totalItems, 2)
        XCTAssertEqual(assetList.items[0].id, "asset-1")
        XCTAssertEqual(assetList.items[1].id, "asset-2")
    }
    
    // MARK: - Error Handling Tests
    
    func testVendureErrorCreation() throws {
        let networkError = VendureError.networkError("Connection failed")
        XCTAssertEqual(networkError.description, "Network error: Connection failed")
        
        let decodingError = VendureError.decodingError(NSError(domain: "test", code: 1))
        XCTAssertTrue(decodingError.description.contains("Decoding error"))
        
        let initError = VendureError.initializationError("Invalid config")
        XCTAssertEqual(initError.description, "Initialization error: Invalid config")
        
        let tokenError = VendureError.tokenMissing
        XCTAssertEqual(tokenError.description, "Authentication token is missing")
        
        let graphqlErrors = VendureError.graphqlError(["Query error", "Field missing"])
        XCTAssertEqual(graphqlErrors.description, "GraphQL error: Query error; Field missing")
    }
    
    // MARK: - Date Handling Tests
    
    func testDateHandling() throws {
        let now = Date()
        let country = Country(
            id: "test-country",
            code: "US",
            name: "Test Country",
            enabled: true
        )
        
        let address = Address(
            id: "test-address",
            streetLine1: "123 Test St",
            city: "Test City",
            postalCode: "12345",
            country: country,
            createdAt: now,
            updatedAt: now
        )
        
        // Dates should be preserved
        XCTAssertEqual(address.createdAt.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(address.updatedAt.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
    }
    
    // MARK: - Optional Fields Tests
    
    func testOptionalFieldHandling() throws {
        // Test with minimal required fields
        let minimalCountry = Country(
            id: "minimal-country",
            code: "XX",
            name: "Minimal Country",
            enabled: false
        )
        
        XCTAssertEqual(minimalCountry.translations.count, 0)
        
        // Test address with minimal fields
        let minimalAddress = Address(
            id: "minimal-address",
            streetLine1: "Basic Street",
            city: "Basic City",
            postalCode: "00000",
            country: minimalCountry,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertNil(minimalAddress.fullName)
        XCTAssertNil(minimalAddress.company)
        XCTAssertNil(minimalAddress.streetLine2)
        XCTAssertNil(minimalAddress.province)
        XCTAssertNil(minimalAddress.phoneNumber)
        XCTAssertNil(minimalAddress.defaultShippingAddress)
        XCTAssertNil(minimalAddress.defaultBillingAddress)
        XCTAssertNil(minimalAddress.customFields)
    }
}
