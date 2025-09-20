// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_tracker.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_stats_card.dart';
import '../services/analytics_service.dart';
import '../l10n/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> 
    with TickerProviderStateMixin {
  final AchievementTracker _tracker = AchievementTracker();
  final AnalyticsService _analytics = AnalyticsService();
  
  late TabController _tabController;
  AchievementCategory? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementCategory.values.length + 1, 
      vsync: this
    );
    _tabController.addListener(_onTabChanged);
    
    // Log screen view
    _analytics.logScreenView(
      screenName: 'achievements',
      screenClass: 'AchievementsScreen',
    );
    
    // Initialize tracker
    _tracker.initialize();
    _tracker.addListener(_onTrackerUpdate);
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tracker.removeListener(_onTrackerUpdate);
    super.dispose();
  }
  
  void _onTrackerUpdate() {
    if (mounted) setState(() {});
  }
  
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 0) {
          _selectedCategory = null;
          // Mark all categories as viewed when on "All" tab
          _tracker.markAllAsViewed();
        } else {
          final category = AchievementCategory.values[_tabController.index - 1];
          _selectedCategory = category;
          // Mark specific category as viewed
          _tracker.markCategoryAsViewed(category);
        }
      });
      
      // Haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  // ✅ ДОБАВЛЕНО: Метод перевода категорий
  String _getCategoryLocalizedTitle(AppLocalizations l10n, AchievementCategory category) {
    switch (category) {
      case AchievementCategory.hydration:
        return l10n.achievementsTabHydration;
      case AchievementCategory.electrolytes:
        return l10n.achievementsTabElectrolytes;
      case AchievementCategory.sugar:
        return l10n.achievementsTabSugar;
      case AchievementCategory.alcohol:
        return l10n.achievementsTabAlcohol;
      case AchievementCategory.workout:
        return l10n.achievementsTabWorkout;
      case AchievementCategory.hri:
        return l10n.achievementsTabHRI;
      case AchievementCategory.streaks:
        return l10n.achievementsTabStreaks;
      case AchievementCategory.special:
        return l10n.achievementsTabSpecial;
    }
  }
  
  List<Achievement> _getFilteredAchievements() {
    List<Achievement> achievements;
    
    if (_selectedCategory == null) {
      achievements = _tracker.getAllAchievements();
    } else {
      achievements = _tracker.getAchievementsByCategory(_selectedCategory!);
    }
    
    // ✅ ИСПРАВЛЕНО: Sort by localized progress (unlocked first, then by localized progress percentage)
    achievements.sort((a, b) {
      if (a.isUnlocked != b.isUnlocked) {
        return a.isUnlocked ? -1 : 1;
      }
      return b.localizedProgressPercent.compareTo(a.localizedProgressPercent);
    });
    
    return achievements;
  }

  Widget _buildTabWithIndicator(String text, AchievementCategory? category) {
    return AnimatedBuilder(
      animation: _tracker,
      builder: (context, child) {
        final hasNew = category != null && _tracker.hasNewInCategory(category);
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Text(text),
            ),
            if (hasNew)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTabWithIndicator(AchievementCategory category, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _tracker,
      builder: (context, child) {
        final hasNew = _tracker.hasNewInCategory(category);
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.emoji),
                  const SizedBox(width: 4),
                  // ✅ ИСПРАВЛЕНО: Используем локализованные названия
                  Text(_getCategoryLocalizedTitle(l10n, category)),
                ],
              ),
            ),
            if (hasNew)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final stats = _tracker.getStatistics();
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.achievements),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                // ✅ ИСПРАВЛЕНО: Используем локализованное "Все"
                Tab(child: _buildTabWithIndicator(l10n.achievementsTabAll, null)),
                ...AchievementCategory.values.map((category) => Tab(
                  child: _buildCategoryTabWithIndicator(category, l10n),
                )),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Achievement counter badge with X/Y format
                AnimatedBuilder(
                  animation: _tracker,
                  builder: (context, child) {
                    final totalNew = _tracker.unlockedQueue.length;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stats['unlockedCount']}/${stats['totalAchievements']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (totalNew > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Thin progress bar with only percentage
                Expanded(
                  child: Container(
                    height: 18,
                    child: Stack(
                      children: [
                        // Background bar
                        Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        // Progress fill
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          widthFactor: (stats['unlockedCount'] as int) / (stats['totalAchievements'] as int),
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                        // Percentage text overlay
                        Center(
                          child: Text(
                            '${((stats['unlockedCount'] as int) / (stats['totalAchievements'] as int) * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Achievements list
          Expanded(
            child: AnimatedBuilder(
              animation: _tracker,
              builder: (context, child) {
                final achievements = _getFilteredAchievements();
                
                if (achievements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_outlined,
                            size: 40,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.achievementNoAchievements,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.achievementKeepUsing,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AchievementCard(
                        achievement: achievement,
                        onTap: () {
                          // УБРАНО: Модальное окно больше не показывается
                          HapticFeedback.lightImpact();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAchievementDetails(Achievement achievement) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AchievementDetailsSheet(achievement: achievement),
    );
    
    _analytics.logAchievementViewed(
      achievementId: achievement.id,
      achievementName: achievement.name,
      category: achievement.category.name,
      isUnlocked: achievement.isUnlocked,
    );
  }
}

/// Bottom sheet for achievement details
class AchievementDetailsSheet extends StatelessWidget {
  final Achievement achievement;
  
  const AchievementDetailsSheet({
    super.key,
    required this.achievement,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon with rarity glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      achievement.rarity.color.withValues(alpha: 0.3),
                      achievement.rarity.color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name
              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // ✅ ИСПРАВЛЕНО: Description with proper units
              Text(
                achievement.getLocalizedDescription(),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Category and rarity
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: achievement.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(achievement.category.emoji),
                        const SizedBox(width: 4),
                        // ✅ ИСПРАВЛЕНО: Используем локализованное название категории
                        Text(
                          _getCategoryLocalizedTitle(AppLocalizations.of(context)!, achievement.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: achievement.category.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: achievement.rarity.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRarityLocalizedLabel(l10n, achievement.rarity),
                      style: TextStyle(
                        fontSize: 12,
                        color: achievement.rarity.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Progress
              if (!achievement.isUnlocked) ...[
                LinearProgressIndicator(
                  // ✅ ИСПРАВЛЕНО: Use localized progress percent
                  value: achievement.localizedProgressPercent / 100,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    achievement.category.color,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  // ✅ ИСПРАВЛЕНО: Use localized max progress
                  '${achievement.currentProgress} / ${achievement.getLocalizedMaxProgress()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.achievementDetailsUnlockedOn} ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
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
                      '${achievement.rewardPoints} ${l10n.points}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ДОБАВЛЕНО: Метод для локализации категорий в деталях
  String _getCategoryLocalizedTitle(AppLocalizations l10n, AchievementCategory category) {
    switch (category) {
      case AchievementCategory.hydration:
        return l10n.achievementsTabHydration;
      case AchievementCategory.electrolytes:
        return l10n.achievementsTabElectrolytes;
      case AchievementCategory.sugar:
        return l10n.achievementsTabSugar;
      case AchievementCategory.alcohol:
        return l10n.achievementsTabAlcohol;
      case AchievementCategory.workout:
        return l10n.achievementsTabWorkout;
      case AchievementCategory.hri:
        return l10n.achievementsTabHRI;
      case AchievementCategory.streaks:
        return l10n.achievementsTabStreaks;
      case AchievementCategory.special:
        return l10n.achievementsTabSpecial;
    }
  }

  // ✅ ДОБАВЛЕНО: Метод для локализации редкости
  String _getRarityLocalizedLabel(AppLocalizations l10n, AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return l10n.achievementRarityCommon;
      case AchievementRarity.uncommon:
        return l10n.achievementRarityUncommon;
      case AchievementRarity.rare:
        return l10n.achievementRarityRare;
      case AchievementRarity.epic:
        return l10n.achievementRarityEpic;
      case AchievementRarity.legendary:
        return l10n.achievementRarityLegendary;
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}