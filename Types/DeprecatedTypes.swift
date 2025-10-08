//
// DeprecatedTypes.swift
// VendureSwiftSDK
//
// This file provides deprecated aliases for the old, pre-refactor types.
// Keep this file temporarily to ease migration: it maps old type names to the new generic implementations (PaginatedList, PaginatedListOptions,FilterParameter, SortParameter). All aliases are marked deprecated so that the compiler will warn consumers to migrate to the generic types.
//

import Foundation

// MARK: - Lists (deprecated aliases to generic PaginatedList)

@available(*, deprecated, message: "Use PaginatedList<CatalogProduct> instead")
public typealias CatalogProductList = PaginatedList<Product>

@available(*, deprecated, message: "Use PaginatedList<Product> instead")
public typealias ProductList = PaginatedList<Product>

@available(*, deprecated, message: "Use PaginatedList<ProductVariant> instead")
public typealias ProductVariantList = PaginatedList<ProductVariant>

@available(*, deprecated, message: "Use PaginatedList<VendureCollection> instead")
public typealias CollectionList = PaginatedList<VendureCollection>

@available(*, deprecated, message: "Use PaginatedList<Facet> instead")
public typealias FacetList = PaginatedList<Facet>

// MARK: - Legacy options (deprecated aliases to generic PaginatedListOptions)

@available(*, deprecated, message: "Use PaginatedListOptions<FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>, SortParameter<SortOrder>> instead")
public typealias ProductListOptions = PaginatedListOptions<
    FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
    SortParameter<SortOrder>
>

@available(*, deprecated, message: "Use PaginatedListOptions<FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>, SortParameter<SortOrder>> instead (or a wrapper with topLevelOnly if needed)")
public typealias VendureCollectionListOptions = PaginatedListOptions<
    FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
    SortParameter<SortOrder>
>

@available(*, deprecated, message: "Use PaginatedListOptions<FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>, SortParameter<SortOrder>> instead")
public typealias FacetListOptions = PaginatedListOptions<
    FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
    SortParameter<SortOrder>
>

// MARK: - Deprecated FilterParameter aliases (map to generic FilterParameter)

@available(*, deprecated, message: "Use FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators> instead")
public typealias ProductFilterParameter = FilterParameter<
    IDOperators,
    DateOperators,
    StringOperators,
    NumberOperators,
    BooleanOperators
>

@available(*, deprecated, message: "Use FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators> instead")
public typealias VendureCollectionFilterParameter = FilterParameter<
    IDOperators,
    DateOperators,
    StringOperators,
    NumberOperators,
    BooleanOperators
>

@available(*, deprecated, message: "Use FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators> instead")
public typealias FacetFilterParameter = FilterParameter<
    IDOperators,
    DateOperators,
    StringOperators,
    NumberOperators,
    BooleanOperators
>

// MARK: - Deprecated SortParameter aliases (map to generic SortParameter)

@available(*, deprecated, message: "Use SortParameter<SortOrder> instead")
public typealias ProductSortParameter = SortParameter<SortOrder>

@available(*, deprecated, message: "Use SortParameter<SortOrder> instead")
public typealias VendureCollectionSortParameter = SortParameter<SortOrder>

@available(*, deprecated, message: "Use SortParameter<SortOrder> instead")
public typealias FacetSortParameter = SortParameter<SortOrder>

// MARK: - Convenience aliases for other legacy lists/options (orders, assets, customers)

@available(*, deprecated, message: "Use PaginatedList<Asset> instead")
public typealias AssetList = PaginatedList<Asset>

@available(*, deprecated, message: "Use PaginatedListOptions<FilterParameter<...>, SortParameter<...>> instead")
public typealias AssetListOptions = PaginatedListOptions<
    FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
    SortParameter<SortOrder>
>

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

@available(*, deprecated, message: "Use PaginatedListOptions<FilterParameter<...>, SortParameter<...>> instead")
public typealias OrderListOptions = PaginatedListOptions<
    FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
    SortParameter<SortOrder>
>

@available(*, deprecated, message: "Use PaginatedList<Customer> instead")
public typealias CustomerList = PaginatedList<Customer>

@available(*, deprecated, message: "Use PaginatedList<Role> instead")
public typealias RoleList = PaginatedList<Role>

@available(*, deprecated, message: "Use PaginatedListOptions<FilterParameter<...>, SortParameter<...>> instead")
public typealias CustomerListOptions = PaginatedListOptions<
    FilterParameter<IDOperators, DateOperators, StringOperators, NumberOperators, BooleanOperators>,
    SortParameter<SortOrder>
>

/// Product translation (name, slug, description)
@available(*, deprecated, message: "Use Translation<TranslationContentNameSlugDescription> instead")
public typealias ProductTranslation = Translation<TranslationContentNameSlugDescription>

/// Product variant translation (name)
@available(*, deprecated, message: "Use Translation<TranslationContentName> instead")
public typealias ProductVariantTranslation = Translation<TranslationContentName>

/// Product option translation (name)
@available(*, deprecated, message: "Use Translation<ProductOptionTranslation> instead")
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

// MARK: - Backwards compatibility helpers (optional)

/*
 If any code expects the old concrete structs (with initializers), you can
 keep the deprecated typealiases above and add small compatibility inits or
 helper converters where necessary.

 Example helper to convert old explicit struct usage to new generic (if needed):

 extension PaginatedList where Item == Product {
     @available(*, deprecated, message: "Construct PaginatedList<Product> directly")
     public init(oldItems: [Product], oldTotalItems: Int) {
         self.init(items: oldItems, totalItems: oldTotalItems)
     }
 }

 Use such helpers sparingly; prefer migrating call-sites to PaginatedList<T>.
 */

// End of DeprecatedTypes.swift
