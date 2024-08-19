## 0.0.17

- Update packages and resolved some deprecations in the code.

## 0.0.16

- [Add] a purchasedListener in the IApEngine to minimize the codes (Check the example).
- [Updated] added try catches for more debugging benefits.
- [Fixed] fixed some minor bugs.

## 0.0.15

- [Updated] packages to include Response code 12 for network error.

## 0.0.14
- [Updated] Updated the example to solve the one time purchase getting canceled, Please read the comments I added for clear understanding.


## 0.0.13
- [Updated] Updated packages
- [New] Added subscription Upgrade/Downgrade
- [New] Added support for iOS and MacOS
- [Updated] Updated the example

## 0.0.11
Updated ProductId class  
- bool? isSubscription;
- bool? isOneTimePurchase;

## 0.0.10
Updated packages

## 0.0.9
added debugs messages

## 0.0.8
Added example

## 0.0.7

Added new functions
- `getIsAvailable()` - to check if the In App Purchase system is available and ready to return products.
- `queryProducts( List<ProductId> storeProductIds)` - to get products from Store and return a `ProductDetailsResponse`
- `handlePurchase(ProductDetails productDetails, List<ProductId> storeProductIds)` - to launch the Purchase Flow for users to subscribe or buy your product.
- `getProductIdsOnly( List<ProductId> storeProductIds)` - this function only returns a list<String> of product Ids

Added new classes
- ``ProductId`` - to define the products

## 0.0.6
fixes

## 0.0.5

Added
- `setPremium(bool v)`
- `setRemoveAds(bool v)`
- `getPremium()`
- `getRemoveAds()`


