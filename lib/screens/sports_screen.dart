// lib/screens/sports_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quick_favorites.dart';
import '../providers/hydration_provider.dart';
import '../services/subscription_service.dart';
import '../services/units_service.dart';
import '../services/hri_service.dart';
import '../services/notification_service.dart';
import '../services/remote_config_service.dart';
import '../screens/paywall_screen.dart';

// Import common widgets
import '../widgets/common/favorite_slot_selector.dart';
import '../widgets/common/items_grid.dart';
import '../widgets/common/status_cards.dart';
import '../widgets/common/volume_selection_dialog.dart';

// Import catalog
import '../data/items_catalog.dart';
import '../data/catalog_item.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  // Catalog
  final ItemsCatalog _catalog = ItemsCatalog();
  
  // Favorites manager
  final QuickFavoritesManager _favoritesManager = QuickFavoritesManager();
  
  // Remote config
  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;
  
  // PRO status
  bool _isPro = false;
  
  // Units
  String _units = 'metric';
  
  // Selected category
  String _selectedCategory = 'cardio';
  
  // User weight for calculations
  double _userWeight = 70;
  
  // Show tips card
  bool _showTipsCard = false;
  
  @override
  void initState() {
    super.initState();
    _units = UnitsService.instance.units;
    _loadUserWeight();
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
  
  void _loadUserWeight() {
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    setState(() {
      _userWeight = provider.weight;
    });
  }
  
  // Get current items based on selected category
  List<CatalogItem> _getCurrentItems() {
    // Get all sport items
    final allItems = _catalog.getSportItems();
    
    // Filter by selected category
    return allItems.where((item) {
      final itemCategory = item.properties['category'] as String?;
      return itemCategory == _selectedCategory;
    }).toList();
  }
  
  // Get today's workout stats
  Map<String, dynamic> _getTodayStats() {
    try {
      final hriService = Provider.of<HRIService>(context, listen: false);
      final workouts = hriService.todayWorkouts;
      final losses = hriService.getTodaysWorkoutLosses();
      
      int totalMinutes = 0;
      for (final workout in workouts) {
        totalMinutes += workout.durationMinutes;
      }
      
      return {
        'workoutCount': workouts.length,
        'totalMinutes': totalMinutes,
        'waterLoss': losses['water'] ?? 0,
        'sodiumLoss': losses['sodium'] ?? 0,
        'potassiumLoss': losses['potassium'] ?? 0,
        'magnesiumLoss': losses['magnesium'] ?? 0,
      };
    } catch (e) {
      print('Error getting workout stats: $e');
      return {
        'workoutCount': 0,
        'totalMinutes': 0,
        'waterLoss': 0,
        'sodiumLoss': 0,
        'potassiumLoss': 0,
        'magnesiumLoss': 0,
      };
    }
  }
  
  // Show workout dialog using VolumeSelectionDialog
  Future<void> _showWorkoutDialog(CatalogItem item) async {
    // Check if PRO item
    if (item.isPro && !_isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(source: 'sports'),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    
    // ИСПРАВЛЕНО: Сохраняем ссылки на провайдеры ДО открытия диалога
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    final hriService = Provider.of<HRIService>(context, listen: false);
    
    // Use universal VolumeSelectionDialog with duration mode
    await VolumeSelectionDialog.show(
      context: context,
      item: item,
      onConfirm: (duration) async {
        // ИСПРАВЛЕНО: Используем сохраненные ссылки, а не context
        await _logWorkoutWithProviders(
          item: item,
          durationMinutes: duration.round(),
          provider: provider,
          hriService: hriService,
        );
      },
      onSaveToFavorites: (duration) => _saveToFavorites(item, duration.round()),
      units: _units,
      showDuration: true,
      userWeight: _userWeight,
      sliderColor: Colors.teal,
    );
  }
  
  // НОВЫЙ МЕТОД: Логирование тренировки с передачей провайдеров
  Future<void> _logWorkoutWithProviders({
    required CatalogItem item,
    required int durationMinutes,
    required HydrationProvider provider,
    required HRIService hriService,
  }) async {
    try {
      final l10n = AppLocalizations.of(context);
      
      // Сначала добавляем тренировку в HRIService напрямую
      await hriService.addWorkout(
        type: item.id,
        intensity: item.properties['intensityValue'] as int? ?? 3,
        durationMinutes: durationMinutes,
        item: item,
        userWeight: _userWeight,
        name: item.getName(l10n),
        emoji: item.icon is String ? item.icon as String : null,
      );
      
      // Затем синхронизируем с HydrationProvider
      await provider.syncWithHRIService(hriService);
      
      // Рассчитываем потери для отображения
      final losses = HRIService.calculateWorkoutLosses(
        item: item,
        durationMinutes: durationMinutes,
        userWeight: _userWeight,
      );
      
      // Schedule post-workout reminder (PRO only)
      if (_isPro) {
        try {
          final notificationService = NotificationService();
          final workoutEndTime = DateTime.now().add(Duration(minutes: durationMinutes));
          await notificationService.sendWorkoutReminder(
            workoutEndTime: workoutEndTime,
          );
        } catch (e) {
          print('Failed to schedule workout reminder: $e');
        }
      }
      
      // Show success message
      if (mounted) {
        final waterStr = UnitsService.instance.formatVolume(losses.waterLossMl);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.getName(l10n)} ${l10n.activityLogged}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('${l10n.waterLoss}: $waterStr'),
                Text('Na ${losses.sodiumLossMg}mg, K ${losses.potassiumLossMg}mg'),
                Text('${l10n.target}: +${UnitsService.instance.formatVolume(losses.waterLossMl)}'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Show tips card
        setState(() {
          _showTipsCard = true;
        });
        
        // Force refresh the stats
        setState(() {});
      }
    } catch (e) {
      print('Error logging workout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Save to favorites
  Future<void> _saveToFavorites(CatalogItem item, int duration) async {
    final l10n = AppLocalizations.of(context);
    
    final slot = await FavoriteSlotSelector.show(
      context: context,
      favoritesManager: _favoritesManager,
      isPro: _isPro,
    );
    
    if (slot == null) return;
    
    final losses = HRIService.calculateWorkoutLosses(
      item: item,
      durationMinutes: duration,
      userWeight: _userWeight,
    );
    
    final favorite = QuickFavorite(
      id: 'sport_${item.id}_$duration',
      type: 'sport',
      label: '${item.getName(l10n)}: $duration min',
      emoji: item.icon as String,
      volumeMl: losses.waterLossMl,
      sodiumMg: losses.sodiumLossMg,
      potassiumMg: losses.potassiumLossMg,
      magnesiumMg: losses.magnesiumLossMg,
      metadata: {
        'sportId': item.id,
        'duration': duration,
      },
    );
    
    await _favoritesManager.saveFavorite(slot, favorite);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.savedToFavorites} (${l10n.slot} ${slot + 1})'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Update PRO status
    final subscription = Provider.of<SubscriptionProvider>(context);
    _isPro = subscription.isPro;
    
    // Listen to HRIService changes to update stats
    final hriService = Provider.of<HRIService>(context);
    
    // Get stats
    final stats = _getTodayStats();
    
    // Get current items
    final items = _getCurrentItems();
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.sports),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HRI Status card
          if (stats['workoutCount'] > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        l10n.todaysWorkouts,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '${stats['workoutCount']}',
                        l10n.sessions,
                        Colors.orange,
                      ),
                      _buildStatItem(
                        '${stats['totalMinutes']} min',
                        l10n.totalTime,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        UnitsService.instance.formatVolume(stats['waterLoss'], shortUnit: true),
                        l10n.waterLoss,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Добавляем информацию об электролитах
                  if (stats['sodiumLoss'] > 0 || stats['potassiumLoss'] > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.needsToReplenish}: Na ${stats['sodiumLoss']}mg, K ${stats['potassiumLoss']}mg',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0),
          
          if (stats['workoutCount'] > 0)
            const SizedBox(height: 16),
          
          // Category selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: ['cardio', 'strength', 'sports'].map((category) {
                final isSelected = category == _selectedCategory;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = category);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryName(category, l10n),
                        style: TextStyle(
                          color: isSelected 
                            ? Colors.white 
                            : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0),
          
          const SizedBox(height: 20),
          
          // Items grid
          ItemsGrid(
            items: items,
            isPro: _isPro,
            onItemSelected: _showWorkoutDialog,
            title: _getCategoryTitle(_selectedCategory, l10n),
            childAspectRatio: 0.85,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Tips card
          if (_showTipsCard)
            HydrationTipsCard(
              onDismiss: () => setState(() => _showTipsCard = false),
              l10n: l10n,
              customTips: [
                TipItem(emoji: '💧', text: l10n.drinkWaterAfterWorkout),
                TipItem(emoji: '🧂', text: l10n.replenishElectrolytes),
                TipItem(emoji: '⏱️', text: l10n.restAndRecover),
                TipItem(emoji: '🥤', text: l10n.avoidSugaryDrinks),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String _getCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'cardio':
        return 'Cardio';
      case 'strength':
        return 'Strength';
      case 'sports':
        return 'Sports';
      default:
        return category;
    }
  }
  
  String _getCategoryTitle(String category, AppLocalizations l10n) {
    switch (category) {
      case 'cardio':
        return l10n.selectCardioActivity;
      case 'strength':
        return l10n.selectStrengthActivity;
      case 'sports':
        return l10n.selectSportsActivity;
      default:
        return l10n.selectActivityType;
    }
  }
}