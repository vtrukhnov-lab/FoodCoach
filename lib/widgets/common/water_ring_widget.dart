// lib/widgets/common/water_ring_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/units_service.dart';

/// Animated water ring widget with wave animation
/// Shows water consumption progress with animated waves
class WaterRingWithWave extends StatelessWidget {
  final int consumed;
  final int goal;
  final Color statusColor;
  final String units;
  final AppLocalizations l10n;
  final double size;
  final bool showTarget;
  final bool showPercentBadge;

  const WaterRingWithWave({
    super.key,
    required this.consumed,
    required this.goal,
    required this.statusColor,
    required this.units,
    required this.l10n,
    this.size = 90.0,
    this.showTarget = true,
    this.showPercentBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (consumed / goal * 100).clamp(0.0, 200.0).toDouble() : 0.0;
    
    final displayVolume = UnitsService.instance.formatVolume(consumed);
    final goalDisplay = UnitsService.instance.formatVolume(goal);
    
    final bool useWhiteText = percent > 65;
    final primaryTextColor = useWhiteText 
      ? Colors.white 
      : const Color(0xFF37474F);

    return SizedBox(
      width: size,
      height: size + (showTarget ? 15 : 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showTarget)
            Positioned(
              top: 0,
              child: Text(
                '${l10n.target}: $goalDisplay',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Positioned(
            top: showTarget ? 15 : 0,
            child: WaterRingBare(
              consumedMl: consumed,
              goalMl: goal,
              size: size - 5,
              ringColor: statusColor,
              ringBgColor: Colors.grey[300]!,
              waterColor: statusColor,
            ),
          ),
          Positioned(
            top: showTarget ? 15 : 0,
            child: SizedBox(
              width: size - 5,
              height: size - 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayVolume,
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      height: 1.2,
                    ),
                  ),
                  if (showPercentBadge) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: useWhiteText
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: useWhiteText
                            ? Colors.transparent
                            : Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${percent.toInt()}%',
                        style: TextStyle(
                          fontSize: size * 0.13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bare water ring with wave animation (internal component)
class WaterRingBare extends StatefulWidget {
  final int consumedMl;
  final int goalMl;
  final double size;
  final Color ringColor;
  final Color ringBgColor;
  final Color waterColor;

  const WaterRingBare({
    super.key,
    required this.consumedMl,
    required this.goalMl,
    required this.size,
    required this.ringColor,
    required this.ringBgColor,
    required this.waterColor,
  });

  @override
  State<WaterRingBare> createState() => _WaterRingBareState();
}

class _WaterRingBareState extends State<WaterRingBare>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _progressCtrl;
  double _animatedProgress = 0;

  double get _targetProgress {
    if (widget.goalMl <= 0) return 0;
    final p = widget.consumedMl / widget.goalMl;
    return p.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _animatedProgress = _targetProgress;

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addListener(() {
        setState(() {
          final t = Curves.easeInOut.transform(_progressCtrl.value);
          _animatedProgress =
              (_animatedProgress * (1 - t)) + (_targetProgress * t);
        });
      });
  }

  @override
  void didUpdateWidget(covariant WaterRingBare oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumedMl != widget.consumedMl ||
        oldWidget.goalMl != widget.goalMl) {
      _progressCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _waveCtrl,
        builder: (context, _) {
          return CustomPaint(
            painter: WaterPainter(
              progress: _animatedProgress,
              t: _waveCtrl.value,
              ringColor: widget.ringColor,
              ringBgColor: widget.ringBgColor,
              waterColor: widget.waterColor,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for water ring with wave effect
class WaterPainter extends CustomPainter {
  final double progress;
  final double t;
  final Color ringColor;
  final Color ringBgColor;
  final Color waterColor;

  WaterPainter({
    required this.progress,
    required this.t,
    required this.ringColor,
    required this.ringBgColor,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);
    final r = math.min(w, h) / 2;

    // Background ring
    final ringBgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = ringBgColor;
    canvas.drawCircle(c, r - 4, ringBgPaint);

    // Water (clipped to circle)
    final clip = Path()..addOval(Rect.fromCircle(center: c, radius: r - 8));
    canvas.save();
    canvas.clipPath(clip);

    final level = (1.0 - progress) * (h - 16) + 8;
    _drawWave(canvas, size, level, t, waterColor.withValues(alpha: 0.85), 5, 1.6);
    _drawWave(canvas, size, level + 2, (t + 0.35) % 1.0, waterColor.withValues(alpha: 0.6), 3, 2.3);

    // Gloss on top
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.25), Colors.transparent],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.4), gloss);

    canvas.restore();

    // Thin inner edge
    final glass = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(c, r - 8, glass);

    // Progress arc
    final sweep = (math.pi * 2) * progress;
    if (sweep > 0.001) {
      final rect = Rect.fromCircle(center: c, radius: r - 4);

      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8
        ..color = ringColor;

      canvas.drawArc(rect, -math.pi / 2, sweep, false, ring);

      // Dot at the end of arc
      final endAngle = -math.pi / 2 + sweep;
      final end = Offset(
        c.dx + (r - 4) * math.cos(endAngle),
        c.dy + (r - 4) * math.sin(endAngle),
      );
      
      // Glowing dot
      final glowPaint = Paint()
        ..color = ringColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(end, 4, glowPaint);
      
      final dotPaint = Paint()..color = ringColor;
      canvas.drawCircle(end, 3, dotPaint);
    }
  }

  void _drawWave(Canvas canvas, Size size, double levelY, double t,
      Color color, double amp, double freq) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, levelY);

    final width = size.width;
    for (double x = 0; x <= width; x += 2) {
      final y = levelY +
          math.sin((x / width * math.pi * 2 * freq) + t * math.pi * 2) * amp;
      path.lineTo(x, y);
    }

    path.lineTo(width, size.height);
    path.close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterPainter old) {
    return old.progress != progress ||
        old.t != t ||
        old.ringColor != ringColor ||
        old.ringBgColor != ringBgColor ||
        old.waterColor != waterColor;
  }
}