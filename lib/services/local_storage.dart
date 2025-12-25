import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String keyFishCount = 'fish_count';
  static const String keyShells = 'shells_currency';
  static const String keyVolume = 'settings_volume';
  static const String keyHighestLevel = 'highest_level_unlocked';
  static const String keyCurrentLevel = 'current_level';

  Future<void> saveFishCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyFishCount, count);
  }

  Future<int> getFishCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyFishCount) ?? 0;
  }

  Future<void> saveShells(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyShells, count);
  }

  Future<int> getShells() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyShells) ?? 0;
  }

  Future<void> saveVolume(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyVolume, isEnabled);
  }

  Future<bool> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyVolume) ?? true;
  }

  // Level Progress
  Future<void> saveHighestLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyHighestLevel) ?? 1;
    // Only save if new level is higher
    if (level > current) {
      await prefs.setInt(keyHighestLevel, level);
    }
  }

  Future<int> getHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyHighestLevel) ?? 1; // Level 1 always unlocked
  }

  Future<void> saveCurrentLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCurrentLevel, level);
  }

  Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCurrentLevel) ?? 1;
  }
}

