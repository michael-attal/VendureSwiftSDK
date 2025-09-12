# VendureSwiftSDK Utilities

## VendureLogger

The VendureLogger provides centralized logging capabilities for the VendureSwiftSDK, allowing you to debug GraphQL queries, HTTP requests, decoding operations, and more.

### Features

- **Configurable Log Levels**: None, Error, Warning, Info, Debug, Verbose
- **Category-based Filtering**: Enable logging for specific components (GraphQL, HTTP, Decode, etc.)
- **Thread-safe**: Uses Swift actors for safe concurrent access
- **Contextual Information**: Includes timestamps, file names, and line numbers

### Usage

#### Quick Setup

```swift
import VendureSwiftSDK

// Enable debug logging for all categories
VendureLoggingConfig.enableDebugLogging()

// Enable info-level logging for specific categories
VendureLoggingConfig.enableInfoLogging()

// Production-safe logging (warnings and errors only)
VendureLoggingConfig.enableProductionLogging()

// Disable all logging
VendureLoggingConfig.disableLogging()
```

#### Custom Configuration

```swift
// Configure specific log level and categories
VendureLoggingConfig.configureLogging(
    level: .debug,
    categories: ["GraphQL", "HTTP", "CustomOps"]
)
```

#### Manual Logger Usage

```swift
// Using the direct logger API
Task {
    await VendureLogger.shared.setLogLevel(.verbose)
    await VendureLogger.shared.enableCategories(["GraphQL", "Decode"])
}

// Log messages directly
vendureLog(.info, category: "MyComponent", "Custom log message")
vendureLogError("Something went wrong")
vendureLogDebug("Debug information")
```

### Log Categories

The SDK uses these predefined categories:

- **GraphQL**: GraphQL query execution and responses
- **HTTP**: HTTP request/response details
- **Decode**: JSON decoding operations
- **CustomOps**: Custom operations and data extraction
- **General**: General purpose logging
- **Products**: Product-related operations
- **Orders**: Order management operations  
- **Auth**: Authentication operations

### Log Levels

- **None**: No logging
- **Error**: Only errors and critical issues
- **Warning**: Warnings and errors
- **Info**: General information, warnings, and errors
- **Debug**: Debug information and above
- **Verbose**: All logging including detailed data dumps

### Example Output

```
2025-09-09 13:45:23.456 ℹ️  [VendureSDK] [GraphQL] Executing query: query getProducts($options: ProductListOptions) { products(options: $options) { items { id name... (GraphQLClient.swift:196)
2025-09-09 13:45:23.478 🔍 [VendureSDK] [HTTP] Making request to: https://demo.vendure.io/shop-api (GraphQLClient.swift:216)  
2025-09-09 13:45:23.612 🔍 [VendureSDK] [HTTP] Response status: 200 (GraphQLClient.swift:225)
2025-09-09 13:45:23.615 🔍 [VendureSDK] [Decode] Successfully decoded response (GraphQLClient.swift:241)
2025-09-09 13:45:23.618 ℹ️  [VendureSDK] [CustomOps] Executing custom query with expectedDataType: products (CustomOperations.swift:50)
```

### Integration with Backend Services

The logger integrates seamlessly with your backend services:

```swift
// In your main.swift or service initialization
import VendureSwiftSDK

// Enable logging during development
#if DEBUG
VendureLoggingConfig.enableDebugLogging()
#else
VendureLoggingConfig.enableProductionLogging()
#endif
```

### Performance Considerations

- Logging is completely disabled when set to `.none` level
- Category filtering happens at log time, so disabled categories have minimal overhead
- Verbose logging can generate significant output - use sparingly in production
- The logger uses Swift actors for thread safety with minimal performance impact

### Best Practices

1. Use `.debug` or `.verbose` only during development
2. Enable specific categories rather than all categories in production
3. Use `.warning` or `.error` levels for production logging
4. Disable logging entirely for release builds if not needed
5. Use contextual logging with the `context` parameter for structured debugging