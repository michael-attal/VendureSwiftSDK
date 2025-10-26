import Foundation

// MARK: - Lists (deprecated aliases to generic PaginatedList)

@available(*, deprecated, message: "Use PaginatedList<Product> instead")
public typealias CatalogProductList = PaginatedList<Product>

@available(*, deprecated, message: "Use PaginatedList<Product> instead")
public typealias ProductList = PaginatedList<Product>

@available(*, deprecated, message: "Use PaginatedList<ProductVariant> instead")
public typealias ProductVariantList = PaginatedList<ProductVariant>

@available(*, deprecated, message: "Use PaginatedList<VendureCollection> instead")
public typealias CollectionList = PaginatedList<VendureCollection>

@available(*, deprecated, message: "Use PaginatedList<Facet> instead")
public typealias FacetList = PaginatedList<Facet>

@available(*, deprecated, message: "Use PaginatedList<Asset> instead")
public typealias AssetList = PaginatedList<Asset>

@available(*, deprecated, message: "Use PaginatedList<Order> instead")
public typealias OrderList = PaginatedList<Order>

@available(*, deprecated, message: "Use PaginatedList<HistoryEntry> instead")
public typealias HistoryEntryList = PaginatedList<HistoryEntry>

@available(*, deprecated, message: "Use PaginatedList<Promotion> instead")
public typealias PromotionList = PaginatedList<Promotion>

@available(*, deprecated, message: "Use PaginatedList<ShippingMethod> instead")
public typealias ShippingMethodList = PaginatedList<ShippingMethod>

@available(*, deprecated, message: "Use PaginatedList<TaxRate> instead")
public typealias TaxRateList = PaginatedList<TaxRate>

@available(*, deprecated, message: "Use PaginatedList<TaxCategory> instead")
public typealias TaxCategoryList = PaginatedList<TaxCategory>

@available(*, deprecated, message: "Use PaginatedList<Customer> instead")
public typealias CustomerList = PaginatedList<Customer>

@available(*, deprecated, message: "Use PaginatedList<Role> instead")
public typealias RoleList = PaginatedList<Role>

@available(*, deprecated, message: "Use IneligibleMethodError instead")
public typealias IneligibleShippingMethodError = IneligibleMethodError

@available(*, deprecated, message: "Use IneligibleMethodError instead")
public typealias IneligiblePaymentMethodError = IneligibleMethodError

/// Product translation (name, slug, description)
@available(*, deprecated, message: "Use Translation<TranslationContentNameSlugDescription> instead")
public typealias ProductTranslation = Translation<TranslationContentNameSlugDescription>

/// Product variant translation (name)
@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias ProductVariantTranslation = Translation<TranslationContentName>

/// Product option translation (name)
@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias ProductOptionTranslation = Translation<TranslationContentName>

/// Product option group translation (name)
@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias ProductOptionGroupTranslation = Translation<TranslationContentName>

@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias CountryTranslation = Translation<TranslationContentName>

@available(*, deprecated, message: "Use Translation<TranslationContentNameSlugDescription> instead")
public typealias VendureCollectionTranslation = Translation<TranslationContentNameSlugDescription>

@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias FacetTranslation = Translation<TranslationContentName>

@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias FacetValueTranslation = Translation<TranslationContentName>

@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias RegionTranslation = Translation<TranslationContentName>

@available(*, deprecated, message: "Use Translation<TranslationContentNameDescription> instead")
public typealias PaymentMethodTranslation = Translation<TranslationContentNameDescription>

@available(*, deprecated, message: "Use Translation<TranslationContentNameDescription> instead")
public typealias PromotionTranslation = Translation<TranslationContentNameDescription>

@available(*, deprecated, message: "Use Translation<TranslationContentNameDescription> instead")
public typealias ShippingMethodTranslation = Translation<TranslationContentNameDescription>

// MARK: - Type Aliases for Specific Errors

// Order Related Errors
@available(*, deprecated, message: "Use VendureErrorType<InsufficientStockDetails> instead")
public typealias InsufficientStockError = VendureErrorType<InsufficientStockDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias NegativeQuantityError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<OrderLimitDetails> instead")
public typealias OrderLimitError = VendureErrorType<OrderLimitDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias OrderModificationError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias OrderPaymentStateError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<OrderStateTransitionDetails> instead")
public typealias OrderStateTransitionError = VendureErrorType<OrderStateTransitionDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias NoActiveOrderError = VendureErrorType<EmptyErrorDetails>

// Authentication Errors
@available(*, deprecated, message: "Use VendureErrorType<AuthenticationErrorDetails> instead")
public typealias InvalidCredentialsError = VendureErrorType<AuthenticationErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias AlreadyLoggedInError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias MissingPasswordError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias PasswordAlreadySetError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<PasswordValidationDetails> instead")
public typealias PasswordValidationError = VendureErrorType<PasswordValidationDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias PasswordResetTokenExpiredError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias PasswordResetTokenInvalidError = VendureErrorType<EmptyErrorDetails>

// Customer Errors
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias EmailAddressConflictError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias NotVerifiedError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias VerificationTokenExpiredError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias VerificationTokenInvalidError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias IdentifierChangeTokenExpiredError = VendureErrorType<EmptyErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias IdentifierChangeTokenInvalidError = VendureErrorType<EmptyErrorDetails>

// Guest Checkout Error
@available(*, deprecated, message: "Use VendureErrorType<GuestCheckoutDetails> instead")
public typealias GuestCheckoutError = VendureErrorType<GuestCheckoutDetails>

// Native Auth Strategy Error
@available(*, deprecated, message: "Use VendureErrorType<EmptyErrorDetails> instead")
public typealias NativeAuthStrategyError = VendureErrorType<EmptyErrorDetails>

// Generic Ineligible Method Error
@available(*, deprecated, message: "Use IneligibleMethodError instead")
public typealias IneligibleMethodError = VendureErrorType<IneligibleMethodDetails>

// Payment Errors
@available(*, deprecated, message: "Use VendureErrorType<PaymentErrorDetails> instead")
public typealias PaymentDeclinedError = VendureErrorType<PaymentErrorDetails>
@available(*, deprecated, message: "Use VendureErrorType<PaymentErrorDetails> instead")
public typealias PaymentFailedError = VendureErrorType<PaymentErrorDetails>

// Coupon Code Errors
@available(*, deprecated, message: "Use VendureErrorType<CouponCodeDetails> instead")
public typealias CouponCodeExpiredError = VendureErrorType<CouponCodeDetails>
@available(*, deprecated, message: "Use VendureErrorType<CouponCodeDetails> instead")
public typealias CouponCodeInvalidError = VendureErrorType<CouponCodeDetails>
@available(*, deprecated, message: "Use VendureErrorType<CouponCodeLimitDetails> instead")
public typealias CouponCodeLimitError = VendureErrorType<CouponCodeLimitDetails>
