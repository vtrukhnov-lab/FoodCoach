// lib/widgets/achievement_stats_card.dart
import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementStatsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  
  const AchievementStatsCard({
    super.key,
    required this.statistics,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedCount = statistics['unlockedCount'] ?? 0;
    final totalCount = statistics['totalAchievements'] ?? 1;
    final unlockedPercent = statistics['unlockedPercent'] ?? 0;
    final totalPoints = statistics['totalPoints'] ?? 0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main progress circle
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: unlockedCount / totalCount,
                strokeWidth: 8,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$unlockedPercent%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$unlockedCount/$totalCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Total points
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                size: 20,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                '$totalPoints points',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Category breakdown
        if (statistics['unlockedByCategory'] != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AchievementCategory.values.map((category) {
              final count = (statistics['unlockedByCategory'] 
                  as Map<AchievementCategory, int>)[category] ?? 0;
              
              if (count == 0) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: category.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}