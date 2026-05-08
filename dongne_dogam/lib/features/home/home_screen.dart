import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/app_colors.dart';
import '../../data/models/story_spot.dart';
import '../../data/repositories/spot_repository.dart';
import '../story/story_screen.dart';
import 'widgets/notification_popup.dart';
import 'widgets/story_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = SpotRepository();
  NaverMapController? _mapController;

  String _regionId = 'seongsu';
  List<StorySpot> _spots = [];
  StorySpot? _selectedSpot;
  final Set<String> _collectedIds = {};
  final Map<String, NOverlayImage> _markerIconCache = {};

  // 실시간 GPS
  final Set<String> _inRangeIds = {};
  StreamSubscription<Position>? _positionSub;
  static const _rangeMeters = 1000.0;

  // 데모용 위치 설정
  NLatLng? _mockPosition;
  bool _locationPickMode = false;

  // 인앱 알림 팝업
  StorySpot? _popupSpot;
  final Set<String> _notifiedIds = {};
  bool _notifyResetFlash = false;

  static const _regions = [
    {'id': 'seongsu', 'name': '성수동',      'lat': 37.5446, 'lng': 127.0556},
    {'id': 'jeonju',  'name': '전주 한옥마을', 'lat': 35.8150, 'lng': 127.1530},
    {'id': 'yeongdo', 'name': '부산 영도',    'lat': 35.0780, 'lng': 129.0670},
  ];

  @override
  void initState() {
    super.initState();
    _loadSpots();
    _initLocationStream();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocationStream() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position pos) {
    if (_mockPosition != null) return;
    _updateInRange(pos.latitude, pos.longitude);
  }

  void _updateInRange(double lat, double lng) {
    final newInRange = <String>{};
    for (final spot in _spots) {
      final dist = Geolocator.distanceBetween(lat, lng, spot.lat, spot.lng);
      if (dist <= _rangeMeters) newInRange.add(spot.id);
    }
    if (newInRange == _inRangeIds) return;

    setState(() {
      _inRangeIds
        ..clear()
        ..addAll(newInRange);
    });
    _triggerPopupIfNeeded(lat, lng);
  }

  void _triggerPopupIfNeeded(double lat, double lng) {
    // 이미 알림을 보낸 적 없는 스팟 중 가장 가까운 것 선택
    StorySpot? closest;
    double minDist = double.infinity;
    for (final spot in _spots) {
      if (!_inRangeIds.contains(spot.id)) continue;
      if (_notifiedIds.contains(spot.id)) continue;
      final dist = Geolocator.distanceBetween(lat, lng, spot.lat, spot.lng);
      if (dist < minDist) {
        minDist = dist;
        closest = spot;
      }
    }
    if (closest == null) return;
    _notifiedIds.add(closest.id);
    setState(() => _popupSpot = closest);
  }

  Future<void> _loadSpots() async {
    final spots = await _repo.fetchSpots(_regionId);
    setState(() {
      _spots = spots;
      _selectedSpot = null;
      _markerIconCache.clear();
    });
    _moveToRegion();
    if (_mapController != null) await _refreshMarkers();
  }

  void _moveToRegion() {
    final region = _regions.firstWhere((r) => r['id'] == _regionId);
    _mapController?.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(region['lat']! as double, region['lng']! as double),
        zoom: 14,
      ),
    );
  }

  Future<void> _refreshMarkers() async {
    if (_mapController == null) return;
    await _mapController!.clearOverlays();
    final overlays = await _buildMarkers();
    if (_mockPosition != null) {
      overlays.addAll(_buildLocationOverlays(_mockPosition!));
    }
    await _mapController!.addOverlayAll(overlays);
  }

  Set<NAddableOverlay> _buildLocationOverlays(NLatLng pos) {
    final circle = NCircleOverlay(
      id: '__range_circle',
      center: pos,
      radius: 1000,
      color: AppColors.accent.withValues(alpha: 0.08),
      outlineColor: AppColors.accent.withValues(alpha: 0.35),
      outlineWidth: 1.5,
    );
    final dot = NCircleOverlay(
      id: '__my_location',
      center: pos,
      radius: 18,
      color: AppColors.accent.withValues(alpha: 0.9),
      outlineColor: Colors.white,
      outlineWidth: 2.5,
    );
    return {circle, dot};
  }

  Future<void> _moveToMyLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      _mapController?.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(pos.latitude, pos.longitude),
          zoom: 15,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 가져올 수 없습니다.')),
        );
      }
    }
  }

  void _openStory(StorySpot spot) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryScreen(
          spot: spot,
          isCollected: _collectedIds.contains(spot.id),
          onCollect: () {
            setState(() => _collectedIds.add(spot.id));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _selectRegion(String regionId) {
    setState(() => _regionId = regionId);
    _loadSpots();
  }

  void _selectSpot(StorySpot spot) {
    setState(() => _selectedSpot = spot);
    _refreshMarkers();
  }

  void _dismissCard() {
    if (_selectedSpot == null) return;
    setState(() => _selectedSpot = null);
    _refreshMarkers();
  }

  void _toggleLocationPickMode() {
    setState(() => _locationPickMode = !_locationPickMode);
  }

  void _onMapTapped(NPoint point, NLatLng coord) {
    if (_locationPickMode) {
      setState(() {
        _mockPosition = coord;
        _locationPickMode = false;
      });
      _updateInRange(coord.latitude, coord.longitude);
      _mapController?.updateCamera(
        NCameraUpdate.withParams(target: coord, zoom: 15),
      );
      _refreshMarkers();
      return;
    }
    _dismissCard();
  }

  Future<Set<NAddableOverlay>> _buildMarkers() async {
    final markers = <NAddableOverlay>{};
    for (final spot in _spots) {
      final isActive = _selectedSpot?.id == spot.id;
      final isCollected = _collectedIds.contains(spot.id);
      final color = AppColors.forCategory(spot.category);
      final glyph = AppColors.glyphForCategory(spot.category);
      final size = isActive ? 48.0 : 36.0;

      final cacheKey = '${spot.id}_${isActive}_$isCollected';
      final icon = _markerIconCache[cacheKey] ?? await NOverlayImage.fromWidget(
        widget: _SpotMarker(
          glyph: isCollected ? glyph : '?',
          color: isCollected ? color : AppColors.surfaceAlt,
          textColor: isCollected ? Colors.white : AppColors.inkMute,
          isActive: isActive,
          borderColor: color,
        ),
        size: Size(size, size),
        context: context,
      );
      _markerIconCache[cacheKey] = icon;

      final marker = NMarker(
        id: spot.id,
        position: NLatLng(spot.lat, spot.lng),
        icon: icon,
      );
      marker.setOnTapListener((_) => _selectSpot(spot));
      markers.add(marker);
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final region = _regions.firstWhere((r) => r['id'] == _regionId);

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  region['lat']! as double,
                  region['lng']! as double,
                ),
                zoom: 14,
              ),
              minZoom: 6,
              maxZoom: 20,
              scaleBarEnable: false,
              logoAlign: NLogoAlign.leftBottom,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              final markers = await _buildMarkers();
              await controller.addOverlayAll(markers);
            },
            onMapTapped: _onMapTapped,
          ),

          // 상단 floating: 지역명 + 수집 현황
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RegionPill(
                        regions: _regions,
                        selected: _regionId,
                        onSelect: _selectRegion,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _toggleLocationPickMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _locationPickMode
                                ? AppColors.accent
                                : AppColors.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _locationPickMode ? AppColors.accent : AppColors.line,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _locationPickMode ? Icons.close : Icons.location_on_outlined,
                                size: 13,
                                color: _locationPickMode ? Colors.white : AppColors.inkSub,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _locationPickMode ? '위치 선택 중... 취소' : '내 위치 설정',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _locationPickMode ? Colors.white : AppColors.inkSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassPill(
                        child: Text(
                          '${_collectedIds.length}/${_spots.length}',
                          style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _notifiedIds.clear();
                            _notifyResetFlash = true;
                          });
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) setState(() => _notifyResetFlash = false);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: _notifyResetFlash
                                ? AppColors.accent
                                : AppColors.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _notifyResetFlash ? AppColors.accent : AppColors.line,
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            size: 14,
                            color: _notifyResetFlash ? Colors.white : AppColors.inkSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 내 위치 버튼
          Positioned(
            right: 16,
            bottom: _selectedSpot != null ? 312 : 108,
            child: GestureDetector(
              onTap: _moveToMyLocation,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location, size: 20, color: AppColors.inkSub),
              ),
            ),
          ),

          // 인앱 알림 팝업
          if (_popupSpot != null)
            Positioned(
              top: 0, left: 0, right: 0,
              child: NotificationPopup(
                spot: _popupSpot!,
                onTap: () {
                  final spot = _popupSpot!;
                  setState(() => _popupSpot = null);
                  _openStory(spot);
                },
                onDismiss: () => setState(() => _popupSpot = null),
              ),
            ),

          // 하단 스토리 카드 (슬라이드 애니메이션)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            left: 16, right: 16,
            bottom: _selectedSpot != null ? 100 : -200,
            child: _selectedSpot != null
                ? StoryCard(
                    spot: _selectedSpot!,
                    isCollected: _collectedIds.contains(_selectedSpot!.id),
                    inRange: _inRangeIds.contains(_selectedSpot!.id),
                    onTap: () => _openStory(_selectedSpot!),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
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
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.line, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ...regions.map((r) => ListTile(
            title: Text(
              r['name']! as String,
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
