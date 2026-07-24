import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';
import 'package:onepref/onepref.dart';

/// Represents the structured result of a single purchase or restore operation.
///
/// Returned by [InAppEngine.purchaseListener] — one instance per processed
/// [PurchaseDetails] in the stream event.
class PurchaseResult {
  /// The store product ID that was processed, if available.
  final String? productId;

  /// `true` when the purchase flow completed and [InAppPurchase.completePurchase]
  /// was called successfully.
  final bool? purchaseComplete;

  /// `true` when an Android consumable was successfully consumed via
  /// [InAppPurchaseAndroidPlatformAddition.consumePurchase].
  final bool? purchaseConsumed;

  /// `true` when a previously purchased product was restored.
  final bool? purchaseRestore;

  /// A human-readable status or error message. Populated on errors and
  /// unhandled states.
  final String? message;

  /// Creates a [PurchaseResult].
  const PurchaseResult({
    this.productId,
    this.purchaseComplete,
    this.purchaseConsumed,
    this.purchaseRestore,
    this.message,
  });

  /// Creates a [PurchaseResult] representing a failed purchase with [message].
  factory PurchaseResult.error(String message) =>
      PurchaseResult(message: message);
}

/// A Singleton engine for managing in-app purchases across Android and iOS.
///
/// Use [InAppEngine.instance] to access the shared instance. Never instantiate
/// directly.
///
/// ### Typical usage
///
/// ```dart
/// final engine = InAppEngine.instance;
///
/// // 1. Listen for purchase updates in initState
/// engine.inAppPurchase.purchaseStream.listen((purchaseDetailsList) async {
///   final results = await engine.purchaseListener(
///     purchaseDetailsList: purchaseDetailsList,
///     productsIds: storeProductIds,
///   );
///   for (final r in results) {
///     if (r.purchaseComplete == true) await OnePref.setPremium(true);
///   }
/// });
///
/// // 2. Query products
/// final response = await engine.queryProducts(storeProductIds);
///
/// // 3. Buy a product
/// await engine.handlePurchase(response.productDetails.first, storeProductIds);
/// ```
class InAppEngine {
  /// Private constructor — use [InAppEngine.instance].
  InAppEngine._();

  /// The shared singleton instance of [InAppEngine].
  static final InAppEngine instance = InAppEngine._();

  /// Direct access to the underlying [InAppPurchase] plugin instance.
  ///
  /// Use this to subscribe to [InAppPurchase.purchaseStream].
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  /// Logs [message] to the console in debug mode only.
  void log(String message) {
    if (kDebugMode) {
      debugPrint("InAppEngineDebug: $message");
    }
  }

  /// Returns `true` if the device's store (Google Play / App Store) is
  /// available and ready to serve products.
  ///
  /// Always check this before calling [queryProducts] or [handlePurchase].
  Future<bool> getIsAvailable() async {
    try {
      return await inAppPurchase.isAvailable();
    } catch (e) {
      log("Error checking store availability: $e");
      return false;
    }
  }

  /// Queries the store for the product details of the given [storeProductIds].
  ///
  /// Returns a [ProductDetailsResponse] which contains the matched
  /// [ProductDetailsResponse.productDetails] and any
  /// [ProductDetailsResponse.notFoundIDs].
  ///
  /// Throws if the underlying platform call fails.
  Future<ProductDetailsResponse> queryProducts(
    List<InAppEngineProductId> storeProductIds,
  ) async {
    try {
      return await inAppPurchase.queryProductDetails(
        getProductIdsOnly(storeProductIds).toSet(),
      );
    } catch (e) {
      log("Error querying products: $e");
      rethrow;
    }
  }

  /// Initiates the native purchase flow for [productDetails].
  ///
  /// The [storeProductIds] list is used to determine whether the product is
  /// consumable and to build the correct [PurchaseParam] for the platform.
  ///
  /// Returns `true` if the purchase flow was successfully launched, or `false`
  /// if [productDetails] was not found in [storeProductIds] or an error occurred.
  ///
  /// Listen to [inAppPurchase.purchaseStream] and pass updates to
  /// [purchaseListener] to handle the result.
  Future<bool> handlePurchase(
    ProductDetails productDetails,
    List<InAppEngineProductId> storeProductIds,
  ) async {
    try {
      final purchaseParam = Platform.isAndroid
          ? GooglePlayPurchaseParam(
              productDetails: productDetails,
              applicationUserName: null,
            )
          : PurchaseParam(
              productDetails: productDetails,
              applicationUserName: null,
            );

      for (final product in storeProductIds) {
        if (product.id == productDetails.id) {
          if (product.isConsumable) {
            log("Buying consumable product: ${productDetails.id}");
            await inAppPurchase.buyConsumable(
              purchaseParam: purchaseParam,
              autoConsume: product.isConsumable,
            );
          } else {
            log("Buying non-consumable product: ${productDetails.id}");
            await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
          }
          return true;
        }
      }
      log("Product ${productDetails.id} not found in storeProductIds.");
      return false;
    } catch (e) {
      log("Error during purchase: $e");
      return false;
    }
  }

  /// Extracts and returns only the string IDs from [storeProductIds].
  ///
  /// Useful when you need a plain `List<String>` for other APIs.
  List<String> getProductIdsOnly(List<InAppEngineProductId> storeProductIds) =>
      storeProductIds.map((e) => e.id).toList();

  /// Upgrades or downgrades an active Android subscription.
  ///
  /// [currentSubPurchaseDetails] must be a [GooglePlayPurchaseDetails] instance
  /// of the subscription the user currently holds.
  /// [newSubProductDetails] is the target subscription tier.
  ///
  /// Returns `true` if the upgrade/downgrade flow was successfully initiated.
  ///
  /// Always returns `false` on non-Android platforms.
  Future<bool> upgradeOrDowngradeSubscription(
    PurchaseDetails currentSubPurchaseDetails,
    ProductDetails newSubProductDetails,
  ) async {
    if (!Platform.isAndroid) {
      log("Subscription change is only supported on Android.");
      return false;
    }

    // Safe type check before casting to avoid a CastError at runtime.
    if (currentSubPurchaseDetails is! GooglePlayPurchaseDetails) {
      log(
        "upgradeOrDowngradeSubscription: currentSubPurchaseDetails is not a "
        "GooglePlayPurchaseDetails instance.",
      );
      return false;
    }

    try {
      log("Upgrading/downgrading subscription...");
      final purchaseParam = GooglePlayPurchaseParam(
        productDetails: newSubProductDetails,
        changeSubscriptionParam: ChangeSubscriptionParam(
          oldPurchaseDetails: currentSubPurchaseDetails,
          replacementMode: ReplacementMode.chargeProratedPrice,
        ),
      );

      await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      log("Error upgrading/downgrading subscription: $e");
      return false;
    }
  }

  /// Triggers a restore of all previous purchases from the store.
  ///
  /// The restored purchases are delivered asynchronously through
  /// [inAppPurchase.purchaseStream] with a status of [PurchaseStatus.restored].
  /// Pass those updates to [purchaseListener] to process them.
  Future<void> restorePurchases() async {
    try {
      log("Restoring purchases...");
      await inAppPurchase.restorePurchases();
    } catch (e) {
      log("Error restoring purchases: $e");
    }
  }

  /// Processes a batch of [PurchaseDetails] from the purchase stream and
  /// returns a [List] of [PurchaseResult]s.
  ///
  /// Pass the list emitted by [inAppPurchase.purchaseStream] directly here.
  /// Every item in [purchaseDetailsList] is processed independently, so
  /// restore events that deliver multiple items at once are handled correctly.
  ///
  /// The [productsIds] list is used to look up whether each product is
  /// consumable and to build the correct result.
  ///
  /// ### Example
  /// ```dart
  /// engine.inAppPurchase.purchaseStream.listen((list) async {
  ///   final results = await engine.purchaseListener(
  ///     purchaseDetailsList: list,
  ///     productsIds: storeProductIds,
  ///   );
  ///   for (final result in results) {
  ///     if (result.purchaseComplete == true) {
  ///       await OnePref.setPremium(true);
  ///     }
  ///   }
  /// });
  /// ```
  Future<List<PurchaseResult>> purchaseListener({
    required List<PurchaseDetails> purchaseDetailsList,
    required List<InAppEngineProductId> productsIds,
  }) async {
    if (purchaseDetailsList.isEmpty) {
      return const [
        PurchaseResult(
          message: "No Product",
          purchaseRestore: false,
          purchaseComplete: false,
          purchaseConsumed: false,
        ),
      ];
    }

    final results = <PurchaseResult>[];

    for (final purchaseDetails in purchaseDetailsList) {
      try {
        // Handle successful purchase or restore
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final productId = purchaseDetails.productID;
          final matchingProduct = productsIds.firstWhere(
            (p) => p.id == productId,
            orElse: () => InAppEngineProductId(id: "", isConsumable: false),
          );

          // Handle Android consumable purchase
          if (Platform.isAndroid &&
              matchingProduct.id.isNotEmpty &&
              matchingProduct.isConsumable) {
            final androidAddition = inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

            log("Consuming Android purchase: $productId");
            await androidAddition.consumePurchase(purchaseDetails);

            results.add(
              PurchaseResult(
                productId: productId,
                purchaseConsumed: true,
                purchaseComplete: null,
                purchaseRestore: null,
              ),
            );
            continue;
          }

          // Complete pending purchases
          if (purchaseDetails.pendingCompletePurchase) {
            await inAppPurchase.completePurchase(purchaseDetails);
            log("Purchase complete: $productId");

            results.add(
              PurchaseResult(
                productId: productId,
                purchaseComplete: true,
                purchaseConsumed: matchingProduct.isConsumable,
                purchaseRestore: null,
              ),
            );
            continue;
          }

          // Handle restore-only scenario
          if (purchaseDetails.status == PurchaseStatus.restored) {
            log("Purchase restored: $productId");
            results.add(
              PurchaseResult(
                productId: productId,
                purchaseComplete: null,
                purchaseConsumed: null,
                purchaseRestore: true,
              ),
            );
            continue;
          }
        }

        // Handle error status
        if (purchaseDetails.status == PurchaseStatus.error) {
          results.add(
            PurchaseResult.error(
              "Purchase failed for ${purchaseDetails.productID}: ${purchaseDetails.error}",
            ),
          );
          continue;
        }

        // Unhandled state
        results.add(const PurchaseResult(message: "Unhandled purchase state"));
      } catch (e) {
        log("Error processing purchase: $e");
        results.add(PurchaseResult.error("Something went wrong: $e"));
      }
    }

    return results;
  }
}
