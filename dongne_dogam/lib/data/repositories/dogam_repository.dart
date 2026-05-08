import 'package:shared_preferences/shared_preferences.dart';

class DogamRepository {
  static const _key = 'collected_spot_ids';

  SharedPreferences? _prefs;
  Set<String>? _cachedIds;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _cachedIds ??= _prefs!.getStringList(_key)?.toSet() ?? {};
  }

  Future<Set<String>> getCollectedIds() async {
    await _init();
    return Set<String>.from(_cachedIds!);
  }

  Future<void> collect(String spotId) async {
    await _init();
    if (_cachedIds!.add(spotId)) {
      await _prefs!.setStringList(_key, _cachedIds!.toList());
    }
  }

  Future<bool> isCollected(String spotId) async {
    await _init();
    return _cachedIds!.contains(spotId);
  }

  Future<double> completionRatio(List<String> allSpotIds) async {
    if (allSpotIds.isEmpty) return 0.0;
    await _init();
    final collected = allSpotIds.where(_cachedIds!.contains).length;
    return collected / allSpotIds.length;
  }
}
