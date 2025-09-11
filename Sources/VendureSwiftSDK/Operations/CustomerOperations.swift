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
    public func getActiveCustomer() async throws -> Customer? {
        let query = """
        query activeCustomer {
          activeCustomer {
            id
            title
            firstName
            lastName
            phoneNumber
            emailAddress
            addresses {
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
            customFields
          }
        }
        """
        
        return try await vendure.custom.query(query, responseType: Customer?.self, expectedDataType: "activeCustomer")
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
        
        return try await vendure.custom.query(query, responseType: CurrentUser?.self, expectedDataType: "me")
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
        
        return try await vendure.custom.query(query, responseType: Channel.self, expectedDataType: "activeChannel")
    }
    
    /// Update customer
    public func updateCustomer(input: UpdateCustomerInput) async throws -> Customer {
        let query = """
        mutation updateCustomer($input: UpdateCustomerInput!) {
          updateCustomer(input: $input) {
            id
            title
            firstName
            lastName
            phoneNumber
            emailAddress
          }
        }
        """
        
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
