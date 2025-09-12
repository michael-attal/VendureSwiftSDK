import Foundation

/// Logging configuration for VendureSwiftSDK
public struct VendureLoggingConfig {
    
    /// Initialize logging with verbose output for debugging
    public static func enableDebugLogging() {
        Task {
            await VendureLogger.shared.setLogLevel(.verbose)
            await VendureLogger.shared.enableAllCategories()
        }
    }
    
    /// Initialize logging with only error and warning output
    public static func enableProductionLogging() {
        Task {
            await VendureLogger.shared.setLogLevel(.warning)
            await VendureLogger.shared.enableCategories(["GraphQL", "HTTP", "General"])
        }
    }
    
    /// Initialize logging with info level for general use
    public static func enableInfoLogging() {
        Task {
            await VendureLogger.shared.setLogLevel(.info)
            await VendureLogger.shared.enableCategories(["GraphQL", "HTTP", "CustomOps", "General"])
        }
    }
    
    /// Disable all logging
    public static func disableLogging() {
        Task {
            await VendureLogger.shared.setLogLevel(.none)
        }
    }
    
    /// Configure custom logging
    /// - Parameters:
    ///   - level: The minimum log level to output
    ///   - categories: Specific categories to enable (or empty array to disable all)
    public static func configureLogging(level: VendureLogLevel, categories: [String] = []) {
        Task {
            await VendureLogger.shared.setLogLevel(level)
            if categories.isEmpty {
                await VendureLogger.shared.enableAllCategories()
            } else {
                await VendureLogger.shared.enableCategories(categories)
            }
        }
    }
}

/// Common logging categories used throughout VendureSwiftSDK
public enum VendureLoggingCategory {
    public static let graphql = "GraphQL"
    public static let http = "HTTP" 
    public static let decode = "Decode"
    public static let customOps = "CustomOps"
    public static let general = "General"
    public static let products = "Products"
    public static let orders = "Orders"
    public static let auth = "Auth"
}