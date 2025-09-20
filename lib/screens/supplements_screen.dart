// ============================================================================
// FILE: lib/screens/supplements_screen.dart
// 
// PURPOSE: Supplements Screen - unified with other screens
// Uses common components and patterns from the project
// ============================================================================

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

// Common widgets
import '../widgets/common/volume_selection_dialog.dart';
import '../widgets/common/favorite_slot_selector.dart';
import '../widgets/common/items_grid.dart';
import '../widgets/common/status_cards.dart';

// Catalog
import '../data/items_catalog.dart';
import '../data/catalog_item.dart';

enum SupplementType { minerals, vitamins, other }

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> 
    with SingleTickerProviderStateMixin {
  
  // Animation controller
  late AnimationController _animController;
  
  // Catalog
  final ItemsCatalog _catalog = ItemsCatalog();
  
  // Favorites manager
  final QuickFavoritesManager _favoritesManager = QuickFavoritesManager();
  
  // Units
  String _units = 'metric';
  
  // Selected subtype
  SupplementType _selectedType = SupplementType.minerals;
  
  // Show tips
  bool _showTips = false;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();
    
    _units = UnitsService.instance.units;
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    
    // Get PRO status from provider
    final subscription = Provider.of<SubscriptionProvider>(context, listen: false);
    await _favoritesManager.init(subscription.isPro);
    
    if (mounted) setState(() {});
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  
  // Map enum to catalog subtype
  String _getSubtype() {
    switch (_selectedType) {
      case SupplementType.minerals:
        return 'minerals';
      case SupplementType.vitamins:
        return 'vitamins';
      case SupplementType.other:
        return 'other';
    }
  }
  
  // Get current items from catalog
  List<CatalogItem> _getCurrentItems() {
    return _catalog.getSupplementItems(subtype: _getSubtype());
  }
  
  // Get today's totals for status card
  Map<String, int> _getTodayTotals() {
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    
    final sodium = provider.totalSodiumToday;
    final potassium = provider.totalPotassiumToday;
    final magnesium = provider.totalMagnesiumToday;
    
    final sodiumGoal = provider.goals.sodium;
    final potassiumGoal = provider.goals.potassium;
    final magnesiumGoal = provider.goals.magnesium;
    
    return {
      'sodium': sodium,
      'sodiumGoal': sodiumGoal,
      'potassium': potassium,
      'potassiumGoal': potassiumGoal,
      'magnesium': magnesium,
      'magnesiumGoal': magnesiumGoal,
    };
  }
  
  // Log supplement intake
  Future<void> _logIntake({
    required CatalogItem item,
    required double dosageValue,
  }) async {
    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context);
      
      // CRITICAL: Set context for AchievementService
      provider.setContext(context);
      
      // Calculate electrolytes based on dosage
      final props = item.properties;
      
      int sodium = 0;
      int potassium = 0;
      int magnesium = 0;
      
      if (props.containsKey('sodium')) {
        sodium = ((props['sodium'] as num) * dosageValue).round();
      }
      
      if (props.containsKey('potassium')) {
        potassium = ((props['potassium'] as num) * dosageValue).round();
      }
      
      if (props.containsKey('magnesium')) {
        magnesium = ((props['magnesium'] as num) * dosageValue).round();
      }
      
      // Log through unified HydrationProvider
      provider.addIntake(
        'supplement_${_getSubtype()}',
        0, // No volume for supplements
        sodium: sodium,
        potassium: potassium,
        magnesium: magnesium,
        source: 'supplements',
        name: item.getName(AppLocalizations.of(context)!),
        emoji: item.icon is String ? item.icon as String : null,
      );
      
      // Show tips after first supplement
      setState(() {
        if (!_showTips) {
          _showTips = true;
        }
      });
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      // Success animation
      _animController.reset();
      _animController.forward();
      
      // Success message
      if (mounted) {
        final dosageUnit = item.getDosageUnit(_units);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('${item.getName(l10n)}: ${dosageValue.toInt()} $dosageUnit'),
              ],
            ),
            backgroundColor: Colors.purple[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('Error logging supplement: $e');
    }
  }
  
  // Save to favorites
  Future<void> _saveToFavorites({
    required CatalogItem item,
    required double dosageValue,
  }) async {
    final l10n = AppLocalizations.of(context);
    
    // Get current PRO status
    final subscription = Provider.of<SubscriptionProvider>(context, listen: false);
    final isPro = subscription.isPro;
    
    // Show favorite slot selector
    final slot = await FavoriteSlotSelector.show(
      context: context,
      favoritesManager: _favoritesManager,
      isPro: isPro,
    );
    
    if (slot == null) return;
    
    // Calculate electrolytes
    final props = item.properties;
    int sodium = 0;
    int potassium = 0;
    int magnesium = 0;
    
    if (props.containsKey('sodium')) {
      sodium = ((props['sodium'] as num) * dosageValue).round();
    }
    
    if (props.containsKey('potassium')) {
      potassium = ((props['potassium'] as num) * dosageValue).round();
    }
    
    if (props.containsKey('magnesium')) {
      magnesium = ((props['magnesium'] as num) * dosageValue).round();
    }
    
    final dosageUnit = item.getDosageUnit(_units);
    final itemName = item.getName(l10n);
    final label = '$itemName: ${dosageValue.toInt()} $dosageUnit';
    
    final favorite = QuickFavorite(
      id: 'supplement_${item.id}_${dosageValue.toInt()}',
      type: 'supplement',
      label: label,
      emoji: '💊',
      volumeMl: 0,
      sodiumMg: sodium,
      potassiumMg: potassium,
      magnesiumMg: magnesium,
      metadata: {
        'supplementType': _getSubtype(),
        'dosageValue': dosageValue,
        'dosageUnit': dosageUnit,
        'name': itemName,
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
  Future<void> _onItemSelected(CatalogItem item) async {
    // Check PRO status
    final subscription = Provider.of<SubscriptionProvider>(context, listen: false);
    final isPro = subscription.isPro;
    
    // Check if PRO item
    if (item.isPro && !isPro) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(source: 'supplements'),
          fullscreenDialog: true,
        ),
      );
      
      // Check if upgraded
      final updatedSubscription = Provider.of<SubscriptionProvider>(context, listen: false);
      if (!updatedSubscription.isPro) return;
    }
    
    // Update favorites manager
    final currentSubscription = Provider.of<SubscriptionProvider>(context, listen: false);
    await _favoritesManager.init(currentSubscription.isPro);
    
    // Show dosage dialog
    await VolumeSelectionDialog.show(
      context: context,
      item: item,
      units: _units,
      showDosage: true,
      sliderColor: Colors.purple,
      onConfirm: (dosageValue) async {
        await _logIntake(item: item, dosageValue: dosageValue);
        if (mounted) Navigator.of(context).pop(true);
      },
      onSaveToFavorites: (dosageValue) async {
        await _saveToFavorites(item: item, dosageValue: dosageValue);
      },
    );
  }
  
  // Show supplement info
  void _showSupplementInfo() {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.medication, color: Colors.purple, size: 28),
            const SizedBox(width: 12),
            Text(l10n.supplements),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('💊', l10n.supplementsInfo1),
              const SizedBox(height: 12),
              _buildInfoRow('⏰', l10n.supplementsInfo2),
              const SizedBox(height: 12),
              _buildInfoRow('💧', l10n.supplementsInfo3),
              const SizedBox(height: 12),
              _buildInfoRow('⚡', l10n.supplementsInfo4),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.purple.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.supplementsWarning,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.purple.shade900,
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
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Get PRO status
    final subscription = Provider.of<SubscriptionProvider>(context);
    final isPro = subscription.isPro;
    
    // Get data
    final items = _getCurrentItems();
    final totals = _getTodayTotals();
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.supplements),
        elevation: 0,
        backgroundColor: Colors.purple[500],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Electrolyte status card with info button
          ElectrolyteStatusCard(
            totals: totals,
            l10n: l10n,
            onInfoTap: _showSupplementInfo,
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.1, end: 0),
          
          const SizedBox(height: 24),
          
          // Type selector - unified style
          _SupplementTypeSelector(
            selected: _selectedType,
            onChanged: (type) {
              setState(() => _selectedType = type);
              HapticFeedback.selectionClick();
            },
            l10n: l10n,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0),
          
          const SizedBox(height: 20),
          
          // Items grid - unified component
          ItemsGrid(
            items: items,
            isPro: isPro,
            title: _getGridTitle(),
            onItemSelected: _onItemSelected,
            showElectrolyteIndicators: true,
            childAspectRatio: 0.85,
          ).animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Tips card
          if (_showTips)
            HydrationTipsCard(
              onDismiss: () => setState(() => _showTips = false),
              l10n: l10n,
              customTips: [
                TipItem(emoji: '💊', text: l10n.supplementTip1),
                TipItem(emoji: '💧', text: l10n.supplementTip2),
                TipItem(emoji: '⏰', text: l10n.supplementTip3),
                TipItem(emoji: '📝', text: l10n.supplementTip4),
              ],
            ).animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
        ],
      ),
    );
  }
  
  String _getGridTitle() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedType) {
      case SupplementType.minerals:
        return l10n.essentialMinerals;
      case SupplementType.vitamins:
        return l10n.vitamins;
      case SupplementType.other:
        return l10n.otherSupplements;
    }
  }
}

// Type selector with unified style
class _SupplementTypeSelector extends StatelessWidget {
  final SupplementType selected;
  final ValueChanged<SupplementType> onChanged;
  final AppLocalizations l10n;
  
  const _SupplementTypeSelector({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: SupplementType.values.map((type) {
          final isSelected = type == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeName(type),
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
    );
  }
  
  String _getTypeName(SupplementType type) {
    switch (type) {
      case SupplementType.minerals:
        return l10n.minerals;
      case SupplementType.vitamins:
        return l10n.vitamins;
      case SupplementType.other:
        return l10n.category_other;
    }
  }
}