import Foundation

public actor SystemOperations {
    private let vendure: Vendure

    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }

    // Specific executor for lists, handling potential empty lists gracefully
    private func executeListQuery<T: Codable & Sendable>(
        _ query: String,
        variables: [String: AnyCodable]?,
        expectedDataType: String, // e.g., "availableCountries", "facets"
        languageCode: String? = nil
    ) async throws -> [T] {
        let response = try await vendure.custom.queryRaw(query, variables: variables, languageCode: languageCode)

        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }

        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            // An empty list is valid, so no data might just mean zero items if the key exists but is empty/null
            if let json = try? JSONSerialization.jsonObject(with: response.rawData) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               dataDict[expectedDataType] is NSNull || dataDict[expectedDataType] == nil
            {
                await VendureLogger.shared.log(.info, category: "SystemOps", "List query for '\(expectedDataType)' returned null or empty.")
                return [] // Return empty array for null/missing list data
            }
            throw VendureError.noData // Throw if structure is wrong before key check
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let targetData = responseData[expectedDataType]
        else {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to find key '\(expectedDataType)' in list response data.")
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid \(expectedDataType) list response structure"]))
        }

        // Handle null or empty array explicitly
        if targetData is NSNull {
            await VendureLogger.shared.log(.info, category: "SystemOps", "List query for '\(expectedDataType)' returned null.")
            return []
        }
        guard let listArray = targetData as? [Any] else {
            await VendureLogger.shared.log(.error, category: "Decode", "Data for key '\(expectedDataType)' is not an array.")
            throw VendureError.decodingError(NSError(domain: "SystemOps", code: 2, userInfo: [NSLocalizedDescriptionKey: "Data for \(expectedDataType) is not an array"]))
        }
        if listArray.isEmpty {
            return []
        }

        let extractedData = try JSONSerialization.data(withJSONObject: listArray, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode([T].self, from: extractedData)
        } catch {
            await VendureLogger.shared.log(.error, category: "Decode", "Failed to decode list [\(String(describing: T.self))]: \(error)")
            let extractedString = String(data: extractedData, encoding: .utf8) ?? "Invalid UTF-8 data"
            await VendureLogger.shared.log(.verbose, category: "Decode", "Extracted Array Data: \(extractedString)")
            throw VendureError.decodingError(error)
        }
    }

    // MARK: - Countries

    public func getAvailableCountries(languageCode: String? = nil) async throws -> [Country] {
        let query = """
        query availableCountries {
          availableCountries {
            id code name enabled
            translations { id languageCode name }
          }
        }
        """
        return try await executeListQuery(
            query,
            variables: nil,
            expectedDataType: "availableCountries",
            languageCode: languageCode
        )
    }

    // MARK: - Facets

    public func getFacets(
        options: PaginatedListOptions<
            FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
            SortParameter<SortOrder>
        >? = nil,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> PaginatedList<Facet> {
        let shouldIncludeFacetFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Facet", userRequested: includeCustomFields)
        let shouldIncludeValueFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "FacetValue", userRequested: includeCustomFields)

        // Pass include flags to builder
        let query = await GraphQLQueryBuilder.buildFacetQuery(
            includeCustomFields: shouldIncludeFacetFields,
            includeValueCustomFields: shouldIncludeValueFields
        )
        let variables: [String: AnyCodable]? = ["options": AnyCodable(anyValue: options ?? nil as String?)]

        return try await vendure.custom.queryGeneric(
            query,
            variables: variables,
            expectedDataType: "facets", // The key holding the PaginatedList<Facet> structure
            responseType: PaginatedList<Facet>.self,
            languageCode: languageCode
        )
    }

    public func getFacet(
        id: String,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Facet {
        let shouldIncludeFacetFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Facet", userRequested: includeCustomFields)
        let shouldIncludeValueFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "FacetValue", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildSingleFacetQuery(
            includeCustomFields: shouldIncludeFacetFields,
            includeValueCustomFields: shouldIncludeValueFields
        )
        let variables: [String: AnyCodable] = ["id": AnyCodable(id)]

        return try await vendure.custom.executeQuery(
            query,
            variables: variables,
            expectedDataType: "facet",
            decodeTo: Facet.self,
            languageCode: languageCode
        )
    }

    // MARK: - Tax Categories

    // Tax Categories might have names that need localization

    public func getTaxCategories(languageCode: String? = nil) async throws -> [TaxCategory] {
        let query = """
        query taxCategories {
            taxCategories { # Assuming simple list query exists
                id name isDefault
                # Add translations if applicable
                # translations { languageCode name }
            }
        }
        """
        return try await executeListQuery(
            query,
            variables: nil,
            expectedDataType: "taxCategories",
            languageCode: languageCode
        )
    }
}
