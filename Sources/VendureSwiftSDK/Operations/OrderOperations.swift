import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public actor OrderOperations {
    private let vendure: Vendure
    
    public init(_ vendure: Vendure) {
        self.vendure = vendure
    }
    
    /// Add item to order
    public func addItemToOrder(productVariantId: String, quantity: Int, includeCustomFields: Bool? = nil) async throws -> UpdateOrderItemsResult {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildAddItemToOrderMutation(includeCustomFields: shouldIncludeCustomFields)
        
        let variables: [String: Any] = ["productVariantId": productVariantId, "quantity": quantity]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables: [String: Any]
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(input),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            variables = ["input": dict]
        } else {
            variables = [:]
        }
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables: [String: Any]
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(input),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            variables = ["input": dict]
        } else {
            variables = [:]
        }
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
    }
    
    /// Get active order
    public func getActiveOrder(includeCustomFields: Bool? = nil) async throws -> Order? {
        let shouldIncludeCustomFields = VendureConfiguration.shared.shouldIncludeCustomFields(for: "Order", userRequested: includeCustomFields)
        let query = GraphQLQueryBuilder.buildActiveOrderQuery(includeCustomFields: shouldIncludeCustomFields)
        
        return try await vendure.custom.query(query, responseType: Order?.self)
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
        
        let variables: [String: Any]
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(input),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            variables = ["input": dict]
        } else {
            variables = [:]
        }
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables = ["code": code]
        return try await vendure.custom.query(query, variables: variables, responseType: Order.self)
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
        
        return try await vendure.custom.queryList(query, responseType: PaymentMethodQuote.self, expectedDataType: "eligiblePaymentMethods")
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
        
        return try await vendure.custom.queryList(query, responseType: ShippingMethodQuote.self, expectedDataType: "eligibleShippingMethods")
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
        
        let variables: [String: Any] = ["input": input]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables: [String: Any] = ["shippingMethodId": methodIds]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables: [String: Any] = ["orderLineId": orderLineId]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables: [String: Any] = ["orderLineId": orderLineId, "quantity": quantity]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
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
        
        let variables: [String: Any] = ["couponCode": couponCode]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order.self)
    }
    
    /// Remove coupon code
    public func removeCouponCode(couponCode: String) async throws -> Order? {
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
        
        let variables = ["couponCode": couponCode]
        return try await vendure.custom.mutate(query, variables: variables, responseType: Order?.self)
    }
    
    /// Transition order to state
    public func transitionOrderToState(state: String) async throws -> Order {
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
        
        let variables = ["state": state]
        return try await vendure.custom.mutate(query, variables: variables, responseType: TransitionOrderToStateResult.self)
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
        
        let variables = ["input": input]
        return try await vendure.custom.mutate(query, variables: variables, responseType: ActiveOrderResult.self)
    }
}
