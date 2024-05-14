import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _preferences;

  static bool _isDarkMode = false;
  static String _userId = '';
  static String _userFirstName = '';
  static String _userLastName = '';
  static String _userCountry = '';
  static String _userEmail = '';
  static String _userPublicKey = '';
  static String _userPrivateKey = '';

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Theme local storage
  static bool get isDarkMode {
    return _preferences.getBool('isDarkMode') ?? _isDarkMode;
  }

  static set isDarkMode(bool value) {
    _isDarkMode = value;
    _preferences.setBool('isDarkMode', value);
  }

  // User id
  static String get userId {
    return _preferences.getString('userId') ?? _userId;
  }

  static set userId(String value) {
    _userId = value;
    _preferences.setString('userId', value);
  }

  // User first name
  static String get userFirstName {
    return _preferences.getString('userFirstName') ?? _userFirstName;
  }

  static set userFirstName(String value) {
    _userFirstName = value;
    _preferences.setString('userFirstName', value);
  }

  // User last name
  static String get userLastName {
    return _preferences.getString('userLastName') ?? _userLastName;
  }

  static set userLastName(String value) {
    _userLastName = value;
    _preferences.setString('userLastName', value);
  }

  // User country
  static String get userCountry {
    return _preferences.getString('userCountry') ?? _userCountry;
  }

  static set userCountry(String value) {
    _userCountry = value;
    _preferences.setString('userCountry', value);
  }

  // User email
  static String get userEmail {
    return _preferences.getString('userEmail') ?? _userEmail;
  }

  static set userEmail(String value) {
    _userEmail = value;
    _preferences.setString('userEmail', value);
  }

  // User public key
  static String get userPublicKey {
    return _preferences.getString('userPublicKey') ?? _userPublicKey;
  }

  static set userPublicKey(String value) {
    _userPublicKey = value;
    _preferences.setString('userPublicKey', value);
  }

  // User private key
  static String get userPrivateKey {
    return _preferences.getString('userPrivateKey') ?? _userPrivateKey;
  }

  static set userPrivateKey(String value) {
    _userPrivateKey = value;
    _preferences.setString('userPrivateKey', value);
  }
}
