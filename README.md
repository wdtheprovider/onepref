# 🛠️ OnePref + InAppEngine

This package is **endorsed**, which means you can simply use [`shared_preferences`](https://pub.dev/packages/shared_preferences) and [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) normally.  
This package will be automatically included in your app when you do — **no need to add it manually** to your `pubspec.yaml`.

---

## ✨ Features

**OnePref** provides the same functionality as `shared_preferences`, but in a **simpler, developer-friendly API**.  
Additionally, it includes an **InAppEngine** utility that helps you **integrate in-app purchases quickly and safely** — saving you hours of setup time.

### Key Highlights
- 🚀 Simplified preference storage using OnePref.
- 💰 Streamlined in-app purchase management for Android & iOS.
- 🧾 Support for both consumable and non-consumable products.
- 🔁 Built-in subscription upgrade/downgrade support (Android).
- 🧩 Easy product query and restore logic.
- 🧠 Debug-friendly logs and structured `PurchaseResult`.

---

## 🚀 Getting Started

### 1️⃣ Install

```bash
flutter pub add onepref
```

```dart
import 'package:onepref/onepref.dart';
```

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OnePref.init();
  runApp(const MyApp());
}
```

## Write a value

```dart
await OnePref.setString("key", "value here");
await OnePref.setBool("darkMode", true);
await OnePref.setInt("launchCount", 5);
```

## Read a value

```dart
final value = OnePref.getString("key");
final isDark = OnePref.getBool("darkMode");
final count  = OnePref.getInt("launchCount");
```

## Premium & Remove Ads helpers

```dart
// Write
await OnePref.setPremium(true);
await OnePref.setRemoveAds(true);

// Read
final isPremium   = OnePref.getPremium();
final noAds       = OnePref.getRemoveAds();
```

## Other Utilities

```dart
// Check whether a key exists
final exists = OnePref.containsKey("key");

// String list support
await OnePref.setStringList("items", ["a", "b", "c"]);
final items = OnePref.getStringList("items");

// Remove a single key or everything
await OnePref.removeKey("key");
await OnePref.removeAllSavedPrefs();
```

---

## 🛒 Usage (In-App Purchases)

```
⚠️ ATTENTION!

Before using InAppEngine, make sure you have correctly configured in-app purchases
in the Play Console (Android) or App Store Connect (iOS).
```

## Setup variables

```dart
late final List<String> _notFoundIds = <String>[];
late final List<ProductDetails> _products = <ProductDetails>[];
late final List<PurchaseDetails> _purchases = <PurchaseDetails>[];
late bool _isAvailable = false;
late bool _purchasePending = false;

final InAppEngine inAppEngine = InAppEngine.instance;
```

## Define your products

```dart
const storeProductIds = [
  InAppEngineProductId(id: "premium_monthly", isConsumable: false, isSubscription: true),
  InAppEngineProductId(id: "remove_ads",      isConsumable: false, isOneTimePurchase: true),
  InAppEngineProductId(id: "coins_100",       isConsumable: true,  reward: 100),
];
```

## Initialize and Query Products

```dart
@override
void initState() {
  super.initState();

  // Listen to purchase updates
  inAppEngine.inAppPurchase.purchaseStream.listen(
    (List<PurchaseDetails> purchaseDetailsList) {
      listenToPurchaseUpdated(purchaseDetailsList);
    },
    onDone: () {},
    onError: (Object error) {
      debugPrint("Purchase Stream Error: $error");
    },
  );

  getProducts(); // Fetch product details
}

Future<void> getProducts() async {
  final isAvailable = await inAppEngine.getIsAvailable();

  if (isAvailable) {
    final response = await inAppEngine.queryProducts(storeProductIds);

    setState(() {
      _isAvailable = isAvailable;
      _products.addAll(response.productDetails);
      _notFoundIds.addAll(response.notFoundIDs);
      _purchasePending = false;
    });
  } else {
    debugPrint("Store not available.");
  }
}
```

## Handle a Purchase

```dart
TextButton(
  onPressed: () async {
    final selected = _products[selectedProduct ?? 0];
    final initiated = await inAppEngine.handlePurchase(selected, storeProductIds);
    if (!initiated) {
      debugPrint("Could not initiate purchase.");
    }
  },
  child: Text(
    "Buy $reward",
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  ),
),
```

## Handle Purchase Results

```dart
Future<void> listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList) async {
  final results = await inAppEngine.purchaseListener(
    purchaseDetailsList: purchaseDetailsList,
    productsIds: storeProductIds,
  );

  for (final result in results) {
    if (result.purchaseComplete == true) {
      debugPrint("Purchase completed: ${result.productId}");
      await OnePref.setPremium(true);
    } else if (result.purchaseRestore == true) {
      debugPrint("Purchase restored: ${result.productId}");
      await OnePref.setPremium(true);
    } else if (result.purchaseConsumed == true) {
      debugPrint("Consumable consumed: ${result.productId}");
    } else if (result.message != null) {
      debugPrint("Purchase message: ${result.message}");
    }
  }
}
```

## 🧩 Restoring Purchases

```dart
ElevatedButton(
  onPressed: () async {
    await inAppEngine.restorePurchases();
    // Results arrive via the purchaseStream listener above
  },
  child: const Text("Restore Purchases"),
),
```

## 🔄 Subscription Upgrade / Downgrade (Android only)

```dart
final success = await inAppEngine.upgradeOrDowngradeSubscription(
  currentSubPurchaseDetails, // existing GooglePlayPurchaseDetails
  newSubProductDetails,      // new ProductDetails
);
```


| Feature               | Description                           |
| --------------------- | ------------------------------------- |
| 🔹 Shared Preferences | Simple key/value storage with OnePref |
| 🔹 Product Query      | Fetch Play/App Store products easily  |
| 🔹 Purchase Handling  | Buy consumables & non-consumables     |
| 🔹 Subscription       | Manage upgrades/downgrades on Android |
| 🔹 Restore            | Restore past purchases with one line  |
| 🔹 Debug Logging      | Built-in safe logging for dev mode    |