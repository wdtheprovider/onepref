// ignore: file_names
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';

class IApEngine {
  InAppPurchase inAppPurchase = InAppPurchase.instance;

  /// Checks if the store is available to get products.
  Future<bool> getIsAvailable() async {
    return await inAppPurchase.isAvailable();
  }

  /// Returns a list of products from the Play / App Store.
  Future<ProductDetailsResponse> queryProducts(
      List<ProductId> storeProductIds) async {
    return await inAppPurchase
        .queryProductDetails(getProductIdsOnly(storeProductIds).toSet());
  }

  /// A Function that launching the purchase flow dialog for a user to purchase.
  void handlePurchase(
      ProductDetails productDetails, List<ProductId> storeProductIds) async {
    late PurchaseParam purchaseParam;
    Platform.isAndroid
        ? purchaseParam = GooglePlayPurchaseParam(
            productDetails: productDetails,
            applicationUserName: null,
          )
        : purchaseParam = PurchaseParam(
            productDetails: productDetails,
            applicationUserName: null,
          );

    for (var product in storeProductIds) {
      if (product.id == productDetails.id) {
        if (product.isConsumable) {
          try {
            print(
                ("iApEngineDebug: buying consumable for id ${productDetails.id}"));
            await IApEngine().inAppPurchase.buyConsumable(
                purchaseParam: purchaseParam,
                autoConsume: product.isConsumable);
          } catch (e) {
            print("Something went wrong $e");
          }
        } else {
          try {
            print(
                ("iApEngineDebug: buying nonConsumable for id ${productDetails.id}"));
            await IApEngine()
                .inAppPurchase
                .buyNonConsumable(purchaseParam: purchaseParam);
          } catch (e) {
            print("Something went wrong $e");
          }
        }
      }
    }
  }

  /// A function that only returns the list of product ids
  List<String> getProductIdsOnly(List<ProductId> storeProductIds) {
    List<String> temp = <String>[];
    for (var product in storeProductIds) {
      temp.add(product.id);
    }
    return temp;
  }

  /// Handles the upgrade and downgrade of subscriptions in android automatically
  Future<bool> upgradeOrDowngradeSubscription(
    PurchaseDetails currentSubPurchaseDetails,
    ProductDetails newSubProductDetails,
  ) async {
    print(("iApEngineDebug: upgrading/downgrading"));
    PurchaseParam purchaseParam = GooglePlayPurchaseParam(
      productDetails: newSubProductDetails,
      changeSubscriptionParam: ChangeSubscriptionParam(
        oldPurchaseDetails:
            currentSubPurchaseDetails as GooglePlayPurchaseDetails,
        replacementMode: ReplacementMode.chargeProratedPrice,
      ),
    );
    return await IApEngine()
        .inAppPurchase
        .buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Handles all the purchase and restore activities from the Store
  Future<Map<String, dynamic>> purchaseListener(
      {required List<PurchaseDetails> purchaseDetailsList,
      required List<ProductId> productsIds}) async {
    late Map<String, dynamic> result = {};
    if (purchaseDetailsList.isNotEmpty) {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //This is for the android
          if (Platform.isAndroid &&
              getProductIdsOnly(productsIds)
                  .contains(purchaseDetails.productID) &&
              productsIds
                      .where(
                          (element) => element.id == purchaseDetails.productID)
                      .first
                      .isConsumable ==
                  true) {
            final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
                inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();

            try {
              await androidPlatformAddition
                  .consumePurchase(purchaseDetails)
                  .then((value) {
                result['billingResponseCode'] = value;
                result['purchaseConsumed'] = true;
              });
            } catch (e) {
              print("Something went wrong $e");
            }
          }

          //handles pending purchases
          if (purchaseDetails.pendingCompletePurchase) {
            try {
              await inAppPurchase
                  .completePurchase(purchaseDetails)
                  .then((value) {
                result['purchaseComplete'] = true;
                result['purchaseRestore'] = null;
                if (!result.containsKey("purchaseConsumed")) {
                  result['purchaseConsumed'] = null;
                }
                result['productId'] = purchaseDetails.productID;
              });
            } catch (e) {
              print("Something went wrong $e");
            }
            // else if will handle restore purchase
          } else if (purchaseDetails.status == PurchaseStatus.restored) {
            result['purchaseComplete'] = null;
            if (!result.containsKey("purchaseConsumed")) {
              result['purchaseConsumed'] = null;
            }
            result['purchaseRestore'] = true;
            result['productId'] = purchaseDetails.productID;
          }
        }
      }
      return result;
    } else {
      // no product
      return {
        'message': "No Product",
        'purchaseRestore': false,
        'purchaseComplete': false,
        'purchaseConsumed': false,
      };
    }
  }
}
