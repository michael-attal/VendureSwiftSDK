import Foundation

/// Logging levels for VendureSwiftSDK
public enum VendureLogLevel: Int, CaseIterable, Sendable {
    case none = 0
    case error = 1
    case warning = 2
    case info = 3
    case debug = 4
    case verbose = 5
    
    public var prefix: String {
        switch self {
        case .none: return ""
        case .error: return "❌ [VendureSDK]"
        case .warning: return "⚠️  [VendureSDK]"
        case .info: return "ℹ️  [VendureSDK]"
        case .debug: return "🔍 [VendureSDK]"
        case .verbose: return "📝 [VendureSDK]"
        }
    }
}

/// Centralized logger for VendureSwiftSDK
public actor VendureLogger {
    public static let shared = VendureLogger()
    
    private var currentLevel: VendureLogLevel = .none
    private var enabledCategories: Set<String> = []
    
    private init() {}
    
    /// Configure the logging level
    /// - Parameter level: The minimum log level to output
    public func setLogLevel(_ level: VendureLogLevel) {
        currentLevel = level
        if level != .none {
            log(.info, category: "Logger", "Logging enabled at level: \(level)")
        }
    }
    
    /// Enable logging for specific categories
    /// - Parameter categories: Array of category names to enable logging for
    public func enableCategories(_ categories: [String]) {
        enabledCategories = Set(categories)
        log(.info, category: "Logger", "Enabled logging for categories: \(categories)")
    }
    
    /// Enable logging for all categories
    public func enableAllCategories() {
        enabledCategories = ["*"]
        log(.info, category: "Logger", "Enabled logging for all categories")
    }
    
    /// Disable logging for specific categories
    /// - Parameter categories: Array of category names to disable logging for
    public func disableCategories(_ categories: [String]) {
        for category in categories {
            enabledCategories.remove(category)
        }
        log(.info, category: "Logger", "Disabled logging for categories: \(categories)")
    }
    
    /// Log a message
    /// - Parameters:
    ///   - level: The log level
    ///   - category: The category for filtering (e.g., "GraphQL", "HTTP", "Decode")
    ///   - message: The message to log
    ///   - file: Source file name
    ///   - function: Source function name
    ///   - line: Source line number
    public func log(
        _ level: VendureLogLevel,
        category: String,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard currentLevel != .none && level.rawValue <= currentLevel.rawValue else { return }
        guard enabledCategories.contains("*") || enabledCategories.contains(category) else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        
        print("\(timestamp) \(level.prefix) [\(category)] \(message) (\(fileName):\(line))")
    }
    
    /// Log a message with additional context data
    public func log(
        _ level: VendureLogLevel,
        category: String,
        _ message: String,
        context: [String: Any],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let contextString = context.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        log(level, category: category, "\(message) | \(contextString)", file: file, function: function, line: line)
    }
    
    /// Get current log level
    public func getLogLevel() -> VendureLogLevel {
        return currentLevel
    }
    
    /// Get enabled categories
    public func getEnabledCategories() -> Set<String> {
        return enabledCategories
    }
}

// MARK: - Convenience functions for easier logging

/// Global logging convenience functions
public func vendureLog(
    _ level: VendureLogLevel,
    category: String,
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Task { @Sendable in
        await VendureLogger.shared.log(level, category: category, message, file: file, function: function, line: line)
    }
}

public func vendureLog(
    _ level: VendureLogLevel,
    category: String,
    _ message: String,
    context: [String: Any],
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    // Convert context to sendable string representation before capturing in closure
    let contextString = context.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    let enhancedMessage = contextString.isEmpty ? message : "\(message) | \(contextString)"
    
    Task { @Sendable in
        await VendureLogger.shared.log(level, category: category, enhancedMessage, file: file, function: function, line: line)
    }
}

// MARK: - Category-specific convenience functions

public func vendureLogError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    vendureLog(.error, category: "General", message, file: file, function: function, line: line)
}

public func vendureLogWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    vendureLog(.warning, category: "General", message, file: file, function: function, line: line)
}

public func vendureLogInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    vendureLog(.info, category: "General", message, file: file, function: function, line: line)
}

public func vendureLogDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    vendureLog(.debug, category: "General", message, file: file, function: function, line: line)
}

// MARK: - Date formatter extension

private extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}