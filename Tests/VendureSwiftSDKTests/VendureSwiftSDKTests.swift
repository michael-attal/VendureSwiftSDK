import XCTest
@testable import VendureSwiftSDK

final class VendureSwiftSDKTests: XCTestCase {
    
    func testSDKVersion() throws {
        XCTAssertEqual(VendureSwiftSDK.version, "1.0.0")
    }
    
    func testVendureError() throws {
        let error = VendureError.networkError("Test error")
        XCTAssertEqual(error.description, "Network error: Test error")
    }
    
    func testTokenManager() async throws {
        let tokenFetcher: TokenFetcher = { _ in
            return "test-token"
        }
        
        let tokenManager = TokenManager(
            fetcher: tokenFetcher,
            parameters: ["key": "value"]
        )
        
        let token = try await tokenManager.getValidToken()
        XCTAssertEqual(token, "test-token")
    }
    
    func testGraphQLRequest() throws {
        let request = GraphQLRequest(
            query: "query { test }",
            variables: ["var": "value"]
        )
        
        XCTAssertEqual(request.query, "query { test }")
        XCTAssertNotNil(request.variables)
    }
    
    func testAnyCodable() throws {
        let stringValue = AnyCodable("test")
        let intValue = AnyCodable(123)
        let boolValue = AnyCodable(true)
        
        XCTAssertTrue(stringValue.value is String)
        XCTAssertTrue(intValue.value is Int)
        XCTAssertTrue(boolValue.value is Bool)
    }
    
    func testInputTypes() throws {
        let addressInput = CreateAddressInput(
            streetLine1: "456 Oak Ave",
            city: "New City",
            postalCode: "12345",
            countryCode: "US"
        )
        
        XCTAssertEqual(addressInput.streetLine1, "456 Oak Ave")
        XCTAssertEqual(addressInput.countryCode, "US")
    }
    
    func testPackageLoads() throws {
        // Simple compile-time test
        XCTAssertTrue(true)
    }
}

