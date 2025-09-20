// lib/widgets/achievement_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement.dart';
import '../l10n/app_localizations.dart';
import '../services/units_service.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;
  final bool compact;
  
  const AchievementCard({
    Key? key,
    required this.achievement,
    this.onTap,
    this.compact = false,
  }) : super(key: key);
  
  // ✅ ИСПРАВЛЕНО: Переводим ключи локализации в реальные тексты
  String _getLocalizedName(AppLocalizations l10n, Achievement achievement) {
    switch (achievement.name) {
      // Hydration achievements
      case 'achievementFirstGlass':
        return l10n.achievementFirstGlass;
      case 'achievementHydrationGoal1':
        return l10n.achievementHydrationGoal1;
      case 'achievementHydrationGoal7':
        return l10n.achievementHydrationGoal7;
      case 'achievementHydrationGoal30':
        return l10n.achievementHydrationGoal30;
      case 'achievementPerfectHydration':
        return l10n.achievementPerfectHydration;
      case 'achievementEarlyBird':
        return l10n.achievementEarlyBird;
      case 'achievementNightOwl':
        return l10n.achievementNightOwl;
      case 'achievementLiterLegend':
        return l10n.achievementLiterLegend;
      
      // Electrolyte achievements
      case 'achievementSaltStarter':
        return l10n.achievementSaltStarter;
      case 'achievementElectrolyteBalance':
        return l10n.achievementElectrolyteBalance;
      case 'achievementSodiumMaster':
        return l10n.achievementSodiumMaster;
      case 'achievementPotassiumPro':
        return l10n.achievementPotassiumPro;
      case 'achievementMagnesiumMaven':
        return l10n.achievementMagnesiumMaven;
      case 'achievementElectrolyteExpert':
        return l10n.achievementElectrolyteExpert;
      
      // Sugar achievements
      case 'achievementSugarAwareness':
        return l10n.achievementSugarAwareness;
      case 'achievementSugarUnder25':
        return l10n.achievementSugarUnder25;
      case 'achievementSugarWeekControl':
        return l10n.achievementSugarWeekControl;
      case 'achievementSugarFreeDay':
        return l10n.achievementSugarFreeDay;
      case 'achievementSugarDetective':
        return l10n.achievementSugarDetective;
      case 'achievementSugarMaster':
        return l10n.achievementSugarMaster;
      case 'achievementNoSodaWeek':
        return l10n.achievementNoSodaWeek;
      case 'achievementNoSodaMonth':
        return l10n.achievementNoSodaMonth;
      case 'achievementSweetToothTamed':
        return l10n.achievementSweetToothTamed;
      
      // Alcohol achievements
      case 'achievementAlcoholTracker':
        return l10n.achievementAlcoholTracker;
      case 'achievementModerateDay':
        return l10n.achievementModerateDay;
      case 'achievementSoberDay':
        return l10n.achievementSoberDay;
      case 'achievementSoberWeek':
        return l10n.achievementSoberWeek;
      case 'achievementSoberMonth':
        return l10n.achievementSoberMonth;
      case 'achievementRecoveryProtocol':
        return l10n.achievementRecoveryProtocol;
      
      // Workout achievements
      case 'achievementFirstWorkout':
        return l10n.achievementFirstWorkout;
      case 'achievementWorkoutWeek':
        return l10n.achievementWorkoutWeek;
      case 'achievementCenturySweat':
        return l10n.achievementCenturySweat;
      case 'achievementCardioKing':
        return l10n.achievementCardioKing;
      case 'achievementStrengthWarrior':
        return l10n.achievementStrengthWarrior;
      
      // HRI achievements
      case 'achievementHRIGreen':
        return l10n.achievementHRIGreen;
      case 'achievementHRIWeekGreen':
        return l10n.achievementHRIWeekGreen;
      case 'achievementHRIPerfect':
        return l10n.achievementHRIPerfect;
      case 'achievementHRIRecovery':
        return l10n.achievementHRIRecovery;
      case 'achievementHRIMaster':
        return l10n.achievementHRIMaster;
      
      // Streak achievements
      case 'achievementStreak3':
        return l10n.achievementStreak3;
      case 'achievementStreak7':
        return l10n.achievementStreak7;
      case 'achievementStreak30':
        return l10n.achievementStreak30;
      case 'achievementStreak100':
        return l10n.achievementStreak100;
      
      // Special achievements
      case 'achievementFirstWeek':
        return l10n.achievementFirstWeek;
      case 'achievementProMember':
        return l10n.achievementProMember;
      case 'achievementDataExport':
        return l10n.achievementDataExport;
      case 'achievementAllCategories':
        return l10n.achievementAllCategories;
      case 'achievementHunter':
        return l10n.achievementHunter;
      
      default:
        return achievement.name; // fallback для неизвестных ключей
    }
  }
  
  // ✅ ИСПРАВЛЕНО: Переводим ключи описаний в реальные тексты
  String _getLocalizedDescription(AppLocalizations l10n, Achievement achievement) {
    switch (achievement.description) {
      // Hydration achievement descriptions
      case 'achievementFirstGlassDesc':
        return l10n.achievementFirstGlassDesc;
      case 'achievementHydrationGoal1Desc':
        return l10n.achievementHydrationGoal1Desc;
      case 'achievementHydrationGoal7Desc':
        return l10n.achievementHydrationGoal7Desc;
      case 'achievementHydrationGoal30Desc':
        return l10n.achievementHydrationGoal30Desc;
      case 'achievementPerfectHydrationDesc':
        return l10n.achievementPerfectHydrationDesc;
      case 'achievementEarlyBirdDesc':
        return l10n.achievementEarlyBirdDesc;
      case 'achievementNightOwlDesc':
        return l10n.achievementNightOwlDesc;
      case 'achievementLiterLegendDesc':
        return l10n.achievementLiterLegendDesc;
      
      // Electrolyte achievement descriptions
      case 'achievementSaltStarterDesc':
        return l10n.achievementSaltStarterDesc;
      case 'achievementElectrolyteBalanceDesc':
        return l10n.achievementElectrolyteBalanceDesc;
      case 'achievementSodiumMasterDesc':
        return l10n.achievementSodiumMasterDesc;
      case 'achievementPotassiumProDesc':
        return l10n.achievementPotassiumProDesc;
      case 'achievementMagnesiumMavenDesc':
        return l10n.achievementMagnesiumMavenDesc;
      case 'achievementElectrolyteExpertDesc':
        return l10n.achievementElectrolyteExpertDesc;
      
      // Sugar achievement descriptions
      case 'achievementSugarAwarenessDesc':
        return l10n.achievementSugarAwarenessDesc;
      case 'achievementSugarUnder25Desc':
        return l10n.achievementSugarUnder25Desc;
      case 'achievementSugarWeekControlDesc':
        return l10n.achievementSugarWeekControlDesc;
      case 'achievementSugarFreeDayDesc':
        return l10n.achievementSugarFreeDayDesc;
      case 'achievementSugarDetectiveDesc':
        return l10n.achievementSugarDetectiveDesc;
      case 'achievementSugarMasterDesc':
        return l10n.achievementSugarMasterDesc;
      case 'achievementNoSodaWeekDesc':
        return l10n.achievementNoSodaWeekDesc;
      case 'achievementNoSodaMonthDesc':
        return l10n.achievementNoSodaMonthDesc;
      case 'achievementSweetToothTamedDesc':
        return l10n.achievementSweetToothTamedDesc;
      
      // Alcohol achievement descriptions
      case 'achievementAlcoholTrackerDesc':
        return l10n.achievementAlcoholTrackerDesc;
      case 'achievementModerateDayDesc':
        return l10n.achievementModerateDayDesc;
      case 'achievementSoberDayDesc':
        return l10n.achievementSoberDayDesc;
      case 'achievementSoberWeekDesc':
        return l10n.achievementSoberWeekDesc;
      case 'achievementSoberMonthDesc':
        return l10n.achievementSoberMonthDesc;
      case 'achievementRecoveryProtocolDesc':
        return l10n.achievementRecoveryProtocolDesc;
      
      // Workout achievement descriptions
      case 'achievementFirstWorkoutDesc':
        return l10n.achievementFirstWorkoutDesc;
      case 'achievementWorkoutWeekDesc':
        return l10n.achievementWorkoutWeekDesc;
      case 'achievementCenturySweatDesc':
        return l10n.achievementCenturySweatDesc;
      case 'achievementCardioKingDesc':
        return l10n.achievementCardioKingDesc;
      case 'achievementStrengthWarriorDesc':
        return l10n.achievementStrengthWarriorDesc;
      
      // HRI achievement descriptions
      case 'achievementHRIGreenDesc':
        return l10n.achievementHRIGreenDesc;
      case 'achievementHRIWeekGreenDesc':
        return l10n.achievementHRIWeekGreenDesc;
      case 'achievementHRIPerfectDesc':
        return l10n.achievementHRIPerfectDesc;
      case 'achievementHRIRecoveryDesc':
        return l10n.achievementHRIRecoveryDesc;
      case 'achievementHRIMasterDesc':
        return l10n.achievementHRIMasterDesc;
      
      // Streak achievement descriptions
      case 'achievementStreak3Desc':
        return l10n.achievementStreak3Desc;
      case 'achievementStreak7Desc':
        return l10n.achievementStreak7Desc;
      case 'achievementStreak30Desc':
        return l10n.achievementStreak30Desc;
      case 'achievementStreak100Desc':
        return l10n.achievementStreak100Desc;
      
      // Special achievement descriptions
      case 'achievementFirstWeekDesc':
        return l10n.achievementFirstWeekDesc;
      case 'achievementProMemberDesc':
        return l10n.achievementProMemberDesc;
      case 'achievementDataExportDesc':
        return l10n.achievementDataExportDesc;
      case 'achievementAllCategoriesDesc':
        return l10n.achievementAllCategoriesDesc;
      case 'achievementHunterDesc':
        return l10n.achievementHunterDesc;
      
      default:
        // Если есть template, используем getLocalizedDescription из модели
        return achievement.getLocalizedDescription();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isUnlocked = achievement.isUnlocked;
    
    // ✅ ИСПРАВЛЕНО: Используем новую систему локализации
    final localizedName = _getLocalizedName(l10n, achievement);
    final localizedDescription = _getLocalizedDescription(l10n, achievement);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked 
                  ? achievement.rarity.color.withValues(alpha: 0.3)
                  : theme.dividerColor.withValues(alpha: 0.1),
              width: isUnlocked ? 2 : 1,
            ),
            boxShadow: [
              if (isUnlocked)
                BoxShadow(
                  color: achievement.rarity.color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: compact ? 48 : 56,
                height: compact ? 48 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? achievement.category.color.withValues(alpha: 0.1)
                      : theme.dividerColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isUnlocked
                        ? achievement.category.color.withValues(alpha: 0.3)
                        : theme.dividerColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isUnlocked
                        ? Text(
                            achievement.icon,
                            key: ValueKey('unlocked'),
                            style: TextStyle(fontSize: compact ? 24 : 28),
                          )
                        : Icon(
                            Icons.lock_outline,
                            key: ValueKey('locked'),
                            size: compact ? 20 : 24,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizedName, // ✅ Использует локализованное название
                            style: TextStyle(
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 8),
                          // Points badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: isUnlocked
                                      ? Colors.amber
                                      : Colors.amber.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${achievement.rewardPoints}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked
                                        ? Colors.amber
                                        : Colors.amber.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        localizedDescription, // ✅ Использует локализованное описание с единицами
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Progress bar or unlock date
                    if (isUnlocked) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.achievementUnlocked,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Rarity badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: achievement.rarity.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getLocalizedRarity(l10n, achievement.rarity),
                              style: TextStyle(
                                fontSize: 10,
                                color: achievement.rarity.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    // ✅ ИСПРАВЛЕНО: Используем локализованный процент прогресса
                                    value: achievement.localizedProgressPercent / 100,
                                    backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      achievement.category.color.withValues(alpha: 0.8),
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ✅ ИСПРАВЛЕНО: Показываем локализованный прогресс
                              Text(
                                '${achievement.currentProgress}/${achievement.getLocalizedMaxProgress()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getLocalizedRarity(AppLocalizations l10n, AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return l10n.achievementRarityCommon;
      case AchievementRarity.uncommon:
        return l10n.achievementRarityUncommon; // ✅ ИСПРАВЛЕНО: Используем правильный ключ
      case AchievementRarity.rare:
        return l10n.achievementRarityRare;
      case AchievementRarity.epic:
        return l10n.achievementRarityEpic;
      case AchievementRarity.legendary:
        return l10n.achievementRarityLegendary;
    }
  }
}

/// Mini achievement card for notifications/popups
class AchievementMiniCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;
  
  const AchievementMiniCard({
    Key? key,
    required this.achievement,
    this.onDismiss,
  }) : super(key: key);
  
  // ✅ ИСПРАВЛЕНО: Упрощенные методы через AppLocalizations
  String _getLocalizedName(AppLocalizations l10n, Achievement achievement) {
    // Просто возвращаем название достижения как есть
    return achievement.name;
  }
  
  String _getLocalizedDescription(AppLocalizations l10n, Achievement achievement) {
    return achievement.getLocalizedDescription() ?? achievement.description;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement.rarity.color.withValues(alpha: 0.5),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                achievement.rarity.color.withValues(alpha: 0.1),
                achievement.rarity.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Shimmer effect
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: achievement.category.color.withValues(alpha: 0.2),
                        border: Border.all(
                          color: achievement.category.color,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.achievementUnlocked,
                            style: TextStyle(
                              fontSize: 10,
                              color: achievement.rarity.color,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getLocalizedName(l10n, achievement), // ✅ Локализованное название
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getLocalizedDescription(l10n, achievement), // ✅ Локализованное описание с единицами
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button
                    if (onDismiss != null)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        onPressed: onDismiss,
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
}