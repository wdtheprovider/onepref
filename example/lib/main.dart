import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';

// ---------------------------------------------------------------------------
// Product definitions
// ---------------------------------------------------------------------------

/// All products offered by this app.
const List<InAppEngineProductId> storeProductIds = [
  InAppEngineProductId(
    id: 'premium_monthly',
    isConsumable: false,
    isSubscription: true,
  ),
  InAppEngineProductId(
    id: 'remove_ads',
    isConsumable: false,
    isOneTimePurchase: true,
  ),
  InAppEngineProductId(id: 'coins_100', isConsumable: true, reward: 100),
];

// ---------------------------------------------------------------------------
// App entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise OnePref before the app starts.
  await OnePref.init();

  runApp(const OnePrefExampleApp());
}

class OnePrefExampleApp extends StatelessWidget {
  const OnePrefExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnePref Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Home page
// ---------------------------------------------------------------------------

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final InAppEngine _engine = InAppEngine.instance;

  bool _isPremium = false;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  String _statusMessage = 'Ready';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _listenToPurchases();
    _loadProducts();
  }

  // ── Preferences ────────────────────────────────────────────────────────────

  void _loadPrefs() {
    setState(() {
      _isPremium = OnePref.getPremium();
    });
  }

  Future<void> _togglePremium() async {
    await OnePref.setPremium(!_isPremium);
    _loadPrefs();
  }

  // ── In-App Purchases ───────────────────────────────────────────────────────

  void _listenToPurchases() {
    _engine.inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object error) {
        setState(() => _statusMessage = 'Stream error: $error');
      },
    );
  }

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    final results = await _engine.purchaseListener(
      purchaseDetailsList: purchaseDetailsList,
      productsIds: storeProductIds,
    );

    for (final result in results) {
      if (result.purchaseComplete == true) {
        await OnePref.setPremium(true);
        setState(
          () => _statusMessage = 'Purchase complete: ${result.productId}',
        );
      } else if (result.purchaseRestore == true) {
        await OnePref.setPremium(true);
        setState(() => _statusMessage = 'Restored: ${result.productId}');
      } else if (result.purchaseConsumed == true) {
        setState(() => _statusMessage = 'Consumed: ${result.productId}');
      } else if (result.message != null) {
        setState(() => _statusMessage = result.message!);
      }
    }
    _loadPrefs();
  }

  Future<void> _loadProducts() async {
    final available = await _engine.getIsAvailable();
    if (!available) {
      setState(() {
        _isAvailable = false;
        _statusMessage = 'Store not available';
      });
      return;
    }

    final response = await _engine.queryProducts(storeProductIds);
    setState(() {
      _isAvailable = true;
      _products = response.productDetails;
      _statusMessage = response.notFoundIDs.isEmpty
          ? 'Products loaded'
          : 'Missing IDs: ${response.notFoundIDs.join(', ')}';
    });
  }

  Future<void> _buyProduct(ProductDetails product) async {
    setState(() => _statusMessage = 'Starting purchase…');
    final initiated = await _engine.handlePurchase(product, storeProductIds);
    if (!initiated) {
      setState(() => _statusMessage = 'Could not initiate purchase.');
    }
  }

  Future<void> _restore() async {
    setState(() => _statusMessage = 'Restoring…');
    await _engine.restorePurchases();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OnePref Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Preferences section ───────────────────────────────────────────
          _SectionHeader(title: 'Shared Preferences'),
          Card(
            child: ListTile(
              title: const Text('Premium status'),
              subtitle: Text(_isPremium ? '✅ Active' : '❌ Inactive'),
              trailing: Switch(
                value: _isPremium,
                onChanged: (_) => _togglePremium(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Benefit widget demo:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Benefit(
                    icon: Icons.star,
                    title: 'Unlimited access to all features',
                  ),
                  const Benefit(
                    icon: Icons.block,
                    title: 'No ads',
                    iconBackgroundColor: Colors.redAccent,
                  ),
                  Benefit(
                    icon: Icons.download,
                    title: 'Offline downloads',
                    iconBackgroundColor: Colors.blue.shade600,
                  ),
                ],
              ),
            ),
          ),

          // ── IAP section ───────────────────────────────────────────────────
          const SizedBox(height: 16),
          _SectionHeader(title: 'In-App Purchases'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Status: $_statusMessage',
                style: TextStyle(
                  color:
                      _statusMessage.contains('error') ||
                          _statusMessage.contains('not')
                      ? Colors.red
                      : Colors.green.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!_isAvailable)
            const Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber, color: Colors.orange),
                title: Text('Store is not available on this device'),
              ),
            )
          else if (_products.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            ..._products.map(
              (product) => Card(
                child: ListTile(
                  title: Text(product.title),
                  subtitle: Text(product.description),
                  trailing: OnClickAnimation(
                    onTap: () => _buyProduct(product),
                    child: ElevatedButton(
                      onPressed: () => _buyProduct(product),
                      child: Text(product.price),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _restore,
            icon: const Icon(Icons.restore),
            label: const Text('Restore Purchases'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widget
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
