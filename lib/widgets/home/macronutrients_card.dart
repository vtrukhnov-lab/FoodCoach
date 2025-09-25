// lib/widgets/home/macronutrients_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final theme = Theme.of(context);

    return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок (без иконки)
              Row(
                children: [
                  Text(
                    l10n.macronutrients,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getBalanceColor(macroData).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBalanceStatus(macroData),
                      style: TextStyle(
                        color: _getBalanceColor(macroData),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Основная круговая диаграмма макронутриентов (идентично calories card)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Круговая диаграмма макронутриентов
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: MacronutrientPieChartPainter(
                          proteins: macroData['proteins'] ?? 0,
                          carbs: macroData['carbs'] ?? 0,
                          fats: macroData['fats'] ?? 0,
                          strokeWidth: 14,
                        ),
                      ),
                    ),
                    // Центральная информация
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${((macroData['proteins'] ?? 0) + (macroData['carbs'] ?? 0) + (macroData['fats'] ?? 0)).round()}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'grams',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total macros',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Статистика макронутриентов (всегда показываем)
              Container(
                width: double.infinity,
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroItem(
                    context,
                    icon: Icons.fitness_center,
                    label: 'Protein',
                    value: '${(macroData['proteins'] ?? 0).round()}g',
                    color: Colors.red,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  _buildMacroItem(
                    context,
                    icon: Icons.grass,
                    label: 'Carbs',
                    value: '${(macroData['carbs'] ?? 0).round()}g',
                    color: Colors.blue,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  _buildMacroItem(
                    context,
                    icon: Icons.opacity,
                    label: 'Fats',
                    value: '${(macroData['fats'] ?? 0).round()}g',
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
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
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  l10n.unlockPro,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Map<String, double> _getMacronutrientData(HydrationProvider provider) {
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    print('🥩 DEBUG: Total food intakes today: ${provider.todayFoodIntakes.length}');

    for (final food in provider.todayFoodIntakes) {
      print('🥩 DEBUG: Food: ${food.foodName} - P:${food.proteins}g, C:${food.carbohydrates}g, F:${food.fats}g');
      totalProteins += food.proteins;
      totalCarbs += food.carbohydrates;
      totalFats += food.fats;
    }

    print('🥩 DEBUG: Total macros - P:${totalProteins}g, C:${totalCarbs}g, F:${totalFats}g');

    return {
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  Color _getBalanceColor(Map<String, double> macroData) {
    final total = macroData['proteins']! + macroData['carbs']! + macroData['fats']!;
    if (total == 0) return Colors.grey;

    final proteinRatio = macroData['proteins']! / total;
    final carbRatio = macroData['carbs']! / total;
    final fatRatio = macroData['fats']! / total;

    // Ideal ratios: Protein 25-35%, Carbs 45-65%, Fats 20-35%
    if (proteinRatio >= 0.25 && proteinRatio <= 0.35 &&
        carbRatio >= 0.45 && carbRatio <= 0.65 &&
        fatRatio >= 0.20 && fatRatio <= 0.35) {
      return Colors.green;
    } else if (proteinRatio >= 0.20 && carbRatio >= 0.40 && fatRatio >= 0.15) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  String _getBalanceStatus(Map<String, double> macroData) {
    final total = macroData['proteins']! + macroData['carbs']! + macroData['fats']!;
    if (total == 0) return 'START';

    final proteinRatio = macroData['proteins']! / total;
    final carbRatio = macroData['carbs']! / total;
    final fatRatio = macroData['fats']! / total;

    if (proteinRatio >= 0.25 && proteinRatio <= 0.35 &&
        carbRatio >= 0.45 && carbRatio <= 0.65 &&
        fatRatio >= 0.20 && fatRatio <= 0.35) {
      return 'BALANCED';
    } else if (proteinRatio >= 0.20 && carbRatio >= 0.40 && fatRatio >= 0.15) {
      return 'GOOD';
    } else {
      return 'ADJUST';
    }
  }
}

class MacronutrientPieChartPainter extends CustomPainter {
  final double proteins;
  final double carbs;
  final double fats;
  final double strokeWidth;

  MacronutrientPieChartPainter({
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final total = proteins + carbs + fats;

    if (total == 0) {
      // Draw empty circle
      final emptyPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    // Calculate angles
    final proteinAngle = (proteins / total) * 2 * math.pi;
    final carbAngle = (carbs / total) * 2 * math.pi;
    final fatAngle = (fats / total) * 2 * math.pi;

    var currentAngle = -math.pi / 2; // Start at top

    // Draw protein arc (red - from Figma)
    if (proteins > 0) {
      final proteinPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        proteinAngle,
        false,
        proteinPaint,
      );
      currentAngle += proteinAngle;
    }

    // Draw carbs arc (green - from Figma)
    if (carbs > 0) {
      final carbPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        carbAngle,
        false,
        carbPaint,
      );
      currentAngle += carbAngle;
    }

    // Draw fats arc (orange - from Figma)
    if (fats > 0) {
      final fatPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        fatAngle,
        false,
        fatPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}