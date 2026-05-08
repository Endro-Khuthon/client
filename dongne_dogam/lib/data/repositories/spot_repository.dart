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
    return (res.data as List).map((e) => StorySpot.fromJson(e)).toList();
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
    return StorySpot.fromJson(res.data);
  }
}
