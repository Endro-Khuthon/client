import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/app_colors.dart';
import '../../data/models/story_spot.dart';
import '../../data/repositories/spot_repository.dart';
import 'widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = SpotRepository();
  final _mapController = MapController();

  String _regionId = 'seongsu';
  List<StorySpot> _spots = [];
  int _activeIdx = 0;
  final Set<String> _collectedIds = {};

  static const _regions = [
    {'id': 'seongsu', 'name': '성수동',     'lat': 37.5446, 'lng': 127.0556},
    {'id': 'jeonju',  'name': '전주 한옥마을', 'lat': 35.8150, 'lng': 127.1530},
    {'id': 'yeongdo', 'name': '부산 영도',    'lat': 35.0780, 'lng': 129.0670},
  ];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    final spots = await _repo.fetchSpots(_regionId);
    setState(() {
      _spots = spots;
      _activeIdx = 0;
    });
    _moveMap();
  }

  void _moveMap() {
    final region = _regions.firstWhere((r) => r['id'] == _regionId);
    _mapController.move(
      LatLng(region['lat']! as double, region['lng']! as double),
      14,
    );
  }

  void _selectRegion(String regionId) {
    setState(() => _regionId = regionId);
    _loadSpots();
  }

  @override
  Widget build(BuildContext context) {
    final cur = _spots.isEmpty ? null : _spots[_activeIdx];
    final region = _regions.firstWhere((r) => r['id'] == _regionId);

    return Scaffold(
      body: Stack(
        children: [
          // 지도 (full-bleed)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                region['lat']! as double,
                region['lng']! as double,
              ),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.dongne_dogam',
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // 상단 floating: 지역명 + 수집 현황
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RegionPill(
                    regions: _regions,
                    selected: _regionId,
                    onSelect: _selectRegion,
                  ),
                  _GlassPill(
                    child: Text(
                      '${_collectedIds.length}/${_spots.length}',
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 카드 (FE-04에서 PageView 스와이프로 교체)
          if (cur != null)
            Positioned(
              left: 16, right: 16, bottom: 32,
              child: StoryCard(
                spot: cur,
                isCollected: _collectedIds.contains(cur.id),
                inRange: false, // FE-05에서 실제 거리 연동
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return _spots.map((spot) {
      final isActive = _spots[_activeIdx].id == spot.id;
      final isCollected = _collectedIds.contains(spot.id);
      final color = AppColors.forCategory(spot.category);
      final glyph = AppColors.glyphForCategory(spot.category);

      return Marker(
        point: LatLng(spot.lat, spot.lng),
        width: isActive ? 48 : 36,
        height: isActive ? 48 : 36,
        child: GestureDetector(
          onTap: () => setState(() => _activeIdx = _spots.indexOf(spot)),
          child: _SpotMarker(
            glyph: isCollected ? glyph : '?',
            color: isCollected ? color : AppColors.surfaceAlt,
            textColor: isCollected ? Colors.white : AppColors.inkMute,
            isActive: isActive,
            borderColor: color,
          ),
        ),
      );
    }).toList();
  }
}

class _SpotMarker extends StatelessWidget {
  final String glyph;
  final Color color;
  final Color textColor;
  final bool isActive;
  final Color borderColor;

  const _SpotMarker({
    required this.glyph,
    required this.color,
    required this.textColor,
    required this.isActive,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? borderColor : AppColors.line,
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: borderColor.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)]
            : null,
      ),
      child: Center(
        child: Text(
          glyph,
          style: TextStyle(
            fontSize: isActive ? 18 : 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _RegionPill extends StatelessWidget {
  final List<Map<String, Object>> regions;
  final String selected;
  final ValueChanged<String> onSelect;

  const _RegionPill({
    required this.regions,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final region = regions.firstWhere((r) => r['id'] == selected);
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              region['name']! as String,
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.inkMute),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          ...regions.map((r) => ListTile(
            title: Text(r['name']! as String,
              style: TextStyle(
                fontWeight: r['id'] == selected ? FontWeight.w700 : FontWeight.normal,
                color: r['id'] == selected ? AppColors.accent : AppColors.ink,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onSelect(r['id']! as String);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
