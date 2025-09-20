// lib/screens/onboarding/pages/weight_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/ion_character.dart';
import '../../../services/units_service.dart';

class WeightPage extends StatelessWidget {
  final double weight;
  final String units;
  final Function(double) onWeightChanged;

  const WeightPage({
    super.key,
    required this.weight,
    required this.units,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const IonCharacter(size: 100, mood: IonMood.happy, showGlow: false)
                  .animate().fadeIn(),
                
                const SizedBox(height: 20),
                
                Text(
                  l10n.weightPageTitle,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  l10n.weightPageSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                
                const SizedBox(height: 24),
                
                _buildWeightSelector(context, l10n),
                
                const SizedBox(height: 16),
                
                _buildWaterNormInfo(l10n),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightSelector(BuildContext context, AppLocalizations l10n) {
    // Создаем временный экземпляр UnitsService для конвертации
    // с правильной системой единиц
    final unitsService = UnitsService.instance;

    // Определяем, какая система единиц выбрана
    final bool isImperial = units == 'imperial';

    // Отладочная информация
    print('WeightPage: weight=$weight, units=$units, isImperial=$isImperial');
    
    // Конвертация веса в отображаемые единицы
    final int displayWeight = isImperial 
        ? (weight * 2.20462).round()  // кг в фунты
        : weight.round();              // остаемся в кг
    
    // Единица измерения
    final String weightUnit = isImperial ? 'lb' : 'кг';

    
    // Границы слайдера всегда в килограммах для внутреннего хранения
    const double minWeightKg = 30.0;
    const double maxWeightKg = 200.0;
    
    // Отображаемые границы в выбранных единицах
    final int minDisplay = isImperial 
        ? (minWeightKg * 2.20462).round()  // кг в фунты
        : minWeightKg.round();              // остаемся в кг
    
    final int maxDisplay = isImperial
        ? (maxWeightKg * 2.20462).round()  // кг в фунты  
        : maxWeightKg.round();              // остаемся в кг

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                displayWeight.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2EC5FF),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                weightUnit,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2EC5FF),
              inactiveTrackColor: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
              thumbColor: const Color(0xFF2EC5FF),
              overlayColor: const Color(0xFF2EC5FF).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 8,
            ),
            child: Slider(
              value: weight.clamp(minWeightKg, maxWeightKg),
              min: minWeightKg,
              max: maxWeightKg,
              divisions: ((maxWeightKg - minWeightKg) * 2).round(), // Шаг 0.5 кг
              onChanged: (value) {
                onWeightChanged(value);
                HapticFeedback.selectionClick();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$minDisplay $weightUnit', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              Text('$maxDisplay $weightUnit', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildWaterNormInfo(AppLocalizations l10n) {
    // Определяем, какая система единиц выбрана
    final bool isImperial = units == 'imperial';

    // Расчет нормы воды основан на весе в кг (22-36 мл на кг веса)
    final int minWaterMl = (22 * weight).round();
    final int maxWaterMl = (36 * weight).round();

    // Конвертируем в выбранные единицы
    final int minWater = isImperial
        ? (minWaterMl / 29.5735).round()  // мл в унции
        : minWaterMl;                      // остаемся в мл

    final int maxWater = isImperial
        ? (maxWaterMl / 29.5735).round()  // мл в унции
        : maxWaterMl;                      // остаемся в мл

    final String waterUnit = isImperial ? 'oz' : 'мл';

    // Расчет калорий (базовый метаболизм + активность)
    // Формула Харриса-Бенедикта (упрощенная): BMR = 22 * вес_в_кг для среднего человека
    final int dailyCalories = (25 * weight).round(); // 25 ккал на кг веса

    return Column(
      children: [
        // Информация о воде
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF8AF5A3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8AF5A3).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: Color(0xFF2EC5FF), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${l10n.recommendedNorm(minWater, maxWater).split(':')[0]}: $minWater-$maxWater $waterUnit',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2EC5FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 12),

        // Информация о калориях
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9F43).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF9F43).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Color(0xFFFF9F43), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.recommendedCalories(dailyCalories),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFF9F43),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }
}