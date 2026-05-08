import 'package:shared_preferences/shared_preferences.dart';

class DogamRepository {
  static const _key = 'collected_spot_ids';

  Future<Set<String>> getCollectedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<void> collect(String spotId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    ids.add(spotId);
    await prefs.setStringList(_key, ids.toList());
  }

  Future<bool> isCollected(String spotId) async {
    final ids = await getCollectedIds();
    return ids.contains(spotId);
  }

  Future<double> completionRatio(List<String> allSpotIds) async {
    if (allSpotIds.isEmpty) return 0;
    final ids = await getCollectedIds();
    final collected = allSpotIds.where(ids.contains).length;
    return collected / allSpotIds.length;
  }
}
