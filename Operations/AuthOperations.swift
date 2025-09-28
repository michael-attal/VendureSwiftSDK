import Foundation

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
        
        let variables: [String: AnyCodable] = [
            "username": AnyCodable(username),
            "password": AnyCodable(password)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Authentication error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let authResult = try decoder.decode(AuthenticationResultWrapper.self, from: response.rawData)
        return authResult.authenticate
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
        
        let variables: [String: AnyCodable] = [
            "uid": AnyCodable(uid),
            "jwt": AnyCodable(jwt)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Firebase authentication error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let authResult = try decoder.decode(AuthenticationResultWrapper.self, from: response.rawData)
        return authResult.authenticate
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
        
        let variables: [String: AnyCodable] = [
            "username": AnyCodable(username),
            "password": AnyCodable(password)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Authentication error"])
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
        
        let variables: [String: AnyCodable] = [
            "uid": AnyCodable(uid),
            "jwt": AnyCodable(jwt)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Firebase authentication error"])
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
        
        let variables: [String: AnyCodable] = [
            "username": AnyCodable(username),
            "password": AnyCodable(password),
            "rememberMe": AnyCodable(rememberMe)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Login error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let loginResult = try decoder.decode(NativeAuthenticationResultWrapper.self, from: response.rawData)
        return loginResult.login
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
        
        let response = try await client.mutateRaw(query, variables: nil)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Logout error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let logoutResult = try decoder.decode(LogoutResultWrapper.self, from: response.rawData)
        return logoutResult.logout
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
        
        let variables: [String: AnyCodable] = [
            "input": AnyCodable(anyValue: input)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Registration error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let registerResult = try decoder.decode(RegisterCustomerAccountResultWrapper.self, from: response.rawData)
        return registerResult.registerCustomerAccount
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
        
        let variables: [String: AnyCodable]
        if let password = password {
            variables = [
                "token": AnyCodable(token),
                "password": AnyCodable(password)
            ]
        } else {
            variables = [
                "token": AnyCodable(token),
                "password": AnyCodable(anyValue: nil as String?)
            ]
        }
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Verification error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let verifyResult = try decoder.decode(VerifyCustomerAccountResultWrapper.self, from: response.rawData)
        return verifyResult.verifyCustomerAccount
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
        
        let variables: [String: AnyCodable] = [
            "currentPassword": AnyCodable(currentPassword),
            "newPassword": AnyCodable(newPassword)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Password update error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let updateResult = try decoder.decode(UpdateCustomerPasswordResultWrapper.self, from: response.rawData)
        return updateResult.updateCustomerPassword
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
        
        let variables: [String: AnyCodable] = [
            "emailAddress": AnyCodable(emailAddress)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Password reset request error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let requestResult = try decoder.decode(RequestPasswordResetResultWrapper.self, from: response.rawData)
        return requestResult.requestPasswordReset
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
        
        let variables: [String: AnyCodable] = [
            "token": AnyCodable(token),
            "password": AnyCodable(password)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Password reset error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let resetResult = try decoder.decode(ResetPasswordResultWrapper.self, from: response.rawData)
        return resetResult.resetPassword
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
        
        let variables: [String: AnyCodable] = [
            "password": AnyCodable(password),
            "newEmailAddress": AnyCodable(newEmailAddress)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Email update request error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let requestResult = try decoder.decode(RequestUpdateCustomerEmailAddressResultWrapper.self, from: response.rawData)
        return requestResult.requestUpdateCustomerEmailAddress
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
        
        let variables: [String: AnyCodable] = [
            "token": AnyCodable(token)
        ]
        
        let response = try await client.mutateRaw(query, variables: variables)
        
        if response.hasErrors {
            throw VendureError.graphqlError(response.errors?.map { $0.message } ?? ["Email update error"])
        }
        
        let decoder = GraphQLClient.createJSONDecoder()
        let updateResult = try decoder.decode(UpdateCustomerEmailAddressResultWrapper.self, from: response.rawData)
        return updateResult.updateCustomerEmailAddress
    }
}

// MARK: - Wrapper Types for GraphQL Responses

// These wrapper types are needed because the GraphQL response wraps the actual data

struct AuthenticationResultWrapper: Codable, Sendable {
    let authenticate: AuthenticationResult
}

struct NativeAuthenticationResultWrapper: Codable, Sendable {
    let login: NativeAuthenticationResult
}

struct LogoutResultWrapper: Codable, Sendable {
    let logout: Success
}

struct RegisterCustomerAccountResultWrapper: Codable, Sendable {
    let registerCustomerAccount: RegisterCustomerAccountResult
}

struct VerifyCustomerAccountResultWrapper: Codable, Sendable {
    let verifyCustomerAccount: VerifyCustomerAccountResult
}

struct UpdateCustomerPasswordResultWrapper: Codable, Sendable {
    let updateCustomerPassword: UpdateCustomerPasswordResult
}

struct RequestPasswordResetResultWrapper: Codable, Sendable {
    let requestPasswordReset: RequestPasswordResetResult
}

struct ResetPasswordResultWrapper: Codable, Sendable {
    let resetPassword: ResetPasswordResult
}

struct RequestUpdateCustomerEmailAddressResultWrapper: Codable, Sendable {
    let requestUpdateCustomerEmailAddress: RequestUpdateCustomerEmailAddressResult
}

struct UpdateCustomerEmailAddressResultWrapper: Codable, Sendable {
    let updateCustomerEmailAddress: UpdateCustomerEmailAddressResult
}
