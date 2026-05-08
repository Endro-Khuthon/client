import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../data/models/story_spot.dart';

class StoryCard extends StatelessWidget {
  final StorySpotSummary spot;
  final bool isCollected;
  final bool inRange;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.spot,
    required this.isCollected,
    required this.inRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.forCategory(spot.category);

    return GestureDetector(
      onTap: inRange ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CategoryChip(category: spot.category, color: catColor),
                Text(
                  inRange ? '● 1km 이내' : '○ 거리 측정 중',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: inRange ? AppColors.accent : AppColors.inkMute,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              spot.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              spot.summary,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: AppColors.inkSub,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: inRange ? onTap : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inRange ? AppColors.accent : AppColors.surfaceAlt,
                        foregroundColor: inRange ? Colors.white : AppColors.inkMute,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        inRange ? '이야기 읽기' : '더 가까이 가야 해요',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final Color color;

  const _CategoryChip({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}
