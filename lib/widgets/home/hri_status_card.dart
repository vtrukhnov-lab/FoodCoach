// lib/widgets/home/hri_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/hri_service.dart';
import '../../services/alcohol_service.dart';
import '../../providers/hydration_provider.dart';
import '../../l10n/app_localizations.dart';

class HRIStatusCard extends StatelessWidget {
  final bool isFasting;
  final String fastingSchedule;

  const HRIStatusCard({
    super.key,
    required this.isFasting,
    required this.fastingSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final hri = Provider.of<HRIService>(context);
    final provider = Provider.of<HydrationProvider>(context);
    final alcohol = Provider.of<AlcoholService>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    final hriValue = hri.currentHRI.round();
    final status = provider.getHydrationStatus(l10n);
    final localizedHRIStatus = _getLocalizedHRIStatus(hri, l10n);
    final components = hri.getComponentsBreakdown();
    
    // Получаем данные о сахаре
    final sugarData = provider.getSugarIntakeData(context);
    final sugarGrams = sugarData.totalGrams;
    final sugarImpact = _calculateSugarHRIImpact(sugarGrams);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.hydrationStatus, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.hydrationRiskIndex),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getHRIColor(hriValue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hri.hriZone.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getHRIColor(hriValue)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hriValue / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(_getHRIColor(hriValue)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$hriValue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getHRIColor(hriValue))),
              const SizedBox(width: 8),
              Text(localizedHRIStatus, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _getHRIColor(hriValue))),
            ],
          ),
          if (_hasActiveFactors(components, alcohol, sugarGrams)) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 6),
                Text(l10n.hriBreakdownTitle, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: _buildEnhancedFactorCards(components, alcohol, sugarGrams, sugarImpact, l10n),
            ),
          ],
          if (isFasting) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(l10n.fastingModeActive, style: TextStyle(fontSize: 12, color: Colors.purple[700], fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(fastingSchedule, style: TextStyle(fontSize: 12, color: Colors.purple[700], fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  // ИСПРАВЛЕНО: добавлена проверка всех компонентов
  bool _hasActiveFactors(Map<String, double> components, AlcoholService alcohol, double sugarGrams) {
    final hasWorkouts = (components['workouts'] ?? 0) > 0;
    final hasCaffeine = (components['caffeine'] ?? 0) > 0;
    final hasAlcohol = (components['alcohol'] ?? 0) > 0;
    final hasWeather = (components['heat'] ?? 0) > 0;
    final hasSugar = (components['sugar'] ?? 0) > 0;
    final hasDehydration = (components['dehydration'] ?? 0) > 0;
    final hasFood = (components['food'] ?? 0) > 0;
    final hasTime = (components['timeSinceIntake'] ?? 0) > 0;
    final hasMorning = (components['morning'] ?? 0) > 0;
    final hasWater = (components['water'] ?? 0) > 2;
    final hasSodium = (components['sodium'] ?? 0) > 2;
    final hasPotassium = (components['potassium'] ?? 0) > 2;
    final hasMagnesium = (components['magnesium'] ?? 0) > 2;

    return hasWorkouts || hasCaffeine || hasAlcohol || hasWeather || hasSugar ||
           hasDehydration || hasFood || hasTime || hasMorning || hasWater ||
           hasSodium || hasPotassium || hasMagnesium;
  }

  List<Widget> _buildEnhancedFactorCards(
    Map<String, double> components,
    AlcoholService alcohol,
    double sugarGrams,
    int sugarImpact,
    AppLocalizations l10n
  ) {
    final cards = <Widget>[];

    // Water dehydration risk (highest priority)
    final waterImpact = components['water'] ?? 0;
    if (waterImpact > 2) {
      cards.add(_buildEnhancedFactorCard(
        'Water Shortage',
        '+${waterImpact.toInt()} HRI',
        waterImpact > 15 ? 'Severe dehydration risk detected' : 'Insufficient water intake today',
        Icons.water_drop,
        waterImpact > 15 ? Colors.red : Colors.orange,
        waterImpact
      ));
    }

    // Dehydration from workouts
    final dehydrationImpact = components['dehydration'] ?? 0;
    if (dehydrationImpact > 0) {
      cards.add(_buildEnhancedFactorCard(
        'Workout Dehydration',
        '+${dehydrationImpact.toInt()} HRI',
        'Fluid losses from physical activity not compensated',
        Icons.fitness_center,
        Colors.red,
        dehydrationImpact
      ));
    }

    // Workouts (ongoing effect)
    final workoutImpact = components['workouts'] ?? 0;
    if (workoutImpact > 0) {
      cards.add(_buildEnhancedFactorCard(
        '${l10n.hriComponentWorkout}',
        '+${workoutImpact.toInt()} HRI',
        'Recent physical activity increases fluid needs',
        Icons.fitness_center,
        Colors.teal,
        workoutImpact
      ));
    }

    // Electrolyte imbalances
    final sodiumImpact = components['sodium'] ?? 0;
    if (sodiumImpact > 2) {
      cards.add(_buildEnhancedFactorCard(
        'Low Sodium',
        '+${sodiumImpact.toInt()} HRI',
        'Insufficient sodium intake disrupts fluid balance',
        Icons.grain,
        Colors.amber,
        sodiumImpact
      ));
    }

    final potassiumImpact = components['potassium'] ?? 0;
    if (potassiumImpact > 2) {
      cards.add(_buildEnhancedFactorCard(
        'Low Potassium',
        '+${potassiumImpact.toInt()} HRI',
        'Low potassium affects cellular hydration',
        Icons.eco,
        Colors.green,
        potassiumImpact
      ));
    }

    final magnesiumImpact = components['magnesium'] ?? 0;
    if (magnesiumImpact > 2) {
      cards.add(_buildEnhancedFactorCard(
        'Low Magnesium',
        '+${magnesiumImpact.toInt()} HRI',
        'Magnesium deficiency impacts muscle function',
        Icons.psychology,
        Colors.purple,
        magnesiumImpact
      ));
    }

    // Environmental factors
    final heatImpact = components['heat'] ?? 0;
    if (heatImpact > 0) {
      const temp = 25; // Default temperature
      String description = temp < 32 ? 'Warm weather increases sweating' : 'High heat significantly increases fluid loss';
      cards.add(_buildEnhancedFactorCard(
        '${l10n.hriComponentHeat}',
        '+${heatImpact.toInt()} HRI',
        '$description (${temp}°C)',
        temp < 32 ? Icons.wb_sunny : Icons.local_fire_department,
        temp < 32 ? Colors.orange : Colors.red,
        heatImpact
      ));
    }

    // Dietary factors
    final alcoholImpact = components['alcohol'] ?? 0;
    if (alcoholImpact > 0) {
      final sd = alcohol.totalStandardDrinks;
      cards.add(_buildEnhancedFactorCard(
        '${l10n.alcohol}',
        '+${alcoholImpact.toInt()} HRI',
        '${sd.toStringAsFixed(1)} standard drinks consumed',
        Icons.local_bar,
        Colors.red,
        alcoholImpact
      ));
    }

    final caffeineImpact = components['caffeine'] ?? 0;
    if (caffeineImpact > 0) {
      cards.add(_buildEnhancedFactorCard(
        '${l10n.hriComponentCaffeine}',
        '+${caffeineImpact.toInt()} HRI',
        'Caffeine has mild diuretic effects',
        Icons.coffee,
        Colors.brown,
        caffeineImpact
      ));
    }

    final sugarImpactComponent = components['sugar'] ?? 0;
    if (sugarImpactComponent > 0) {
      Color sugarColor = Colors.amber;
      String level = 'Moderate';
      if (sugarImpactComponent > 5) {
        sugarColor = Colors.orange;
        level = 'High';
      }
      if (sugarImpactComponent > 8) {
        sugarColor = Colors.red;
        level = 'Very High';
      }

      cards.add(_buildEnhancedFactorCard(
        '${l10n.sugarIntake}',
        '+${sugarImpactComponent.toInt()} HRI',
        '$level sugar intake increases fluid needs',
        Icons.cake,
        sugarColor,
        sugarImpactComponent
      ));
    }

    final foodImpact = components['food'] ?? 0;
    if (foodImpact > 0) {
      cards.add(_buildEnhancedFactorCard(
        'Processed Food',
        '+${foodImpact.toInt()} HRI',
        'High sodium food reduces hydration efficiency',
        Icons.restaurant,
        Colors.orange,
        foodImpact
      ));
    }

    // Time-based factors
    final timeImpact = components['timeSinceIntake'] ?? 0;
    if (timeImpact > 0) {
      final hours = (timeImpact / 2).round();
      cards.add(_buildEnhancedFactorCard(
        'Long Gap',
        '+${timeImpact.toInt()} HRI',
        '${hours}h since last fluid intake',
        Icons.schedule,
        Colors.blue,
        timeImpact
      ));
    }

    final morningImpact = components['morning'] ?? 0;
    if (morningImpact > 0) {
      cards.add(_buildEnhancedFactorCard(
        'Morning Indicators',
        '+${morningImpact.toInt()} HRI',
        'Dark urine or weight loss detected this morning',
        Icons.wb_twilight,
        Colors.orange,
        morningImpact
      ));
    }

    return cards;
  }

  List<Widget> _buildActiveFactorChips(
    Map<String, double> components,
    AlcoholService alcohol,
    double sugarGrams,
    int sugarImpact,
    AppLocalizations l10n
  ) {
    final chips = <Widget>[];
    
    // ИСПРАВЛЕНО: показываем спорт первым если есть активность
    final workoutImpact = components['workouts'] ?? 0;
    if (workoutImpact > 0) {
      chips.add(_buildFactorChip(
        '${l10n.hriComponentWorkout} +${workoutImpact.toInt()}', 
        Icons.fitness_center, 
        Colors.teal
      ));
    }
    
    // Показываем погоду/жару
    final heatImpact = components['heat'] ?? 0;
    if (heatImpact > 0) {
      const temp = 25; // Default temperature
      if (temp < 32) {
        chips.add(_buildFactorChip(
          '${l10n.hriComponentHeat} +${heatImpact.toInt()}',
          Icons.wb_sunny,
          Colors.orange
        ));
      } else {
        chips.add(_buildFactorChip(
          '${l10n.hriComponentHeat} +${heatImpact.toInt()}',
          Icons.local_fire_department,
          Colors.red
        ));
      }
    }
    
    // Показываем кофеин
    final caffeineImpact = components['caffeine'] ?? 0;
    if (caffeineImpact > 0) {
      chips.add(_buildFactorChip(
        '${l10n.hriComponentCaffeine} +${caffeineImpact.toInt()}', 
        Icons.coffee, 
        Colors.brown
      ));
    }
    
    // Показываем алкоголь
    if (alcohol.totalStandardDrinks > 0) {
      final sd = alcohol.totalStandardDrinks;
      final alcoholImpact = components['alcohol'] ?? 0;
      chips.add(_buildFactorChip(
        '${l10n.alcohol} ${sd.toStringAsFixed(1)} SD +${alcoholImpact.toInt()}', 
        Icons.local_bar, 
        Colors.red
      ));
    }
    
    // Показываем сахар
    if (sugarGrams > 50) {
      Color sugarColor = Colors.amber;
      if (sugarGrams > 75) {
        sugarColor = Colors.orange;
      }
      if (sugarGrams > 100) {
        sugarColor = Colors.red;
      }
      
      chips.add(_buildFactorChip(
        '${l10n.sugarIntake} ${sugarGrams.toStringAsFixed(0)}g +$sugarImpact', 
        Icons.cake, 
        sugarColor
      ));
    }
    
    return chips;
  }

  Widget _buildEnhancedFactorCard(String title, String impact, String description, IconData icon, Color color, double impactValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        impact,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  int _calculateSugarHRIImpact(double grams) {
    if (grams <= 50) return 0;
    if (grams <= 75) return ((grams - 50) * 0.2).round();
    return (5 + (grams - 75) * 0.2).clamp(0, 10).round();
  }

  Color _getStatusColor(String status) {
    if (status.contains('Normal') || status.contains('Норма')) return Colors.green;
    if (status.contains('Low salt') || status.contains('Мало соли') || 
        status.contains('Diluting') || status.contains('Разбавляешь')) {
      return Colors.orange;
    }
    if (status.contains('Under-hydrated') || status.contains('Недобор воды')) return Colors.red;
    return Colors.grey;
  }

  Color _getHRIColor(int hri) {
    if (hri < 30) return Colors.green;
    if (hri < 60) return Colors.orange;
    return Colors.red;
  }

  String _getLocalizedHRIStatus(HRIService hri, AppLocalizations l10n) {
    final hriValue = hri.currentHRI;
    if (hriValue <= 20) return l10n.hriStatusExcellent;
    if (hriValue <= 40) return l10n.hriStatusGood;
    if (hriValue <= 60) return l10n.hriStatusModerate;
    if (hriValue <= 80) return l10n.hriStatusHighRisk;
    return l10n.hriStatusCritical;
  }
}

// Определяем класс SugarIntakeData прямо здесь
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

  factory SugarIntakeData.empty() {
    return SugarIntakeData(
      totalGrams: 0,
      naturalSugarGrams: 0,
      addedSugarGrams: 0,
      hiddenSugarGrams: 0,
      drinksGrams: 0,
      foodGrams: 0,
      snacksGrams: 0,
      bySource: {},
    );
  }
}