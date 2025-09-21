// lib/widgets/home/electrolytes_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/hydration_provider.dart';
import '../../services/subscription_service.dart';
import '../../screens/paywall_screen.dart';
import '../../screens/liquids_catalog_screen.dart';

/// Карточка отображения электролитов на главном экране
class ElectrolytesCard extends StatelessWidget {
  const ElectrolytesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final subscription = context.watch<SubscriptionProvider>();
    final l10n = AppLocalizations.of(context);

    // Проверяем PRO статус
    if (!subscription.isPro) {
      return _buildProLockedCard(context, l10n);
    }

    // Остальной код для PRO пользователей
    final progress = provider.getProgress();

    final sodiumCurrent = (progress['sodium'] ?? 0).toInt();
    final sodiumGoal = provider.goals.sodium;
    final potassiumCurrent = (progress['potassium'] ?? 0).toInt();
    final potassiumGoal = provider.goals.potassium;
    final magnesiumCurrent = (progress['magnesium'] ?? 0).toInt();
    final magnesiumGoal = provider.goals.magnesium;

    // Расчёт общего процента
    final totalPercent = _calculateTotalPercent(
      sodiumCurrent, sodiumGoal,
      potassiumCurrent, potassiumGoal,
      magnesiumCurrent, magnesiumGoal,
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/liquids');
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
              // Верхняя секция с основной информацией и HRI Impact
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
                              Icons.battery_5_bar,
                              color: Theme.of(context).primaryColor,
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${totalPercent.round()}%',
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
                          l10n.electrolytes,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getStatusText(totalPercent),
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

              // Детальная информация - электролиты
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    context,
                    icon: Icons.grain,
                    label: l10n.sodium,
                    value: '${sodiumCurrent}mg',
                    progress: sodiumCurrent / sodiumGoal,
                    color: const Color(0xFFFF5722),
                  ),
                  _buildDetailItem(
                    context,
                    icon: Icons.spa,
                    label: l10n.potassium,
                    value: '${potassiumCurrent}mg',
                    progress: potassiumCurrent / potassiumGoal,
                    color: const Color(0xFF4CAF50),
                  ),
                  _buildDetailItem(
                    context,
                    icon: Icons.bubble_chart,
                    label: l10n.magnesium,
                    value: '${magnesiumCurrent}mg',
                    progress: magnesiumCurrent / magnesiumGoal,
                    color: const Color(0xFF9C27B0),
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
                            _getAdviceText(totalPercent, l10n),
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
                      icon: Icons.local_drink,
                      label: l10n.balance,
                      value: _getBalanceStatus(totalPercent),
                    ),
                    const SizedBox(height: 6),
                    _buildAdjustmentRow(
                      context,
                      icon: Icons.speed,
                      label: l10n.dailyGoal,
                      value: '${totalPercent.round()}% achieved',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
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
                l10n.electrolytes,
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
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildDetailItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double progress,
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
          const SizedBox(height: 4),
          // Мини прогресс-бар
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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

  // Расчет общего процента
  double _calculateTotalPercent(
    int sodiumCurrent, int sodiumGoal,
    int potassiumCurrent, int potassiumGoal,
    int magnesiumCurrent, int magnesiumGoal,
  ) {
    final sodiumPercent = sodiumGoal > 0 ? (sodiumCurrent / sodiumGoal) * 100 : 0.0;
    final potassiumPercent = potassiumGoal > 0 ? (potassiumCurrent / potassiumGoal) * 100 : 0.0;
    final magnesiumPercent = magnesiumGoal > 0 ? (magnesiumCurrent / magnesiumGoal) * 100 : 0.0;

    return (sodiumPercent + potassiumPercent + magnesiumPercent) / 3;
  }

  // Расчет HRI Impact
  int _calculateHRIImpact(double totalPercent) {
    if (totalPercent < 30) return -15;
    if (totalPercent < 50) return -10;
    if (totalPercent < 70) return -5;
    if (totalPercent < 90) return 0;
    if (totalPercent < 110) return 5;
    return 10;
  }

  String _getStatusText(double totalPercent) {
    if (totalPercent < 30) return 'Critical deficiency';
    if (totalPercent < 50) return 'Low electrolyte levels';
    if (totalPercent < 70) return 'Moderate levels';
    if (totalPercent < 90) return 'Good balance';
    if (totalPercent < 110) return 'Optimal levels';
    return 'Excellent balance';
  }

  String _getAdviceText(double totalPercent, AppLocalizations l10n) {
    if (totalPercent < 30) {
      return 'Critical electrolyte deficiency. Consider electrolyte drinks or supplements immediately.';
    }
    if (totalPercent < 50) {
      return 'Low electrolyte levels detected. Add sports drinks or mineral-rich foods to your diet.';
    }
    if (totalPercent < 70) {
      return 'Moderate electrolyte levels. Consider adding more fruits and vegetables to boost intake.';
    }
    if (totalPercent < 90) {
      return 'Good electrolyte balance! You\'re on the right track with your hydration.';
    }
    if (totalPercent < 110) {
      return 'Optimal electrolyte levels achieved! Keep up this excellent balance.';
    }
    return 'Excellent electrolyte balance! Your hydration strategy is working perfectly.';
  }

  String _getBalanceStatus(double totalPercent) {
    if (totalPercent < 50) return 'Poor';
    if (totalPercent < 80) return 'Fair';
    if (totalPercent < 110) return 'Good';
    return 'Excellent';
  }
}