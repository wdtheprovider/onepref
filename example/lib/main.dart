import 'package:example/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'package:onepref/onepref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OnePref.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final List<ProductDetails> _products = <ProductDetails>[];
  late final List<PurchaseDetails> _currentPurchaseDetails =
      <PurchaseDetails>[];

  // create a new instance of this class
  IApEngine iApEngine = IApEngine();
  bool isSubscribed = false;

  bool subExisting = false;

  //Use ProductId type to create product ids
  final List<ProductId> _productsIds = [
    ProductId(id: "test_sub_weekly1", isConsumable: false),
    ProductId(id: "test_remove_ads1", isConsumable: false),
  ];

  @override
  void initState() {
    super.initState();

    isSubscribed = OnePref.getPremium()!;

    iApEngine.inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      //listen to the purchases, it will be called everytime there's a purchase or restore purchase.
      if (purchaseDetailsList.isNotEmpty) {
        subExisting = true;
        _currentPurchaseDetails.addAll(purchaseDetailsList);
        print(_currentPurchaseDetails[0].productID);
      }
      listenPurchasedActivities(purchaseDetailsList);
    }, onDone: () {
      print("onDone");
    }, onError: (Object error) {
      print("onError");
    });

    //get products
    getProducts();
  }

  void getProducts() async {
    // This method will handle the query of products from the store.
    await iApEngine.getIsAvailable().then((value) async => {
          if (value)
            {
              await iApEngine.queryProducts(_productsIds).then((value) => {
                    setState(() {
                      _products.addAll(value.productDetails);
                    })
                  })
            }
        });
  }

  Future<void> listenPurchasedActivities(List<PurchaseDetails> list) async {
    if (list.isNotEmpty) {
      for (var purchaseDetails in list) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //This is for the android
          if (Platform.isAndroid &&
              iApEngine
                  .getProductIdsOnly(_productsIds)
                  .contains(purchaseDetails.productID) &&
              _productsIds
                      .where(
                          (element) => element.id == purchaseDetails.productID)
                      .first
                      .isConsumable ==
                  true) {
            /// (_productsIds.where((element) => element.id == purchaseDetails.productID).first.isConsumable ==  true)
            ///
            ///
            ///The above check has been added for not consuming a non-consumable
            ///

            final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
                iApEngine.inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidPlatformAddition.consumePurchase(purchaseDetails).then(
                  (value) => setState(() => {
                        OnePref.setPremium(true), // activate the premium
                        isSubscribed = OnePref.getPremium() ?? false,
                      }),
                );
          }

          print(purchaseDetails.productID);
          print(purchaseDetails.pendingCompletePurchase);
          print(purchaseDetails.status);

          //handles pending purchases
          if (purchaseDetails.pendingCompletePurchase) {
            await iApEngine.inAppPurchase
                .completePurchase(purchaseDetails)
                .then((value) {
              updateOneTimePurchaseAndSubscritpion(purchaseDetails.productID);
            });

            // else if will handle restore purchase
          } else if (purchaseDetails.status == PurchaseStatus.restored) {
            //  get the ProductId Object from the productIds
            updateOneTimePurchaseAndSubscritpion(purchaseDetails.productID);
          }





        }
      }
    } else {
      setState(() {
        OnePref.setPremium(false); // de-activate the premium
        isSubscribed = OnePref.getPremium() ?? false;
      });
    }
  }

//added this function to handle the subscription and one timme purchase
  void updateOneTimePurchaseAndSubscritpion(var purchasedProductId) {
    var productId =
        _productsIds.where((element) => element.id == purchasedProductId).first;

    if (productId.isOneTimePurchase ?? false) {
      setState(() {
        OnePref.setBool("oneTimePurchase", true);
      });
    } else if (productId.isSubscription ?? false) {
      setState(() => {
            OnePref.setPremium(true), // activate the premium
            isSubscribed = OnePref.getPremium() ?? false,
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OnClickAnimation(
                            onTap: () => {},
                            child: const Text(
                              "Dismiss",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                        OnClickAnimation(
                          onTap: () async => {
                            await InAppPurchase.instance
                                .restorePurchases()
                                .then(
                                  (value) => {
                                    _products.clear(),
                                    getProducts(),
                                  },
                                ),
                          },
                          child: const Text(
                            "Restore",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                "${Constants.appName} Go ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isSubscribed
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "PRO",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: Constants.benefits.length,
                      itemBuilder: (context, index) => Benefit(
                        title: Constants.benefits[index],
                        icon: Icons.check,
                        iconBackgroundColor: Colors.orange,
                        iconColor: Colors.white,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !_products.isNotEmpty,
                    child: const SizedBox(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Expanded(
                    child: Visibility(
                      visible: _products.isNotEmpty,
                      child: ListView.builder(
                        itemBuilder: ((context, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 25.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.orange,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                _products[index].price,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              subtitle: Text(
                                                _products[index].description,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              trailing: OnClickAnimation(
                                                onTap: () async {
                                                  print(_products[index].id);

                                                  await InAppPurchase.instance
                                                      .restorePurchases();
                                                  if (subExisting &&
                                                      _products[index].id !=
                                                          _currentPurchaseDetails[
                                                                  0]
                                                              .productID) {
                                                    await iApEngine
                                                        .upgradeOrDowngradeSubscription(
                                                            _currentPurchaseDetails[
                                                                0],
                                                            _products[index]);
                                                  } else {
                                                    iApEngine.handlePurchase(
                                                        _products[index],
                                                        _productsIds);
                                                  }
                                                },
                                                child: const Text(
                                                  "Subscribe",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ))),
                                  ),
                                ],
                              ),
                            )),
                        itemCount: _products.length,
                      ),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
                    child: Text(
                      "Subscritions automatically renews monthly until canceled.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
