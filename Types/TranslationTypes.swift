import Foundation

// MARK: - Generic Translation Wrapper

/// Generic translation container for any translatable content.
/// - `Content` should contain only the translatable fields (e.g. `name`, `slug`, `description`).
public struct Translation<TranslationContent: Codable & Hashable & Sendable>: Codable, Hashable, Sendable {
    /// Language of the translation
    public let languageCode: LanguageCode

    /// The translated fields for that language (name, slug, description, ...).
    public let content: TranslationContent

    public init(languageCode: LanguageCode, content: TranslationContent) {
        self.languageCode = languageCode
        self.content = content
    }
}

// MARK: - Common translation content helpers

/// Translation content with only `name`.
public struct TranslationContentName: Codable, Hashable, Sendable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

/// Translation content with `name` and `slug`.
public struct TranslationContentNameSlug: Codable, Hashable, Sendable {
    public let name: String
    public let slug: String

    public init(name: String, slug: String) {
        self.name = name
        self.slug = slug
    }
}

/// Translation content with `name` and `description`.
public struct TranslationContentNameDescription: Codable, Hashable, Sendable {
    public let name: String
    public let description: String

    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}

/// Translation content with `name`, `slug` and `description`.
public struct TranslationContentNameSlugDescription: Codable, Hashable, Sendable {
    public let name: String
    public let slug: String
    public let description: String

    public init(name: String, slug: String, description: String) {
        self.name = name
        self.slug = slug
        self.description = description
    }
}

/// Generic convenience aliases if needed:
public typealias SimpleNameTranslation = Translation<TranslationContentName>
public typealias NameSlugTranslation = Translation<TranslationContentNameSlug>
