// lib/widgets/common/type_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

/// Common type selector widget for different categories
class TypeSelector<T> extends StatelessWidget {
  final T selectedType;
  final List<T> types;
  final Function(T) onTypeChanged;
  final String Function(T, AppLocalizations) getTypeName;
  final Color? activeColor;
  final EdgeInsets? padding;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.types,
    required this.onTypeChanged,
    required this.getTypeName,
    this.activeColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = activeColor ?? Colors.blue;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = type == selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onTypeChanged(type);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getTypeName(type, l10n),
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Liquid type selector specifically for liquids screen
enum LiquidType { plain, enhanced, beverages, sodas }

class LiquidTypeSelector extends StatelessWidget {
  final LiquidType selectedType;
  final Function(LiquidType) onTypeChanged;

  const LiquidTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  String _getName(LiquidType type, AppLocalizations l10n) {
    switch (type) {
      case LiquidType.plain:
        return l10n.plainWater;
      case LiquidType.enhanced:
        return l10n.enhancedWater;
      case LiquidType.beverages:
        return l10n.beverages;
      case LiquidType.sodas:
        return l10n.sodas;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeSelector<LiquidType>(
      selectedType: selectedType,
      types: LiquidType.values,
      onTypeChanged: onTypeChanged,
      getTypeName: _getName,
      activeColor: Colors.blue,
    );
  }
}

/// Electrolyte type selector
enum ElectrolyteType { basic, mixes, pills }

class ElectrolyteTypeSelector extends StatelessWidget {
  final ElectrolyteType selectedType;
  final Function(ElectrolyteType) onTypeChanged;

  const ElectrolyteTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  String _getName(ElectrolyteType type, AppLocalizations l10n) {
    switch (type) {
      case ElectrolyteType.basic:
        return l10n.electrolytesBasic;
      case ElectrolyteType.mixes:
        return l10n.electrolytesMixes;
      case ElectrolyteType.pills:
        return l10n.electrolytesPills;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeSelector<ElectrolyteType>(
      selectedType: selectedType,
      types: ElectrolyteType.values,
      onTypeChanged: onTypeChanged,
      getTypeName: _getName,
      activeColor: Colors.orange,
    );
  }
}

/// Hot drinks type selector
enum HotDrinkType { coffee, tea, other }

class HotDrinkTypeSelector extends StatelessWidget {
  final HotDrinkType selectedType;
  final Function(HotDrinkType) onTypeChanged;

  const HotDrinkTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  String _getName(HotDrinkType type, AppLocalizations l10n) {
    switch (type) {
      case HotDrinkType.coffee:
        return l10n.coffee;
      case HotDrinkType.tea:
        return l10n.tea;
      case HotDrinkType.other:
        return l10n.category_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeSelector<HotDrinkType>(
      selectedType: selectedType,
      types: HotDrinkType.values,
      onTypeChanged: onTypeChanged,
      getTypeName: _getName,
      activeColor: Colors.brown,
    );
  }
}

/// Alcohol type selector
enum AlcoholType { beer, wine, spirits, cocktails }

class AlcoholTypeSelector extends StatelessWidget {
  final AlcoholType selectedType;
  final Function(AlcoholType) onTypeChanged;

  const AlcoholTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  String _getName(AlcoholType type, AppLocalizations l10n) {
    switch (type) {
      case AlcoholType.beer:
        return l10n.beer;
      case AlcoholType.wine:
        return l10n.wine;
      case AlcoholType.spirits:
        return l10n.spirits;
      case AlcoholType.cocktails:
        return l10n.cocktail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeSelector<AlcoholType>(
      selectedType: selectedType,
      types: AlcoholType.values,
      onTypeChanged: onTypeChanged,
      getTypeName: _getName,
      activeColor: Colors.purple,
    );
  }
}