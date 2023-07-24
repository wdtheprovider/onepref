class ProductId {
  String id;
  bool isConsumable;
  bool? isSubscription;
  bool? isOneTimePurchase;
  int? reward;

  ProductId({
    required this.id,
    required this.isConsumable,
    this.reward,
    this.isSubscription = false,
    this.isOneTimePurchase = false,
  });
}
