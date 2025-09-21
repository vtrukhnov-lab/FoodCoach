// lib/widgets/home/calories_intake_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/hydration_provider.dart';
import '../../services/subscription_service.dart';
import '../../screens/paywall_screen.dart';
import '../../screens/food_catalog_screen.dart';
import '../../l10n/app_localizations.dart';

class CaloriesIntakeCard extends StatelessWidget {
  const CaloriesIntakeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final l10n = AppLocalizations.of(context);

    // Проверяем PRO статус
    if (!subscription.isPro) {
      return _buildProLockedCard(context, l10n);
    }

    // Остальной код для PRO пользователей
    final provider = Provider.of<HydrationProvider>(context);
    final totalCalories = provider.totalCaloriesToday;
    final foodProgress = provider.getFoodProgress();
    final calorieGoal = provider.calorieGoal;
    final progress = (totalCalories / calorieGoal).clamp(0.0, 1.0);

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
                    l10n.calories,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(totalCalories, calorieGoal).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusBadge(totalCalories, calorieGoal),
                      style: TextStyle(
                        color: _getStatusColor(totalCalories, calorieGoal),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Большая круговая диаграмма в центре
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Основная круговая диаграмма
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: LargeCircularProgressPainter(
                          progress: progress,
                          color: _getProgressColor(progress, context),
                          backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                          strokeWidth: 14,
                        ),
                      ),
                    ),
                    // Центральная информация
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalCalories',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).round()}% of $calorieGoal',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
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

              // Статистика внизу (только если есть приемы пищи)
              if (foodProgress['foodCount'] > 0) ...[
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.restaurant_menu,
                      label: l10n.meals,
                      value: '${foodProgress['foodCount']}',
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.local_fire_department,
                      label: 'Avg/meal',
                      value: '${(totalCalories / foodProgress['foodCount']).round()}',
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.schedule,
                      label: 'Last meal',
                      value: provider.todayFoodIntakes.isNotEmpty ? provider.todayFoodIntakes.last.formattedTime : '--:--',
                    ),
                  ],
                ),
              ] else ...[
                // Пустое состояние
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tapToAddFood,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
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
                l10n.calories,
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

  Widget _buildStatItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
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

  IconData _getCaloriesIcon(int calories) {
    if (calories == 0) return Icons.restaurant_menu;
    if (calories < 500) return Icons.local_fire_department;
    if (calories < 1500) return Icons.whatshot;
    return Icons.local_fire_department;
  }

  Color _getProgressColor(double progress, BuildContext context) {
    if (progress < 0.5) return Colors.orange;
    if (progress < 0.8) return Colors.blue;
    if (progress <= 1.0) return Colors.green;
    return Colors.red;
  }

  Color _getStatusColor(int calories, int goal) {
    final percentage = (calories / goal * 100).round();
    if (percentage < 50) return Colors.orange;
    if (percentage < 80) return Colors.blue;
    if (percentage <= 110) return Colors.green;
    return Colors.red;
  }

  String _getStatusBadge(int calories, int goal) {
    final percentage = (calories / goal * 100).round();
    if (percentage < 50) return 'LOW';
    if (percentage < 80) return 'GOOD';
    if (percentage <= 110) return 'PERFECT';
    return 'HIGH';
  }
}

class LargeCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  LargeCircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}