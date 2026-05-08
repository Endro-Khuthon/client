import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/story_spot.dart';

class StoryScreen extends StatefulWidget {
  final StorySpot spot;
  final bool isCollected;
  final Future<void> Function() onCollect;

  const StoryScreen({
    super.key,
    required this.spot,
    required this.isCollected,
    required this.onCollect,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _overlayCtrl;
  late final Animation<double> _overlayAnim;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _overlayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _overlayAnim = CurvedAnimation(parent: _overlayCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _overlayCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCollect() async {
    setState(() => _showOverlay = true);
    await widget.onCollect();
    await _overlayCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _overlayCtrl.reverse();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forCategory(widget.spot.category);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: widget.isCollected ? null : _handleCollect,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCollected ? AppColors.surfaceAlt : color,
                foregroundColor: widget.isCollected ? AppColors.inkMute : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isCollected ? Icons.check_circle : Icons.add_circle_outline,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isCollected ? '수집 완료' : '스토리 수집하기',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── 헤더 ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.bg,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.spot.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.spot.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, stack) => Container(color: color.withValues(alpha: 0.12)),
                        )
                      : Container(color: color.withValues(alpha: 0.12)),
                ),
              ),

              // ── 본문 ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // summary — italic lead
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: color.withValues(alpha: 0.5), width: 3),
                          ),
                        ),
                        child: Text(
                          widget.spot.summary,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: AppColors.inkSub,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 섹션 카드 3개
                      _StoryCard(label: '과거', color: color, content: widget.spot.storyPast),
                      const SizedBox(height: 12),
                      _StoryCard(label: '현재', color: color, content: widget.spot.storyPresent),
                      const SizedBox(height: 12),
                      _StoryCard(label: '의미', color: color, content: widget.spot.storyMeaning),
                      const SizedBox(height: 28),

                      // 키워드 태그
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.spot.keywords.map((kw) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: color.withValues(alpha: 0.20)),
                          ),
                          child: Text(
                            '# $kw',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                              letterSpacing: 0.2,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 수집 완료 오버레이
          if (_showOverlay)
            FadeTransition(
              opacity: _overlayAnim,
              child: Container(
                color: AppColors.bg.withValues(alpha: 0.92),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle, size: 36, color: color),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '스토리를 수집했어요',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '도감에서 확인할 수 있어요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 섹션 카드 — 흰 배경 + 상단 컬러 bar
class _StoryCard extends StatelessWidget {
  final String label;
  final Color color;
  final String content;

  const _StoryCard({
    required this.label,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 컬러 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: color.withValues(alpha: 0.09),
            child: Row(
              children: [
                Container(
                  width: 3, height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // 본문
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.8,
                color: AppColors.ink,
                letterSpacing: 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
