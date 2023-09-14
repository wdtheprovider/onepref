// ignore: file_names
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';

class IApEngine {

  
  InAppPurchase inAppPurchase = InAppPurchase.instance;

  Future<bool> getIsAvailable() async {
    return await inAppPurchase.isAvailable();
  }

  Future<ProductDetailsResponse> queryProducts(
      List<ProductId> storeProductIds) async {
    return await inAppPurchase
        .queryProductDetails(getProductIdsOnly(storeProductIds).toSet());
  }

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

  List<String> getProductIdsOnly(List<ProductId> storeProductIds) {
    List<String> temp = <String>[];
    for (var product in storeProductIds) {
      temp.add(product.id);
    }
    return temp;
  }

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
