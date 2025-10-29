

This package is endorsed, which means you can simply use shared_preferences and in_app_purchase normally. 
This package will be automatically included in your app when you do, so you do not need to add it to your pubspec.yaml.

## Features

OnePref offers the same functionality shared_preferences package offers but in a friendly way and it has other in app purchase 
functions to fast track your development when you add in app purchase in your application.

## Getting started

```dart
flutter pub add onepref
```

```dart
import 'package:onepref/onepref.dart' 
```

```dart
//In your main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OnePref.init();
  runApp(const MyApp());
}

```

## Usage

```dart
To Write

OnePref.setString("key","value here");
```

```dart
Get the Value

const value = OnePref.getString("key");
```

##  To get Products 

```dart
//declare these 

late final List<String> _notFoundIds = <String>[];
late final List<ProductDetails> _products = <ProductDetails>[];
late final List<PurchaseDetails> _purchases = <PurchaseDetails>[];
late bool _isAvailable = false;
late bool _purchasePending = false;

InAppEngine inAppEngine = InAppEngine();

ATTENTATION !!!!!  ATTENTATION !!!!!   ATTENTATION !!!!!
//(Please make sure you have configured in App purchase for your app)

@override
void initState() {
  super.initState();
  
  inAppEngine.inAppPurchase.purchaseStream.listen(
          (List<PurchaseDetails> purchaseDetailsList) {
        //listen to the purchases
        listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {}, onError: (Object error) {});
  
  getProducts();// calling get products
}

void getProducts() async {
    // Querying the products from Google Play
    await inAppEngine.getIsAvailable().then((isAvailable) async {
      if (isAvailable) {
        await inAppEngine
            .queryProducts(Constants.storeProductIds)
            .then((value) => {
                  setState(() {
                    _isAvailable = isAvailable;
                    _products.addAll(value
                        .productDetails); // Setting the returned products here.
                    _notFoundIds.addAll(value
                        .notFoundIDs); // Setting the returned notProductIds here.
                    _purchasePending = false;
                  })
                });
      }
    });
  }
  
```

## HandlePurchase

```dart
 TextButton(onPressed: () {
     inAppEngine.handlePurchase(_products[selectedProduct ?? 0],Constants.storeProductIds);},
   child: Text("Buy $reward",
                textAlign: TextAlign.center,
            style: const TextStyle(
           color: Colors.white, fontSize: 14,
          fontWeight: FontWeight.normal,
       ),
     ),
  ),
```