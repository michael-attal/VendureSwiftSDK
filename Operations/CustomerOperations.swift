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
        return try await baseOps.queryCustomer(query, variablesJSON: nil, headers: headers)
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
        return try await baseOps.queryCurrentUser(query, variablesJSON: nil, headers: headers)
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
        return try await baseOps.queryChannel(query, variablesJSON: nil, headers: headers)
    }
    
    /// Update customer
    public func updateCustomer(input: UpdateCustomerInput, includeCustomFields: Bool? = nil) async throws -> Customer {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildUpdateCustomerMutation(includeCustomFields: shouldIncludeCustomFields)
        
        // Convert input to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        let inputData = try encoder.encode(input)
        let inputJSON = String(data: inputData, encoding: .utf8) ?? "{}"
        
        let variablesJSON = """
        {
            "input": \(inputJSON)
        }
        """
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateCustomer(query, variablesJSON: variablesJSON, headers: headers)
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
        
        // Convert input to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        let inputData = try encoder.encode(input)
        let inputJSON = String(data: inputData, encoding: .utf8) ?? "{}"
        
        let variablesJSON = """
        {
            "input": \(inputJSON)
        }
        """
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateAddress(query, variablesJSON: variablesJSON, headers: headers)
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
        
        // Convert input to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        let inputData = try encoder.encode(input)
        let inputJSON = String(data: inputData, encoding: .utf8) ?? "{}"
        
        let variablesJSON = """
        {
            "input": \(inputJSON)
        }
        """
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateAddress(query, variablesJSON: variablesJSON, headers: headers)
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
        
        let variablesJSON = """
        {
            "id": "\(id)"
        }
        """
        
        let headers = try await vendure.defaultHeaders()
        let baseOps = await getBaseOps()
        return try await baseOps.mutateSuccess(query, variablesJSON: variablesJSON, headers: headers)
    }
}
