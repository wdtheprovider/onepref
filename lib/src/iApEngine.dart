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

  ///  Returns a list of products from the Play / App Store.
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
          print(
              ("iApEngineDebug: buying consumable for id ${productDetails.id}"));
          await IApEngine().inAppPurchase.buyConsumable(
              purchaseParam: purchaseParam, autoConsume: product.isConsumable);
        } else {
          print(
              ("iApEngineDebug: buying nonConsumable for id ${productDetails.id}"));
          await IApEngine()
              .inAppPurchase
              .buyNonConsumable(purchaseParam: purchaseParam);
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
        prorationMode: ProrationMode.immediateWithTimeProration,
      ),
    );
    return await IApEngine()
        .inAppPurchase
        .buyNonConsumable(purchaseParam: purchaseParam);
  }
}
