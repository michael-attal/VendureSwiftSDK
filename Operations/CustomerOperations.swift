import Foundation

public actor CustomerOperations {
    private let vendure: Vendure
    private var baseOps: BaseOperations?
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
        self.baseOps = nil
    }
    
    private func getBaseOps() async -> BaseOperations {
        if let baseOps = self.baseOps {
            return baseOps
        }
        let client = await vendure.client()
        let newBaseOps = BaseOperations(client)
        self.baseOps = newBaseOps
        return newBaseOps
    }
    
    /// Get active customer
    public func getActiveCustomer(includeCustomFields: Bool? = nil) async throws -> Customer? {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildActiveCustomerQuery(includeCustomFields: shouldIncludeCustomFields)
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.queryCustomer(query, variables: nil, headers: headers)
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
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.queryCurrentUser(query, variables: nil, headers: headers)
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
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.queryChannel(query, variables: nil, headers: headers)
    }
    
    /// Update customer
    public func updateCustomer(input: UpdateCustomerInput, includeCustomFields: Bool? = nil) async throws -> Customer {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildUpdateCustomerMutation(includeCustomFields: shouldIncludeCustomFields)
        
        let variables: [String: AnyCodable] = [
            "input": AnyCodable(anyValue: input)
        ]
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateCustomer(query, variables: variables, headers: headers)
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
            country {
              id
              code
              name
            }
            phoneNumber
            defaultShippingAddress
            defaultBillingAddress
          }
        }
        """
        
        let variables: [String: AnyCodable] = [
            "input": AnyCodable(anyValue: input)
        ]
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateAddress(query, variables: variables, headers: headers)
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
            country {
              id
              code
              name
            }
            phoneNumber
            defaultShippingAddress
            defaultBillingAddress
          }
        }
        """
        
        let variables: [String: AnyCodable] = [
            "input": AnyCodable(anyValue: input)
        ]
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateAddress(query, variables: variables, headers: headers)
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
        
        let variables: [String: AnyCodable] = [
            "id": AnyCodable(id)
        ]
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateSuccess(query, variables: variables, headers: headers)
    }
}
