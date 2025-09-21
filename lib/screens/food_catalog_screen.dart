// lib/screens/food_catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quick_favorites.dart';
import '../models/food_intake.dart';
import '../providers/hydration_provider.dart';
import '../services/subscription_service.dart';
import '../services/units_service.dart';
import '../services/analytics_service.dart';
import '../screens/paywall_screen.dart';
import '../screens/barcode_scanner_screen.dart';
import '../screens/openfood_catalog_screen.dart';
import '../data/items_catalog.dart';
import '../data/catalog_item.dart';

// Import common widgets
import '../widgets/common/type_selector.dart';
import '../widgets/common/items_grid.dart';
import '../widgets/common/volume_selection_dialog.dart';
import '../widgets/common/favorite_slot_selector.dart';

// Food categories enum
enum FoodCategory {
  fruits,
  vegetables,
  soups,
  dairy,
  meat,
  fastFood,
}

class FoodCatalogScreen extends StatefulWidget {
  const FoodCatalogScreen({super.key});

  @override
  State<FoodCatalogScreen> createState() => _FoodCatalogScreenState();
}

class _FoodCatalogScreenState extends State<FoodCatalogScreen>
    with SingleTickerProviderStateMixin {

  // Animation controller
  late AnimationController _animController;

  // Favorites manager
  final QuickFavoritesManager _favoritesManager = QuickFavoritesManager();

  // Items catalog
  final ItemsCatalog _catalog = ItemsCatalog();

  // PRO status
  bool _isPro = false;

  // Units
  String _units = 'metric';

  // Selected food category
  FoodCategory _selectedCategory = FoodCategory.fruits;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();

    _units = UnitsService.instance.units;
    _initializePro();
  }

  Future<void> _initializePro() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final subscription = Provider.of<SubscriptionProvider>(context, listen: false);
    _isPro = subscription.isPro;
    await _favoritesManager.init(_isPro);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Get items for current category from catalog
  List<CatalogItem> _getCurrentItems() {
    ItemCategory category;
    switch (_selectedCategory) {
      case FoodCategory.fruits:
        category = ItemCategory.fruits;
        break;
      case FoodCategory.vegetables:
        category = ItemCategory.vegetables;
        break;
      case FoodCategory.soups:
        category = ItemCategory.soups;
        break;
      case FoodCategory.dairy:
        category = ItemCategory.dairy;
        break;
      case FoodCategory.meat:
        category = ItemCategory.meat;
        break;
      case FoodCategory.fastFood:
        category = ItemCategory.fastFood;
        break;
    }
    return _catalog.getItemsForCategory(category);
  }

  // Get today's food intake
  Map<String, dynamic> _getTodayFoodIntake() {
    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      final todayFood = provider.todayFoodIntakes;

      int totalCalories = 0;
      double totalWater = 0;
      int totalSodium = 0;
      int totalPotassium = 0;
      int totalMagnesium = 0;
      double totalSugar = 0;

      for (final food in todayFood) {
        totalCalories += food.calories;
        totalWater += food.waterContent;
        totalSodium += food.sodium;
        totalPotassium += food.potassium;
        totalMagnesium += food.magnesium;
        totalSugar += food.sugar;
      }

      return {
        'count': todayFood.length,
        'calories': totalCalories,
        'water': totalWater,
        'sodium': totalSodium,
        'potassium': totalPotassium,
        'magnesium': totalMagnesium,
        'sugar': totalSugar,
      };
    } catch (e) {
      return {
        'count': 0,
        'calories': 0,
        'water': 0.0,
        'sodium': 0,
        'potassium': 0,
        'magnesium': 0,
        'sugar': 0.0,
      };
    }
  }

  // Handle item tap
  Future<void> _onItemTap(CatalogItem item) async {
    // Check PRO status
    if (item.isPro && !_isPro) {
      if (mounted) {
        final shouldShowPaywall = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaywallScreen(source: 'food_catalog'),
          ),
        );
        if (shouldShowPaywall != true) return;
      }
      return;
    }

    // Show food weight selection dialog using VolumeSelectionDialog
    await VolumeSelectionDialog.show(
      context: context,
      item: item,
      onConfirm: (weight) => _logFoodIntake(item, weight),
      onSaveToFavorites: (weight) => _saveToFavorites(item, weight),
      units: _units,
      sliderColor: Colors.deepOrange,
      showFoodInfo: true, // New parameter for food mode
    );
  }

  // Log food intake
  Future<void> _logFoodIntake(CatalogItem item, double weight) async {
    // Calculate nutritional values based on weight
    final waterPercentage = item.properties['waterPercentage'] as double;
    final caloriesPer100g = item.properties['caloriesPer100g'] as int;
    final sugarPer100g = item.properties['sugarPer100g'] as double;
    final sodium = item.properties['sodium'] as int;
    final potassium = item.properties['potassium'] as int;
    final magnesium = item.properties['magnesium'] as int;
    final hasCaffeine = item.properties['hasCaffeine'] as bool;

    // Calculate values for the actual weight
    final actualCalories = ((caloriesPer100g * weight) / 100).round();
    final actualWater = (weight * waterPercentage);
    final actualSugar = (sugarPer100g * weight) / 100;
    final actualSodium = ((sodium * weight) / 100).round();
    final actualPotassium = ((potassium * weight) / 100).round();
    final actualMagnesium = ((magnesium * weight) / 100).round();

    // Create food intake
    final foodIntake = FoodIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      foodId: item.id,
      foodName: item.getName(AppLocalizations.of(context)!),
      weight: weight,
      calories: actualCalories,
      waterContent: actualWater,
      sodium: actualSodium,
      potassium: actualPotassium,
      magnesium: actualMagnesium,
      sugar: actualSugar,
      hasCaffeine: hasCaffeine,
      emoji: item.icon is String ? item.icon as String : null,
    );

    // Add to provider
    if (mounted) {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      await provider.addFoodIntake(foodIntake);

      // Log analytics
      await AnalyticsService().log('food_added', {
        'food_id': item.id,
        'food_name': item.getName(AppLocalizations.of(context)!),
        'category': _selectedCategory.name,
        'weight': weight,
        'calories': actualCalories,
        'water_content': actualWater,
        'is_pro': item.isPro,
      });

      // Show feedback
      HapticFeedback.lightImpact();
      final l10nLocal = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10nLocal.foodAddedSuccess(
              item.getName(l10nLocal),
              actualCalories,
              UnitsService.instance.formatVolume(actualWater.round()),
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Save to favorites
  Future<void> _saveToFavorites(CatalogItem item, double weight) async {
    final l10n = AppLocalizations.of(context);

    // Show favorite slot selector
    final slot = await FavoriteSlotSelector.show(
      context: context,
      favoritesManager: _favoritesManager,
      isPro: _isPro,
    );

    if (slot == null) return;

    final weightStr = UnitsService.instance.isImperial
        ? '${(weight / 28.3495).round()}oz'
        : '${weight.round()}g';
    final itemName = item.getName(l10n);
    final calories = ((item.properties['caloriesPer100g'] as int) * weight / 100).round();

    final favorite = QuickFavorite(
      id: 'food_${item.id}_${weight.toInt()}',
      type: 'food',
      label: '$itemName: $weightStr ($calories kcal)',
      emoji: item.icon as String,
      volumeMl: weight.toInt(), // Store weight as volume for compatibility
      metadata: {
        'foodName': itemName,
        'weight': weight,
        'calories': calories,
        'category': _selectedCategory.name,
        'waterPercentage': item.properties['waterPercentage'],
        'caloriesPer100g': item.properties['caloriesPer100g'],
        'sugarPer100g': item.properties['sugarPer100g'],
        'sodium': item.properties['sodium'],
        'potassium': item.properties['potassium'],
        'magnesium': item.properties['magnesium'],
        'hasCaffeine': item.properties['hasCaffeine'],
      },
    );

    await _favoritesManager.saveFavorite(slot, favorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.savedToFavorites} (${l10n.slot} ${slot + 1})'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }


  // Get status color based on food intake
  Color _getStatusColor(Map<String, dynamic> intake) {
    final calories = intake['calories'] as int;
    if (calories == 0) {
      return Colors.grey;
    } else if (calories < 500) {
      return Colors.green;
    } else if (calories < 1000) {
      return Colors.blue;
    } else if (calories < 1500) {
      return Colors.orange;
    } else if (calories < 2000) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Update PRO status
    final subscription = Provider.of<SubscriptionProvider>(context);
    _isPro = subscription.isPro;

    // Get food intake
    final intake = _getTodayFoodIntake();
    final statusColor = _getStatusColor(intake);

    // Get items for current category
    final currentItems = _getCurrentItems();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.foodCatalog),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OpenFoodCatalogScreen(),
                ),
              );
            },
            tooltip: 'Search OpenFood',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerScreen(),
                ),
              );
            },
            tooltip: l10n.scanBarcode,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card with food summary
          FoodStatusCard(
            intake: intake,
            statusColor: statusColor,
            l10n: l10n,
            units: _units,
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.1, end: 0),

          const SizedBox(height: 24),

          // Category selector
          FoodCategorySelector(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
              HapticFeedback.selectionClick();
            },
          ).animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0),

          const SizedBox(height: 20),

          // Items grid using catalog items
          ItemsGrid(
            items: currentItems,
            isPro: _isPro,
            title: l10n.selectFoodType,
            onItemSelected: (item) async {
              await _onItemTap(item);
            },
            showElectrolyteIndicators: true,
            showSugarIndicators: true,
            showCaffeineIndicators: true,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

}

// Food Status Card - matches liquid catalog design
class FoodStatusCard extends StatelessWidget {
  final Map<String, dynamic> intake;
  final Color statusColor;
  final AppLocalizations l10n;
  final String units;

  const FoodStatusCard({
    super.key,
    required this.intake,
    required this.statusColor,
    required this.l10n,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calories = intake['calories'] as int;
    final count = intake['count'] as int;
    final water = intake['water'] as double;
    final sodium = intake['sodium'] as int;
    final potassium = intake['potassium'] as int;
    final magnesium = intake['magnesium'] as int;
    final sugar = intake['sugar'] as double;

    // Get today's food intakes for additional info
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    final todayFood = provider.todayFoodIntakes;

    // Calculate daily progress (assume 2000 kcal daily goal)
    final dailyCalorieGoal = 2000;
    final calorieProgress = calories / dailyCalorieGoal;
    final progressPercent = (calorieProgress * 100).clamp(0, 100).round();

    // Get last food item
    final lastFood = todayFood.isNotEmpty ? todayFood.last : null;
    final timeSinceLastFood = lastFood != null
        ? DateTime.now().difference(lastFood.timestamp)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.todaysFoodIntake,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (calories > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$progressPercent%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      count == 0
                          ? l10n.noFoodToday
                          : lastFood != null
                              ? '${l10n.last}: ${lastFood.foodName} ${_formatTimeAgo(timeSinceLastFood!)}'
                              : l10n.foodItemsCount(count),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main stats row with better layout
          Row(
            children: [
              // Calories with progress bar
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('🔥', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '$calories ${l10n.kcal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: calorieProgress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of $dailyCalorieGoal daily',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Water and Sugar
              Expanded(
                child: Column(
                  children: [
                    _buildCompactStat('💧', UnitsService.instance.formatVolume(water.round()), l10n.water),
                    const SizedBox(height: 8),
                    _buildCompactStat('🍯', '${sugar.round()}g', l10n.sugar),
                  ],
                ),
              ),
            ],
          ),

          // Electrolytes section (only if there are significant amounts)
          if (sodium > 0 || potassium > 0 || magnesium > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.electrolytes,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (sodium > 0)
                        _buildElectrolyteItem('Na', sodium, Colors.blue),
                      if (potassium > 0)
                        _buildElectrolyteItem('K', potassium, Colors.green),
                      if (magnesium > 0)
                        _buildElectrolyteItem('Mg', magnesium, Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Compact stat item
  Widget _buildCompactStat(String icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Format time ago
  String _formatTimeAgo(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildElectrolyteItem(String symbol, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'mg',
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// Food Category Selector - matches liquid catalog design
class FoodCategorySelector extends StatelessWidget {
  final FoodCategory selectedCategory;
  final ValueChanged<FoodCategory> onCategoryChanged;

  const FoodCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TypeSelector<FoodCategory>(
      selectedType: selectedCategory,
      onTypeChanged: onCategoryChanged,
      types: FoodCategory.values,
      getTypeName: (category, l10n) => _getCategoryName(category, l10n),
    );
  }

  String _getCategoryName(FoodCategory category, AppLocalizations l10n) {
    switch (category) {
      case FoodCategory.fruits:
        return l10n.categoryFruits;
      case FoodCategory.vegetables:
        return l10n.categoryVegetables;
      case FoodCategory.soups:
        return l10n.categorySoups;
      case FoodCategory.dairy:
        return l10n.categoryDairy;
      case FoodCategory.meat:
        return l10n.categoryMeat;
      case FoodCategory.fastFood:
        return l10n.categoryFastFood;
    }
  }
}