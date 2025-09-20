import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import '../l10n/app_localizations.dart';

class AchievementOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const AchievementOverlay({
    super.key,
    required this.achievement,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<AchievementOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: widget.displayDuration,
      vsync: this,
    );

    _controller.forward();
    _progressController.forward().then((_) {
      if (!_isDismissed && mounted) {
        _dismiss();
      }
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;

    HapticFeedback.lightImpact();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  String _getLocalizedTitle(AppLocalizations l10n) {
    // Проверяем name напрямую - он должен содержать ключ локализации
    print('DEBUG: achievement.name = "${widget.achievement.name}"');
    
    switch (widget.achievement.name) {
      case 'achievementFirstGlass':
        return l10n.achievementFirstGlass;
      case 'achievementSaltStarter':
        return l10n.achievementSaltStarter;
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
      case 'achievementStreak3':
        return l10n.achievementStreak3;
      case 'achievementStreak7':
        return l10n.achievementStreak7;
      case 'achievementStreak30':
        return l10n.achievementStreak30;
      case 'achievementStreak100':
        return l10n.achievementStreak100;
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
        // Fallback на оригинальное название
        return widget.achievement.name;
    }
  }

  String _getLocalizedDescription(AppLocalizations l10n) {
    // Проверяем description напрямую - он должен содержать ключ локализации
    switch (widget.achievement.description) {
      case 'achievementFirstGlassDesc':
        return l10n.achievementFirstGlassDesc;
      case 'achievementSaltStarterDesc':
        return l10n.achievementSaltStarterDesc;
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
      case 'achievementStreak3Desc':
        return l10n.achievementStreak3Desc;
      case 'achievementStreak7Desc':
        return l10n.achievementStreak7Desc;
      case 'achievementStreak30Desc':
        return l10n.achievementStreak30Desc;
      case 'achievementStreak100Desc':
        return l10n.achievementStreak100Desc;
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
        // Fallback на оригинальное описание
        return widget.achievement.description;
    }
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey.shade600;
      case AchievementRarity.uncommon:
        return Colors.green.shade600;
      case AchievementRarity.rare:
        return Colors.blue.shade600;
      case AchievementRarity.epic:
        return Colors.purple.shade600;
      case AchievementRarity.legendary:
        return Colors.amber.shade600;
    }
  }

  String _getRarityText(AppLocalizations l10n, AchievementRarity rarity) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: Curves.elasticOut.transform(_controller.value),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      (1 - _controller.value) * 50,
                    ),
                    child: Opacity(
                      opacity: _controller.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress bar
                            Container(
                              height: 3,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 1 - _progressController.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Header
                            Text(
                              l10n.achievementUnlocked,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ).animate().fadeIn(delay: 200.ms),

                            const SizedBox(height: 16),

                            // Achievement icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _getRarityColor(widget.achievement.rarity)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _getRarityColor(widget.achievement.rarity),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.achievement.icon,
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                            )
                                .animate()
                                .scale(delay: 300.ms, duration: 600.ms)
                                .then()
                                .shake(duration: 200.ms),

                            const SizedBox(height: 20),

                            // Achievement name
                            Text(
                              _getLocalizedTitle(l10n),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 400.ms),

                            const SizedBox(height: 8),

                            // Achievement description
                            Text(
                              _getLocalizedDescription(l10n),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 500.ms),

                            const SizedBox(height: 20),

                            // Rarity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getRarityColor(widget.achievement.rarity),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getRarityText(l10n, widget.achievement.rarity),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ).animate().fadeIn(delay: 600.ms),

                            const SizedBox(height: 16),

                            // Dismiss hint
                            Text(
                              l10n.tapToDismiss,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ).animate().fadeIn(delay: 800.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}