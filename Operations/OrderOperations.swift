// VendureSwiftSDK/Operations/OrderOperations.swift
import Foundation

public actor OrderOperations {
    private let vendure: Vendure

    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }

    /// Add item to order. The returned Order might contain localized product variant names.
    public func addItemToOrder(
        productVariantId: String,
        quantity: Int,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> UpdateOrderItemsResult {
        let shouldIncludeOrderFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        let shouldIncludeVariantFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildAddItemToOrderMutation(
            includeCustomFields: shouldIncludeOrderFields,
            includeVariantCustomFields: shouldIncludeVariantFields
        )

        let variables: [String: AnyCodable] = [
            "productVariantId": AnyCodable(productVariantId),
            "quantity": AnyCodable(quantity)
        ]

        // Use mutateRaw via custom operations, passing languageCode
        let response = try await vendure.custom.mutateRaw(
            query,
            variables: variables,
            languageCode: languageCode
        )

        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            await VendureLogger.shared.log(.error, category: VendureLoggingCategory.orders, "addItemToOrder failed: \(errorMessages.joined(separator: "; "))")
            // Attempt to decode specific error types if needed, otherwise throw generic
            if let data = response.rawData.isEmpty ? nil : response.rawData {
                let decoder = GraphQLClient.createJSONDecoder()
                if let specificError = try? decoder.decode(UpdateOrderItemsResult.self, from: data) {
                    // If the result type itself represents an error state
                    throw VendureError.graphqlError(["addItemToOrder returned specific error: \(specificError)"])
                }
            }
            throw VendureError.graphqlError(errorMessages)
        }

        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }

        let decoder = GraphQLClient.createJSONDecoder()
        do {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = jsonObject["data"] as? [String: Any],
                  let resultData = dataDict["addItemToOrder"]
            else {
                throw VendureError.decodingError(NSError(domain: "OrderOps", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing 'addItemToOrder' data"]))
            }
            let resultJsonData = try JSONSerialization.data(withJSONObject: resultData)
            return try decoder.decode(UpdateOrderItemsResult.self, from: resultJsonData)
        } catch {
            await VendureLogger.shared.log(.error, category: VendureLoggingCategory.decode, "Failed to decode addItemToOrder response: \(error)")
            throw VendureError.decodingError(error)
        }
    }

    /// Set order shipping address. The returned Order is less likely to need localization itself, but consistency is good.
    public func setOrderShippingAddress(
        input: CreateAddressInput,
        languageCode: String? = nil
    ) async throws -> Order {
        let query = """
        mutation setOrderShippingAddress($input: CreateAddressInput!) {
          setOrderShippingAddress(input: $input) {
            __typename
            ... on Order {
              id code state # Include essential fields
              shippingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber }
            }
            ... on NoActiveOrderError { errorCode message }
            # Add other potential errors like OrderModificationError
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        // Use custom mutateOrder, passing languageCode
        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "setOrderShippingAddress",
            languageCode: languageCode
        )
    }

    /// Set order billing address. Similar to shipping address.
    public func setOrderBillingAddress(
        input: CreateAddressInput,
        languageCode: String? = nil
    ) async throws -> Order {
        let query = """
        mutation setOrderBillingAddress($input: CreateAddressInput!) {
          setOrderBillingAddress(input: $input) {
            __typename
            ... on Order {
              id code state # Include essential fields
              billingAddress { id fullName company streetLine1 streetLine2 city province postalCode country phoneNumber }
            }
            ... on NoActiveOrderError { errorCode message }
            # Add other potential errors
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "setOrderBillingAddress",
            languageCode: languageCode
        )
    }

    /// Get active order. Product/Variant names within lines can be localized.
    public func getActiveOrder(
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Order {
        let shouldIncludeOrderFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        let shouldIncludeLineFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "OrderLine", userRequested: includeCustomFields)
        let shouldIncludeVariantFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)
        let shouldIncludeProdFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let shouldIncludeCustFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)

        let query = await GraphQLQueryBuilder.buildActiveOrderQuery(
            includeCustomFields: shouldIncludeOrderFields,
            includeLineCustomFields: shouldIncludeLineFields,
            includeVariantCustomFields: shouldIncludeVariantFields,
            includeProductCustomFields: shouldIncludeProdFields,
            includeCustomerCustomFields: shouldIncludeCustFields
        )

        // This will throw if the 'activeOrder' key maps to null or error
        return try await vendure.custom.queryOrder(
            query,
            variables: nil,
            expectedDataType: "activeOrder",
            languageCode: languageCode
        )
        // Upstream (VendureBackendService) should catch specific VendureError.graphqlError
        // containing "NO_ACTIVE_ORDER_ERROR" message and return nil.
    }

    /// Add payment to order. Returned Order object might need localized item names if queried.
    public func addPaymentToOrder(
        input: PaymentInput,
        languageCode: String? = nil
    ) async throws -> Order {
        // The query primarily focuses on payment status, but includes Order ID/Code/State
        let query = """
        mutation addPaymentToOrder($input: PaymentInput!) {
          addPaymentToOrder(input: $input) {
            __typename
            ... on Order {
              id code state total totalWithTax currencyCode
              payments { id method amount state errorMessage transactionId metadata createdAt }
            }
            ... on OrderPaymentStateError { errorCode message }
            ... on PaymentFailedError { errorCode message paymentErrorMessage }
            ... on PaymentDeclinedError { errorCode message paymentErrorMessage }
            ... on IneligiblePaymentMethodError { errorCode message eligibilityCheckerMessage }
            ... on OrderStateTransitionError { errorCode message transitionError fromState toState }
            ... on NoActiveOrderError { errorCode message }
            # Add other relevant errors
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        // Use mutateGeneric as the result is a union type
        let result: AddPaymentToOrderResult = try await vendure.custom.mutateGeneric(
            query,
            variables: variables,
            expectedDataType: "addPaymentToOrder",
            responseType: AddPaymentToOrderResult.self,
            languageCode: languageCode
        )

        // Handle the union result
        switch result {
            case .order(let order):
                return order
            case .orderPaymentStateError(let error):
                throw VendureError.graphqlError(["\(error.errorCode): \(error.message)"])
            case .ineligiblePaymentMethodError(let error):
                throw VendureError.graphqlError(["\(error.errorCode): \(error.message) \(error.details?.eligibilityCheckerMessage ?? "")"])
            case .paymentFailedError(let error):
                throw VendureError.graphqlError(["\(error.errorCode): \(error.message) - \(error.details?.paymentErrorMessage ?? "")"])
            case .paymentDeclinedError(let error):
                throw VendureError.graphqlError(["\(error.errorCode): \(error.message) - \(error.details?.paymentErrorMessage ?? "")"])
            case .orderStateTransitionError(let error):
                throw VendureError.graphqlError(["\(error.errorCode): \(error.message) (\(error.details?.fromState ?? "") -> \(error.details?.toState ?? "")): \(error.details?.transitionError ?? "")"])
            case .noActiveOrderError(let error):
                throw VendureError.graphqlError(["\(error.errorCode): \(error.message)"])
        }
    }

    /// Get order by code. Item names can be localized.
    public func getOrderByCode(
        code: String,
        includeCustomFields: Bool? = nil,
        languageCode: String? = nil
    ) async throws -> Order {
        // Determine if custom fields needed based on flag and config
        let shouldIncludeOrderFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        // ... include checks for Line, Variant, Product, Customer ...
        let shouldIncludeLineFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "OrderLine", userRequested: includeCustomFields)
        let shouldIncludeVariantFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: includeCustomFields)
        let shouldIncludeProdFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Product", userRequested: includeCustomFields)
        let shouldIncludeCustFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Customer", userRequested: includeCustomFields)

        // Use builder that includes all necessary flags
        let query = await GraphQLQueryBuilder.buildSingleOrderQuery(
            byCode: true, // Need to add 'byCode' flag or separate builder method
            includeCustomFields: shouldIncludeOrderFields,
            includeCustomerCustomFields: shouldIncludeCustFields,
            includeLineCustomFields: shouldIncludeLineFields,
            includeVariantCustomFields: shouldIncludeVariantFields,
            includeProductCustomFields: shouldIncludeProdFields
        )

        let variables: [String: AnyCodable] = ["code": AnyCodable(code)]

        return try await vendure.custom.queryOrder(
            query,
            variables: variables,
            expectedDataType: "orderByCode",
            languageCode: languageCode
        )
    }

    /// Get eligible payment methods. Names/Descriptions can be localized.
    public func getPaymentMethods(languageCode: String? = nil) async throws -> [PaymentMethodQuote] {
        // Check config for custom fields on PaymentMethodQuote if applicable
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "PaymentMethodQuote", userRequested: nil)

        let query = """
        query eligiblePaymentMethods {
          eligiblePaymentMethods {
            id code name description isEligible eligibilityMessage
            \(shouldIncludeFields ? VendureConfiguration.shared.injectCustomFields(for: "PaymentMethodQuote") : "")
          }
        }
        """

        let response = try await vendure.custom.queryRaw(query, variables: nil, languageCode: languageCode)

        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }

        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let methodsArray = responseData["eligiblePaymentMethods"] as? [Any]
        else {
            throw VendureError.decodingError(NSError(domain: "OrderOps", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid payment methods response structure"]))
        }

        if methodsArray.isEmpty { return [] }

        let decoder = GraphQLClient.createJSONDecoder()
        let methodsData = try JSONSerialization.data(withJSONObject: methodsArray)
        return try decoder.decode([PaymentMethodQuote].self, from: methodsData)
    }

    /// Get eligible shipping methods. Names/Descriptions can be localized.
    public func getShippingMethods(languageCode: String? = nil) async throws -> [ShippingMethodQuote] {
        let shouldIncludeFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ShippingMethodQuote", userRequested: nil)

        let query = """
        query eligibleShippingMethods {
          eligibleShippingMethods {
            id price priceWithTax code name description metadata
             \(shouldIncludeFields ? VendureConfiguration.shared.injectCustomFields(for: "ShippingMethodQuote") : "")
          }
        }
        """

        let response = try await vendure.custom.queryRaw(query, variables: nil, languageCode: languageCode)

        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }

        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let methodsArray = responseData["eligibleShippingMethods"] as? [Any]
        else {
            throw VendureError.decodingError(NSError(domain: "OrderOps", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid shipping methods response structure"]))
        }

        if methodsArray.isEmpty { return [] }

        let decoder = GraphQLClient.createJSONDecoder()
        let methodsData = try JSONSerialization.data(withJSONObject: methodsArray)
        return try decoder.decode([ShippingMethodQuote].self, from: methodsData)
    }

    /// Set customer for order. Returned Order minimally needs localization.
    public func setCustomerForOrder(
        input: CreateCustomerInput,
        languageCode: String? = nil
    ) async throws -> Order {
        let query = """
        mutation setCustomerForOrder($input: CreateCustomerInput!) {
          setCustomerForOrder(input: $input) {
            __typename
            ... on Order {
              id code state # Essential fields
              customer { id firstName lastName emailAddress }
            }
            ... on AlreadyLoggedInError { errorCode message }
            ... on EmailAddressConflictError { errorCode message }
            ... on NoActiveOrderError { errorCode message }
            # Add GuestCheckoutError if applicable
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "setCustomerForOrder",
            languageCode: languageCode
        )
    }

    /// Set order shipping method.
    public func setOrderShippingMethod(
        shippingMethodId: String,
        additionalMethodIds: [String]? = nil,
        languageCode: String? = nil
    ) async throws -> Order {
        let query = """
        mutation setOrderShippingMethod($shippingMethodId: [ID!]!) {
          setOrderShippingMethod(shippingMethodId: $shippingMethodId) {
            __typename
            ... on Order {
              id code state # Essential fields
              shipping shippingWithTax # Updated totals
              shippingLines {
                shippingMethod { id code name } # Name might be localized
                price priceWithTax
              }
            }
            ... on OrderModificationError { errorCode message }
            ... on IneligibleShippingMethodError { errorCode message eligibilityCheckerMessage }
            ... on NoActiveOrderError { errorCode message }
            # Add OrderStateError if applicable
          }
        }
        """
        var methodIds = [shippingMethodId]
        if let additional = additionalMethodIds { methodIds.append(contentsOf: additional) }
        let variables: [String: AnyCodable] = ["shippingMethodId": AnyCodable(methodIds)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "setOrderShippingMethod",
            languageCode: languageCode
        )
    }

    /// Remove order line. Returned Order might need localized item names.
    public func removeOrderLine(
        orderLineId: String,
        languageCode: String? = nil
    ) async throws -> Order {
        let shouldIncludeLineFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "OrderLine", userRequested: nil)
        let shouldIncludeVariantFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: nil)

        let query = """
        mutation removeOrderLine($orderLineId: ID!) {
          removeOrderLine(orderLineId: $orderLineId) {
            __typename
            ... on Order {
              id code state totalQuantity subTotal subTotalWithTax total totalWithTax # Totals
              lines {
                id quantity linePrice linePriceWithTax
                productVariant { id name sku # Name is localized
                     \(shouldIncludeVariantFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                 }
                 \(shouldIncludeLineFields ? VendureConfiguration.shared.injectCustomFields(for: "OrderLine") : "")
              }
              # Include Order custom fields if needed
            }
            ... on OrderModificationError { errorCode message }
            ... on NoActiveOrderError { errorCode message } # Added possibility
          }
        }
        """
        let variables: [String: AnyCodable] = ["orderLineId": AnyCodable(orderLineId)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "removeOrderLine",
            languageCode: languageCode
        )
    }

    /// Adjust order line quantity.
    public func adjustOrderLine(
        orderLineId: String,
        quantity: Int,
        languageCode: String? = nil
    ) async throws -> Order {
        let shouldIncludeLineFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "OrderLine", userRequested: nil)
        let shouldIncludeVariantFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "ProductVariant", userRequested: nil)

        let query = """
        mutation adjustOrderLine($orderLineId: ID!, $quantity: Int!) {
          adjustOrderLine(orderLineId: $orderLineId, quantity: $quantity) {
            __typename
            ... on Order {
              id code state totalQuantity subTotal subTotalWithTax total totalWithTax # Totals
              lines {
                id quantity linePrice linePriceWithTax
                productVariant { id name sku price priceWithTax # Name is localized
                     \(shouldIncludeVariantFields ? VendureConfiguration.shared.injectCustomFields(for: "ProductVariant") : "")
                 }
                  \(shouldIncludeLineFields ? VendureConfiguration.shared.injectCustomFields(for: "OrderLine") : "")
              }
               # Include Order custom fields if needed
            }
            ... on InsufficientStockError { errorCode message quantityAvailable order { id } }
            ... on NegativeQuantityError { errorCode message }
            ... on OrderModificationError { errorCode message }
            ... on OrderLimitError { errorCode message maxItems } # Added possibility
            ... on NoActiveOrderError { errorCode message } # Added possibility
          }
        }
        """
        let variables: [String: AnyCodable] = ["orderLineId": AnyCodable(orderLineId), "quantity": AnyCodable(quantity)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "adjustOrderLine",
            languageCode: languageCode
        )
    }

    /// Apply coupon code.
    public func applyCouponCode(
        couponCode: String,
        languageCode: String? = nil
    ) async throws -> Order {
        // Query focuses on discounts and totals
        let query = """
        mutation applyCouponCode($couponCode: String!) {
          applyCouponCode(couponCode: $couponCode) {
            __typename
            ... on Order {
              id code state couponCodes
              discounts { adjustmentSource amount amountWithTax description type }
              subTotal subTotalWithTax total totalWithTax
            }
            ... on CouponCodeExpiredError { errorCode message couponCode }
            ... on CouponCodeInvalidError { errorCode message couponCode }
            ... on CouponCodeLimitError { errorCode message couponCode limit }
             # Add NoActiveOrderError
             ... on NoActiveOrderError { errorCode message }
          }
        }
        """
        let variables: [String: AnyCodable] = ["couponCode": AnyCodable(couponCode)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "applyCouponCode",
            languageCode: languageCode
        )
    }

    /// Remove coupon code.
    public func removeCouponCode(
        couponCode: String,
        languageCode: String? = nil
    ) async throws -> Order {
        // Query focuses on discounts and totals
        let query = """
        mutation removeCouponCode($couponCode: String!) {
          removeCouponCode(couponCode: $couponCode) {
             # Add __typename for potential error handling if API supports it
             # __typename
            # ... on Order { ... }
             # ... on NoActiveOrderError { ... }
            id code state couponCodes
            discounts { adjustmentSource amount amountWithTax description type }
            subTotal subTotalWithTax total totalWithTax
          }
        }
        """
        let variables: [String: AnyCodable] = ["couponCode": AnyCodable(couponCode)]

        return try await vendure.custom.mutateOrder(
            query,
            variables: variables,
            expectedDataType: "removeCouponCode",
            languageCode: languageCode
        )
    }

    /// Transition order to state.
    public func transitionOrderToState(
        state: String,
        languageCode: String? = nil
    ) async throws -> TransitionOrderToStateResult {
        let query = """
        mutation transitionOrderToState($state: String!) {
          transitionOrderToState(state: $state) {
            __typename
            ... on Order {
              id code state # Essential fields
            }
            ... on OrderStateTransitionError {
              errorCode message transitionError fromState toState
            }
             # Add NoActiveOrderError
             ... on NoActiveOrderError { errorCode message }
          }
        }
        """
        let variables: [String: AnyCodable] = ["state": AnyCodable(state)]

        return try await vendure.custom.mutateGeneric(
            query,
            variables: variables,
            expectedDataType: "transitionOrderToState",
            responseType: TransitionOrderToStateResult.self,
            languageCode: languageCode
        )
    }

    /// Set order custom fields.
    public func setOrderCustomFields(
        input: UpdateOrderInput,
        languageCode: String? = nil
    ) async throws -> ActiveOrderResult {
        // Query needs to select the custom fields being set/updated
        // This requires knowing the specific custom fields or using the generic customFields block if available
        let customFieldsFragment = VendureConfiguration.shared.injectCustomFields(for: "Order") // Get configured fields

        let query = """
        mutation setOrderCustomFields($input: UpdateOrderInput!) {
          setOrderCustomFields(input: $input) {
            __typename
            ... on Order {
              id code state # Essential fields
              \(customFieldsFragment.isEmpty ? "" : customFieldsFragment) # Include configured custom fields
            }
             # Add NoActiveOrderError
             ... on NoActiveOrderError { errorCode message }
             # Add OrderModificationError if applicable
             # ... on OrderModificationError { errorCode message }
          }
        }
        """
        let variables: [String: AnyCodable] = ["input": AnyCodable(anyValue: input)]

        return try await vendure.custom.mutateGeneric(
            query,
            variables: variables,
            expectedDataType: "setOrderCustomFields",
            responseType: ActiveOrderResult.self,
            languageCode: languageCode
        )
    }
}
