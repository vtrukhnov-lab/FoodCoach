// lib/screens/electrolytes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quick_favorites.dart';
import '../providers/hydration_provider.dart';
import '../services/subscription_service.dart';
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

class ElectrolytesScreen extends StatefulWidget {
  const ElectrolytesScreen({super.key});

  @override
  State<ElectrolytesScreen> createState() => _ElectrolytesScreenState();
}

class _ElectrolytesScreenState extends State<ElectrolytesScreen> {
  // Catalog
  final ItemsCatalog _catalog = ItemsCatalog();
  
  // Favorites manager
  final QuickFavoritesManager _favoritesManager = QuickFavoritesManager();
  
  // PRO status
  bool _isPro = false;
  
  // Units
  String _units = 'metric';
  
  // Selected type - only basic and mixes
  String _selectedType = 'basic';
  
  // Show tips card
  bool _showTipsCard = false;
  
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
  
  // Get current items based on selected type
  List<CatalogItem> _getCurrentItems() {
    return _catalog.getElectrolyteItems(subtype: _selectedType);
  }
  
  // Get today's totals
  Map<String, int> _getTodayTotals() {
    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      
      return {
        'sodium': provider.totalSodiumToday,
        'potassium': provider.totalPotassiumToday,
        'magnesium': provider.totalMagnesiumToday,
        'sodiumGoal': provider.goals.sodium,
        'potassiumGoal': provider.goals.potassium,
        'magnesiumGoal': provider.goals.magnesium,
      };
    } catch (e) {
      print('Error getting electrolyte totals: $e');
      return {
        'sodium': 0,
        'potassium': 0,
        'magnesium': 0,
        'sodiumGoal': 2000,
        'potassiumGoal': 3500,
        'magnesiumGoal': 400,
      };
    }
  }
  
  // Log electrolyte intake
  Future<void> _logIntake(CatalogItem item, double volumeMl) async {
    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      
      // Calculate proportional electrolytes based on volume
      final baseVolume = item.getDefaultVolume(_units).toDouble();
      final baseVolumeMl = _units == 'imperial' ? baseVolume * 29.5735 : baseVolume;
      final multiplier = volumeMl / baseVolumeMl;
      
      final sodium = ((item.properties['sodium'] ?? 0) * multiplier).round();
      final potassium = ((item.properties['potassium'] ?? 0) * multiplier).round();
      final magnesium = ((item.properties['magnesium'] ?? 0) * multiplier).round();
      
      provider.addIntake(
        'electrolyte',
        volumeMl.round(),
        sodium: sodium,
        potassium: potassium,
        magnesium: magnesium,
        source: 'electrolytes_screen',
        name: item.getName(AppLocalizations.of(context)!),
        emoji: item.icon is String ? item.icon as String : null,
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).addedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Show tips card after first intake
      setState(() {
        _showTipsCard = true;
      });
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
    
    // Calculate proportional electrolytes
    final baseVolume = item.getDefaultVolume(_units).toDouble();
    final baseVolumeMl = _units == 'imperial' ? baseVolume * 29.5735 : baseVolume;
    final multiplier = volumeMl / baseVolumeMl;
    
    final favorite = QuickFavorite(
      id: 'electrolyte_${item.id}_${volumeMl.round()}',
      type: 'electrolyte',
      label: '${item.getName(l10n)}: $volumeStr',
      emoji: item.icon as String,
      volumeMl: volumeMl.round(),
      sodiumMg: ((item.properties['sodium'] ?? 0) * multiplier).round(),
      potassiumMg: ((item.properties['potassium'] ?? 0) * multiplier).round(),
      magnesiumMg: ((item.properties['magnesium'] ?? 0) * multiplier).round(),
      metadata: {
        'name': item.getName(l10n),
        'sugar': (item.properties['sugar'] ?? 0.0) * multiplier,
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
    // Check if PRO item
    if (item.isPro && !_isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(source: 'electrolytes'),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    
    // Show enhanced volume selection dialog with electrolyte support
    await VolumeSelectionDialog.show(
      context: context,
      item: item,
      onConfirm: (volumeMl) => _logIntake(item, volumeMl),
      onSaveToFavorites: (volumeMl) => _saveToFavorites(item, volumeMl),
      units: _units,
      showElectrolytes: true,
      sliderColor: Colors.orange,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Update PRO status
    final subscription = Provider.of<SubscriptionProvider>(context);
    _isPro = subscription.isPro;
    
    // Get electrolyte totals
    final totals = _getTodayTotals();
    
    // Get current items
    final items = _getCurrentItems();
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.electrolyte),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card using enhanced common component
          ElectrolyteStatusCard(
            totals: totals,
            l10n: l10n,
          ),
          
          const SizedBox(height: 24),
          
          // Type selector - simple implementation for two types
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: ['basic', 'mixes'].map((type) {
                final isSelected = type == _selectedType;
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
                        color: isSelected ? Colors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type == 'basic' 
                          ? l10n.electrolytesBasic 
                          : l10n.electrolytesMixes,
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
          
          // Items grid using enhanced common component
          ItemsGrid(
            items: items,
            isPro: _isPro,
            onItemSelected: _handleItemSelection,
            title: _selectedType == 'basic' 
              ? l10n.popularSalts 
              : l10n.popularMixes,
            childAspectRatio: 0.75,
            showElectrolyteIndicators: true,
            showSugarIndicators: true,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Tips card using common component
          if (_showTipsCard)
            HydrationTipsCard(
              onDismiss: () => setState(() => _showTipsCard = false),
              l10n: l10n,
              customTips: [
                TipItem(emoji: '💧', text: l10n.takeWithWater),
                TipItem(emoji: '⏰', text: l10n.bestBetweenMeals),
                TipItem(emoji: '🧂', text: l10n.startSmallAmounts),
                TipItem(emoji: '🏃', text: l10n.extraDuringExercise),
              ],
            ),
        ],
      ),
    );
  }
}