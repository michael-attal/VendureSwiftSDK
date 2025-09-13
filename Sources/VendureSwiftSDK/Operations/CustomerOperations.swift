import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public actor CustomerOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Get active customer
    public func getActiveCustomer(includeCustomFields: Bool? = nil) async throws -> Customer? {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildActiveCustomerQuery(includeCustomFields: shouldIncludeCustomFields)
        
        return try await vendure.custom.query(query, expectedDataType: "activeCustomer", responseType: Customer?.self)
    }
    
    /// Get current user
    public func getCurrentUser() async throws -> CurrentUser? {
        let query = """
        query me {
          me {
            id
            identifier
            channels {
              id
              code
              token
            }
          }
        }
        """
        
        return try await vendure.custom.query(query, expectedDataType: "me", responseType: CurrentUser?.self)
    }
    
    /// Get active channel
    public func getActiveChannel() async throws -> Channel {
        let query = """
        query activeChannel {
          activeChannel {
            id
            code
            token
            currencyCode
            defaultLanguageCode
            availableLanguageCodes
            pricesIncludeTax
          }
        }
        """
        
        return try await vendure.custom.query(query, expectedDataType: "activeChannel", responseType: Channel.self)
    }
    
    /// Update customer
    public func updateCustomer(input: UpdateCustomerInput, includeCustomFields: Bool? = nil) async throws -> Customer {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildUpdateCustomerMutation(includeCustomFields: shouldIncludeCustomFields)
        
        let variables = ["input": input]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Customer.self, expectedDataType: "updateCustomer")
    }
    
    /// Create customer address
    public func createCustomerAddress(input: CreateAddressInput) async throws -> Address {
        let query = """
        mutation createCustomerAddress($input: CreateAddressInput!) {
          createCustomerAddress(input: $input) {
            id
            fullName
            company
            streetLine1
            streetLine2
            city
            province
            postalCode
            country
            phoneNumber
            defaultShippingAddress
            defaultBillingAddress
          }
        }
        """
        
        let variables = ["input": input]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Address.self, expectedDataType: "createCustomerAddress")
    }
    
    /// Update customer address
    public func updateCustomerAddress(input: UpdateAddressInput) async throws -> Address {
        let query = """
        mutation updateCustomerAddress($input: UpdateAddressInput!) {
          updateCustomerAddress(input: $input) {
            id
            fullName
            company
            streetLine1
            streetLine2
            city
            province
            postalCode
            country
            phoneNumber
            defaultShippingAddress
            defaultBillingAddress
          }
        }
        """
        
        let variables = ["input": input]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Address.self, expectedDataType: "updateCustomerAddress")
    }
    
    /// Delete customer address
    public func deleteCustomerAddress(id: String) async throws -> Success {
        let query = """
        mutation deleteCustomerAddress($id: ID!) {
          deleteCustomerAddress(id: $id) {
            success
          }
        }
        """
        
        let variables = ["id": id]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Success.self, expectedDataType: "deleteCustomerAddress")
    }
}
