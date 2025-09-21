// lib/widgets/home/main_progress_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/hydration_provider.dart';
import '../../services/units_service.dart';
import 'electrolyte_bar_display.dart';
import '../../services/units_service.dart';

/// Главная карточка прогресса на домашнем экране
/// Отображает круговой прогресс воды, электролиты и быстрые действия
class MainProgressCard extends StatefulWidget {
  final VoidCallback onUpdate;

  const MainProgressCard({
    super.key,
    required this.onUpdate,
  });

  @override
  State<MainProgressCard> createState() => _MainProgressCardState();
}

class _MainProgressCardState extends State<MainProgressCard> {
  // Настройки быстрого добавления
  final int _quickAddVolume = 250; // ml

  // Флаг для визуального отклика при нажатии
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Убеждаемся, что контекст установлен при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<HydrationProvider>();
        provider.setContext(context);
      }
    });
  }

  /// Добавляет воду через одиночное нажатие
  void _handleQuickAdd() {
    final provider = context.read<HydrationProvider>();

    HapticFeedback.lightImpact();
    provider.addIntake('Water', _quickAddVolume);
    widget.onUpdate();
  }

  /// Добавляет удвоенную порцию через двойное нажатие
  void _handleDoubleTap() {
    final provider = context.read<HydrationProvider>();

    HapticFeedback.mediumImpact();
    provider.addIntake('Water', _quickAddVolume * 2);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final units = context.watch<UnitsService>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Получаем текущий прогресс
    final waterConsumed = provider.totalWaterToday.toInt();
    final waterGoal = provider.goals.waterOpt;
    final progress = (waterConsumed / waterGoal).clamp(0.0, 1.0);

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
                  l10n.water,
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
                    color: _getStatusColor(progress).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusBadge(progress),
                    style: TextStyle(
                      color: _getStatusColor(progress),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Основной круг прогресса с жестами (идентично calories card)
            Center(
              child: GestureDetector(
                onTap: _handleQuickAdd,
                onDoubleTap: _handleDoubleTap,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Основная круговая диаграмма
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: WaterCircularProgressPainter(
                            progress: progress,
                            color: _getProgressColor(progress),
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
                            units.formatVolume(waterConsumed),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            units.volumeUnit,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress * 100).round()}% of ${units.formatVolume(waterGoal)}',
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
              ),
            ),

            const SizedBox(height: 20),

            // Разделитель (как в карточке калорий)
            Container(
              width: double.infinity,
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),

            const SizedBox(height: 16),

            // Подсказка о жестах
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: theme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.quickAdd,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap: ${units.formatVolume(_quickAddVolume)} • Double tap: ${units.formatVolume(_quickAddVolume * 2)}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return Colors.orange;
    if (progress < 0.8) return Colors.blue;
    if (progress <= 1.0) return Colors.green;
    return Colors.red;
  }

  Color _getStatusColor(double progress) {
    if (progress < 0.5) return Colors.orange;
    if (progress < 0.8) return Colors.blue;
    if (progress <= 1.1) return Colors.green;
    return Colors.red;
  }

  String _getStatusBadge(double progress) {
    final percentage = (progress * 100).round();
    if (percentage < 50) return 'LOW';
    if (percentage < 80) return 'GOOD';
    if (percentage <= 110) return 'PERFECT';
    return 'HIGH';
  }
}

class WaterCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  WaterCircularProgressPainter({
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