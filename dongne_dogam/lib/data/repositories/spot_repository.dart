import '../models/story_spot.dart';
import '../services/api_client.dart';
import 'mock_spots.dart';

class SpotRepository {
  final ApiClient _client;
  final bool useMock;

  SpotRepository({ApiClient? client, this.useMock = true})
      : _client = client ?? ApiClient();

  Future<List<StorySpot>> fetchSpots(String regionId) async {
    if (useMock) return mockSpots[regionId] ?? [];
    final res = await _client.dio.get('/regions/$regionId/spots');
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => StorySpot.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StorySpot?> fetchSpot(String spotId) async {
    if (useMock) {
      for (final spots in mockSpots.values) {
        for (final s in spots) {
          if (s.id == spotId) return s;
        }
      }
      return null;
    }
    final res = await _client.dio.get('/spots/$spotId');
    if (res.data == null) return null;
    return StorySpot.fromJson(res.data as Map<String, dynamic>);
  }
}
