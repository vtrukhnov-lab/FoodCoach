// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

// Services
import '../services/hri_service.dart';
import '../services/weather_service.dart';
import '../services/alcohol_service.dart';
import '../services/achievement_tracker.dart';

// Providers
import '../providers/hydration_provider.dart';

// Screens
import '../screens/achievements_screen.dart';

// Widgets
import '../widgets/home/home_header.dart';
import '../widgets/home/weather_card.dart';
import '../widgets/home/main_progress_card.dart';
import '../widgets/home/electrolytes_card.dart';
import '../widgets/home/hri_status_card.dart';
import '../widgets/home/sugar_intake_card.dart';
import '../widgets/home/food_intake_card.dart';
import '../widgets/achievement_overlay.dart';
import '../models/achievement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _fastingSchedule = '16:8';
  bool _isInitialized = false;
  int _currentIndex = 0;
  late PageController _pageController;
  final AchievementTracker _achievementTracker = AchievementTracker();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _removeListeners();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateHRI();
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      _updateHRI();
    }
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    
    // Initialize achievement tracker
    await _achievementTracker.initialize();
    
    // ✅ ИСПРАВЛЕНО: Слушаем изменения в AchievementTracker только для обновления UI
    _achievementTracker.addListener(_onAchievementTrackerChanged);
    
    final alcohol = Provider.of<AlcoholService>(context, listen: false);
    alcohol.addListener(_onAlcoholChanged);
    
    final weather = Provider.of<WeatherService>(context, listen: false);
    weather.addListener(_onWeatherChanged);
    await weather.loadWeather();
    
    final hydrationProvider = Provider.of<HydrationProvider>(context, listen: false);
    
    // Pass context to HydrationProvider for AchievementService
    hydrationProvider.setContext(context);
    
    hydrationProvider.addListener(() {
      if (mounted) _updateHRI();
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyAlcoholAdjustments();
      _updateHRI();
      _checkMorningCheckin();
      setState(() => _isInitialized = true);
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _fastingSchedule = prefs.getString('fastingSchedule') ?? '16:8';
      });
    }
  }

  void _removeListeners() {
    try {
      final alcohol = Provider.of<AlcoholService>(context, listen: false);
      alcohol.removeListener(_onAlcoholChanged);
      final weather = Provider.of<WeatherService>(context, listen: false);
      weather.removeListener(_onWeatherChanged);
      _achievementTracker.removeListener(_onAchievementTrackerChanged);
    } catch (e) {
      debugPrint("Error removing listeners: $e");
    }
  }

  // ✅ ИСПРАВЛЕНО: Только обновляем UI, НЕ удаляем достижения из очереди
  void _onAchievementTrackerChanged() {
    if (!mounted) return;
    
    // Просто обновляем UI для показа красной точки
    setState(() {});
  }

  void _onIntakeUpdated() {
    setState(() {});
    _updateHRI();
  }

  void _onAlcoholChanged() {
    if (!mounted) return;
    _applyAlcoholAdjustments();
    _updateHRI();
  }

  void _onWeatherChanged() {
    if (!mounted) return;
    _updateHRI();
  }

  void _checkMorningCheckin() {
    final alcohol = Provider.of<AlcoholService>(context, listen: false);
    if (alcohol.totalStandardDrinks > 0 && DateTime.now().hour < 12) {
      debugPrint('Morning check-in needed after alcohol');
    }
  }

  void _applyAlcoholAdjustments() {
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    final alcohol = Provider.of<AlcoholService>(context, listen: false);
    
    provider.updateAlcoholAdjustments(
      alcohol.totalWaterCorrection,
      alcohol.totalSodiumCorrection.round(),
    );
  }

  void _updateHRI() {
    if (!mounted) return;
    
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    final hri = Provider.of<HRIService>(context, listen: false);
    final alcohol = Provider.of<AlcoholService>(context, listen: false);
    final weather = Provider.of<WeatherService>(context, listen: false);
    
    DateTime? lastIntakeTime = provider.todayIntakes.isNotEmpty 
        ? provider.todayIntakes.last.timestamp 
        : null;
        
    bool isFasting = _isCurrentlyFasting(provider);
    hri.setFastingStatus(isFasting);
    
    final sugarData = provider.getSugarIntakeData(context);
    
    hri.calculateHRI(
      waterIntake: provider.totalWaterToday,
      waterGoal: provider.goals.waterOpt.toDouble(),
      sodiumIntake: provider.totalSodiumToday.toDouble(),
      sodiumGoal: provider.goals.sodium.toDouble(),
      potassiumIntake: provider.totalPotassiumToday.toDouble(),
      potassiumGoal: provider.goals.potassium.toDouble(),
      magnesiumIntake: provider.totalMagnesiumToday.toDouble(),
      magnesiumGoal: provider.goals.magnesium.toDouble(),
      heatIndex: weather.heatIndex,
      coffeeCups: provider.coffeeCupsToday,
      alcoholSD: alcohol.totalStandardDrinks,
      sugarIntake: sugarData.totalGrams,
      lastIntakeTime: lastIntakeTime,
      userWeightKg: provider.weight,
      // NEW: Add food data
      foodWaterContent: provider.totalWaterFromFoodToday,
      foodSodiumIntake: provider.todayFoodIntakes.fold(0.0, (sum, food) => sum + food.sodium),
      foodCount: provider.todayFoodIntakes.length,
      foodSugarIntake: provider.todayFoodIntakes.fold(0.0, (sum, food) => sum + food.sugar),
    );
  }

  bool _isCurrentlyFasting(HydrationProvider provider) {
    if (provider.dietMode != 'fasting') return false;
    final hour = DateTime.now().hour;
    switch (_fastingSchedule) {
      case '16:8':
        return hour < 12 || hour >= 20;
      case 'OMAD':
        return hour < 18 || hour >= 19;
      case 'ADF':
        final dayOfYear = DateTime.now().difference(
          DateTime(DateTime.now().year, 1, 1)
        ).inDays;
        return dayOfYear % 2 == 0;
      default:
        return hour < 12 || hour >= 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final provider = Provider.of<HydrationProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final List<Widget> cards = [
      MainProgressCard(onUpdate: _onIntakeUpdated),
      const ElectrolytesCard(),
      const WeatherCard(),
      const SugarIntakeCard(),
      const FoodIntakeCard(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FoodCoach',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(DateTime.now(), l10n),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          // ✅ ИСПРАВЛЕНО: Achievement button с правильной логикой показа красной точки
          AnimatedBuilder(
            animation: _achievementTracker,
            builder: (context, child) {
              // ✅ Проверяем есть ли новые достижения через AchievementTracker
              final hasNewAchievements = _achievementTracker.hasUnlockedAchievements || 
                                       _achievementTracker.unlockedQueue.isNotEmpty;
              
              return Stack(
                children: [
                  IconButton(
                    icon: Text(
                      '🏆',
                      style: TextStyle(
                        fontSize: 26,
                        shadows: hasNewAchievements ? [
                          Shadow(
                            color: Colors.amber.withOpacity(0.8),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ] : null,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    tooltip: l10n.achievements,
                  ),
                  if (hasNewAchievements)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
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
          ),
          
          // PRO button
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigate to PRO screen
                Navigator.pushNamed(context, '/pro');
              },
              tooltip: l10n.getPro,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [            
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Card carousel
                  SizedBox(
                    height: 520,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: cards.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: cards[index],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cards.length, (index) {
                      final isActive = _currentIndex == index;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive
                                ? theme.primaryColor
                                : theme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            SliverToBoxAdapter(
              child: HRIStatusCard(
                isFasting: _isCurrentlyFasting(provider),
                fastingSchedule: _fastingSchedule,
              ),
            ),
            
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 80),
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final weekdays = [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
    ];
    
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    
    final weekday = weekdays[date.weekday % 7];
    final month = months[date.month - 1];
    
    return l10n.dateFormat(weekday, date.day, month);
  }
}