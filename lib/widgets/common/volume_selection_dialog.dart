// lib/widgets/common/volume_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../services/units_service.dart';
import '../../services/hri_service.dart';
import '../../data/catalog_item.dart';

/// Enhanced dialog for volume/serving/dosage/duration selection with electrolyte and alcohol support
class VolumeSelectionDialog extends StatefulWidget {
  final CatalogItem item;
  final Function(double value) onConfirm;
  final Function(double value) onSaveToFavorites;
  final String units;
  final bool showElectrolytes;
  final bool showAlcoholInfo;
  final bool showFoodInfo; // for food items
  final bool showDosage; // for supplements
  final bool showDuration; // for workouts
  final double? userWeight; // for workout calculations
  final Color? sliderColor;
  final Function(double, double)? calculateSD;

  const VolumeSelectionDialog({
    super.key,
    required this.item,
    required this.onConfirm,
    required this.onSaveToFavorites,
    required this.units,
    this.showElectrolytes = false,
    this.showAlcoholInfo = false,
    this.showFoodInfo = false,
    this.showDosage = false,
    this.showDuration = false,
    this.userWeight,
    this.sliderColor,
    this.calculateSD,
  });

  /// Static method for easy showing
  static Future<void> show({
    required BuildContext context,
    required CatalogItem item,
    required Function(double value) onConfirm,
    required Function(double value) onSaveToFavorites,
    required String units,
    bool showElectrolytes = false,
    bool showAlcoholInfo = false,
    bool showFoodInfo = false,
    bool showDosage = false,
    bool showDuration = false,
    double? userWeight,
    Color? sliderColor,
    Function(double, double)? calculateSD,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return VolumeSelectionDialog(
          item: item,
          onConfirm: onConfirm,
          onSaveToFavorites: onSaveToFavorites,
          units: units,
          showElectrolytes: showElectrolytes,
          showAlcoholInfo: showAlcoholInfo,
          showFoodInfo: showFoodInfo,
          showDosage: showDosage,
          showDuration: showDuration,
          userWeight: userWeight,
          sliderColor: sliderColor,
          calculateSD: calculateSD,
        );
      },
    );
  }

  @override
  State<VolumeSelectionDialog> createState() => _VolumeSelectionDialogState();
}

class _VolumeSelectionDialogState extends State<VolumeSelectionDialog> {
  late double sliderValue;
  late double minValue;
  late double maxValue;
  late String displayUnit;
  WorkoutLossResult? workoutLosses; // Store workout calculation results

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    // Handle duration mode for workouts
    if (widget.showDuration) {
      displayUnit = 'min'; // Always minutes for duration
      minValue = 5;
      maxValue = 120;

      // Initialize with default duration
      sliderValue = (widget.item.properties['defaultMinutes'] as int? ?? 30).toDouble();

      // Calculate initial workout losses
      if (widget.userWeight != null) {
        _calculateWorkoutLosses();
      }
    } else if (widget.showFoodInfo) {
      // Food mode - weight in grams/ounces
      displayUnit = widget.units == 'imperial' ? 'oz' : 'g';
      minValue = widget.units == 'imperial' ? 0.5 : 10.0;
      maxValue = widget.units == 'imperial' ? 18.0 : 500.0;

      // Initialize with default weight
      sliderValue = widget.item.getDefaultVolume(widget.units).toDouble();
    } else if (widget.showDosage) {
      // Dosage mode for supplements
      displayUnit = widget.item.getDosageUnit(widget.units);
      
      // Set min/max based on dosage unit
      switch (displayUnit) {
        case 'IU':
          minValue = 500;
          maxValue = 10000;
          break;
        case 'mg':
          final type = widget.item.properties['type'] as String?;
          if (type == 'vitamin_c') {
            minValue = 100;
            maxValue = 3000;
          } else {
            minValue = 10;
            maxValue = 500;
          }
          break;
        case 'ml':
          minValue = 5;
          maxValue = 30;
          break;
        case 'tsp':
          minValue = 0.5;
          maxValue = 4;
          break;
        case 'caps':
        case 'tabs':
        default:
          minValue = 1;
          maxValue = 4;
          break;
      }
      
      // Initialize with default dosage
      sliderValue = widget.item.getDefaultDosage(widget.units).toDouble();
    } else {
      // Regular volume mode
      displayUnit = widget.units == 'imperial' ? 'oz' : 'ml';
      
      // Set min/max based on type
      if (widget.showAlcoholInfo) {
        minValue = widget.units == 'imperial' ? 1.0 : 30.0;
        maxValue = widget.units == 'imperial' ? 20.0 : 500.0;
      } else if (widget.showElectrolytes) {
        minValue = widget.units == 'imperial' ? 1.0 : 30.0;
        maxValue = widget.units == 'imperial' ? 40.0 : 1000.0;
      } else {
        minValue = widget.units == 'imperial' ? 4.0 : 100.0;
        maxValue = widget.units == 'imperial' ? 40.0 : 1000.0;
      }
      
      // Initialize with default volume
      sliderValue = widget.item.getDefaultVolume(widget.units).toDouble();
    }
    
    // Ensure value is within bounds
    sliderValue = sliderValue.clamp(minValue, maxValue);
  }

  void _calculateWorkoutLosses() {
    if (!widget.showDuration || widget.userWeight == null) return;
    
    workoutLosses = HRIService.calculateWorkoutLosses(
      item: widget.item,
      durationMinutes: sliderValue.round(),
      userWeight: widget.userWeight!,
    );
  }

  double getVolumeMl() {
    // For duration mode, return duration in minutes
    if (widget.showDuration) {
      return sliderValue; // Return minutes, not volume
    }

    // For dosage mode, return the dosage value as is
    if (widget.showDosage) {
      return sliderValue; // Return dosage, not volume
    }

    // For food mode, return weight in grams
    if (widget.showFoodInfo) {
      if (widget.units == 'imperial') {
        return sliderValue * 28.3495; // Convert oz to grams
      }
      return sliderValue; // Already in grams
    }

    // For volume mode, convert to ml if needed
    if (widget.units == 'imperial') {
      return sliderValue * 29.5735;
    }
    return sliderValue;
  }

  Map<String, int> getElectrolytes() {
    // For workouts with duration
    if (widget.showDuration && workoutLosses != null) {
      return {
        'sodium': workoutLosses!.sodiumLossMg,
        'potassium': workoutLosses!.potassiumLossMg,
        'magnesium': workoutLosses!.magnesiumLossMg,
      };
    }

    // For supplements with dosage
    if (widget.showDosage) {
      final magnesium = widget.item.getMagnesiumContent(widget.units);
      return {
        'sodium': ((widget.item.properties['sodium'] ?? 0) * sliderValue).round(),
        'potassium': ((widget.item.properties['potassium'] ?? 0) * sliderValue).round(),
        'magnesium': (magnesium * sliderValue).round(),
      };
    }

    // For food items, calculate electrolytes based on weight
    if (widget.showFoodInfo) {
      try {
        final weightGrams = getVolumeMl(); // Returns weight in grams for food
        return {
          'sodium': ((widget.item.properties['sodium'] ?? 0) * weightGrams / 100).round(),
          'potassium': ((widget.item.properties['potassium'] ?? 0) * weightGrams / 100).round(),
          'magnesium': ((widget.item.properties['magnesium'] ?? 0) * weightGrams / 100).round(),
        };
      } catch (e) {
        return {'sodium': 0, 'potassium': 0, 'magnesium': 0};
      }
    }

    // For regular electrolytes with volume
    if (!widget.showElectrolytes) {
      return {'sodium': 0, 'potassium': 0, 'magnesium': 0};
    }

    try {
      final baseVolume = widget.item.getDefaultVolume(widget.units).toDouble();
      final baseVolumeMl = widget.units == 'imperial' ? baseVolume * 29.5735 : baseVolume;
      final multiplier = getVolumeMl() / baseVolumeMl;

      return {
        'sodium': ((widget.item.properties['sodium'] ?? 0) * multiplier).round(),
        'potassium': ((widget.item.properties['potassium'] ?? 0) * multiplier).round(),
        'magnesium': ((widget.item.properties['magnesium'] ?? 0) * multiplier).round(),
      };
    } catch (e) {
      return {'sodium': 0, 'potassium': 0, 'magnesium': 0};
    }
  }

  double getHydrationValue() {
    // For workouts, return water loss (negative hydration)
    if (widget.showDuration && workoutLosses != null) {
      return workoutLosses!.waterLossMl.toDouble();
    }
    
    if (widget.showDosage) return 0; // Supplements don't have hydration value
    
    final hydration = widget.item.properties['hydration'] as num? ?? 1.0;
    return getVolumeMl() * hydration.toDouble();
  }

  double getTotalSugar() {
    if (widget.showDosage || widget.showDuration) return 0; // Supplements and workouts don't have sugar

    // For food items, calculate sugar based on weight
    if (widget.showFoodInfo) {
      try {
        final weightGrams = getVolumeMl(); // Returns weight in grams for food
        final sugarPer100g = (widget.item.properties['sugarPer100g'] ?? 0.0) as num;
        return (sugarPer100g * weightGrams / 100.0);
      } catch (e) {
        return 0.0;
      }
    }

    // For drinks, calculate sugar based on volume
    try {
      final baseVolume = widget.item.getDefaultVolume(widget.units).toDouble();
      final baseVolumeMl = widget.units == 'imperial' ? baseVolume * 29.5735 : baseVolume;
      final baseSugar = (widget.item.properties['sugar'] ?? 0.0) as num;
      return (baseSugar * getVolumeMl() / baseVolumeMl);
    } catch (e) {
      return 0.0;
    }
  }

  int getCalories() {
    if (!widget.showFoodInfo) return 0; // Only food items have calories

    try {
      final weightGrams = getVolumeMl(); // Returns weight in grams for food
      final caloriesPer100g = (widget.item.properties['caloriesPer100g'] ?? 0) as int;
      return ((caloriesPer100g * weightGrams) / 100).round();
    } catch (e) {
      return 0;
    }
  }

  double getCaffeine() {
    if (widget.showDosage || widget.showDuration) return 0; // Supplements and workouts don't have caffeine
    
    try {
      final baseCaffeine = (widget.item.properties['caffeineMgPer100ml'] ?? 0.0) as num;
      return (baseCaffeine * getVolumeMl() / 100);
    } catch (e) {
      return 0.0;
    }
  }

  double getStandardDrinks() {
    if (!widget.showAlcoholInfo || widget.calculateSD == null) return 0.0;
    
    final abv = widget.item.properties['abv'] as num? ?? 0.0;
    return widget.calculateSD!(getVolumeMl(), abv.toDouble());
  }

  int getCaloriesBurned() {
    if (!widget.showDuration || workoutLosses == null) return 0;
    return workoutLosses!.caloriesBurned;
  }

  double getHRIImpact() {
    // For workouts, HRI impact is negative (increases risk)
    if (widget.showDuration && workoutLosses != null) {
      // Higher water loss = worse HRI impact
      final waterLossFactor = workoutLosses!.waterLossMl / 100.0;
      final intensityFactor = (widget.item.properties['intensityValue'] as int? ?? 3) / 3.0;
      final durationFactor = sliderValue / 30.0;
      
      return waterLossFactor * intensityFactor * durationFactor;
    }
    
    // Supplements don't affect HRI directly (only through electrolytes)
    if (widget.showDosage) return 0.0;
    
    try {
      final volumeMl = getVolumeMl();
      
      // For alcohol, HRI impact is positive (bad)
      if (widget.showAlcoholInfo) {
        final sd = getStandardDrinks();
        return sd * 3.0; // 3 points per standard drink
      }
      
      final hydrationFactor = (widget.item.properties['hydration'] as num? ?? 1.0).toDouble();
      final effectiveVolume = volumeMl * hydrationFactor;
      
      // Base impact (negative is good)
      double impact = -(effectiveVolume / 2000.0 * 10);
      
      // Electrolyte bonus
      if (widget.showElectrolytes) {
        final electrolytes = getElectrolytes();
        final sodium = electrolytes['sodium'] ?? 0;
        if (sodium > 500) {
          impact -= 3;
        } else if (sodium > 0) {
          impact -= 1;
        }
      }
      
      // Sugar penalty
      final sugar = getTotalSugar();
      if (sugar > 50) {
        impact += (sugar - 50) * 0.2;
      } else if (sugar > 25) {
        impact += (sugar - 25) * 0.1;
      }
      
      // Caffeine impact
      final caffeine = getCaffeine();
      if (caffeine > 0) {
        impact += (caffeine * 0.02).clamp(0, 5);
      }
      
      return impact;
    } catch (e) {
      return 0.0;
    }
  }

  List<Color> getHRIGradientColors() {
    final impact = getHRIImpact();
    
    // For workouts, invert the color scheme (positive impact = bad)
    if (widget.showDuration) {
      if (impact <= 2) {
        return [Colors.green.shade400, Colors.green.shade600];
      } else if (impact <= 5) {
        return [Colors.amber.shade400, Colors.amber.shade600];
      } else if (impact <= 10) {
        return [Colors.orange.shade400, Colors.orange.shade600];
      } else {
        return [Colors.red.shade400, Colors.red.shade600];
      }
    }
    
    // Regular color scheme
    if (impact <= -5) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (impact <= 0) {
      return [Colors.amber.shade400, Colors.amber.shade600];
    } else if (impact <= 5) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  List<Color> getSugarGradientColors(double grams) {
    if (grams <= 5) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (grams <= 15) {
      return [Colors.amber.shade400, Colors.amber.shade600];
    } else if (grams <= 30) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  List<Color> getSDGradientColors(double sd) {
    if (sd <= 0.5) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (sd <= 1.0) {
      return [Colors.amber.shade400, Colors.amber.shade600];
    } else if (sd <= 2.0) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  bool get hasSignificantElectrolytes {
    if (!widget.showElectrolytes && !widget.showDosage && !widget.showDuration && !widget.showFoodInfo) return false;
    final e = getElectrolytes();
    return (e['sodium'] ?? 0) > 0 ||
           (e['potassium'] ?? 0) > 0 ||
           (e['magnesium'] ?? 0) > 0;
  }

  String _formatValue(double value) {
    // For dosage units that should be integers
    if (widget.showDosage && (displayUnit == 'caps' || displayUnit == 'tabs')) {
      return value.toInt().toString();
    }
    
    // For duration, show as integer minutes
    if (widget.showDuration) {
      return value.toInt().toString();
    }
    
    // For other values, show decimal if needed
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    
    return value.toStringAsFixed(1);
  }

  int _getDivisions() {
    if (widget.showDuration) {
      return 23; // 5 to 120 minutes in 5-minute increments
    }
    
    if (widget.showDosage) {
      switch (displayUnit) {
        case 'IU':
          return 19; // 500 to 10000 in 500 increments
        case 'mg':
          final type = widget.item.properties['type'] as String?;
          if (type == 'vitamin_c') {
            return 29; // 100 to 3000 in 100 increments
          }
          return 49; // 10 to 500 in 10 increments
        case 'ml':
          return 5; // 5 to 30 in 5 increments
        case 'tsp':
          return 7; // 0.5 to 4 in 0.5 increments
        case 'caps':
        case 'tabs':
        default:
          return 3; // 1 to 4
      }
    }
    
    // Regular volume divisions
    return widget.showAlcoholInfo 
      ? (widget.units == 'imperial' ? 19 : 47)
      : (widget.units == 'imperial' ? 36 : 90);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final itemName = widget.item.getName(l10n);
    final hydration = (widget.item.properties['hydration'] as num? ?? 1.0);
    final sliderActiveColor = widget.sliderColor ??
      (widget.showDuration ? Colors.teal :
       widget.showFoodInfo ? Colors.deepOrange :
       widget.showDosage ? Colors.purple :
       Colors.blue);
    final caffeine = getCaffeine();
    final sugar = getTotalSugar();
    final abv = widget.item.properties['abv'] as num?;
    final electrolytes = getElectrolytes();

    // Determine icon to show
    Widget iconWidget;
    if (widget.item.icon is IconData) {
      // For supplements with IconData
      iconWidget = Icon(
        widget.item.icon as IconData,
        size: 28,
        color: widget.showDosage ? Colors.purple[600] : 
               widget.showDuration ? Colors.teal[600] : null,
      );
    } else {
      // For items with emoji
      iconWidget = Text(
        widget.item.icon as String? ?? '🥤',
        style: const TextStyle(fontSize: 28),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(fontSize: 18),
                ),
                if (widget.showDuration && widget.item.properties['met'] != null)
                  Text(
                    'MET ${(widget.item.properties['met'] as num).toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  )
                else if (widget.showAlcoholInfo && abv != null)
                  Text(
                    l10n.abvPercent(abv.toStringAsFixed(1)),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  )
                else if (widget.showFoodInfo)
                  Text(
                    '${widget.item.properties['caloriesPer100g']} ${l10n.kcal}/${l10n.per100g}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  )
                else if (!widget.showElectrolytes && !widget.showDosage && hydration != 1.0)
                  Text(
                    '${(hydration * 100).toInt()}% ${l10n.hydration.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Volume/Dosage/Duration slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.showDuration ? l10n.duration :
                      widget.showFoodInfo ? l10n.weight :
                      widget.showDosage ? l10n.dosage :
                      l10n.volume,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.showDuration
                          ? Colors.teal.withValues(alpha: 0.1)
                          : widget.showFoodInfo
                            ? Colors.deepOrange.shade100
                          : widget.showDosage
                            ? Colors.purple.shade100
                            : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.showDuration 
                          ? '${_formatValue(sliderValue)} ${l10n.minutes}'
                          : '${_formatValue(sliderValue)} $displayUnit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.showDuration
                            ? Colors.teal[700]
                            : widget.showFoodInfo
                              ? Colors.deepOrange[700]
                            : widget.showDosage
                              ? Colors.purple[700]
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: sliderActiveColor,
                    inactiveTrackColor: sliderActiveColor.withValues(alpha: 0.2),
                    thumbColor: sliderActiveColor,
                    overlayColor: sliderActiveColor.withValues(alpha: 0.1),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: sliderValue.clamp(minValue, maxValue),
                    min: minValue,
                    max: maxValue,
                    divisions: _getDivisions(),
                    onChanged: (value) {
                      setState(() {
                        sliderValue = value;
                        if (widget.showDuration) {
                          _calculateWorkoutLosses();
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Metrics display - different for workouts
            if (widget.showDuration && workoutLosses != null) ...[
              // For workouts, show water loss and HRI impact
              Row(
                children: [
                  // Water Loss card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UnitsService.instance.formatVolume(workoutLosses!.waterLossMl, shortUnit: true),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.waterLoss,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // HRI Impact card (negative for workouts)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: getHRIGradientColors(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+${getHRIImpact().toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.hriImpact,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Electrolytes to replenish
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade50, Colors.teal.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.teal[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.needsToReplenish,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (electrolytes['sodium']! > 0)
                          _buildElectrolyteMetric(
                            'Na',
                            electrolytes['sodium']!,
                            Colors.blue,
                          ),
                        if (electrolytes['potassium']! > 0)
                          _buildElectrolyteMetric(
                            'K',
                            electrolytes['potassium']!,
                            Colors.green,
                          ),
                        if (electrolytes['magnesium']! > 0)
                          _buildElectrolyteMetric(
                            'Mg',
                            electrolytes['magnesium']!,
                            Colors.purple,
                          ),
                      ],
                    ),
                    if (getCaloriesBurned() > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, size: 16, color: Colors.orange[700]),
                            const SizedBox(width: 6),
                            Text(
                              '${getCaloriesBurned()} kcal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (widget.showFoodInfo) ...[
              // For food items, show calories and sugar as main metrics
              Row(
                children: [
                  // Calories card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getCalories().toString(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.kcal,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sugar card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: getSugarGradientColors(getTotalSugar()),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cake,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getTotalSugar().toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.gramsSugar,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Electrolytes for food
              if (hasSignificantElectrolytes) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepOrange.shade50, Colors.deepOrange.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.electrolyteContent,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (electrolytes['sodium']! > 0)
                            _buildElectrolyteMetric(
                              'Na',
                              electrolytes['sodium']!,
                              Colors.blue,
                            ),
                          if (electrolytes['potassium']! > 0)
                            _buildElectrolyteMetric(
                              'K',
                              electrolytes['potassium']!,
                              Colors.green,
                            ),
                          if (electrolytes['magnesium']! > 0)
                            _buildElectrolyteMetric(
                              'Mg',
                              electrolytes['magnesium']!,
                              Colors.purple,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (widget.showDosage) ...[
              // For supplements, show only electrolytes if present
              if (hasSignificantElectrolytes) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.purple.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.electrolyteContent,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (electrolytes['sodium']! > 0)
                            _buildElectrolyteMetric(
                              'Na',
                              electrolytes['sodium']!,
                              Colors.blue,
                            ),
                          if (electrolytes['potassium']! > 0)
                            _buildElectrolyteMetric(
                              'K',
                              electrolytes['potassium']!,
                              Colors.green,
                            ),
                          if (electrolytes['magnesium']! > 0)
                            _buildElectrolyteMetric(
                              'Mg',
                              electrolytes['magnesium']!,
                              Colors.purple,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Regular metrics display for drinks
              Row(
                children: [
                  // For alcohol: SD card, otherwise HRI Impact card
                  if (widget.showAlcoholInfo) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: getSDGradientColors(getStandardDrinks()),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.local_bar,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getStandardDrinks().toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.standardDrinksUnit,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: getHRIGradientColors(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${getHRIImpact() > 0 ? "+" : ""}${getHRIImpact().toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.hriImpact,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  // Sugar card
                  if (sugar > 0 || widget.showAlcoholInfo) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: getSugarGradientColors(sugar),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cake,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sugar.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.gramsSugar,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Electrolyte content for regular items
              if (widget.showElectrolytes && hasSignificantElectrolytes) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildElectrolyteMetric(
                        'Na',
                        getElectrolytes()['sodium']!,
                        Colors.blue,
                      ),
                      _buildElectrolyteMetric(
                        'K',
                        getElectrolytes()['potassium']!,
                        Colors.green,
                      ),
                      _buildElectrolyteMetric(
                        'Mg',
                        getElectrolytes()['magnesium']!,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ],
            
            // Caffeine display (not for supplements or workouts)
            if (!widget.showDosage && !widget.showDuration && caffeine > 0.5) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 16, color: Colors.brown.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.caffeine}: ${caffeine.round()} mg',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add button - color and text depends on mode
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton.icon(
                onPressed: () {
                  // For workouts pass duration, for supplements pass dosage, for others pass volume in ml
                  final value = widget.showDuration ? sliderValue : 
                               widget.showDosage ? sliderValue : 
                               getVolumeMl();
                  widget.onConfirm(value);
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add),
                label: Text(
                  widget.showDuration ? l10n.logActivity :
                  widget.showFoodInfo ? l10n.addFood :
                  l10n.add
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.showDuration ? Colors.teal :
                                 widget.showFoodInfo ? const Color.fromARGB(255, 98, 179, 246) :
                                 widget.showDosage ? const Color.fromARGB(255, 98, 179, 246) :
                                 const Color.fromARGB(255, 98, 179, 246),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Save to Favorites button
            SizedBox(
              width: double.infinity,
              height: 53,
              child: OutlinedButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  // For workouts pass duration, for supplements pass dosage, for others pass volume in ml
                  final value = widget.showDuration ? sliderValue : 
                               widget.showDosage ? sliderValue : 
                               getVolumeMl();
                  await widget.onSaveToFavorites(value);
                },
                icon: const Icon(Icons.star_border),
                label: Text(l10n.saveToFavorites),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber[700],
                  side: BorderSide(color: Colors.amber[600]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElectrolyteMetric(String label, int value, Color color) {
    if (value == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Квадратный символ как в главной карточке
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'mg',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}