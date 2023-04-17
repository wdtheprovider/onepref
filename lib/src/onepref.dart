
import 'package:shared_preferences/shared_preferences.dart';

class OnePref {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setBool(String key, bool value) async =>
      await _preferences?.setBool(
        key,
        value,
      );

  static Future setPremium(bool value) async =>
      await _preferences?.setBool(
        "onePref_Premium",
        value,
      );

  static Future setRemoveAds(bool value) async =>
      await _preferences?.setBool(
        "onePref_RemoveAds",
        value,
      );

  static Future setString(String key, String value) async =>
      await _preferences?.setString(
        key,
        value,
      );

  static Future setInt(String key, int value) async =>
      await _preferences?.setInt(
        key,
        value,
      );

  static Future setDouble(String key, double value) async =>
      await _preferences?.setDouble(
        key,
        value,
      );

// Getter Methods
  static bool? getBool(String key) => _preferences?.getBool(key) ?? false;
  static bool? getPremium() => _preferences?.getBool("onePref_Premium") ?? false;
  static bool? getRemoveAds() => _preferences?.getBool("onePref_RemoveAds") ?? false;
  static String? getString(String key) => _preferences?.getString(key);
  static int? getInt(String key) => _preferences?.getInt(key) ?? 0;
  static double? getDouble(String key) => _preferences?.getDouble(key) ?? 0.0;

  //remove/clear
  static Future removeAllSavedPrefs() async => await _preferences?.clear();
  static Future removeKey(String key) async => await _preferences?.remove(key);
}
