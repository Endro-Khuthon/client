class StorySpotSummary {
  final String id;
  final String name;
  final String category;
  final double lat;
  final double lng;
  final String summary;
  final String imageUrl;

  const StorySpotSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.summary,
    this.imageUrl = '',
  });

  factory StorySpotSummary.fromJson(Map<String, dynamic> json) => StorySpotSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        summary: json['summary'] as String,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class StorySpot {
  final String id;
  final String name;
  final String category;
  final double lat;
  final double lng;
  final String summary;
  final String storyPast;
  final String storyPresent;
  final String storyMeaning;
  final List<String> keywords;
  final String imageUrl;

  const StorySpot({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.summary,
    required this.storyPast,
    required this.storyPresent,
    required this.storyMeaning,
    required this.keywords,
    this.imageUrl = '',
  });

  factory StorySpot.fromJson(Map<String, dynamic> json) => StorySpot(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        summary: json['summary'] as String,
        storyPast: json['story_past'] as String,
        storyPresent: json['story_present'] as String,
        storyMeaning: json['story_meaning'] as String,
        keywords: List<String>.from(json['keywords'] as List? ?? []),
        imageUrl: json['image_url'] as String? ?? '',
      );
}
