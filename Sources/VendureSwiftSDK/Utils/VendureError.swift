import Foundation

public enum VendureError: Error, CustomStringConvertible {
    case networkError(String)
    case httpError(Int, String)
    case graphqlError([String])
    case decodingError(Error)
    case initializationError(String)
    case tokenMissing

    public var description: String {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .httpError(let status, let body):
            return "HTTP error \(status): \(body)"
        case .graphqlError(let messages):
            return "GraphQL error: \(messages.joined(separator: "; "))"
        case .decodingError(let error):
            return "Decoding error: \(error)"
        case .initializationError(let message):
            return "Initialization error: \(message)"
        case .tokenMissing:
            return "Authentication token is missing"
        }
    }
}

