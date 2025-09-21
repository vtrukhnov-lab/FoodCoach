// ============================================================================
// FILE: lib/providers/hydration_provider.dart
// 
// PURPOSE: Provider for hydration tracking and goals management
// UPDATED: Added workout losses integration with HRIService + HistoryService integration
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:math' as math;

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart' as notif;
import '../services/notification_texts.dart';
import '../services/water_progress_cache.dart';
import '../services/remote_config_service.dart';
import '../services/hri_service.dart';
import '../services/alcohol_service.dart';
import '../services/achievement_service.dart';
import '../services/units_service.dart';
import '../services/history_service.dart';
import '../services/analytics_service.dart';
import '../models/daily_goals.dart';
import '../models/intake.dart';
import '../models/alcohol_intake.dart';
import '../models/food_intake.dart';
import '../data/catalog_item.dart'; // Added for CatalogItem
// import '../widgets/home/sugar_intake_card.dart'; // Removed - now using carbs
import '../widgets/home/carbs_intake_card.dart'; // Added for CarbsIntakeData
import '../services/achievement_tracker.dart';

// SugarIntakeData class for compatibility
class SugarIntakeData {
  final double totalGrams;
  final double naturalSugarGrams;
  final double addedSugarGrams;
  final double hiddenSugarGrams;
  final double drinksGrams;
  final double foodGrams;
  final double snacksGrams;
  final Map<String, double> bySource;

  SugarIntakeData({
    required this.totalGrams,
    required this.naturalSugarGrams,
    required this.addedSugarGrams,
    required this.hiddenSugarGrams,
    required this.drinksGrams,
    required this.foodGrams,
    required this.snacksGrams,
    required this.bySource,
  });
}



// Internal status enum for logic (not exposed to UI)
enum _HydrationStatusInternal {
  normal,
  diluted,
  dehydrated,
  lowSalt,
}

// Diet modes for carbs calculation
enum DietMode {
  normal,    // 55% carbs (WHO standard)
  lowCarb,   // 25% carbs
  keto,      // 8% carbs
}

class HydrationProvider extends ChangeNotifier {
  double weight = 70;
  String dietMode = 'normal';
  String activityLevel = 'medium'; // Kept for compatibility
  int dailyCaloriesGoal = 2000; // Цель по калориям на основе веса
  DietMode carbsDietMode = DietMode.normal; // Режим диеты для углеводов
  List<Intake> todayIntakes = [];
  List<FoodIntake> todayFoodIntakes = [];
  
  
  // Alcohol adjustments
  double alcoholWaterAdjustment = 0;
  int alcoholSodiumAdjustment = 0;
  
  // NEW: Workout adjustments from HRIService
  double workoutWaterAdjustment = 0;
  int workoutSodiumAdjustment = 0;
  int workoutPotassiumAdjustment = 0;
  int workoutMagnesiumAdjustment = 0;
  
  // Track last reschedule time to prevent too frequent updates
  DateTime? _lastRescheduleTime;
  
  // Store BuildContext for AchievementService
  BuildContext? _context;
  
  final AchievementTracker _achievementTracker = AchievementTracker();

  late DailyGoals goals;

  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;
  final AnalyticsService _analytics = AnalyticsService();
  
  HydrationProvider() {
    _calculateGoals();
    _achievementTracker.initialize();
    _loadData();
    _checkAndResetDaily();
    _subscribeFCMTopics();
  }
  
  // Set context for AchievementService
  void setContext(BuildContext context) {
    _context = context;
  }

  // NEW: Update workout adjustments from HRIService
  void updateWorkoutAdjustments({
    required double waterAdjustment,
    required int sodiumAdjustment,
    required int potassiumAdjustment,
    required int magnesiumAdjustment,
  }) {
    workoutWaterAdjustment = waterAdjustment;
    workoutSodiumAdjustment = sodiumAdjustment;
    workoutPotassiumAdjustment = potassiumAdjustment;
    workoutMagnesiumAdjustment = magnesiumAdjustment;
    _calculateGoals();
    notifyListeners();
  }

  // NEW: Get workout losses from HRIService and update goals
  Future<void> syncWithHRIService(HRIService hriService) async {
    final losses = hriService.getTodaysWorkoutLosses();
    print('=== SYNC DEBUG ===');
    print('Losses from HRI: ${losses['water']} ml');
    print('Old water goal: ${goals.waterOpt}');
    
    // ИСПРАВЛЕНО: обновляем adjustments напрямую
    workoutWaterAdjustment = losses['water']!.toDouble();
    workoutSodiumAdjustment = losses['sodium']!;
    workoutPotassiumAdjustment = losses['potassium']!;
    workoutMagnesiumAdjustment = losses['magnesium']!;
    
    // КРИТИЧНО: пересчитать цели после обновления adjustments
    _calculateGoals();
    
    print('New water goal: ${goals.waterOpt}');
    print('=================');
    
    // КРИТИЧНО: уведомить слушателей об изменениях
    notifyListeners();
  }
  
  // ============ SUGAR INTAKE METHODS (UPDATED) ============
  
  /// Calculate sugar intake data for today including alcohol
  SugarIntakeData getSugarIntakeData(BuildContext context) {
    double totalSugar = 0;
    double naturalSugar = 0;
    double addedSugar = 0;
    double hiddenSugar = 0;
    double drinksGrams = 0;
    double foodGrams = 0;
    double snacksGrams = 0;
    Map<String, double> bySource = {};
    
    // Process regular intakes
    for (final intake in todayIntakes) {
      double sugarGrams = 0;
      String category = 'other';
      bool isNatural = false;
      bool isHidden = false;
      
      // Calculate sugar based on intake type
      switch (intake.type) {
        case 'juice':
          // Natural sugar from juice ~12g/100ml
          sugarGrams = (intake.volume / 100) * (_remoteConfig.getDouble('sugar_juice_per_100ml') ?? 12.0);
          category = 'drinks';
          isNatural = true;
          bySource['juice'] = (bySource['juice'] ?? 0) + sugarGrams;
          break;
          
        case 'soda':
          // Added sugar from soda ~10g/100ml
          sugarGrams = (intake.volume / 100) * (_remoteConfig.getDouble('sugar_soda_per_100ml') ?? 10.0);
          category = 'drinks';
          bySource['soda'] = (bySource['soda'] ?? 0) + sugarGrams;
          break;
          
        case 'energy':
          // Added sugar from energy drinks ~11g/100ml
          sugarGrams = (intake.volume / 100) * (_remoteConfig.getDouble('sugar_energy_per_100ml') ?? 11.0);
          category = 'drinks';
          bySource['energy'] = (bySource['energy'] ?? 0) + sugarGrams;
          break;
          
        case 'sports_drink':
          // Added sugar from sports drinks ~6g/100ml
          sugarGrams = (intake.volume / 100) * (_remoteConfig.getDouble('sugar_sports_per_100ml') ?? 6.0);
          category = 'drinks';
          bySource['sports'] = (bySource['sports'] ?? 0) + sugarGrams;
          break;
          
        case 'coffee_latte':
        case 'coffee_cappuccino':
        case 'coffee_flat_white':
          // Milk sugar (natural) ~5g + possible syrup
          double milkSugar = _remoteConfig.getDouble('sugar_coffee_milk_base') ?? 5.0;
          // For now, assume no syrup unless we track it separately
          sugarGrams = milkSugar;
          category = 'drinks';
          isNatural = true;
          bySource['coffee'] = (bySource['coffee'] ?? 0) + sugarGrams;
          break;
          
        case 'tea_sweet':
          // Sweet tea - added sugar
          sugarGrams = _remoteConfig.getDouble('sugar_sweet_tea') ?? 8.0;
          category = 'drinks';
          bySource['tea'] = (bySource['tea'] ?? 0) + sugarGrams;
          break;
          
        case 'smoothie':
          // Natural sugar from fruits in smoothie
          sugarGrams = (intake.volume / 250) * (_remoteConfig.getDouble('sugar_smoothie_per_250ml') ?? 20.0);
          category = 'drinks';
          isNatural = true;
          bySource['smoothie'] = (bySource['smoothie'] ?? 0) + sugarGrams;
          break;
          
        case 'protein_shake':
          // May contain added sugar
          sugarGrams = _remoteConfig.getDouble('sugar_protein_shake') ?? 5.0;
          category = 'drinks';
          bySource['protein'] = (bySource['protein'] ?? 0) + sugarGrams;
          break;
          
        case 'kombucha':
          // Mix of natural and added sugar
          sugarGrams = (intake.volume / 100) * (_remoteConfig.getDouble('sugar_kombucha_per_100ml') ?? 3.0);
          category = 'drinks';
          isNatural = true;
          bySource['kombucha'] = (bySource['kombucha'] ?? 0) + sugarGrams;
          break;
          
        // Skip old alcohol cases as alcohol is now tracked separately
        case 'alcohol_beer':
        case 'alcohol_wine':
        case 'alcohol_cocktail':
          continue;
          
        // For food items, we would need metadata or additional tracking
        // For now, we'll estimate based on common values
        case 'snack':
          // Estimate for typical snack
          sugarGrams = _remoteConfig.getDouble('sugar_snack_average') ?? 10.0;
          category = 'snacks';
          bySource['snack'] = (bySource['snack'] ?? 0) + sugarGrams;
          break;
          
        case 'meal':
          // Hidden sugars in meals (sauces, etc.)
          sugarGrams = _remoteConfig.getDouble('sugar_meal_hidden') ?? 5.0;
          category = 'food';
          isHidden = true;
          bySource['meal'] = (bySource['meal'] ?? 0) + sugarGrams;
          break;
      }
      
      // Sum up by categories
      totalSugar += sugarGrams;
      
      if (isNatural) {
        naturalSugar += sugarGrams;
      } else if (isHidden) {
        hiddenSugar += sugarGrams;
      } else if (sugarGrams > 0) {
        addedSugar += sugarGrams;
      }
      
      switch (category) {
        case 'drinks':
          drinksGrams += sugarGrams;
          break;
        case 'food':
          foodGrams += sugarGrams;
          break;
        case 'snacks':
          snacksGrams += sugarGrams;
          break;
      }
    }
    
    // NEW: Add sugar from alcoholic drinks
    try {
      final alcoholService = Provider.of<AlcoholService>(context, listen: false);
      final alcoholIntakes = alcoholService.todayIntakes;
      
      for (final intake in alcoholIntakes) {
        double sugarGrams = 0;
        
        // Use the sugar value if explicitly set, otherwise use default
        if (intake.sugar != null) {
          sugarGrams = intake.sugar!;
        } else {
          // Use getSugarContent() method from updated AlcoholIntake model
          sugarGrams = intake.getSugarContent();
        }
        
        if (sugarGrams > 0) {
          // Alcohol sugar is considered "hidden"
          totalSugar += sugarGrams;
          hiddenSugar += sugarGrams;
          drinksGrams += sugarGrams;
          
          // Add to sources
          bySource['alcohol'] = (bySource['alcohol'] ?? 0) + sugarGrams;
          
          // Detailed breakdown by alcohol type
          switch (intake.type) {
            case AlcoholType.beer:
              bySource['beer'] = (bySource['beer'] ?? 0) + sugarGrams;
              break;
            case AlcoholType.wine:
              bySource['wine'] = (bySource['wine'] ?? 0) + sugarGrams;
              break;
            case AlcoholType.cocktail:
              bySource['cocktails'] = (bySource['cocktails'] ?? 0) + sugarGrams;
              break;
            case AlcoholType.spirits:
              // Spirits usually have no sugar
              break;
          }
        }
      }
    } catch (e) {
      // If AlcoholService is not available or error occurred
      print('Could not get alcohol sugar data: $e');
    }

    // NEW: Add sugar from food intakes
    for (final foodIntake in todayFoodIntakes) {
      final sugarGrams = foodIntake.sugar;

      if (sugarGrams > 0) {
        totalSugar += sugarGrams;

        // Food sugars are mostly natural (fruits) or added (processed foods)
        // We can categorize based on food category or just count as natural for now
        if (foodIntake.foodName.toLowerCase().contains('fruit') ||
            foodIntake.foodName.toLowerCase().contains('apple') ||
            foodIntake.foodName.toLowerCase().contains('banana') ||
            foodIntake.foodName.toLowerCase().contains('orange') ||
            foodIntake.foodName.toLowerCase().contains('berry')) {
          naturalSugar += sugarGrams;
        } else {
          addedSugar += sugarGrams; // Most other foods have processed sugars
        }

        foodGrams += sugarGrams;

        // Add to sources by food type
        bySource['food'] = (bySource['food'] ?? 0) + sugarGrams;

        // More detailed breakdown by food name if needed
        final foodKey = foodIntake.foodName.toLowerCase().replaceAll(' ', '_');
        bySource[foodKey] = (bySource[foodKey] ?? 0) + sugarGrams;
      }
    }

    return SugarIntakeData(
      totalGrams: totalSugar,
      naturalSugarGrams: naturalSugar,
      addedSugarGrams: addedSugar,
      hiddenSugarGrams: hiddenSugar,
      drinksGrams: drinksGrams,
      foodGrams: foodGrams,
      snacksGrams: snacksGrams,
      bySource: bySource,
    );
  }

  /// Get carbohydrates intake data from food intakes
  CarbsIntakeData getCarbsIntakeData(BuildContext context) {
    double totalCarbs = 0;
    Map<String, double> bySource = {};

    // Calculate carbs from food intakes only
    for (final foodIntake in todayFoodIntakes) {
      final carbsGrams = foodIntake.carbohydrates;

      if (carbsGrams > 0) {
        totalCarbs += carbsGrams;

        // Add to sources by food type
        bySource['food'] = (bySource['food'] ?? 0) + carbsGrams;

        // More detailed breakdown by food name if needed
        final foodKey = foodIntake.foodName.toLowerCase().replaceAll(' ', '_');
        bySource[foodKey] = (bySource[foodKey] ?? 0) + carbsGrams;
      }
    }

    // Daily carbs goal based on selected diet mode
    double carbsPercentage;
    switch (carbsDietMode) {
      case DietMode.normal:
        carbsPercentage = 0.55; // 55% WHO standard
        break;
      case DietMode.lowCarb:
        carbsPercentage = 0.25; // 25% low carb
        break;
      case DietMode.keto:
        carbsPercentage = 0.08; // 8% keto
        break;
    }

    final carbsCalorieGoal = dailyCaloriesGoal * carbsPercentage;
    final dailyLimit = carbsCalorieGoal / 4; // Convert calories to grams (4 kcal per gram)

    return CarbsIntakeData(
      totalGrams: totalCarbs,
      dailyLimit: dailyLimit,
      foodCount: todayFoodIntakes.length,
      bySource: bySource,
    );
  }

  /// Set carbs diet mode and save to preferences
  Future<void> setCarbsDietMode(DietMode mode) async {
    carbsDietMode = mode;
    notifyListeners();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carbsDietMode', mode.name);
  }

  /// Load carbs diet mode from preferences
  Future<void> loadCarbsDietMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('carbsDietMode');

    if (savedMode != null) {
      try {
        carbsDietMode = DietMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => DietMode.normal,
        );
      } catch (e) {
        carbsDietMode = DietMode.normal;
      }
    }
    notifyListeners();
  }
  
  /// Get sugar impact on HRI (updated to use context)
  double getSugarHRIImpact(BuildContext context) {
    final sugarData = getSugarIntakeData(context);
    final threshold = _remoteConfig.getDouble('sugar_hri_threshold_grams') ?? 50.0;
    final multiplier = _remoteConfig.getDouble('sugar_hri_multiplier') ?? 0.2;
    
    if (sugarData.totalGrams <= threshold) return 0;
    
    final excess = sugarData.totalGrams - threshold;
    return (excess * multiplier).clamp(0, 10);
  }
  
  /// Check if sugar intake is high for notifications (updated to use context)
  bool isSugarIntakeHigh(BuildContext context) {
    final sugarData = getSugarIntakeData(context);
    final warningThreshold = _remoteConfig.getDouble('sugar_warning_threshold_grams') ?? 50.0;
    
    return sugarData.totalGrams > warningThreshold;
  }
  
  /// Get sugar reduction tips
  List<String> getSugarReductionTips(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sugarData = getSugarIntakeData(context);
    List<String> tips = [];
    
    if (sugarData.drinksGrams > 20) {
      tips.add(l10n.tip_reduce_sweet_drinks);
    }
    
    if (sugarData.addedSugarGrams > 25) {
      tips.add(l10n.tip_avoid_added_sugar);
    }
    
    if (sugarData.hiddenSugarGrams > 10) {
      tips.add(l10n.tip_check_labels);
    }
    
    if (sugarData.bySource['soda'] != null && sugarData.bySource['soda']! > 0) {
      tips.add(l10n.tip_replace_soda);
    }
    
    // New tip for alcohol sugar
    if (sugarData.bySource['alcohol'] != null && sugarData.bySource['alcohol']! > 15) {
      tips.add('Consider lower-sugar alcohol options like spirits or dry wine');
    }
    
    return tips;
  }
  
  // ============ HRI SERVICE INTEGRATION ============
  
  // Log workout with proper loss tracking
  Future<void> logWorkout({
    required String type,
    required int intensity, // 1-5
    required int durationMinutes,
    CatalogItem? item,
    String? name,
    String? emoji,
  }) async {
    print('=== LOGWORKOUT DEBUG ===');
    print('Logging workout: $type, $intensity, ${durationMinutes}min, weight: $weight');
    print('Item: ${item?.id}');
    
    // ИСПРАВЛЕНО: используем Provider.of для получения существующего HRIService
    final hriService = Provider.of<HRIService>(_context!, listen: false);
    
    // Add workout with full loss calculations
    await hriService.addWorkout(
      type: type,
      intensity: intensity,
      durationMinutes: durationMinutes,
      item: item,
      userWeight: weight,
      name: name,
      emoji: emoji,
    );
    
    // NEW: Sync workout losses back to goals
    await syncWithHRIService(hriService);
    
    notifyListeners();
  }
  
  // Log caffeine
  Future<void> logCoffeeIntake(int caffeineMg) async {
    final hriService = HRIService();
    await hriService.addCoffeeIntake(caffeineMg);
    notifyListeners();
  }
  
  // Log alcohol through HRI
  Future<void> logAlcoholIntake(double standardDrinks) async {
    final hriService = HRIService();
    await hriService.addAlcoholIntake(standardDrinks);
    notifyListeners();
  }
  
  // Update HRI with full data (updated to include sugar)
  Future<void> updateHRI({
    required BuildContext context,
    required HRIService hriService,
    AlcoholService? alcoholService,
  }) async {
    // Calculate current electrolytes
    int totalSodium = 0;
    int totalPotassium = 0;
    int totalMagnesium = 0;
    
    for (var intake in todayIntakes) {
      totalSodium += intake.sodium;
      totalPotassium += intake.potassium;
      totalMagnesium += intake.magnesium;
    }
    
    // Get sugar intake for HRI
    final sugarData = getSugarIntakeData(context);
    
    // Call full HRI calculation
    await hriService.calculateHRI(
      waterIntake: totalWaterToday,
      waterGoal: goals.waterOpt.toDouble(),
      sodiumIntake: totalSodium.toDouble(),
      sodiumGoal: goals.sodium.toDouble(),
      potassiumIntake: totalPotassium.toDouble(),
      potassiumGoal: goals.potassium.toDouble(),
      magnesiumIntake: totalMagnesium.toDouble(),
      magnesiumGoal: goals.magnesium.toDouble(),
      heatIndex: 25.0, // Default temperature
      sugarIntake: sugarData.totalGrams,
      lastIntakeTime: lastIntakeTime,
      userWeightKg: weight,
      // NEW: Add food data
      foodWaterContent: totalWaterFromFoodToday,
      foodSodiumIntake: todayFoodIntakes.fold(0.0, (sum, food) => sum + food.sodium),
      foodCount: todayFoodIntakes.length,
      foodSugarIntake: todayFoodIntakes.fold(0.0, (sum, food) => sum + food.sugar),
    );

    // NEW: Sync workout losses back to update goals
    await syncWithHRIService(hriService);
  }
  
  // ============ GETTERS ============
  
  double get totalWaterToday {
    double total = 0;
    for (var intake in todayIntakes) {
      // Учитываем ВСЕ напитки, кроме алкоголя
      // Алкоголь обрабатывается отдельно через AlcoholService
      if (!intake.type.startsWith('alcohol_')) {
        total += intake.volume;
      }
    }
    return total;
  }
  
  int get totalSodiumToday {
    int total = 0;
    for (var intake in todayIntakes) {
      total += intake.sodium;
    }
    return total;
  }
  
  int get totalPotassiumToday {
    int total = 0;
    for (var intake in todayIntakes) {
      total += intake.potassium;
    }
    return total;
  }
  
  int get totalMagnesiumToday {
    int total = 0;
    for (var intake in todayIntakes) {
      total += intake.magnesium;
    }
    return total;
  }
  
  int get coffeeCupsToday {
    return todayIntakes.where((intake) => intake.type == 'coffee').length;
  }
  
  DateTime? get lastIntakeTime {
    if (todayIntakes.isEmpty) return null;
    return todayIntakes.last.timestamp;
  }
  
  // ============ CORE METHODS ============
  
  void _subscribeFCMTopics() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('all_users');
    
    if (dietMode == 'keto') {
      await messaging.subscribeToTopic('keto_users');
    } else if (dietMode == 'fasting') {
      await messaging.subscribeToTopic('fasting_users');
    }
    
  }
  
  void _calculateGoals() {
  // 🔥 УПРОЩЕНО: Используем константы из ТЗ вместо Remote Config

  // Константы формул воды (мл на кг веса) - из ТЗ
  const double waterMinPerKg = 22.0;
  const double waterOptPerKg = 30.0;
  const double waterMaxPerKg = 36.0;

  // Константы электролитов (мг в день) - из ТЗ
  const int sodiumNormal = 2500;
  const int sodiumKeto = 3500;
  const int potassiumNormal = 3000;
  const int potassiumKeto = 3500;
  const int magnesiumNormal = 350;
  const int magnesiumKeto = 400;

  // Безопасная проверка веса
  final double safeWeight = weight > 0 ? weight : 70.0;

  // Расчет цели по калориям (25 ккал на кг веса)
  dailyCaloriesGoal = (25 * safeWeight).round();
  
  // Базовые цели воды
  int baseWaterMin = (waterMinPerKg * safeWeight).round();
  int baseWaterOpt = (waterOptPerKg * safeWeight).round();
  int baseWaterMax = (waterMaxPerKg * safeWeight).round();
  
  // Отладочная информация
  print('=== GOALS CALCULATION DEBUG ===');
  print('Weight: $safeWeight kg');
  print('Base goals: min=$baseWaterMin, opt=$baseWaterOpt, max=$baseWaterMax ml');
  
  // Start with base values
  int waterMin = baseWaterMin;
  int waterOpt = baseWaterOpt;
  int waterMax = baseWaterMax;
  
  
  // Apply alcohol correction (addition to already corrected values)
  if (alcoholWaterAdjustment > 0) {
    waterMin += alcoholWaterAdjustment.round();
    waterOpt += alcoholWaterAdjustment.round();
    waterMax += alcoholWaterAdjustment.round();
    print('After alcohol adjustment (+${alcoholWaterAdjustment.round()} ml): opt=$waterOpt ml');
  }

  // Apply workout correction (addition to already corrected values)
  if (workoutWaterAdjustment > 0) {
    waterMin += workoutWaterAdjustment.round();
    waterOpt += workoutWaterAdjustment.round();
    waterMax += workoutWaterAdjustment.round();
    print('After workout adjustment (+${workoutWaterAdjustment.round()} ml): opt=$waterOpt ml');
  }
  
  // Базовые электролиты по режиму питания
  int baseSodium = (dietMode == 'keto' || dietMode == 'fasting') 
      ? sodiumKeto 
      : sodiumNormal;
      
  int basePotassium = (dietMode == 'keto' || dietMode == 'fasting') 
      ? potassiumKeto 
      : potassiumNormal;
      
  int baseMagnesium = (dietMode == 'keto' || dietMode == 'fasting') 
      ? magnesiumKeto 
      : magnesiumNormal;
  
  // Start with base values
  int sodium = baseSodium;
  int potassium = basePotassium;
  int magnesium = baseMagnesium;
  
  
  // Add alcohol salt correction
  sodium += alcoholSodiumAdjustment;

  // Add workout corrections
  sodium += workoutSodiumAdjustment;
  potassium += workoutPotassiumAdjustment;
  magnesium += workoutMagnesiumAdjustment;
  
  print('Electrolytes: Na=$sodium, K=$potassium, Mg=$magnesium mg');
  
  // Create final goals
  goals = DailyGoals(
    waterMin: waterMin,
    waterOpt: waterOpt,
    waterMax: waterMax,
    sodium: sodium,
    potassium: potassium,
    magnesium: magnesium,
  );
  
  print('Final water goal: ${goals.waterOpt} ml');
  print('==============================');
  
  // Update water progress cache whenever goals change
  _updateWaterProgressCache();
  
  // Сохраняем цели дня в Firestore для истории
  _saveDailyGoals();
}
  
  void updateAlcoholAdjustments(double waterAdjustment, int sodiumAdjustment) {
    alcoholWaterAdjustment = waterAdjustment;
    alcoholSodiumAdjustment = sodiumAdjustment;
    _calculateGoals();
    notifyListeners();
  }
  
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    weight = prefs.getDouble('weight') ?? 70;
    dietMode = prefs.getString('dietMode') ?? 'normal';
    activityLevel = prefs.getString('activityLevel') ?? 'medium';
    dailyCaloriesGoal = prefs.getInt('dailyCaloriesGoal') ?? 2000;
    
    final todayKey = 'intakes_${DateTime.now().toIso8601String().split('T')[0]}';
    final intakesJson = prefs.getStringList(todayKey) ?? [];

    todayIntakes = intakesJson.map((json) {
      final parts = json.split('|');
      return Intake(
        id: parts[0],
        timestamp: DateTime.parse(parts[1]),
        type: parts[2],
        volume: int.parse(parts[3]),
        sodium: int.parse(parts[4]),
        potassium: int.parse(parts[5]),
        magnesium: int.parse(parts[6]),
        // Handle new fields for backward compatibility
        name: parts.length > 7 && parts[7].isNotEmpty ? parts[7] : null,
        emoji: parts.length > 8 && parts[8].isNotEmpty ? parts[8] : null,
      );
    }).toList();

    // Load food intakes
    final todayFoodKey = 'food_intakes_${DateTime.now().toIso8601String().split('T')[0]}';
    final foodIntakesJson = prefs.getStringList(todayFoodKey) ?? [];

    todayFoodIntakes = foodIntakesJson.map((json) {
      try {
        final data = json.split('|');
        return FoodIntake(
          id: data[0],
          timestamp: DateTime.parse(data[1]),
          foodId: data[2],
          foodName: data[3],
          weight: double.parse(data[4]),
          calories: int.parse(data[5]),
          waterContent: double.parse(data[6]),
          sodium: int.parse(data[7]),
          potassium: int.parse(data[8]),
          magnesium: int.parse(data[9]),
          sugar: double.parse(data[10]),
          hasCaffeine: data[11] == 'true',
          emoji: data.length > 12 && data[12].isNotEmpty ? data[12] : null,
          proteins: data.length > 13 ? double.parse(data[13]) : 0.0,
          carbohydrates: data.length > 14 ? double.parse(data[14]) : 0.0,
          fats: data.length > 15 ? double.parse(data[15]) : 0.0,
        );
      } catch (e) {
        print('Error parsing food intake: $e');
        return null;
      }
    }).where((intake) => intake != null).cast<FoodIntake>().toList();
    
    _calculateGoals();

    // Load carbs diet mode
    await loadCarbsDietMode();

    // Update water progress cache after loading data
    await _updateWaterProgressCache();

    notifyListeners();
  }
  
  // Сохранение целей дня в Firestore
  Future<void> _saveDailyGoals() async {
    try {
      final historyService = HistoryService();
      await historyService.saveDailyGoals(
        date: DateTime.now(),
        waterMin: goals.waterMin,
        waterOpt: goals.waterOpt,
        waterMax: goals.waterMax,
        sodium: goals.sodium,
        potassium: goals.potassium,
        magnesium: goals.magnesium,
      );
    } catch (e) {
      print('Error saving daily goals: $e');
      // Не блокируем работу приложения при ошибке
    }
  }
  
  // NEW: Update water progress cache for notifications
  Future<void> _updateWaterProgressCache() async {
    final consumedMl = totalWaterToday.round();
    final goalMl = goals.waterOpt;
    await WaterProgressCache.set(consumedMl: consumedMl, goalMl: goalMl);
    print('Water progress cached: $consumedMl / $goalMl ml (${(consumedMl * 100 / goalMl).round()}%)');
    
    // Reschedule notifications with debouncing (max once per second)
    final now = DateTime.now();
    if (_lastRescheduleTime == null || 
        now.difference(_lastRescheduleTime!).inSeconds > 1) {
      _lastRescheduleTime = now;
      try {
        await notif.NotificationService().scheduleSmartReminders();
        print('Notifications rescheduled with updated progress');
      } catch (e) {
        print('Failed to reschedule notifications: $e');
      }
    }
  }
  
  // Save method
  Future<void> _saveIntakes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = 'intakes_${DateTime.now().toIso8601String().split('T')[0]}';
      
      final intakesJson = todayIntakes.map((intake) {
        return '${intake.id}|${intake.timestamp.toIso8601String()}|${intake.type}|'
               '${intake.volume}|${intake.sodium}|${intake.potassium}|${intake.magnesium}|'
               '${intake.name ?? ""}|${intake.emoji ?? ""}';
      }).toList();
      
      await prefs.setStringList(todayKey, intakesJson);
      
      final progress = getProgress();
      await prefs.setDouble('waterProgress', progress['waterPercent']!);
      
      // Update water progress cache after saving
      await _updateWaterProgressCache();
    } catch (e) {
      print('Error saving intakes: $e');
    }
  }
  
  void _checkAndResetDaily() {
    final now = DateTime.now();
    const lastResetKey = 'lastReset';
    
    SharedPreferences.getInstance().then((prefs) async {
      final lastResetStr = prefs.getString(lastResetKey);
      if (lastResetStr != null) {
        final lastReset = DateTime.parse(lastResetStr);
        if (lastReset.day != now.day) {
          todayIntakes.clear();
          
          // NEW: Reset workout adjustments for new day
          workoutWaterAdjustment = 0;
          workoutSodiumAdjustment = 0;
          workoutPotassiumAdjustment = 0;
          workoutMagnesiumAdjustment = 0;
          
          await prefs.setString(lastResetKey, now.toIso8601String());
          
          // Recalculate goals after reset
          _calculateGoals();
          
          // Reset water progress cache for new day
          await _updateWaterProgressCache();
          
          notifyListeners();
          
          notif.NotificationService().scheduleEveningReport();
        }
      } else {
        await prefs.setString(lastResetKey, now.toIso8601String());
      }
    });
  }
  
  void updateProfile({
    required double weight,
    required String dietMode,
    required String activityLevel,
    String? fastingSchedule,
  }) {
    this.weight = weight;
    this.dietMode = dietMode;
    this.activityLevel = activityLevel;
    _calculateGoals();
    _saveProfile();
    _subscribeFCMTopics();
    notifyListeners();
  }
  
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weight', weight);
    await prefs.setString('dietMode', dietMode);
    await prefs.setString('activityLevel', activityLevel);
    await prefs.setInt('dailyCaloriesGoal', dailyCaloriesGoal);
  }
  
  // NEW: Save intake to Firestore via HistoryService
  Future<void> _saveToFirestore(Intake intake) async {
    try {
      final historyService = HistoryService();
      await historyService.saveIntake(intake);
      print('Intake saved to Firestore: ${intake.type} ${intake.volume}ml');
    } catch (e) {
      print('Error saving to Firestore: $e');
      // Не блокируем UI если Firestore недоступен - данные остаются в SharedPreferences
    }
  }
  
  // UPDATED: Added achievement service integration with control parameter
  void addIntake(String type, int volume, {
    int sodium = 0,
    int potassium = 0,
    int magnesium = 0,
    bool showAchievement = true,  // NEW: Control achievement notification
    String source = 'manual_entry',
    String? name,  // NEW: Specific product name
    String? emoji, // NEW: Product emoji
  }) {
    // Calculate old percentage BEFORE adding intake
    final oldPercent = goals.waterOpt > 0 
        ? (totalWaterToday / goals.waterOpt * 100).clamp(0.0, 200.0)
        : 0.0;
    
    // Add to list
    final newIntake = Intake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: type,
      volume: volume,
      sodium: sodium,
      potassium: potassium,
      magnesium: magnesium,
      name: name,
      emoji: emoji,
    );

    todayIntakes.add(newIntake);

    switch (type) {
      case 'water':
      case 'broth':
        _analytics.logWaterIntake(amount: volume, source: source);
        break;
      case 'electrolyte':
        if (sodium > 0) {
          _analytics.logElectrolyteIntake(type: 'sodium', amount: sodium);
        }
        if (potassium > 0) {
          _analytics.logElectrolyteIntake(type: 'potassium', amount: potassium);
        }
        if (magnesium > 0) {
          _analytics.logElectrolyteIntake(type: 'magnesium', amount: magnesium);
        }
        break;
      case 'coffee':
        _analytics.logCoffeeIntake(cups: 1);
        break;
      default:
        break;
    }

    // NEW: Save to Firestore via HistoryService
    _saveToFirestore(newIntake);
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Calculate new percentage AFTER adding intake (only for water types)
    if (type == 'water' || type == 'electrolyte' || type == 'broth') {
      final newPercent = goals.waterOpt > 0 
          ? (totalWaterToday / goals.waterOpt * 100).clamp(0.0, 200.0)
          : 0.0;
      
      // Check and show achievement if context is available AND showAchievement is true
      if (showAchievement && _context != null && _context!.mounted) {
        // Get units service for formatting
        final unitsService = Provider.of<UnitsService>(_context!, listen: false);
        final formattedVolume = unitsService.formatVolume(volume);
        
        // Track achievement progress - only once per day per achievement type
        _achievementTracker.trackWaterIntake(
          volumeMl: volume,
          currentProgress: totalWaterToday,
          goalProgress: newPercent,
        );
        
        AchievementService.checkAndShow(
          context: _context!,
          oldPercent: oldPercent,
          newPercent: newPercent,
          addedVolume: volume,
          formattedVolume: formattedVolume,
        );
      }
    }

    // ИСПРАВЛЕНИЕ: Добавляем отслеживание электролитов для достижений
    if (type == 'electrolyte' && showAchievement) {
      // Проверяем достижение целей электролитов
      final currentSodium = totalSodiumToday;
      final currentPotassium = totalPotassiumToday;
      final currentMagnesium = totalMagnesiumToday;
      
      final reachedSodiumGoal = currentSodium >= goals.sodium;
      final reachedPotassiumGoal = currentPotassium >= goals.potassium;
      final reachedMagnesiumGoal = currentMagnesium >= goals.magnesium;
      
      // Вызываем отслеживание электролитов для достижений
      _achievementTracker.trackElectrolyteIntake(
        sodiumMg: sodium,
        potassiumMg: potassium,
        magnesiumMg: magnesium,
        reachedSodiumGoal: reachedSodiumGoal,
        reachedPotassiumGoal: reachedPotassiumGoal,
        reachedMagnesiumGoal: reachedMagnesiumGoal,
      );
      
      print('Electrolyte tracking called: Na=$sodium, K=$potassium, Mg=$magnesium');
    }
    
    // First notify UI about changes
    notifyListeners();
    
    // Then save asynchronously (includes water progress cache update)
    _saveIntakes().then((_) {
      print('Intake saved successfully');
    }).catchError((error) {
      print('Error saving intake: $error');
    });
    
    // Schedule post-coffee reminder if it's coffee
    if (type == 'coffee') {
      // FIXED: Ensure locale is loaded before scheduling notification
      _schedulePostCoffeeWithLocale();
      
      // Log coffee to HRI (approximately 80mg caffeine per cup)
      logCoffeeIntake(80);
    }
  }
  
  // NEW: Helper method to ensure locale is loaded before scheduling
  Future<void> _schedulePostCoffeeWithLocale() async {
    try {
      // Load current locale from preferences
      await NotificationTexts.loadLocale();
      
      // Now schedule the notification with correct locale
      await notif.NotificationService().schedulePostCoffeeReminder();
      
      print('Post-coffee reminder scheduled with correct locale');
    } catch (e) {
      print('Error scheduling post-coffee reminder: $e');
    }
  }
  
  void removeIntake(String id) {
    todayIntakes.removeWhere((intake) => intake.id == id);

    // First update UI
    notifyListeners();

    // Then save (includes water progress cache update)
    _saveIntakes().then((_) {
      print('Intake removed successfully');
    });
  }

  // =============================================================================
  // FOOD INTAKE METHODS
  // =============================================================================

  /// Add food intake
  Future<void> addFoodIntake(FoodIntake foodIntake) async {
    todayFoodIntakes.add(foodIntake);

    // Log analytics for food
    _analytics.log('food_intake_added', {
      'food_id': foodIntake.foodId,
      'food_name': foodIntake.foodName,
      'weight': foodIntake.weight,
      'calories': foodIntake.calories,
      'water_content': foodIntake.waterContent,
      'sodium': foodIntake.sodium,
      'potassium': foodIntake.potassium,
      'magnesium': foodIntake.magnesium,
      'sugar': foodIntake.sugar,
      'has_caffeine': foodIntake.hasCaffeine,
    });

    // Add water content from food to hydration goals
    if (foodIntake.waterContent > 0) {
      addIntake(
        'water',
        foodIntake.waterContent.round(),
        sodium: foodIntake.sodium,
        potassium: foodIntake.potassium,
        magnesium: foodIntake.magnesium,
        showAchievement: false, // Don't show achievement for food water
        source: 'food_intake',
      );
    }

    // Handle high sodium foods - increase water need
    if (foodIntake.isHighSodium) {
      // Add extra 100ml per 300mg of sodium above normal
      final extraWater = ((foodIntake.sodium - 300) / 300 * 100).clamp(0, 500);
      if (extraWater > 0) {
        // This increases the recommended water intake for the day
        _analytics.log('high_sodium_food_adjustment', {
          'food_name': foodIntake.foodName,
          'sodium': foodIntake.sodium,
          'extra_water_needed': extraWater,
        });
      }
    }

    // Handle caffeine from food (like chocolate)
    if (foodIntake.hasCaffeine) {
      // Estimate caffeine content (rough estimate for food)
      final estimatedCaffeine = (foodIntake.weight * 0.1).round(); // ~10mg per 100g
      logCoffeeIntake(estimatedCaffeine);
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Save to Firestore
    _saveFoodToFirestore(foodIntake);

    // Update UI
    notifyListeners();

    // Save locally
    await _saveFoodIntakes();
  }

  /// Remove food intake
  void removeFoodIntake(String id) {
    FoodIntake? foodIntake;
    try {
      foodIntake = todayFoodIntakes.where((intake) => intake.id == id).first;
    } catch (e) {
      foodIntake = null;
    }
    if (foodIntake != null) {
      // Remove the water that was added from this food
      Intake? waterIntakeToRemove;
      try {
        waterIntakeToRemove = todayIntakes.where((intake) =>
            intake.id.contains(foodIntake!.id) ||
            (intake.timestamp.difference(foodIntake.timestamp).abs().inMinutes < 1 &&
             intake.volume == foodIntake.waterContent.round())
        ).first;
      } catch (e) {
        waterIntakeToRemove = null;
      }

      if (waterIntakeToRemove != null) {
        removeIntake(waterIntakeToRemove.id);
      }
    }

    todayFoodIntakes.removeWhere((intake) => intake.id == id);

    // Update UI
    notifyListeners();

    // Save
    _saveFoodIntakes().then((_) {
      print('Food intake removed successfully');
    });
  }

  /// Save food intakes to local storage
  Future<void> _saveFoodIntakes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayFoodKey = 'food_intakes_${DateTime.now().toIso8601String().split('T')[0]}';

      final foodIntakesJson = todayFoodIntakes.map((intake) {
        return '${intake.id}|${intake.timestamp.toIso8601String()}|${intake.foodId}|'
               '${intake.foodName}|${intake.weight}|${intake.calories}|${intake.waterContent}|'
               '${intake.sodium}|${intake.potassium}|${intake.magnesium}|${intake.sugar}|${intake.hasCaffeine}|'
               '${intake.emoji ?? ""}|${intake.proteins}|${intake.carbohydrates}|${intake.fats}';
      }).toList();

      await prefs.setStringList(todayFoodKey, foodIntakesJson);
      print('Food intakes saved successfully');
    } catch (e) {
      print('Error saving food intakes: $e');
    }
  }

  /// Save food intake to Firestore
  Future<void> _saveFoodToFirestore(FoodIntake foodIntake) async {
    try {
      final historyService = HistoryService();

      // Save food intake using the proper saveFoodIntake method
      await historyService.saveFoodIntake(foodIntake);

      print('Food intake saved to Firestore: ${foodIntake.foodName}');
    } catch (e) {
      print('Error saving food to Firestore: $e');
      // Don't block the app on Firestore errors
    }
  }

  /// Get today's total calories from food
  int get totalCaloriesToday {
    return todayFoodIntakes.fold(0, (sum, intake) => sum + intake.calories);
  }

  /// Get daily calorie goal based on weight
  int get calorieGoal => dailyCaloriesGoal;

  /// Get today's total sugar from food
  double get totalSugarToday {
    return todayFoodIntakes.fold(0.0, (sum, intake) => sum + intake.sugar);
  }

  /// Get today's water from food
  double get totalWaterFromFoodToday {
    return todayFoodIntakes.fold(0.0, (sum, intake) => sum + intake.waterContent);
  }

  /// Get food intake progress/summary
  Map<String, dynamic> getFoodProgress() {
    final totalCalories = totalCaloriesToday;
    final totalSugar = totalSugarToday;
    final totalWaterFromFood = totalWaterFromFoodToday;
    final foodCount = todayFoodIntakes.length;

    // Calculate additional sodium from food
    final additionalSodium = todayFoodIntakes.fold(0, (sum, intake) => sum + intake.sodium);

    // Calculate calories from different food categories
    int fruitCalories = 0;
    int vegetableCalories = 0;
    int meatCalories = 0;
    int fastFoodCalories = 0;
    int dairyCalories = 0;
    int soupCalories = 0;

    for (final intake in todayFoodIntakes) {
      if (intake.foodId.startsWith('fruit_')) {
        fruitCalories += intake.calories;
      } else if (intake.foodId.startsWith('vegetable_')) {
        vegetableCalories += intake.calories;
      } else if (intake.foodId.startsWith('meat_')) {
        meatCalories += intake.calories;
      } else if (intake.foodId.startsWith('fastfood_')) {
        fastFoodCalories += intake.calories;
      } else if (intake.foodId.startsWith('dairy_')) {
        dairyCalories += intake.calories;
      } else if (intake.foodId.startsWith('soup_')) {
        soupCalories += intake.calories;
      }
    }

    return {
      'totalCalories': totalCalories,
      'totalSugar': totalSugar,
      'totalWaterFromFood': totalWaterFromFood,
      'foodCount': foodCount,
      'additionalSodium': additionalSodium,
      'breakdown': {
        'fruits': fruitCalories,
        'vegetables': vegetableCalories,
        'meat': meatCalories,
        'fastFood': fastFoodCalories,
        'dairy': dairyCalories,
        'soups': soupCalories,
      },
    };
  }
  
  Map<String, double> getProgress() {
    int totalWater = 0;
    int totalSodium = 0;
    int totalPotassium = 0;
    int totalMagnesium = 0;
    
    for (var intake in todayIntakes) {
      if (intake.type == 'water' || intake.type == 'electrolyte' || intake.type == 'broth') {
        totalWater += intake.volume;
      }
      totalSodium += intake.sodium;
      totalPotassium += intake.potassium;
      totalMagnesium += intake.magnesium;
    }
    
    return {
      'water': totalWater.toDouble(),
      'waterPercent': math.min((totalWater / goals.waterOpt) * 100, 100),
      'sodium': totalSodium.toDouble(),
      'sodiumPercent': math.min((totalSodium / goals.sodium) * 100, 100),
      'potassium': totalPotassium.toDouble(),
      'potassiumPercent': math.min((totalPotassium / goals.potassium) * 100, 100),
      'magnesium': totalMagnesium.toDouble(),
      'magnesiumPercent': math.min((totalMagnesium / goals.magnesium) * 100, 100),
    };
  }
  
  // Private method to get internal status enum (for logic)
  _HydrationStatusInternal _getInternalHydrationStatus() {
    final progress = getProgress();
    final waterRatio = progress['water']! / goals.waterOpt;
    final sodiumRatio = progress['sodium']! / goals.sodium;
    
    if (waterRatio > _remoteConfig.dilutionWaterThreshold && 
        sodiumRatio < _remoteConfig.dilutionSodiumThreshold) {
      return _HydrationStatusInternal.diluted;
    } else if (waterRatio < _remoteConfig.dehydrationThreshold) {
      return _HydrationStatusInternal.dehydrated;
    } else if (sodiumRatio < _remoteConfig.lowSaltThreshold) {
      return _HydrationStatusInternal.lowSalt;
    } else {
      return _HydrationStatusInternal.normal;
    }
  }
  
  // Public method to get localized status string
  String getHydrationStatus(AppLocalizations l10n) {
    final status = _getInternalHydrationStatus();
    
    switch (status) {
      case _HydrationStatusInternal.normal:
        return l10n.hydrationStatusNormal;
      case _HydrationStatusInternal.diluted:
        return l10n.hydrationStatusDiluted;
      case _HydrationStatusInternal.dehydrated:
        return l10n.hydrationStatusDehydrated;
      case _HydrationStatusInternal.lowSalt:
        return l10n.hydrationStatusLowSalt;
    }
  }
  
  // DEPRECATED: Old getHRI method - kept for compatibility
  // Use HRIService directly
  @deprecated
  int getHRI(AlcoholService? alcoholService) {
    final status = _getInternalHydrationStatus();
    int baseHRI = 0;
    
    // Use internal enum for logic
    switch (status) {
      case _HydrationStatusInternal.normal:
        baseHRI = 15;
        break;
      case _HydrationStatusInternal.lowSalt:
        baseHRI = 45;
        break;
      case _HydrationStatusInternal.dehydrated:
        baseHRI = 55;
        break;
      case _HydrationStatusInternal.diluted:
        baseHRI = 65;
        break;
    }
    
    
    // Add alcohol risk
    if (alcoholService != null) {
      baseHRI += alcoholService.totalHRIModifier.round();
    }
    
    return math.min(baseHRI, 100);
  }
  
  @override
  void dispose() {
    // Clean up achievement service when provider is disposed
    AchievementService.forceHide();
    super.dispose();
  }
}