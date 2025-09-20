// lib/widgets/common/status_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';
import '../../services/units_service.dart';
import 'water_ring_widget.dart';
import 'package:provider/provider.dart';
import '../../services/subscription_service.dart';
import '../../screens/paywall_screen.dart';

/// Animated status card showing hydration progress
class AnimatedStatusCard extends StatelessWidget {
  final Map<String, dynamic> intake;
  final Color statusColor;
  final AppLocalizations l10n;
  final String units;
  final bool showWaterRing;
  final bool expanded;

  const AnimatedStatusCard({
    super.key,
    required this.intake,
    required this.statusColor,
    required this.l10n,
    required this.units,
    this.showWaterRing = true,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = intake['percent'] as double;
    
    return Container(
      padding: EdgeInsets.all(expanded ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Animated water ring
              if (showWaterRing) ...[
                WaterRingWithWave(
                  consumed: intake['current'] as int,
                  goal: intake['goal'] as int,
                  statusColor: statusColor,
                  units: units,
                  l10n: l10n,
                  size: expanded ? 90 : 70,
                  showTarget: expanded,
                ),
                const SizedBox(width: 20),
              ],
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todayHydration,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusMessage(percent, l10n),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (percent / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 16),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(
                  icon: Icons.water_drop,
                  value: UnitsService.instance.formatVolume(intake['current'] as int, hideUnit: true),
                  label: l10n.currentIntake,
                  color: Colors.blue,
                ),
                StatItem(
                  icon: Icons.flag,
                  value: UnitsService.instance.formatVolume(intake['goal'] as int, hideUnit: true),
                  label: l10n.dailyGoal,
                  color: Colors.green,
                ),
                StatItem(
                  icon: Icons.trending_up,
                  value: UnitsService.instance.formatVolume(
                    ((intake['goal'] as int) - (intake['current'] as int)).clamp(0, 999999),
                    hideUnit: true
                  ),
                  label: l10n.toGo,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  String _getStatusMessage(double percent, AppLocalizations l10n) {
    if (percent >= 100) return l10n.goalReached;
    if (percent >= 75) return l10n.almostThere;
    if (percent >= 50) return l10n.halfwayThere;
    if (percent >= 25) return l10n.keepGoing;
    return l10n.startDrinking;
  }
}

/// Alcohol status card with SD tracking and corrections
class AlcoholStatusCard extends StatelessWidget {
  final double todaySD;
  final Color statusColor;
  final String statusMessage;
  final double waterCorrection;
  final double sodiumCorrection;
  final double hriModifier;
  final AppLocalizations l10n;
  final String units;
  
  const AlcoholStatusCard({
    super.key,
    required this.todaySD,
    required this.statusColor,
    required this.statusMessage,
    required this.waterCorrection,
    required this.sodiumCorrection,
    required this.hriModifier,
    required this.l10n,
    required this.units,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (todaySD / 3.0).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          todaySD.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          l10n.standardDrinksUnit,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todayConsumed,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusMessage,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (todaySD > 0) ...[
            const SizedBox(height: 16),
            // Corrections
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(
                  icon: Icons.water_drop,
                  value: '+${UnitsService.instance.formatVolume(waterCorrection.round(), hideUnit: true)} ${UnitsService.instance.volumeUnit}',
                  label: l10n.additionalWater,
                  color: Colors.blue,
                ),
                StatItem(
                  icon: Icons.grain,
                  value: '+${sodiumCorrection.toStringAsFixed(0)} mg',
                  label: l10n.additionalSodium,
                  color: Colors.purple,
                ),
                StatItem(
                  icon: Icons.warning,
                  value: '+${hriModifier.toStringAsFixed(1)}',
                  label: l10n.hriRisk,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Harm reduction card for alcohol
class HarmReductionCard extends StatelessWidget {
  final VoidCallback onDismiss;
  final AppLocalizations l10n;
  final bool isPro;
  
  const HarmReductionCard({
    super.key,
    required this.onDismiss,
    required this.l10n,
    required this.isPro,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.minimumHarm,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('💧', l10n.drinkWaterNow),
          _buildStep('🧂', l10n.addPinchSalt),
          _buildStep('☕', l10n.avoidLateCoffee),
          _buildStep('🛏️', l10n.goToBedEarly ?? 'Go to bed early'),
          if (isPro) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.purple.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.alcoholProtocolsDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStep(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// Enhanced caffeine status card with animated ring
class CaffeineStatusCard extends StatelessWidget {
  final int todayCaffeine;
  final int maxCaffeine;
  final AppLocalizations l10n;
  final VoidCallback? onInfoTap;
  
  const CaffeineStatusCard({
    super.key,
    required this.todayCaffeine,
    required this.l10n,
    this.maxCaffeine = 400,
    this.onInfoTap,
  });
  
  Color get statusColor {
    final percent = (todayCaffeine / maxCaffeine) * 100;
    if (percent == 0) return Colors.green;
    if (percent <= 50) return Colors.blue;
    if (percent <= 100) return Colors.orange;
    return Colors.red;
  }
  
  String _getStatusMessage() {
    if (todayCaffeine == 0) {
      return l10n.caffeineStatusNone;
    } else if (todayCaffeine <= 200) {
      return l10n.caffeineStatusModerate(todayCaffeine);
    } else if (todayCaffeine <= 400) {
      return l10n.caffeineStatusHigh(todayCaffeine);
    } else {
      return l10n.caffeineStatusVeryHigh(todayCaffeine);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = ((todayCaffeine / maxCaffeine) * 100).clamp(0.0, 150.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Animated caffeine ring
              CaffeineRingWidget(
                consumed: todayCaffeine,
                max: maxCaffeine,
                statusColor: statusColor,
                size: 90,
              ),
              const SizedBox(width: 20),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.todaysCaffeine,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (onInfoTap != null)
                          IconButton(
                            onPressed: onInfoTap,
                            icon: Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusMessage(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (percent / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatItem(
                icon: Icons.coffee,
                value: '${todayCaffeine}mg',
                label: l10n.consumed,
                color: Colors.brown,
              ),
              StatItem(
                icon: Icons.flag,
                value: '${maxCaffeine}mg',
                label: l10n.dailyLimit,
                color: Colors.orange,
              ),
              StatItem(
                icon: Icons.hourglass_empty,
                value: '${(maxCaffeine - todayCaffeine).clamp(0, maxCaffeine)}mg',
                label: l10n.remaining,
                color: todayCaffeine > maxCaffeine ? Colors.red : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Caffeine ring progress widget with animation
class CaffeineRingWidget extends StatefulWidget {
  final int consumed;
  final int max;
  final Color statusColor;
  final double size;
  
  const CaffeineRingWidget({
    super.key,
    required this.consumed,
    required this.max,
    required this.statusColor,
    this.size = 90,
  });
  
  @override
  State<CaffeineRingWidget> createState() => _CaffeineRingWidgetState();
}

class _CaffeineRingWidgetState extends State<CaffeineRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: (widget.consumed / widget.max).clamp(0.0, 1.5),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    
    _animController.forward();
  }
  
  @override
  void didUpdateWidget(CaffeineRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed) {
      _progressAnimation = Tween<double>(
        begin: (oldWidget.consumed / widget.max).clamp(0.0, 1.5),
        end: (widget.consumed / widget.max).clamp(0.0, 1.5),
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _animController.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final percent = widget.max > 0 ? (widget.consumed / widget.max * 100).clamp(0.0, 200.0) : 0.0;
    final isOverLimit = widget.consumed > widget.max;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 8,
                  ),
                ),
              ),
              // Progress arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: ArcPainter(
                  progress: _progressAnimation.value,
                  color: widget.statusColor,
                  strokeWidth: 8,
                ),
              ),
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOverLimit ? Icons.error : Icons.bolt,
                    size: widget.size * 0.25,
                    color: widget.statusColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.consumed}mg',
                    style: TextStyle(
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.bold,
                      color: widget.statusColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${percent.toInt()}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.12,
                        fontWeight: FontWeight.w600,
                        color: widget.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Arc painter for caffeine ring
class ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      progress * 2 * math.pi, // Full circle = 2π
      false,
      paint,
    );
    
    // Draw dot at the end of arc if there's progress
    if (progress > 0.01) {
      final endAngle = -math.pi / 2 + progress * 2 * math.pi;
      final radius = (size.width - strokeWidth) / 2;
      final center = Offset(size.width / 2, size.height / 2);
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );
      
      // Glowing dot
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(endPoint, 5, glowPaint);
      
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(endPoint, 4, dotPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Specialized status card for electrolytes with 3 bars - PRO blocked version
class ElectrolyteStatusCard extends StatelessWidget {
  final Map<String, int> totals;
  final AppLocalizations l10n;
  final VoidCallback? onInfoTap;
  
  const ElectrolyteStatusCard({
    super.key,
    required this.totals,
    required this.l10n,
    this.onInfoTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Проверяем PRO статус
    final subscription = context.watch<SubscriptionProvider>();
    
    // Если не PRO - показываем заблокированную карточку
    if (!subscription.isPro) {
      return _buildProLockedCard(context, l10n);
    }
    
    // PRO версия карточки
    return _buildProCard(context, l10n);
  }
  
  // PRO-заблокированная карточка
  Widget _buildProLockedCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaywallScreen(source: 'status_card'),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade700,
              Colors.grey.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PRO иконка
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.bolt,
                color: Colors.orange,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Заголовок PRO
            Text(
              'PRO',
              style: TextStyle(
                color: Colors.orange.shade600,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Название функции
            Text(
              l10n.todaysElectrolytes,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Описание
            Text(
              l10n.electrolyteTrackingPro,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 20),
            
            // Кнопка разблокировки
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade600, Colors.deepOrange.shade600],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_open,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.unlock,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
  
  // PRO версия карточки (оригинальная логика)
  Widget _buildProCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.todaysElectrolytes,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (onInfoTap != null)
                          IconButton(
                            onPressed: onInfoTap,
                            icon: Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusMessage(l10n),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Electrolyte bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElectrolyteBar(
                label: 'Na',
                current: totals['sodium']!,
                goal: totals['sodiumGoal']!,
                color: Colors.blue,
              ),
              ElectrolyteBar(
                label: 'K',
                current: totals['potassium']!,
                goal: totals['potassiumGoal']!,
                color: Colors.green,
              ),
              ElectrolyteBar(
                label: 'Mg',
                current: totals['magnesium']!,
                goal: totals['magnesiumGoal']!,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: -0.1, end: 0);
  }
  
  // Определяем цвет статуса
  Color _getStatusColor() {
    final sodiumPercent = (totals['sodium']! / totals['sodiumGoal']!) * 100;
    final potassiumPercent = (totals['potassium']! / totals['potassiumGoal']!) * 100;
    final magnesiumPercent = (totals['magnesium']! / totals['magnesiumGoal']!) * 100;
    
    final avgPercent = (sodiumPercent + potassiumPercent + magnesiumPercent) / 3;
    
    if (avgPercent >= 80) return Colors.green;
    if (avgPercent >= 50) return Colors.orange;
    return Colors.red;
  }
  
  // Определяем текст статуса
  String _getStatusMessage(AppLocalizations l10n) {
    final sodiumPercent = (totals['sodium']! / totals['sodiumGoal']!) * 100;
    final potassiumPercent = (totals['potassium']! / totals['potassiumGoal']!) * 100;
    final magnesiumPercent = (totals['magnesium']! / totals['magnesiumGoal']!) * 100;
    
    final avgPercent = (sodiumPercent + potassiumPercent + magnesiumPercent) / 3;
    
    if (avgPercent >= 80) return l10n.greatBalance;
    if (avgPercent >= 50) return l10n.gettingThere;
    if (avgPercent >= 25) return l10n.needMoreElectrolytes;
    return l10n.lowElectrolyteLevels;
  }
}

/// Electrolyte bar widget
class ElectrolyteBar extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;
  
  const ElectrolyteBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final percent = (current / goal * 100).clamp(0, 100).toInt();
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          '/ $goal mg',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Individual stat item widget
class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  const StatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Hydration tips card widget
class HydrationTipsCard extends StatelessWidget {
  final VoidCallback? onDismiss;
  final AppLocalizations l10n;
  final List<TipItem>? customTips;
  
  const HydrationTipsCard({
    super.key,
    this.onDismiss,
    required this.l10n,
    this.customTips,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final tips = customTips ?? [
      TipItem(emoji: '💧', text: l10n.drinkRegularly),
      TipItem(emoji: '🌡️', text: l10n.roomTemperature),
      TipItem(emoji: '🍋', text: l10n.addLemon),
      TipItem(emoji: '⚠️', text: l10n.limitSugary),
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.cyan.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.hydrationTips,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => _buildTip(tip.emoji, tip.text)),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
  
  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom tip item
class TipItem {
  final String emoji;
  final String text;
  
  const TipItem({
    required this.emoji,
    required this.text,
  });
}

/// Simple info card
class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}