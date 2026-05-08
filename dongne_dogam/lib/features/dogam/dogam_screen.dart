import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/story_spot.dart';
import '../../data/repositories/dogam_repository.dart';
import '../../data/repositories/spot_repository.dart';
import '../story/story_screen.dart';

class DogamScreen extends StatefulWidget {
  const DogamScreen({super.key});

  @override
  State<DogamScreen> createState() => _DogamScreenState();
}

class _DogamScreenState extends State<DogamScreen> {
  final _spotRepo = SpotRepository();
  final _dogamRepo = DogamRepository();

  static const _regions = [
    {'id': 'seongsu', 'name': '성수동'},
    {'id': 'jeonju',  'name': '전주 한옥마을'},
    {'id': 'yeongdo', 'name': '부산 영도'},
  ];

  Map<String, List<StorySpotSummary>> _spotsByRegion = {};
  Set<String> _collectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ..._regions.map((r) => _spotRepo.fetchSpots(r['id']!)),
      _dogamRepo.getCollectedIds(),
    ]);

    final byRegion = <String, List<StorySpotSummary>>{};
    for (var i = 0; i < _regions.length; i++) {
      byRegion[_regions[i]['id']!] = results[i] as List<StorySpotSummary>;
    }

    setState(() {
      _spotsByRegion = byRegion;
      _collectedIds = results.last as Set<String>;
      _loading = false;
    });
  }

  Future<void> _openStory(String regionId, StorySpotSummary summary) async {
    final spot = await _spotRepo.fetchSpot(regionId, summary.id);
    if (spot == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryScreen(
          spot: spot,
          isCollected: true,
          onCollect: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '도감',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  ..._regions.map((r) {
                    final spots = _spotsByRegion[r['id']!] ?? [];
                    final collected = spots.where((s) => _collectedIds.contains(s.id)).toList();
                    final ratio = spots.isEmpty ? 0.0 : collected.length / spots.length;
                    return _RegionSection(
                      name: r['name']!,
                      spots: spots,
                      collected: collected,
                      ratio: ratio,
                      onSpotTap: (spot) => _openStory(r['id']!, spot),
                    );
                  }),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                ],
              ),
      ),
    );
  }
}

class _RegionSection extends StatelessWidget {
  final String name;
  final List<StorySpotSummary> spots;
  final List<StorySpotSummary> collected;
  final double ratio;
  final ValueChanged<StorySpotSummary> onSpotTap;

  const _RegionSection({
    required this.name,
    required this.spots,
    required this.collected,
    required this.ratio,
    required this.onSpotTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${collected.length}/${spots.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMute,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppColors.surfaceAlt,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            if (collected.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '아직 수집한 스토리가 없어요.',
                  style: const TextStyle(fontSize: 13, color: AppColors.inkMute),
                ),
              )
            else
              ...collected.map((spot) => _SpotRow(spot: spot, onTap: () => onSpotTap(spot))),
            const SizedBox(height: 8),
            Divider(color: AppColors.line),
          ],
        ),
      ),
    );
  }
}

class _SpotRow extends StatelessWidget {
  final StorySpotSummary spot;
  final VoidCallback onTap;

  const _SpotRow({required this.spot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forCategory(spot.category);
    final glyph = AppColors.glyphForCategory(spot.category);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  glyph,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    spot.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkMute),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.inkMute),
          ],
        ),
      ),
    );
  }
}
