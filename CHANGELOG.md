## 0.0.5

Added
- `setPremium(bool v)`
- `setRemoveAds(bool v)`
- `getPremium()`
- `getRemoveAds()`

## 0.0.6
fixes

## 0.0.7

Added new functions
- `getIsAvailable()` - to check if the In App Purchase system is available and ready to return products.
- `queryProducts( List<ProductId> storeProductIds)` - to get products from Store and return a `ProductDetailsResponse`
- `handlePurchase(ProductDetails productDetails, List<ProductId> storeProductIds)` - to launch the Purchase Flow for users to subscribe or buy your product.
- `getProductIdsOnly( List<ProductId> storeProductIds)` - this function only returns a list<String> of product Ids

Added new classes
 - ``ProductId`` - to define the products
## 0.0.8
Added example