import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String isLoggedInKey = 'isLoggedIn';

  static Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }
}
class UserDetailSharedPreferences {
  static const String _keyName = 'name';
  static const String _keyPhone = 'phone';
  static const String _keyCity = 'city';
  static const String _keyState = 'state';
  static const String _keyCountry = 'country';
  static const String _keyId = 'Id';
  static Future<void> setName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  static Future<String?> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<void> setPhone(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhone, phone);
  }

  static Future<String?> getPhone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  static Future<void> setCity(String city) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCity, city);
  }

  static Future<String?> getCity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCity);
  }

  static Future<void> setState(String state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyState, state);
  }

  static Future<String?> getState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyState);
  }

  static Future<void> setCountry(String country) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCountry, country);
  }

  static Future<String?> getCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCountry);
  }

    static Future<void> setId(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyId,id);
  }

  static Future<String?> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyId);
  }
}
