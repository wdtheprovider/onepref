## 0.0.25

### Bug Fixes
- **[Fixed]** `OnePref` — Added `_ensureInitialized()` guard: methods now throw a clear `StateError` when `init()` was not called, instead of silently no-oping.
- **[Fixed]** `OnePref` — All setter methods now correctly return `Future<bool>` instead of untyped `Future`.
- **[Fixed]** `OnePref` — `getBool`, `getInt`, `getDouble` return types changed from nullable (`bool?`, `int?`, `double?`) to non-nullable since they already provide a fallback default.
- **[Fixed]** `Benefit` — Widget fields made `final`; removed unnecessary `// ignore: must_be_immutable` suppression.
- **[Fixed]** `Benefit` — Critical bug: the `icon` constructor parameter was being ignored. `Icons.check` was hardcoded in the build method. Now correctly uses the provided `icon`.
- **[Fixed]** `OnClickAnimation` — Replaced `TickerProviderStateMixin` with `SingleTickerProviderStateMixin` (only one controller is used).
- **[Fixed]** `OnClickAnimation` — `onTap` parameter type changed from untyped `Function` to `VoidCallback`.
- **[Fixed]** `InAppEngine.upgradeOrDowngradeSubscription` — Replaced an unsafe `as` cast that would crash at runtime with a safe `is` type-check.
- **[Fixed]** `InAppEngine.purchaseListener` — Loop now processes all purchases in the list instead of returning after the first item. This fixes batch restore events being silently discarded. Return type changed to `List<PurchaseResult>`.
- **[Fixed]** `pubspec.yaml` — `platforms:` key moved inside the `flutter:` section where it belongs (was incorrectly at top level).
- **[Fixed]** `README.md` — Removed references to `restorePurchases()` and `initPurchaseStream()` which did not exist. Updated all examples to match current APIs.

### New Features
- **[New]** `OnePref.setStringList(String key, List<String> value)` — Saves a list of strings.
- **[New]** `OnePref.getStringList(String key)` — Reads a list of strings.
- **[New]** `OnePref.containsKey(String key)` — Checks if a key exists.
- **[New]** `InAppEngine.restorePurchases()` — Wraps `InAppPurchase.restorePurchases()`. Results arrive via the existing `purchaseStream`.
- **[New]** `InAppEngine.handlePurchase` now returns `Future<bool>` indicating whether the purchase flow was successfully initiated.

## 0.0.24
- update read me file

## 0.0.23
- update docs

## 0.0.22 
- Update packages and resolved some deprecations in the code.
- Fixed some bugs.
- Supporting Google Play Billing Version 8

## 0.0.21

- Update packages and resolved some deprecations in the code.
- Updates in_app_purchase_android to 0.4.0+4
- Fixed bugs
- support 16kb memory page size

## 0.0.20

- Update packages and resolved some deprecations in the code.
- Updates in_app_purchase_android to 0.4.0.

## 0.0.19

- Update packages and resolved some deprecations in the code.
- Updates in_app_purchase_android to 0.4.0.
- Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

- ## 0.0.17

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


