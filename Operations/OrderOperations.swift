import Foundation

public actor OrderOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Add item to order
    public func addItemToOrder(productVariantId: String, quantity: Int, includeCustomFields: Bool? = nil) async throws -> UpdateOrderItemsResult {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildAddItemToOrderMutation(includeCustomFields: shouldIncludeCustomFields)
        
        let variablesJSON = """
        {
            "productVariantId": "\(productVariantId)",
            "quantity": \(quantity)
        }
        """
        
        // Use mutateRaw and decode manually for SKIP compatibility
        let response = try await vendure.custom.mutateRaw(
            query,
            variablesJSON: variablesJSON
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(UpdateOrderItemsResult.self, from: data)
    }
    
    /// Set order shipping address
    public func setOrderShippingAddress(input: CreateAddressInput) async throws -> Order {
        let query = """
        mutation setOrderShippingAddress($input: CreateAddressInput!) {
          setOrderShippingAddress(input: $input) {
            __typename
            ... on Order {
              id
              code
              shippingAddress {
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
              }
            }
            ... on NoActiveOrderError {
              errorCode
              message
            }
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
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "setOrderShippingAddress"
        )
    }
    
    /// Set order billing address
    public func setOrderBillingAddress(input: CreateAddressInput) async throws -> Order {
        let query = """
        mutation setOrderBillingAddress($input: CreateAddressInput!) {
          setOrderBillingAddress(input: $input) {
            __typename
            ... on Order {
              id
              code
              billingAddress {
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
              }
            }
            ... on NoActiveOrderError {
              errorCode
              message
            }
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
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "setOrderBillingAddress"
        )
    }
    
    /// Get active order
    public func getActiveOrder(includeCustomFields: Bool? = nil) async throws -> Order {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        let query = await GraphQLQueryBuilder.buildActiveOrderQuery(includeCustomFields: shouldIncludeCustomFields)
        
        return try await vendure.custom.queryOrder(
            query,
            variablesJSON: nil,
            expectedDataType: nil
        )
    }
    
    /// Add payment to order
    public func addPaymentToOrder(input: PaymentInput) async throws -> Order {
        let query = """
        mutation addPaymentToOrder($input: PaymentInput!) {
          addPaymentToOrder(input: $input) {
            __typename
            ... on Order {
              id
              code
              state
              payments {
                id
                method
                amount
                state
                metadata
              }
            }
            ... on OrderPaymentStateError {
              errorCode
              message
            }
            ... on PaymentFailedError {
              errorCode
              message
              paymentErrorMessage
            }
            ... on PaymentDeclinedError {
              errorCode
              message
              paymentErrorMessage
            }
            ... on IneligiblePaymentMethodError {
              errorCode
              message
            }
            ... on OrderStateTransitionError {
              errorCode
              message
            }
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
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "addPaymentToOrder"
        )
    }
    
    /// Get order by code
    public func getOrderByCode(code: String) async throws -> Order {
        let query = """
        query orderByCode($code: String!) {
          orderByCode(code: $code) {
            id
            code
            active
            createdAt
            updatedAt
            orderPlacedAt
            state
            currencyCode
            totalQuantity
            subTotal
            subTotalWithTax
            shipping
            shippingWithTax
            total
            totalWithTax
            customer {
              id
              firstName
              lastName
              emailAddress
            }
            shippingAddress {
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
            }
            billingAddress {
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
            }
            lines {
              id
              quantity
              linePrice
              linePriceWithTax
              productVariant {
                id
                name
                price
                priceWithTax
                sku
                product {
                  id
                  name
                  slug
                  description
                }
              }
            }
            couponCodes
          }
        }
        """
        
        let variablesJSON = """
        {
            "code": "\(code)"
        }
        """
        
        return try await vendure.custom.queryOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "orderByCode"
        )
    }
    
    /// Get eligible payment methods
    public func getPaymentMethods() async throws -> [PaymentMethodQuote] {
        let query = """
        query eligiblePaymentMethods {
          eligiblePaymentMethods {
            id
            code
            name
            description
            isEligible
            eligibilityMessage
          }
        }
        """
        
        // Use queryRaw and decode manually for SKIP compatibility
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: nil
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract payment methods array from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let methodsArray = responseData["eligiblePaymentMethods"] as? [Any] else {
            throw VendureError.decodingError(NSError(domain: "OrderOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid payment methods response"]))
        }
        
        // Decode each payment method
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var methods: [PaymentMethodQuote] = []
        for methodData in methodsArray {
            let itemData = try JSONSerialization.data(withJSONObject: methodData, options: [])
            let method = try decoder.decode(PaymentMethodQuote.self, from: itemData)
            methods.append(method)
        }
        
        return methods
    }
    
    /// Get eligible shipping methods
    public func getShippingMethods() async throws -> [ShippingMethodQuote] {
        let query = """
        query eligibleShippingMethods {
          eligibleShippingMethods {
            id
            price
            priceWithTax
            code
            name
            description
          }
        }
        """
        
        // Use queryRaw and decode manually for SKIP compatibility
        let response = try await vendure.custom.queryRaw(
            query,
            variablesJSON: nil
        )
        
        if response.hasErrors {
            let errorMessages = response.errors?.map { $0.message } ?? ["Unknown GraphQL error"]
            throw VendureError.graphqlError(errorMessages)
        }
        
        guard let data = response.rawData.isEmpty ? nil : response.rawData else {
            throw VendureError.noData
        }
        
        // Extract shipping methods array from response
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = jsonObject as? [String: Any],
              let responseData = dict["data"] as? [String: Any],
              let methodsArray = responseData["eligibleShippingMethods"] as? [Any] else {
            throw VendureError.decodingError(NSError(domain: "OrderOps", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid shipping methods response"]))
        }
        
        // Decode each shipping method
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var methods: [ShippingMethodQuote] = []
        for methodData in methodsArray {
            let itemData = try JSONSerialization.data(withJSONObject: methodData, options: [])
            let method = try decoder.decode(ShippingMethodQuote.self, from: itemData)
            methods.append(method)
        }
        
        return methods
    }
    
    /// Set customer for order
    public func setCustomerForOrder(input: CreateCustomerInput) async throws -> Order {
        let query = """
        mutation setCustomerForOrder($input: CreateCustomerInput!) {
          setCustomerForOrder(input: $input) {
            __typename
            ... on Order {
              id
              customer {
                id
                firstName
                lastName
                emailAddress
              }
            }
            ... on AlreadyLoggedInError {
              errorCode
              message
            }
            ... on EmailAddressConflictError {
              errorCode
              message
            }
            ... on NoActiveOrderError {
              errorCode
              message
            }
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
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "setCustomerForOrder"
        )
    }
    
    /// Set order shipping method
    public func setOrderShippingMethod(shippingMethodId: String, additionalMethodIds: [String]? = nil) async throws -> Order {
        let query = """
        mutation setOrderShippingMethod($shippingMethodId: [ID!]!) {
          setOrderShippingMethod(shippingMethodId: $shippingMethodId) {
            __typename
            ... on Order {
              id
              shippingLines {
                shippingMethod {
                  id
                  code
                  name
                }
                price
                priceWithTax
              }
            }
            ... on OrderModificationError {
              errorCode
              message
            }
            ... on IneligibleShippingMethodError {
              errorCode
              message
            }
            ... on NoActiveOrderError {
              errorCode
              message
            }
          }
        }
        """
        
        var methodIds = [shippingMethodId]
        if let additional = additionalMethodIds {
            methodIds.append(contentsOf: additional)
        }
        
        // Build array JSON
        let methodIdsJSON = methodIds.map { "\"\($0)\"" }.joined(separator: ", ")
        
        let variablesJSON = """
        {
            "shippingMethodId": [\(methodIdsJSON)]
        }
        """
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "setOrderShippingMethod"
        )
    }
    
    /// Remove order line
    public func removeOrderLine(orderLineId: String) async throws -> Order {
        let query = """
        mutation removeOrderLine($orderLineId: ID!) {
          removeOrderLine(orderLineId: $orderLineId) {
            __typename
            ... on Order {
              id
              lines {
                id
                quantity
                productVariant {
                  id
                  name
                }
              }
            }
            ... on OrderModificationError {
              errorCode
              message
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "orderLineId": "\(orderLineId)"
        }
        """
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "removeOrderLine"
        )
    }
    
    /// Adjust order line quantity
    public func adjustOrderLine(orderLineId: String, quantity: Int) async throws -> Order {
        let query = """
        mutation adjustOrderLine($orderLineId: ID!, $quantity: Int!) {
          adjustOrderLine(orderLineId: $orderLineId, quantity: $quantity) {
            __typename
            ... on Order {
              id
              lines {
                id
                quantity
                linePrice
                linePriceWithTax
                productVariant {
                  id
                  name
                  price
                  priceWithTax
                }
              }
              totalQuantity
              subTotal
              subTotalWithTax
              total
              totalWithTax
            }
            ... on InsufficientStockError {
              errorCode
              message
              quantityAvailable
            }
            ... on NegativeQuantityError {
              errorCode
              message
            }
            ... on OrderModificationError {
              errorCode
              message
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "orderLineId": "\(orderLineId)",
            "quantity": \(quantity)
        }
        """
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "adjustOrderLine"
        )
    }
    
    /// Apply coupon code
    public func applyCouponCode(couponCode: String) async throws -> Order {
        let query = """
        mutation applyCouponCode($couponCode: String!) {
          applyCouponCode(couponCode: $couponCode) {
            __typename
            ... on Order {
              id
              couponCodes
              discounts {
                adjustmentSource
                amount
                amountWithTax
                description
                type
              }
              subTotal
              subTotalWithTax
              total
              totalWithTax
            }
            ... on CouponCodeExpiredError {
              errorCode
              message
            }
            ... on CouponCodeInvalidError {
              errorCode
              message
            }
            ... on CouponCodeLimitError {
              errorCode
              message
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "couponCode": "\(couponCode)"
        }
        """
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "applyCouponCode"
        )
    }
    
    /// Remove coupon code
    public func removeCouponCode(couponCode: String) async throws -> Order {
        let query = """
        mutation removeCouponCode($couponCode: String!) {
          removeCouponCode(couponCode: $couponCode) {
            id
            couponCodes
            discounts {
              adjustmentSource
              amount
              amountWithTax
              description
              type
            }
            subTotal
            subTotalWithTax
            total
            totalWithTax
          }
        }
        """
        
        let variablesJSON = """
        {
            "couponCode": "\(couponCode)"
        }
        """
        
        return try await vendure.custom.mutateOrder(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "removeCouponCode"
        )
    }
    
    /// Transition order to state
    public func transitionOrderToState(state: String) async throws -> TransitionOrderToStateResult {
        let query = """
        mutation transitionOrderToState($state: String!) {
          transitionOrderToState(state: $state) {
            __typename
            ... on Order {
              id
              state
            }
            ... on OrderStateTransitionError {
              errorCode
              message
              transitionError
              fromState
              toState
            }
          }
        }
        """
        
        let variablesJSON = """
        {
            "state": "\(state)"
        }
        """
        
        return try await vendure.custom.mutateTransitionOrderToStateResult(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "transitionOrderToState"
        )
    }
    
    /// Set order custom fields
    public func setOrderCustomFields(input: UpdateOrderInput) async throws -> ActiveOrderResult {
        let query = """
        mutation setOrderCustomFields($input: UpdateOrderInput!) {
          setOrderCustomFields(input: $input) {
            __typename
            ... on Order {
              id
              customFields
            }
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
        
        return try await vendure.custom.mutateActiveOrderResult(
            query,
            variablesJSON: variablesJSON,
            expectedDataType: "setOrderCustomFields"
        )
    }
}
