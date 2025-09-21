// lib/widgets/home/carbs_intake_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/hydration_provider.dart';
import '../../services/subscription_service.dart';
import '../../screens/paywall_screen.dart';
import '../../screens/food_catalog_screen.dart';
import '../../l10n/app_localizations.dart';

class CarbsIntakeCard extends StatelessWidget {
  const CarbsIntakeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final l10n = AppLocalizations.of(context);

    // Проверяем PRO статус
    if (!subscription.isPro) {
      return _buildProLockedCard(context, l10n);
    }

    final provider = Provider.of<HydrationProvider>(context);
    final carbsData = provider.getCarbsIntakeData(context);
    final theme = Theme.of(context);
    final progress = carbsData.dailyLimit > 0 ? (carbsData.totalGrams / carbsData.dailyLimit).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () => _showCarbsInfoDialog(context),
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
                    l10n.carbohydrates,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCarbsStatusColor(carbsData.totalGrams, carbsData.dailyLimit).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCarbsStatusBadge(carbsData.totalGrams, carbsData.dailyLimit),
                      style: TextStyle(
                        color: _getCarbsStatusColor(carbsData.totalGrams, carbsData.dailyLimit),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Основная круговая диаграмма (идентично calories card)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Круговая диаграмма углеводов
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: CarbsCircularProgressPainter(
                          progress: progress,
                          color: _getCarbsProgressColor(carbsData.totalGrams, carbsData.dailyLimit),
                          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                          strokeWidth: 14,
                        ),
                      ),
                    ),
                    // Центральная информация
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${carbsData.totalGrams.round()}',
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
                          '${(carbsData.dailyLimit > 0 ? (carbsData.totalGrams / carbsData.dailyLimit * 100) : 0).round()}% of ${carbsData.dailyLimit.round()}g',
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

              const SizedBox(height: 16),

              // Разделитель и селектор диеты (как в карточке калорий)
              Container(
                width: double.infinity,
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 8),
              // Селектор режима диеты
              _buildDietModeSelector(context, provider),
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
                l10n.carbohydrates,
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

  Color _getCarbsProgressColor(double carbs, double limit) {
    if (limit == 0) return Colors.grey;
    final ratio = carbs / limit;
    if (ratio < 0.5) return Colors.orange;
    if (ratio < 0.8) return Colors.blue;
    if (ratio <= 1.0) return Colors.green;
    return Colors.red;
  }

  Color _getCarbsStatusColor(double carbs, double limit) {
    if (limit == 0) return Colors.grey;
    final ratio = carbs / limit;
    if (ratio < 0.5) return Colors.orange;
    if (ratio < 0.8) return Colors.blue;
    if (ratio <= 1.1) return Colors.green;
    return Colors.red;
  }

  String _getCarbsStatusBadge(double carbs, double limit) {
    if (limit == 0) return 'NO GOAL';
    final percentage = (carbs / limit * 100).round();
    if (percentage < 50) return 'LOW';
    if (percentage < 80) return 'GOOD';
    if (percentage <= 110) return 'PERFECT';
    return 'HIGH';
  }

  void _showCarbsInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.grain,
              color: theme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.carbsInfo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.carbsWhoRecommendation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.carbsWhoDetails,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.carbsWholeFoodsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.carbsWholeFoodsDetails,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.carbsGoodSources,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.carbsGoodSourcesList,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.understood,
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietModeSelector(BuildContext context, HydrationProvider provider) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dietMode,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDietModeChip(
                  context,
                  DietMode.normal,
                  l10n.dietNormal,
                  '55%',
                  provider.carbsDietMode == DietMode.normal,
                  () => provider.setCarbsDietMode(DietMode.normal),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildDietModeChip(
                  context,
                  DietMode.lowCarb,
                  l10n.dietLowCarb,
                  '25%',
                  provider.carbsDietMode == DietMode.lowCarb,
                  () => provider.setCarbsDietMode(DietMode.lowCarb),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildDietModeChip(
                  context,
                  DietMode.keto,
                  l10n.dietKeto,
                  '8%',
                  provider.carbsDietMode == DietMode.keto,
                  () => provider.setCarbsDietMode(DietMode.keto),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietModeChip(
    BuildContext context,
    DietMode mode,
    String label,
    String percentage,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              percentage,
              style: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CarbsCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CarbsCircularProgressPainter({
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

class CarbsIntakeData {
  final double totalGrams;
  final double dailyLimit;
  final int foodCount;
  final Map<String, double> bySource;

  CarbsIntakeData({
    required this.totalGrams,
    required this.dailyLimit,
    required this.foodCount,
    required this.bySource,
  });
}