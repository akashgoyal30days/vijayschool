import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesInstance {
  static late final SharedPreferences instance;
  static initialize() async => instance = await SharedPreferences.getInstance();
  static String? getString(String key) => instance.getString(key);
}
