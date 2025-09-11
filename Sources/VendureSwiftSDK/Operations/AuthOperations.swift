import Foundation
#if canImport(SkipFoundation)
import SkipFoundation
#endif

public actor AuthOperations {
    private let client: GraphQLClient
    
    public init(_ client: GraphQLClient) {
        self.client = client
    }
    
    /// Authenticate with username and password
    public func authenticate(username: String, password: String) async throws -> AuthenticationResult {
        let query = """
        mutation authenticate($username: String!, $password: String!) {
          authenticate(input: { username: $username, password: $password }) {
            __typename
            ... on CurrentUser {
              id
              identifier
              channels {
                id
                code
                token
              }
            }
            ... on InvalidCredentialsError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = ["username": username, "password": password]
        let response = try await client.mutate(query, variables: variables, responseType: AuthenticationResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from authentication")
        }
        
        return result
    }
    
    /// Authenticate with Firebase
    public func authenticateFirebase(uid: String, jwt: String) async throws -> AuthenticationResult {
        let query = """
        mutation authenticateFirebase($uid: String!, $jwt: String!) {
          authenticate(input: { uid: $uid, jwt: $jwt }) {
            __typename
            ... on CurrentUser {
              id
              identifier
              channels {
                id
                code
                token
              }
            }
            ... on InvalidCredentialsError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = ["uid": uid, "jwt": jwt]
        let response = try await client.mutate(query, variables: variables, responseType: AuthenticationResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from Firebase authentication")
        }
        
        return result
    }
    
    /// Get authentication token
    public func getToken(username: String, password: String) async throws -> String? {
        let query = """
        mutation authenticate($username: String!, $password: String!) {
          authenticate(input: { username: $username, password: $password }) {
            __typename
            ... on CurrentUser {
              id
            }
          }
        }
        """
        
        let variables = ["username": username, "password": password]
        let response = try await client.mutate(query, variables: variables, responseType: AnyCodable.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        // In a real implementation, you'd extract the token from response headers
        // This is a placeholder implementation
        return "token_placeholder"
    }
    
    /// Get Firebase authentication token
    public func getTokenFirebase(uid: String, jwt: String) async throws -> String? {
        let query = """
        mutation authenticateFirebase($uid: String!, $jwt: String!) {
          authenticate(input: { uid: $uid, jwt: $jwt }) {
            __typename
            ... on CurrentUser {
              id
            }
          }
        }
        """
        
        let variables = ["uid": uid, "jwt": jwt]
        let response = try await client.mutate(query, variables: variables, responseType: AnyCodable.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        // In a real implementation, you'd extract the token from response headers
        // This is a placeholder implementation
        return "firebase_token_placeholder"
    }
    
    /// Login with username and password
    public func login(username: String, password: String, rememberMe: Bool = false) async throws -> NativeAuthenticationResult {
        let query = """
        mutation login($username: String!, $password: String!, $rememberMe: Boolean) {
          login(username: $username, password: $password, rememberMe: $rememberMe) {
            __typename
            ... on CurrentUser {
              id
              identifier
              channels {
                id
                code
                token
              }
            }
            ... on InvalidCredentialsError {
              errorCode
              message
            }
            ... on NotVerifiedError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables: [String: Any] = [
            "username": username,
            "password": password,
            "rememberMe": rememberMe
        ]
        let response = try await client.mutate(query, variables: variables, responseType: NativeAuthenticationResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from login")
        }
        
        return result
    }
    
    /// Logout current user
    public func logout() async throws -> Success {
        let query = """
        mutation logout {
          logout {
            success
          }
        }
        """
        
        let response = try await client.mutate(query, responseType: Success.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from logout")
        }
        
        return result
    }
    
    /// Register a new customer account
    public func registerCustomerAccount(input: RegisterCustomerInput) async throws -> RegisterCustomerAccountResult {
        let query = """
        mutation registerCustomerAccount($input: RegisterCustomerInput!) {
          registerCustomerAccount(input: $input) {
            __typename
            ... on Success {
              success
            }
            ... on MissingPasswordError {
              errorCode
              message
            }
            ... on PasswordValidationError {
              errorCode
              message
            }
            ... on NativeAuthStrategyError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = ["input": input]
        let response = try await client.mutate(query, variables: variables, responseType: RegisterCustomerAccountResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from register customer account")
        }
        
        return result
    }
    
    /// Verify customer account with verification token
    public func verifyCustomerAccount(token: String, password: String? = nil) async throws -> VerifyCustomerAccountResult {
        let query = """
        mutation verifyCustomerAccount($token: String!, $password: String) {
          verifyCustomerAccount(token: $token, password: $password) {
            __typename
            ... on CurrentUser {
              id
              identifier
            }
            ... on VerificationTokenInvalidError {
              errorCode
              message
            }
            ... on VerificationTokenExpiredError {
              errorCode
              message
            }
            ... on MissingPasswordError {
              errorCode
              message
            }
            ... on PasswordValidationError {
              errorCode
              message
            }
            ... on NativeAuthStrategyError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables: [String: Any] = [
            "token": token,
            "password": password as Any
        ]
        let response = try await client.mutate(query, variables: variables, responseType: VerifyCustomerAccountResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from verify customer account")
        }
        
        return result
    }
    
    /// Update customer password
    public func updateCustomerPassword(currentPassword: String, newPassword: String) async throws -> UpdateCustomerPasswordResult {
        let query = """
        mutation updateCustomerPassword($currentPassword: String!, $newPassword: String!) {
          updateCustomerPassword(currentPassword: $currentPassword, newPassword: $newPassword) {
            __typename
            ... on Success {
              success
            }
            ... on InvalidCredentialsError {
              errorCode
              message
            }
            ... on PasswordValidationError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]
        let response = try await client.mutate(query, variables: variables, responseType: UpdateCustomerPasswordResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from update customer password")
        }
        
        return result
    }
    
    /// Request password reset
    public func requestPasswordReset(emailAddress: String) async throws -> RequestPasswordResetResult {
        let query = """
        mutation requestPasswordReset($emailAddress: String!) {
          requestPasswordReset(emailAddress: $emailAddress) {
            __typename
            ... on Success {
              success
            }
          }
        }
        """
        
        let variables = ["emailAddress": emailAddress]
        let response = try await client.mutate(query, variables: variables, responseType: RequestPasswordResetResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from request password reset")
        }
        
        return result
    }
    
    /// Reset password with token
    public func resetPassword(token: String, password: String) async throws -> ResetPasswordResult {
        let query = """
        mutation resetPassword($token: String!, $password: String!) {
          resetPassword(token: $token, password: $password) {
            __typename
            ... on CurrentUser {
              id
              identifier
            }
            ... on PasswordResetTokenInvalidError {
              errorCode
              message
            }
            ... on PasswordResetTokenExpiredError {
              errorCode
              message
            }
            ... on PasswordValidationError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = [
            "token": token,
            "password": password
        ]
        let response = try await client.mutate(query, variables: variables, responseType: ResetPasswordResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from reset password")
        }
        
        return result
    }
    
    /// Request update customer email address
    public func requestUpdateCustomerEmailAddress(password: String, newEmailAddress: String) async throws -> RequestUpdateCustomerEmailAddressResult {
        let query = """
        mutation requestUpdateCustomerEmailAddress($password: String!, $newEmailAddress: String!) {
          requestUpdateCustomerEmailAddress(password: $password, newEmailAddress: $newEmailAddress) {
            __typename
            ... on Success {
              success
            }
            ... on InvalidCredentialsError {
              errorCode
              message
            }
            ... on EmailAddressConflictError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = [
            "password": password,
            "newEmailAddress": newEmailAddress
        ]
        let response = try await client.mutate(query, variables: variables, responseType: RequestUpdateCustomerEmailAddressResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from request update customer email address")
        }
        
        return result
    }
    
    /// Update customer email address with token
    public func updateCustomerEmailAddress(token: String) async throws -> UpdateCustomerEmailAddressResult {
        let query = """
        mutation updateCustomerEmailAddress($token: String!) {
          updateCustomerEmailAddress(token: $token) {
            __typename
            ... on Success {
              success
            }
            ... on IdentifierChangeTokenInvalidError {
              errorCode
              message
            }
            ... on IdentifierChangeTokenExpiredError {
              errorCode
              message
            }
          }
        }
        """
        
        let variables = ["token": token]
        let response = try await client.mutate(query, variables: variables, responseType: UpdateCustomerEmailAddressResult.self)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Unknown error"])
        }
        
        guard let result = response.data else {
            throw VendureError.networkError("No data returned from update customer email address")
        }
        
        return result
    }
}
