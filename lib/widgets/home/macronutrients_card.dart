// lib/widgets/home/macronutrients_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../providers/hydration_provider.dart';
import '../../services/subscription_service.dart';
import '../../screens/paywall_screen.dart';
import '../../screens/food_catalog_screen.dart';
import '../../l10n/app_localizations.dart';

class MacronutrientsCard extends StatelessWidget {
  const MacronutrientsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final l10n = AppLocalizations.of(context);

    // Проверяем PRO статус
    if (!subscription.isPro) {
      return _buildProLockedCard(context, l10n);
    }

    final provider = Provider.of<HydrationProvider>(context);
    final macroData = _getMacronutrientData(provider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FoodCatalogScreen(),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Верхняя секция с заголовком и общими калориями
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pie_chart,
                              color: Theme.of(context).primaryColor,
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${macroData['totalCalories']}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.macronutrients,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getStatusText(macroData, l10n),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Круговая диаграмма макронутриентов
                  if (macroData['hasData']) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CustomPaint(
                              painter: MacroPieChartPainter(
                                proteins: macroData['proteins'],
                                carbs: macroData['carbs'],
                                fats: macroData['fats'],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.balance,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            color: Theme.of(context).colorScheme.outline,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No data',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Разделитель
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.outline.withValues(alpha: 0),
                      Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      Theme.of(context).colorScheme.outline.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Детальная информация о макронутриентах
              if (macroData['hasData']) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem(
                      context,
                      icon: Icons.fitness_center,
                      label: l10n.proteins,
                      value: '${macroData['proteins'].toStringAsFixed(1)}g',
                      color: const Color(0xFF4CAF50),
                    ),
                    _buildDetailItem(
                      context,
                      icon: Icons.grain,
                      label: l10n.carbohydrates,
                      value: '${macroData['carbs'].toStringAsFixed(1)}g',
                      color: const Color(0xFF2196F3),
                    ),
                    _buildDetailItem(
                      context,
                      icon: Icons.opacity,
                      label: l10n.fats,
                      value: '${macroData['fats'].toStringAsFixed(1)}g',
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ),

                // Блок рекомендаций
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _getAdviceText(macroData, l10n),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAdjustmentRow(
                        context,
                        icon: Icons.restaurant_menu,
                        label: l10n.meals,
                        value: '${macroData['foodCount']} today',
                      ),
                      const SizedBox(height: 6),
                      _buildAdjustmentRow(
                        context,
                        icon: Icons.local_fire_department,
                        label: l10n.avgCaloriesPerMeal,
                        value: '${macroData['caloriesPerMeal'].toStringAsFixed(0)} kcal',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Пустое состояние
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Theme.of(context).colorScheme.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.tapToAddFood,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.trackMacronutrients,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildProLockedCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaywallScreen(),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                color: Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.macronutrients,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.proFeature,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.unlockPro,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildDetailItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Flexible(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getMacronutrientData(HydrationProvider provider) {
    final foodIntakes = provider.todayFoodIntakes;

    if (foodIntakes.isEmpty) {
      return {
        'hasData': false,
        'proteins': 0.0,
        'carbs': 0.0,
        'fats': 0.0,
        'totalCalories': 0,
        'foodCount': 0,
        'caloriesPerMeal': 0.0,
        'proteinsPercent': 0.0,
        'carbsPercent': 0.0,
        'fatsPercent': 0.0,
      };
    }

    double totalProteins = 0.0;
    double totalCarbs = 0.0;
    double totalFats = 0.0;
    int totalCalories = 0;

    for (final intake in foodIntakes) {
      totalProteins += intake.proteins;
      totalCarbs += intake.carbohydrates;
      totalFats += intake.fats;
      totalCalories += intake.calories;
    }

    final totalMacros = totalProteins + totalCarbs + totalFats;
    final proteinsPercent = totalMacros > 0 ? (totalProteins / totalMacros) * 100 : 0.0;
    final carbsPercent = totalMacros > 0 ? (totalCarbs / totalMacros) * 100 : 0.0;
    final fatsPercent = totalMacros > 0 ? (totalFats / totalMacros) * 100 : 0.0;

    return {
      'hasData': true,
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
      'totalCalories': totalCalories,
      'foodCount': foodIntakes.length,
      'caloriesPerMeal': foodIntakes.isNotEmpty ? totalCalories / foodIntakes.length : 0.0,
      'proteinsPercent': proteinsPercent,
      'carbsPercent': carbsPercent,
      'fatsPercent': fatsPercent,
    };
  }

  String _getStatusText(Map<String, dynamic> macroData, AppLocalizations l10n) {
    if (!macroData['hasData']) return l10n.tapToAddFood;

    final totalCalories = macroData['totalCalories'] as int;
    final foodCount = macroData['foodCount'] as int;

    if (totalCalories < 500) return 'Light intake - $foodCount meals tracked';
    if (totalCalories < 1500) return 'Moderate intake - $foodCount meals tracked';
    return 'Good intake - $foodCount meals tracked';
  }

  String _getAdviceText(Map<String, dynamic> macroData, AppLocalizations l10n) {
    if (!macroData['hasData']) return 'Start tracking your meals to see macronutrient breakdown.';

    final proteinsPercent = macroData['proteinsPercent'] as double;
    final carbsPercent = macroData['carbsPercent'] as double;
    final fatsPercent = macroData['fatsPercent'] as double;

    if (proteinsPercent > 40) return 'High protein intake. Consider balancing with more carbs and healthy fats.';
    if (carbsPercent > 60) return 'High carb intake. Try adding more protein and healthy fats for balance.';
    if (fatsPercent > 40) return 'High fat intake. Balance with lean proteins and complex carbs.';
    if (proteinsPercent < 15) return 'Low protein intake. Consider adding lean meats, fish, or plant proteins.';

    return 'Good macronutrient balance! Keep maintaining this healthy ratio.';
  }
}

class MacroPieChartPainter extends CustomPainter {
  final double proteins;
  final double carbs;
  final double fats;

  MacroPieChartPainter({
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    final total = proteins + carbs + fats;
    if (total == 0) return;

    const startAngle = -math.pi / 2;

    // Белки - зеленый
    final proteinsAngle = (proteins / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      proteinsAngle,
      true,
      Paint()..color = const Color(0xFF4CAF50),
    );

    // Углеводы - синий
    final carbsAngle = (carbs / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + proteinsAngle,
      carbsAngle,
      true,
      Paint()..color = const Color(0xFF2196F3),
    );

    // Жиры - оранжевый
    final fatsAngle = (fats / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + proteinsAngle + carbsAngle,
      fatsAngle,
      true,
      Paint()..color = const Color(0xFFFF9800),
    );

    // Центральный белый круг
    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}