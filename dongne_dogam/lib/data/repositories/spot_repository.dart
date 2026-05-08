import '../models/story_spot.dart';
import '../services/api_client.dart';
import 'mock_spots.dart';

class SpotRepository {
  final ApiClient _client;
  final bool useMock;

  SpotRepository({ApiClient? client, this.useMock = false})
      : _client = client ?? ApiClient();

  Future<List<StorySpotSummary>> fetchSpots(String regionId) async {
    if (useMock) return mockSummaries[regionId] ?? [];
    final res = await _client.dio.get('/regions/$regionId/spots');
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => StorySpotSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StorySpot?> fetchSpot(String regionId, String spotId) async {
    if (useMock) return mockSpotDetails[spotId];
    final res = await _client.dio.get('/regions/$regionId/spots/$spotId');
    if (res.data == null) return null;
    return StorySpot.fromJson(res.data as Map<String, dynamic>);
  }
}
