// Mark as deprecated with guidance
@Deprecated('ProductId is deprecated — use InAppEngineProductId instead. '
    'Deprecated in v0.0.21 and will be removed in v0.0.22.')
class ProductId {
  final String id;
  final bool isConsumable;
  final bool? isSubscription;
  final bool? isOneTimePurchase;
  final int? reward;

  const ProductId({
    required this.id,
    required this.isConsumable,
    this.reward,
    this.isSubscription = false,
    this.isOneTimePurchase = false,
  });

  // Optional: helper to convert to the new type
  InAppEngineProductId toPurchaseProductId() => InAppEngineProductId(
        id: id,
        isConsumable: isConsumable,
        reward: reward,
        isSubscription: isSubscription ?? false,
        isOneTimePurchase: isOneTimePurchase ?? false,
      );
}

// New replacement API
class InAppEngineProductId {
  final String id;
  final bool isConsumable;
  final bool isSubscription;
  final bool isOneTimePurchase;
  final int? reward;

  const InAppEngineProductId({
    required this.id,
    required this.isConsumable,
    this.reward,
    this.isSubscription = false,
    this.isOneTimePurchase = false,
  });
}
