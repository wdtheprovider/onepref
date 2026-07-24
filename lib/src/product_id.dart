// `ProductId` was deprecated in v0.0.21 and is scheduled for removal.
// Use [InAppEngineProductId] instead.
/// A product identifier — **deprecated**, use [InAppEngineProductId] instead.
///
/// Migrate by calling [toPurchaseProductId] to convert existing instances.
@Deprecated(
  'ProductId is deprecated — use InAppEngineProductId instead. '
  'Deprecated in v0.0.21.',
)
class ProductId {
  /// The store product ID string (e.g. `"premium_monthly"`).
  final String id;

  /// Whether this product is consumable (e.g. coins, credits).
  final bool isConsumable;

  /// Whether this product is a subscription.
  final bool? isSubscription;

  /// Whether this product is a one-time purchase.
  final bool? isOneTimePurchase;

  /// Optional reward value associated with this product (e.g. coin amount).
  final int? reward;

  /// Creates a [ProductId].
  const ProductId({
    required this.id,
    required this.isConsumable,
    this.reward,
    this.isSubscription = false,
    this.isOneTimePurchase = false,
  });

  /// Converts this deprecated [ProductId] to the current [InAppEngineProductId].
  InAppEngineProductId toPurchaseProductId() => InAppEngineProductId(
    id: id,
    isConsumable: isConsumable,
    reward: reward,
    isSubscription: isSubscription ?? false,
    isOneTimePurchase: isOneTimePurchase ?? false,
  );
}

/// Describes an in-app product and its purchase behaviour.
///
/// Pass a list of [InAppEngineProductId]s to [InAppEngine.queryProducts],
/// [InAppEngine.handlePurchase], and [InAppEngine.purchaseListener].
///
/// ```dart
/// const storeProductIds = [
///   InAppEngineProductId(id: 'premium_monthly', isConsumable: false, isSubscription: true),
///   InAppEngineProductId(id: 'remove_ads',      isConsumable: false, isOneTimePurchase: true),
///   InAppEngineProductId(id: 'coins_100',        isConsumable: true,  reward: 100),
/// ];
/// ```
class InAppEngineProductId {
  /// The store product ID string exactly as configured in Play Console / App Store Connect.
  final String id;

  /// Whether this product is consumable (e.g. coins, credits).
  ///
  /// Consumable products can be purchased multiple times. The engine will
  /// automatically call `consumePurchase` on Android when this is `true`.
  final bool isConsumable;

  /// Whether this product is a recurring subscription. Defaults to `false`.
  final bool isSubscription;

  /// Whether this product is a one-time (non-renewable) purchase. Defaults to `false`.
  final bool isOneTimePurchase;

  /// Optional reward value associated with this product (e.g. coin amount).
  ///
  /// Not used internally by [InAppEngine] — it is available for your own
  /// business logic after a successful purchase.
  final int? reward;

  /// Creates an [InAppEngineProductId].
  const InAppEngineProductId({
    required this.id,
    required this.isConsumable,
    this.reward,
    this.isSubscription = false,
    this.isOneTimePurchase = false,
  });
}
