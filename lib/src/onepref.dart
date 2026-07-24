import 'package:shared_preferences/shared_preferences.dart';

/// A simple, developer-friendly wrapper around [SharedPreferences].
///
/// Call [OnePref.init] once in `main()` before using any other methods.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await OnePref.init();
///   runApp(const MyApp());
/// }
/// ```
class OnePref {
  static SharedPreferences? _preferences;

  /// Initialises the underlying [SharedPreferences] instance.
  ///
  /// Must be called **once** before any other [OnePref] method, typically
  /// inside `main()` after `WidgetsFlutterBinding.ensureInitialized()`.
  ///
  /// Throws a [StateError] if any method is called before [init].
  static Future<void> init() async =>
      _preferences = await SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------
  // Internal guard
  // ---------------------------------------------------------------------------

  static SharedPreferences _prefs() {
    assert(
      _preferences != null,
      'OnePref.init() must be called before accessing preferences.',
    );
    if (_preferences == null) {
      throw StateError(
        'OnePref has not been initialized. '
        'Call `await OnePref.init()` in main() before using OnePref.',
      );
    }
    return _preferences!;
  }

  // ---------------------------------------------------------------------------
  // Setter Methods
  // ---------------------------------------------------------------------------

  /// Persists a [bool] value associated with the given [key].
  ///
  /// Returns `true` on success.
  static Future<bool> setBool(String key, bool value) =>
      _prefs().setBool(key, value);

  /// Persists the premium status of the user.
  ///
  /// Stored under the reserved key `"onePref_Premium"`.
  /// Returns `true` on success.
  static Future<bool> setPremium(bool value) =>
      _prefs().setBool('onePref_Premium', value);

  /// Persists whether ads should be removed for the user.
  ///
  /// Stored under the reserved key `"onePref_RemoveAds"`.
  /// Returns `true` on success.
  static Future<bool> setRemoveAds(bool value) =>
      _prefs().setBool('onePref_RemoveAds', value);

  /// Persists a [String] value associated with the given [key].
  ///
  /// Returns `true` on success.
  static Future<bool> setString(String key, String value) =>
      _prefs().setString(key, value);

  /// Persists an [int] value associated with the given [key].
  ///
  /// Returns `true` on success.
  static Future<bool> setInt(String key, int value) =>
      _prefs().setInt(key, value);

  /// Persists a [double] value associated with the given [key].
  ///
  /// Returns `true` on success.
  static Future<bool> setDouble(String key, double value) =>
      _prefs().setDouble(key, value);

  /// Persists a list of strings associated with the given [key].
  ///
  /// Returns `true` on success.
  static Future<bool> setStringList(String key, List<String> value) =>
      _prefs().setStringList(key, value);

  // ---------------------------------------------------------------------------
  // Getter Methods
  // ---------------------------------------------------------------------------

  /// Reads a [bool] value for [key]. Returns `false` if the key does not exist.
  static bool getBool(String key) => _prefs().getBool(key) ?? false;

  /// Returns the stored premium status. Defaults to `false` if not set.
  static bool getPremium() => _prefs().getBool('onePref_Premium') ?? false;

  /// Returns whether ads should be removed. Defaults to `false` if not set.
  static bool getRemoveAds() => _prefs().getBool('onePref_RemoveAds') ?? false;

  /// Reads a [String] value for [key]. Returns `null` if the key does not exist.
  static String? getString(String key) => _prefs().getString(key);

  /// Reads an [int] value for [key]. Returns `0` if the key does not exist.
  static int getInt(String key) => _prefs().getInt(key) ?? 0;

  /// Reads a [double] value for [key]. Returns `0.0` if the key does not exist.
  static double getDouble(String key) => _prefs().getDouble(key) ?? 0.0;

  /// Reads a list of strings for [key]. Returns `null` if the key does not exist.
  static List<String>? getStringList(String key) => _prefs().getStringList(key);

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Returns `true` if [key] exists in the stored preferences.
  static bool containsKey(String key) => _prefs().containsKey(key);

  /// Removes the value associated with [key] from preferences.
  ///
  /// Returns `true` on success.
  static Future<bool> removeKey(String key) => _prefs().remove(key);

  /// Clears **all** stored preferences.
  ///
  /// ⚠️ Use with caution — this removes every key persisted by [OnePref].
  /// Returns `true` on success.
  static Future<bool> removeAllSavedPrefs() => _prefs().clear();
}
