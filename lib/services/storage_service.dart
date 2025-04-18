import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _macKey = 'bluetooth_mac_address';
  
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<void> saveMacAddress(String macAddress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_macKey, macAddress);
  }

  Future<String?> getMacAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_macKey);
  }

  Future<void> clearMacAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_macKey);
  }
} 