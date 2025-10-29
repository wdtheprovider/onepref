import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';
import 'package:onepref/onepref.dart';

/// Represents the structured result of a purchase or restore operation.
class PurchaseResult {
  final String? productId;
  final bool? purchaseComplete;
  final bool? purchaseConsumed;
  final bool? purchaseRestore;
  final String? message;

  const PurchaseResult({
    this.productId,
    this.purchaseComplete,
    this.purchaseConsumed,
    this.purchaseRestore,
    this.message,
  });

  factory PurchaseResult.error(String message) =>
      PurchaseResult(message: message);
}

/// A Singleton engine for managing in-app purchases across Android and iOS.
class InAppEngine {
  // Singleton pattern
  InAppEngine._();
  static final InAppEngine instance = InAppEngine._();

  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  /// Logs messages safely for debug builds only.
  void log(String message) {
    if (kDebugMode) {
      debugPrint("InAppEngineDebug: $message");
    }
  }

  /// Checks if the store is available to get products.
  Future<bool> getIsAvailable() async {
    try {
      return await inAppPurchase.isAvailable();
    } catch (e) {
      log("Error checking store availability: $e");
      return false;
    }
  }

  /// Returns a list of products from the Play / App Store.
  Future<ProductDetailsResponse> queryProducts(
      List<InAppEngineProductId> storeProductIds) async {
    try {
      return await inAppPurchase
          .queryProductDetails(getProductIdsOnly(storeProductIds).toSet());
    } catch (e) {
      log("Error querying products: $e");
      rethrow;
    }
  }

  /// Launches the purchase flow dialog for a user to purchase.
  Future<void> handlePurchase(
      ProductDetails productDetails, List<ProductId> storeProductIds) async {
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
            await inAppPurchase.buyNonConsumable(
              purchaseParam: purchaseParam,
            );
          }
        }
      }
    } catch (e) {
      log("Error during purchase: $e");
    }
  }

  /// Returns only the list of product IDs.
  List<String> getProductIdsOnly(List<InAppEngineProductId> storeProductIds) =>
      storeProductIds.map((e) => e.id).toList();

  /// Handles the upgrade and downgrade of subscriptions in Android automatically.
  Future<bool> upgradeOrDowngradeSubscription(
    PurchaseDetails currentSubPurchaseDetails,
    ProductDetails newSubProductDetails,
  ) async {
    if (!Platform.isAndroid) {
      log("Subscription change is only supported on Android.");
      return false;
    }

    try {
      log("Upgrading/downgrading subscription...");
      final purchaseParam = GooglePlayPurchaseParam(
        productDetails: newSubProductDetails,
        changeSubscriptionParam: ChangeSubscriptionParam(
          oldPurchaseDetails:
              currentSubPurchaseDetails as GooglePlayPurchaseDetails,
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

  /// Handles all the purchase and restore activities from the store.
  Future<PurchaseResult> purchaseListener({
    required List<PurchaseDetails> purchaseDetailsList,
    required List<InAppEngineProductId> productsIds,
  }) async {
    if (purchaseDetailsList.isEmpty) {
      return const PurchaseResult(
        message: "No Product",
        purchaseRestore: false,
        purchaseComplete: false,
        purchaseConsumed: false,
      );
    }

    for (final purchaseDetails in purchaseDetailsList) {
      try {
        // Handle successful purchase or restore
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final productId = purchaseDetails.productID;
          final matchingProduct = productsIds.firstWhere(
              (p) => p.id == productId,
              orElse: () => InAppEngineProductId(id: "", isConsumable: false));

          // Handle Android consumable purchase
          if (Platform.isAndroid &&
              matchingProduct.id.isNotEmpty &&
              matchingProduct.isConsumable) {
            final androidAddition = inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

            log("Consuming Android purchase: $productId");
            await androidAddition.consumePurchase(purchaseDetails);

            return PurchaseResult(
              productId: productId,
              purchaseConsumed: true,
              purchaseComplete: null,
              purchaseRestore: null,
            );
          }

          // Complete pending purchases
          if (purchaseDetails.pendingCompletePurchase) {
            await inAppPurchase.completePurchase(purchaseDetails);
            log("Purchase complete: $productId");

            return PurchaseResult(
              productId: productId,
              purchaseComplete: true,
              purchaseConsumed: matchingProduct.isConsumable,
              purchaseRestore: null,
            );
          }

          // Handle restore-only scenario
          if (purchaseDetails.status == PurchaseStatus.restored) {
            log("Purchase restored: $productId");
            return PurchaseResult(
              productId: productId,
              purchaseComplete: null,
              purchaseConsumed: null,
              purchaseRestore: true,
            );
          }
        }

        // Handle error status
        if (purchaseDetails.status == PurchaseStatus.error) {
          return PurchaseResult.error(
              "Purchase failed for ${purchaseDetails.productID}: ${purchaseDetails.error}");
        }
      } catch (e) {
        log("Error processing purchase: $e");
        return PurchaseResult.error("Something went wrong: $e");
      }
    }

    // Fallback case
    return const PurchaseResult(
      message: "Unhandled purchase state",
    );
  }
}
