import 'package:audioplayerdb/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSharedPreferences {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static const String _kQuranScript = "quran_script";

  static SharedPreferences prefs;

  /// ------------------------------------------------------------
  /// Method that returns the user that dark theme mode is on or off
  /// ------------------------------------------------------------

  static Future _getInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<QuranScript> getQuranScript() async {
    await _getInstance();
    if (isValueExists(key: _kQuranScript)) {
      String value = prefs.getString(_kQuranScript) ?? null;
      if (value != null) {
        return toObjectValue(value);
      }
      return QuranScript.NONE;
    }
  }

  static QuranScript toObjectValue(String value) {
    if (value == 'A+U') return QuranScript.Arabic_Urdu;
    if (value == 'A') return QuranScript.Arabic;
    if (value == 'U') return QuranScript.Urdu;
  }

  static String toStringValue(QuranScript value) {
    if (value == QuranScript.Arabic_Urdu) return 'A+U';
    if (value == QuranScript.Arabic) return 'A';
    if (value == QuranScript.Urdu) return 'U';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user dark theme mode to on or off
  /// ----------------------------------------------------------
  static Future<bool> setQuranScript(QuranScript value) async {
    await _getInstance();
    return prefs.setString(_kQuranScript, toStringValue(value));
  }

  static Future<bool> removeValue({String key}) async {
    await prefs.remove(key);
  }

  static bool isValueExists({String key}) {
    return prefs.containsKey(key);
  }

//  /// ------------------------------------------------------------
//  /// Method that returns the user decision on sorting order
//  /// ------------------------------------------------------------
//  Future<String> getSortingOrder() async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//    return prefs.getString(_kSortingOrderPrefs) ?? 'name';
//  }
//
//  /// ----------------------------------------------------------
//  /// Method that saves the user decision on sorting order
//  /// ----------------------------------------------------------
//  Future<bool> setSortingOrder(String value) async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//    return prefs.setString(_kSortingOrderPrefs, value);
//  }
}
