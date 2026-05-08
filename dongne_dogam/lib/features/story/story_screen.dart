import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/story_spot.dart';

class StoryScreen extends StatelessWidget {
  final StorySpot spot;
  final bool isCollected;
  final VoidCallback onCollect;

  const StoryScreen({
    super.key,
    required this.spot,
    required this.isCollected,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forCategory(spot.category);
    final glyph = AppColors.glyphForCategory(spot.category);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // 상단 헤더
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.bg,
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
              background: Container(
                color: color.withValues(alpha: 0.08),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            glyph,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          spot.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        spot.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 본문
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // summary
                  Text(
                    spot.summary,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.65,
                      color: AppColors.inkSub,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _StorySection(label: '과거', color: color, content: spot.storyPast),
                  const SizedBox(height: 20),
                  _StorySection(label: '현재', color: color, content: spot.storyPresent),
                  const SizedBox(height: 20),
                  _StorySection(label: '의미', color: color, content: spot.storyMeaning),
                  const SizedBox(height: 28),

                  // 키워드 태그
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: spot.keywords.map((kw) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Text(
                        '# $kw',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 32),

                  // 수집 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isCollected ? null : onCollect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCollected ? AppColors.surfaceAlt : color,
                        foregroundColor: isCollected ? AppColors.inkMute : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCollected ? Icons.check_circle : Icons.add_circle_outline,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCollected ? '수집 완료' : '스토리 수집하기',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  final String label;
  final Color color;
  final String content;

  const _StorySection({
    required this.label,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.75,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
