import Foundation

public actor CustomerOperations {
    private let vendure: Vendure

    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }

    /// Get active customer
    /// Fetches customer data, potentially localized if queries include related localized entities.
    public func getActiveCustomer(
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Customer? {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildActiveCustomerQuery(includeCustomFields: shouldIncludeCustomFields)

        return try await vendure.custom.queryCustomer(
            query,
            variables: nil,
            expectedDataType: "activeCustomer", // The key in the response 'data' object
            languageCode: languageCode
        )
    }

    /// Get current user (Identifiers/Channels typically aren't localized)
    public func getCurrentUser() async throws -> CurrentUser? {
        let query = """
        query me {
          me {
            id identifier
            channels { id code token permissions } # Added permissions
          }
        }
        """
        // Auth/User info usually doesn't need language override
        // Using queryRaw directly without languageCode override
        let response = try await vendure.custom.queryRaw(query, variables: nil) // No languageCode override needed

        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Get current user error"])
        }
        guard let data = response.rawData.isEmpty ? nil : response.rawData else { return nil }

        // Using CurrentUserWrapper for safe decoding
        let decoder = GraphQLClient.createJSONDecoder()
        do {
            let wrapper = try decoder.decode(CurrentUserWrapper.self, from: data)
            return wrapper.currentUser
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode CurrentUser: \(error)")
            return nil
        }
    }

    /// Get active channel (Names/Descriptions might be localized)
    /// Use includeCustomFields to fetch channel custom fields (store info, branding, etc.)
    /// Custom fields must be registered via VendureConfiguration.shared.addCustomField() for "Channel" type
    public func getActiveChannel(includeCustomFields: Bool? = nil, languageCode: String? = nil) async throws -> Channel {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Channel", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildActiveChannelQuery(includeCustomFields: shouldIncludeCustomFields)

        return try await vendure.custom.queryGeneric(
            query,
            variables: nil,
            expectedDataType: "activeChannel",
            responseType: Channel.self,
            languageCode: languageCode
        )
    }

    /// Update customer
    /// Input data is not localized, but the returned Customer object might be if the query includes localized fields.
    public func updateCustomer(
        input: UpdateCustomerInput,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Customer {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)
        // Ensure the mutation query itself requests localized fields if needed in the response
        let query = await GraphQLQueryBuilder.buildUpdateCustomerMutation(includeCustomFields: shouldIncludeCustomFields)

        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        // Using CustomOperations mutateCustomer which handles languageCode for the underlying call
        return try await vendure.custom.mutateCustomer(
            query,
            variables: variables,
            expectedDataType: "updateCustomer",
            languageCode: languageCode
        )
    }

    /// Create customer address (Address fields usually not localized, country name might be)
    public func createCustomerAddress(input: CreateAddressInput, languageCode: String? = nil) async throws -> Address {
        // Query asks for country name which can be localized
        let query = """
        mutation createCustomerAddress($input: CreateAddressInput!) {
          createCustomerAddress(input: $input) {
            id fullName company streetLine1 streetLine2 city province postalCode
            country { id code name } # Name is localized
            phoneNumber defaultShippingAddress defaultBillingAddress
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        return try await vendure.custom.mutateGeneric(
            query,
            variables: variables,
            expectedDataType: "createCustomerAddress",
            responseType: Address.self,
            languageCode: languageCode
        )
    }

    /// Update customer address (Similar to create, country name might be localized in response)
    public func updateCustomerAddress(input: UpdateAddressInput, languageCode: String? = nil) async throws -> Address {
        let query = """
        mutation updateCustomerAddress($input: UpdateAddressInput!) {
          updateCustomerAddress(input: $input) {
            id fullName company streetLine1 streetLine2 city province postalCode
            country { id code name } # Name is localized
            phoneNumber defaultShippingAddress defaultBillingAddress
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        return try await vendure.custom.mutateGeneric(
            query,
            variables: variables,
            expectedDataType: "updateCustomerAddress",
            responseType: Address.self,
            languageCode: languageCode
        )
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
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]

        return try await vendure.custom.mutateGeneric(
            query,
            variables: variables,
            expectedDataType: "deleteCustomerAddress",
            responseType: Success.self
        )
    }
}
