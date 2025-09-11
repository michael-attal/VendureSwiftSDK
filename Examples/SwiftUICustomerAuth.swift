import SwiftUI
import VendureSwiftSDK

struct CustomerLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var loginResult: String = ""
    @State private var currentCustomer: Customer?
    @State private var vendure: Vendure?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Vendure Customer Login")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: login) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Login")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
            }
            .padding(.horizontal)
            
            if !loginResult.isEmpty {
                Text(loginResult)
                    .multilineTextAlignment(.center)
                    .foregroundColor(loginResult.contains("Success") ? .green : .red)
                    .padding()
            }
            
            if let customer = currentCustomer {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Logged in as:")
                        .font(.headline)
                    
                    Text("Name: \\(customer.firstName) \\(customer.lastName)")
                    Text("Email: \\(customer.emailAddress)")
                    Text("ID: \\(customer.id)")
                    
                    Button("Get Active Order") {
                        Task {
                            await getActiveOrder()
                        }
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button("Logout") {
                        Task {
                            await logout()
                        }
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func login() {
        Task {
            await performLogin()
        }
    }
    
    private func performLogin() async {
        isLoading = true
        loginResult = ""
        
        do {
            // Initialize Vendure with native authentication
            let vendureInstance = try await VendureSwiftSDK.initializeWithNativeAuth(
                endpoint: "https://your-vendure-api.com/shop-api", // Replace with your Vendure API endpoint
                username: email,
                password: password
            )
            
            self.vendure = vendureInstance
            
            // Try to login and get current customer
            let loginResponse = try await vendureInstance.auth.login(
                username: email,
                password: password,
                rememberMe: true
            )
            
            // Handle login result
            switch loginResponse {
            case .currentUser(let user):
                loginResult = "Login successful!"
                
                // Get detailed customer information
                let customer = try await vendureInstance.customer.getActiveCustomer()
                self.currentCustomer = customer
                
            case .invalidCredentialsError(let error):
                loginResult = "Login failed: \\(error.message)"
                
            case .notVerifiedError(let error):
                loginResult = "Account not verified: \\(error.message)"
            }
            
        } catch VendureError.networkError(let message) {
            loginResult = "Network error: \\(message)"
        } catch VendureError.graphqlError(let errors) {
            loginResult = "GraphQL errors: \\(errors.joined(separator: ", "))"
        } catch {
            loginResult = "Unexpected error: \\(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func getActiveOrder() async {
        guard let vendure = vendure else { return }
        
        do {
            let order = try await vendure.order.getActiveOrder()
            if let order = order {
                loginResult = "Active order found: \\(order.code)"
            } else {
                loginResult = "No active order"
            }
        } catch {
            loginResult = "Error getting order: \\(error.localizedDescription)"
        }
    }
    
    private func logout() async {
        guard let vendure = vendure else { return }
        
        do {
            let result = try await vendure.auth.logout()
            if result.success {
                loginResult = "Logged out successfully"
                currentCustomer = nil
                self.vendure = nil
                email = ""
                password = ""
            }
        } catch {
            loginResult = "Logout error: \\(error.localizedDescription)"
        }
    }
}

// Alternative login approach using direct authentication
struct AlternativeCustomerLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var loginResult: String = ""
    @State private var currentCustomer: Customer?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Alternative Login Method")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: authenticateUser) {
                    Text("Authenticate")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
            }
            .padding(.horizontal)
            
            if !loginResult.isEmpty {
                Text(loginResult)
                    .multilineTextAlignment(.center)
                    .foregroundColor(loginResult.contains("Success") ? .green : .red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func authenticateUser() {
        Task {
            isLoading = true
            loginResult = ""
            
            do {
                // Initialize Vendure with basic configuration
                let vendure = try await VendureSwiftSDK.initialize(
                    endpoint: "https://your-vendure-api.com/shop-api" // Replace with your endpoint
                )
                
                // Authenticate using the auth operations
                let authResult = try await vendure.auth.authenticate(
                    username: email,
                    password: password
                )
                
                // Handle authentication result
                switch authResult {
                case .currentUser(let user):
                    loginResult = "Authentication successful! User ID: \\(user.id)"
                    
                    // Get customer details
                    let customer = try await vendure.customer.getActiveCustomer()
                    self.currentCustomer = customer
                    
                case .invalidCredentialsError(let error):
                    loginResult = "Authentication failed: \\(error.message)"
                }
                
            } catch {
                loginResult = "Authentication error: \\(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
}

// Complete example with registration
struct CustomerRegistrationView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var registrationResult: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Customer Registration")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: registerCustomer) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Register")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading || firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty)
            }
            .padding(.horizontal)
            
            if !registrationResult.isEmpty {
                Text(registrationResult)
                    .multilineTextAlignment(.center)
                    .foregroundColor(registrationResult.contains("Success") ? .green : .red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func registerCustomer() {
        Task {
            isLoading = true
            registrationResult = ""
            
            do {
                // Initialize Vendure
                let vendure = try await VendureSwiftSDK.initialize(
                    endpoint: "https://your-vendure-api.com/shop-api"
                )
                
                // Create registration input
                let registrationInput = RegisterCustomerInput(
                    firstName: firstName,
                    lastName: lastName,
                    emailAddress: email,
                    password: password
                )
                
                // Register customer
                let result = try await vendure.auth.registerCustomerAccount(input: registrationInput)
                
                switch result {
                case .success(let success):
                    if success.success {
                        registrationResult = "Registration successful! Please check your email for verification."
                    }
                case .missingPasswordError(let error):
                    registrationResult = "Password required: \\(error.message)"
                case .passwordValidationError(let error):
                    registrationResult = "Password validation failed: \\(error.message)"
                case .nativeAuthStrategyError(let error):
                    registrationResult = "Auth strategy error: \\(error.message)"
                }
                
            } catch {
                registrationResult = "Registration failed: \\(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
}

#Preview {
    NavigationView {
        TabView {
            CustomerLoginView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Login")
                }
            
            AlternativeCustomerLoginView()
                .tabItem {
                    Image(systemName: "key")
                    Text("Auth")
                }
            
            CustomerRegistrationView()
                .tabItem {
                    Image(systemName: "person.badge.plus")
                    Text("Register")
                }
        }
    }
}
