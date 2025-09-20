// lib/screens/alcohol_log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/alcohol_intake.dart';
import '../models/quick_favorites.dart';
import '../providers/hydration_provider.dart';
import '../services/alcohol_service.dart';
import '../services/hri_service.dart';
import '../services/remote_config_service.dart';
import '../services/subscription_service.dart';
import '../services/notification_service.dart';
import '../services/units_service.dart';
import '../screens/paywall_screen.dart';

// Import common widgets
import '../widgets/common/volume_selection_dialog.dart';
import '../widgets/common/favorite_slot_selector.dart';
import '../widgets/common/items_grid.dart';
import '../widgets/common/status_cards.dart';

// Import catalog
import '../data/items_catalog.dart';
import '../data/catalog_item.dart';

class AlcoholLogScreen extends StatefulWidget {
  const AlcoholLogScreen({super.key});

  @override
  State<AlcoholLogScreen> createState() => _AlcoholLogScreenState();
}

class _AlcoholLogScreenState extends State<AlcoholLogScreen> {
  // Catalog & managers
  final ItemsCatalog _catalog = ItemsCatalog();
  final QuickFavoritesManager _favoritesManager = QuickFavoritesManager();
  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;
  
  // State
  bool _isPro = false;
  String _units = 'metric';
  String _selectedType = 'beer'; // beer, wine, spirits, cocktail
  bool _showHarmReduction = false;
  
  @override
  void initState() {
    super.initState();
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
  
  // Get current items from catalog
  List<CatalogItem> _getCurrentItems() {
    return _catalog.getAlcoholItems(type: _selectedType);
  }
  
  // Calculate standard drinks
  double _calculateSD(double volumeMl, double abv) {
    final stdDrinkGrams = _remoteConfig.getDouble('std_drink_grams') ?? 10.0;
    final ethanolGrams = volumeMl * (abv / 100.0) * 0.789;
    return ethanolGrams / stdDrinkGrams;
  }
  
  // Get today's alcohol data
  Map<String, dynamic> _getTodayAlcoholData() {
    try {
      final alcoholService = Provider.of<AlcoholService>(context, listen: false);
      final todaySD = alcoholService.totalStandardDrinks;
      
      return {
        'totalSD': todaySD,
        'waterCorrection': alcoholService.totalWaterCorrection,
        'sodiumCorrection': alcoholService.totalSodiumCorrection,
        'hriModifier': alcoholService.totalHRIModifier,
      };
    } catch (e) {
      return {
        'totalSD': 0.0,
        'waterCorrection': 0.0,
        'sodiumCorrection': 0.0,
        'hriModifier': 0.0,
      };
    }
  }
  
  // Log alcohol intake
  Future<void> _logIntake(CatalogItem item, double volumeMl) async {
    final abv = (item.properties['abv'] as num).toDouble();
    final sugar = item.properties['sugar'] as double? ?? 0.0;
    
    // Calculate proportional sugar based on volume
    final baseVolume = item.getDefaultVolume(_units).toDouble();
    final baseVolumeMl = _units == 'imperial' ? baseVolume * 29.5735 : baseVolume;
    final proportionalSugar = (sugar * volumeMl / baseVolumeMl);
    
    // Create intake
    final intake = AlcoholIntake(
      timestamp: DateTime.now(),
      type: _getAlcoholType(_selectedType),
      volumeMl: volumeMl,
      abv: abv,
      sugar: proportionalSugar,
      name: item.getName(AppLocalizations.of(context)!),
      emoji: item.icon is String ? item.icon as String : null,
    );
    
    try {
  final alcoholService = Provider.of<AlcoholService>(context, listen: false);
  await alcoholService.addIntake(intake);
  
  // ДОБАВИТЬ: Синхронизируем с HRIService
  try {
    final hriService = Provider.of<HRIService>(context, listen: false);
    await hriService.addAlcoholIntake(intake.standardDrinks);
    print('Alcohol synced: ${intake.standardDrinks} SD to HRIService');
  } catch (e) {
    print('Error syncing with HRIService: $e');
  }
  
  // ДОБАВИТЬ: Обновляем корректировки в HydrationProvider
  try {
    final hydrationProvider = Provider.of<HydrationProvider>(context, listen: false);
    hydrationProvider.updateAlcoholAdjustments(
      alcoholService.totalWaterCorrection,
      alcoholService.totalSodiumCorrection.round(),
    );
    print('Alcohol adjustments updated in HydrationProvider');
  } catch (e) {
    print('Error updating alcohol adjustments: $e');
  }
  
  // Schedule notification
  await NotificationService().scheduleAlcoholCounterReminder(intake.standardDrinks.toInt());
  
  // Show harm reduction card
  setState(() => _showHarmReduction = true);
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      // Success message
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${intake.formattedSD} ${l10n.addedSuccessfully}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error logging intake: $e');
    }
  }
  
  // Save to favorites
  Future<void> _saveToFavorites(CatalogItem item, double volumeMl) async {
    final l10n = AppLocalizations.of(context);
    
    final slot = await FavoriteSlotSelector.show(
      context: context,
      favoritesManager: _favoritesManager,
      isPro: _isPro,
    );
    
    if (slot == null) return;
    
    final volumeStr = UnitsService.instance.formatVolume(volumeMl.round());
    final abv = item.properties['abv'] as num;
    
    final favorite = QuickFavorite(
      id: 'alcohol_${item.id}_${volumeMl.toInt()}',
      type: 'alcohol',
      label: '${item.getName(l10n)}: $abv% - $volumeStr',
      emoji: item.icon as String,
      volumeMl: volumeMl.toInt(),
      metadata: {
        'alcoholType': _selectedType,
        'abv': abv,
        'name': item.getName(l10n),
        'sugar': item.properties['sugar'] ?? 0.0,
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
  
  // Handle item selection
  void _handleItemSelection(CatalogItem item) async {
    if (item.isPro && !_isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(source: 'alcohol_log'),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    
    // Show enhanced volume selection dialog with ABV and SD calculation
    await VolumeSelectionDialog.show(
      context: context,
      item: item,
      onConfirm: (volumeMl) => _logIntake(item, volumeMl),
      onSaveToFavorites: (volumeMl) => _saveToFavorites(item, volumeMl),
      units: _units,
      sliderColor: Colors.red.shade400,
      showAlcoholInfo: true, // This will show ABV and SD
      calculateSD: _calculateSD,
    );
  }
  
  // Show alcohol info dialog
  void _showAlcoholInfoDialog() {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.local_bar, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(l10n.aboutAlcohol),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('🍺', l10n.alcoholInfo1),
              const SizedBox(height: 12),
              _buildInfoRow('💧', l10n.alcoholInfo2),
              const SizedBox(height: 12),
              _buildInfoRow('🧂', l10n.alcoholInfo3),
              const SizedBox(height: 12),
              _buildInfoRow('❤️', l10n.alcoholInfo4),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.alcoholWarningHealth,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
  
  AlcoholType _getAlcoholType(String type) {
    switch (type) {
      case 'beer': return AlcoholType.beer;
      case 'wine': return AlcoholType.wine;
      case 'spirits': return AlcoholType.spirits;
      case 'cocktail': return AlcoholType.cocktail;
      default: return AlcoholType.beer;
    }
  }
  
  Color _getStatusColor(double sd) {
    if (sd == 0) return Colors.green;
    if (sd <= 1.0) return Colors.blue;
    if (sd <= 2.0) return Colors.orange;
    if (sd <= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
  
  String _getStatusMessage(double sd, AppLocalizations l10n) {
    if (sd == 0) return l10n.noAlcoholToday;
    if (sd <= 1) return l10n.moderateConsumption;
    if (sd <= 2) return l10n.aboveRecommendations;
    if (sd <= 3) return l10n.highConsumption;
    return l10n.veryHighConsider;
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Update PRO status
    final subscription = Provider.of<SubscriptionProvider>(context);
    _isPro = subscription.isPro;
    
    // Get alcohol data
    final alcoholData = _getTodayAlcoholData();
    final todaySD = alcoholData['totalSD'] as double;
    final statusColor = _getStatusColor(todaySD);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.addAlcohol),
        elevation: 0,
        backgroundColor: Colors.red[500],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Enhanced alcohol status card - similar to CaffeineStatusCard
          EnhancedAlcoholStatusCard(
            todaySD: todaySD,
            waterCorrection: alcoholData['waterCorrection'] as double,
            sodiumCorrection: alcoholData['sodiumCorrection'] as double,
            hriModifier: alcoholData['hriModifier'] as double,
            l10n: l10n,
            onInfoTap: _showAlcoholInfoDialog,
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Type selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: ['beer', 'wine', 'spirits', 'cocktail'].map((type) {
                final isSelected = type == _selectedType;
                final emoji = _getTypeEmoji(type);
                final name = _getTypeName(type, l10n);
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = type);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                          if (type != 'spirits') ...[
                            const SizedBox(width: 4),
                            Text(
                              name,
                              style: TextStyle(
                                color: isSelected 
                                  ? theme.colorScheme.onPrimary 
                                  : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
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
          
          // Items grid using catalog
          ItemsGrid(
            items: _getCurrentItems(),
            isPro: _isPro,
            onItemSelected: _handleItemSelection,
            title: l10n.popularDrinks(_getTypeName(_selectedType, l10n).toLowerCase()),
            showAlcoholIndicators: true,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Harm reduction card
          if (_showHarmReduction)
            HarmReductionCard(
              onDismiss: () => setState(() => _showHarmReduction = false),
              l10n: l10n,
              isPro: _isPro,
            ).animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
        ],
      ),
    );
  }
  
  String _getTypeEmoji(String type) {
    switch (type) {
      case 'beer': return '🍺';
      case 'wine': return '🍷';
      case 'spirits': return '🥃';
      case 'cocktail': return '🍹';
      default: return '🍺';
    }
  }
  
  String _getTypeName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'beer': return l10n.beer;
      case 'wine': return l10n.wine;
      case 'spirits': return l10n.spirits;
      case 'cocktail': return l10n.cocktail;
      default: return '';
    }
  }
}

// Enhanced status card for alcohol - similar to CaffeineStatusCard style
class EnhancedAlcoholStatusCard extends StatelessWidget {
  final double todaySD;
  final double waterCorrection;
  final double sodiumCorrection;
  final double hriModifier;
  final AppLocalizations l10n;
  final VoidCallback onInfoTap;
  
  const EnhancedAlcoholStatusCard({
    super.key,
    required this.todaySD,
    required this.waterCorrection,
    required this.sodiumCorrection,
    required this.hriModifier,
    required this.l10n,
    required this.onInfoTap,
  });
  
  Color _getStatusColor(double sd) {
    if (sd == 0) return Colors.green;
    if (sd <= 1.0) return Colors.blue;
    if (sd <= 2.0) return Colors.orange;
    if (sd <= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
  
  String _getStatusMessage(double sd) {
    if (sd == 0) return l10n.noAlcoholToday;
    if (sd <= 1) return l10n.moderateConsumption;
    if (sd <= 2) return l10n.aboveRecommendations;
    if (sd <= 3) return l10n.highConsumption;
    return l10n.veryHighConsider;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(todaySD);
    final percent = (todaySD / 3.0 * 100).clamp(0.0, 150.0);
    
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
        children: [
          // Top row with ring and info
          Row(
            children: [
              // Ring indicator - similar to CaffeineStatusCard
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background ring
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 10,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          Colors.grey.shade200,
                        ),
                      ),
                    ),
                    // Progress ring
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: (todaySD / 3.0).clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(statusColor),
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          todaySD.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          l10n.standardDrinksUnit,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.todayConsumed,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          iconSize: 20,
                          onPressed: onInfoTap,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    Text(
                      _getStatusMessage(todaySD),
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Percentage indicator
                    Row(
                      children: [
                        Icon(
                          Icons.local_bar,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${percent.toStringAsFixed(0)}% ${l10n.ofRecommendedLimit}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Corrections row - only show if there's alcohol consumed
          if (todaySD > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CorrectionItem(
                    icon: Icons.water_drop,
                    value: '+${UnitsService.instance.formatVolume(waterCorrection.round(), hideUnit: true)}',
                    unit: UnitsService.instance.volumeUnit,
                    label: l10n.additionalWater,
                    color: Colors.blue,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  _CorrectionItem(
                    icon: Icons.grain,
                    value: '+${sodiumCorrection.toStringAsFixed(0)}',
                    unit: 'mg',
                    label: l10n.additionalSodium,
                    color: Colors.purple,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  _CorrectionItem(
                    icon: Icons.warning,
                    value: '+${hriModifier.toStringAsFixed(1)}',
                    unit: '',
                    label: l10n.hriRisk,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CorrectionItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;
  
  const _CorrectionItem({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Harm reduction card
class HarmReductionCard extends StatelessWidget {
  final VoidCallback onDismiss;
  final AppLocalizations l10n;
  final bool isPro;
  
  const HarmReductionCard({
    super.key,
    required this.onDismiss,
    required this.l10n,
    required this.isPro,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.minimumHarm,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('💧', l10n.drinkWaterNow),
          _buildStep('🧂', l10n.addPinchSalt),
          _buildStep('☕', l10n.avoidLateCoffee),
          _buildStep('🛏️', l10n.goToBedEarly),
          if (isPro) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.purple.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.alcoholProtocolsDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStep(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}