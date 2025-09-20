// lib/widgets/common/items_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../data/catalog_item.dart';

/// Grid widget for displaying catalog items with enhanced indicators
class ItemsGrid extends StatelessWidget {
  final List<CatalogItem> items;
  final bool isPro;
  final Function(CatalogItem) onItemSelected;
  final String? title;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showElectrolyteIndicators;
  final bool showSugarIndicators;
  final bool showCaffeineIndicators;
  final bool showAlcoholIndicators;

  const ItemsGrid({
    super.key,
    required this.items,
    required this.isPro,
    required this.onItemSelected,
    this.title,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.showElectrolyteIndicators = false,
    this.showSugarIndicators = false,
    this.showCaffeineIndicators = false,
    this.showAlcoholIndicators = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ItemGridTile(
              item: item,
              isLocked: item.isPro && !isPro,
              onTap: () {
                HapticFeedback.lightImpact();
                onItemSelected(item);
              },
              l10n: l10n,
              showElectrolyteIndicators: showElectrolyteIndicators,
              showSugarIndicators: showSugarIndicators,
              showCaffeineIndicators: showCaffeineIndicators,
              showAlcoholIndicators: showAlcoholIndicators,
            );
          },
        ),
      ],
    );
  }
}

/// Individual grid tile for an item with enhanced indicators
class ItemGridTile extends StatelessWidget {
  final CatalogItem item;
  final bool isLocked;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final bool showElectrolyteIndicators;
  final bool showSugarIndicators;
  final bool showCaffeineIndicators;
  final bool showAlcoholIndicators;

  const ItemGridTile({
    super.key,
    required this.item,
    required this.isLocked,
    required this.onTap,
    required this.l10n,
    this.showElectrolyteIndicators = false,
    this.showSugarIndicators = false,
    this.showCaffeineIndicators = false,
    this.showAlcoholIndicators = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked 
            ? theme.colorScheme.surface.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked
              ? theme.colorScheme.outline.withValues(alpha: 0.1)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLocked ? 0.02 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: isLocked ? 0.5 : 1.0,
                    child: Text(
                      item.icon as String,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.getName(l10n),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLocked 
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                          : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Show additional info if available
                  if (!isLocked) ...[
                    const SizedBox(height: 2),
                    _buildIndicators(context),
                  ],
                ],
              ),
            ),
            // PRO badge
            if (item.isPro)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            // Gray overlay for locked items
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators(BuildContext context) {
    // Priority order for indicators based on flags
    
    // Alcohol indicators - now returns empty (no indicators for alcohol in grid)
    if (showAlcoholIndicators) {
      return _buildAlcoholIndicators(context);
    }
    
    // Electrolyte indicators
    if (showElectrolyteIndicators) {
      return _buildElectrolyteIndicators();
    }
    
    // Sugar indicator
    if (showSugarIndicators) {
      return _buildSugarIndicator();
    }
    
    // Caffeine indicator
    if (showCaffeineIndicators) {
      return _buildCaffeineIndicator();
    }
    
    // Default: smart detection
    return _buildDefaultInfo(context);
  }

  Widget _buildAlcoholIndicators(BuildContext context) {
    // For alcohol items, we don't show any indicators in the grid
    // The ABV and other info will be shown in the selection dialog
    return const SizedBox.shrink();
  }

  Widget _buildElectrolyteIndicators() {
    final indicators = _getElectrolyteIndicators();
    if (indicators.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        indicators,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildSugarIndicator() {
    final sugar = (item.properties['sugar'] ?? 0.0) as num;
    if (sugar <= 0.1) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getSugarBadgeColor(sugar.toDouble()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${sugar.toStringAsFixed(sugar >= 10 ? 0 : 1)}g',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCaffeineIndicator() {
    final caffeine = item.properties['caffeine'] as num? ?? 0;
    if (caffeine <= 0) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt,
          size: 10,
          color: Colors.brown[700],
        ),
        const SizedBox(width: 2),
        Text(
          '${caffeine}mg',
          style: TextStyle(
            fontSize: 9,
            color: Colors.brown[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    // Check for alcohol content first - but don't show it in grid
    if (item.properties.containsKey('abv')) {
      final abv = item.properties['abv'] as num? ?? 0;
      if (abv > 0) {
        // For alcohol items, don't show any indicators in the grid
        return const SizedBox.shrink();
      }
    }
    
    // Show hydration percentage if available and not 100%
    if (item.properties.containsKey('hydration')) {
      final hydration = (item.properties['hydration'] as num? ?? 1.0) * 100;
      if (hydration != 100) {
        return Text(
          '${hydration.toInt()}%',
          style: TextStyle(
            fontSize: 9,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        );
      }
    }
    
    // Show caffeine if present
    if (item.properties.containsKey('caffeine')) {
      final caffeine = item.properties['caffeine'] as num? ?? 0;
      if (caffeine > 0) {
        return _buildCaffeineIndicator();
      }
    }
    
    // Show sugar if significant
    if (item.properties.containsKey('sugar')) {
      final sugar = item.properties['sugar'] as num? ?? 0;
      if (sugar > 0.1) {
        return _buildSugarIndicator();
      }
    }
    
    // Show sodium if significant (for non-electrolyte items)
    if (item.properties.containsKey('sodium')) {
      final sodium = item.properties['sodium'] as num? ?? 0;
      if (sodium > 100) {
        return Text(
          'Na: ${sodium}mg',
          style: TextStyle(
            fontSize: 9,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        );
      }
    }
    
    return const SizedBox.shrink();
  }

  String _getElectrolyteIndicators() {
    List<String> indicators = [];
    
    final sodium = (item.properties['sodium'] ?? 0) as num;
    final potassium = (item.properties['potassium'] ?? 0) as num;
    final magnesium = (item.properties['magnesium'] ?? 0) as num;
    
    if (sodium > 0) indicators.add('Na');
    if (potassium > 0) indicators.add('K');
    if (magnesium > 0) indicators.add('Mg');
    
    return indicators.join(' • ');
  }

  Color _getSugarBadgeColor(double grams) {
    if (grams <= 5) return Colors.green.shade600;
    if (grams <= 10) return Colors.amber.shade600;
    if (grams <= 20) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}