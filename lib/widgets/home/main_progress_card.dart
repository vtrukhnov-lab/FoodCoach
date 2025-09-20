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
import 'favorite_beverages_bar.dart';

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
    
    // Тактильная обратная связь
    HapticFeedback.lightImpact();
    
    // Убеждаемся, что контекст установлен перед добавлением
    provider.setContext(context);

    // Добавляем воду (AchievementService покажет уведомление автоматически)
    provider.addIntake('water', _quickAddVolume, source: 'quick_add_single');
    
    // Обновляем родительский виджет
    widget.onUpdate();
  }

  /// Двойное нажатие - добавляет двойной объем
  void _handleDoubleTap() {
    final provider = context.read<HydrationProvider>();
    
    HapticFeedback.mediumImpact();
    
    // Убеждаемся, что контекст установлен перед добавлением
    provider.setContext(context);
    
    // Добавляем двойной объем
    provider.addIntake('water', _quickAddVolume * 2, source: 'quick_add_double');
    
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final units = context.watch<UnitsService>();
    final l10n = AppLocalizations.of(context);
    
    // Получаем текущий прогресс
    final waterConsumed = provider.totalWaterToday.toInt();
    final waterGoal = provider.goals.waterOpt;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Основной круг прогресса с жестами
            GestureDetector(
              onTap: _handleQuickAdd,
              onDoubleTap: _handleDoubleTap,
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: _WaterProgressRing(
                  consumed: waterConsumed,
                  goal: waterGoal,
                  units: units,
                  l10n: l10n,
                ),
              ),
            ),
            
            // Заголовок и подсказка о жестах
            const SizedBox(height: 16),
            Text(
              l10n.quickAdd,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 28,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${units.formatVolume(_quickAddVolume)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 28,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.touch_app,
                          size: 28,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${units.formatVolume(_quickAddVolume * 2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 5),
            
            // Панель быстрых напитков
            FavoriteBeveragesBar(onUpdate: widget.onUpdate),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}

/// Круговой индикатор прогресса воды с волновой анимацией
class _WaterProgressRing extends StatefulWidget {
  final int consumed;
  final int goal;
  final UnitsService units;
  final AppLocalizations l10n;
  
  const _WaterProgressRing({
    required this.consumed,
    required this.goal,
    required this.units,
    required this.l10n,
  });

  @override
  State<_WaterProgressRing> createState() => _WaterProgressRingState();
}

class _WaterProgressRingState extends State<_WaterProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _progressController;
  double _animatedProgress = 0;
  
  @override
  void initState() {
    super.initState();
    _animatedProgress = _getTargetProgress();
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    )..addListener(() {
      setState(() {
        final t = Curves.easeInOut.transform(_progressController.value);
        _animatedProgress = (_animatedProgress * (1 - t)) + (_getTargetProgress() * t);
      });
    });
  }
  
  @override
  void didUpdateWidget(covariant _WaterProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed || oldWidget.goal != widget.goal) {
      _progressController.reset();
      _progressController.forward();
    }
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  double _getTargetProgress() {
    if (widget.goal <= 0) return 0;
    final progress = widget.consumed / widget.goal;
    return progress.clamp(0.0, 1.0);
  }
  
  Color _getProgressColor(double percent) {
    if (percent < 30) return Colors.red.shade400;
    if (percent < 60) return Colors.orange.shade400;
    if (percent < 90) return Colors.blue.shade400;
    if (percent <= 110) return Colors.green.shade400;
    return Colors.deepOrange.shade400; // Переизбыток
  }
  
  @override
  Widget build(BuildContext context) {
    final double percent = widget.goal > 0 
        ? (widget.consumed / widget.goal * 100).clamp(0.0, 200.0) 
        : 0.0;
    final color = _getProgressColor(percent);
    
    // Форматируем отображение объема
    final displayVolume = widget.units.formatVolume(widget.consumed);
    final goalDisplay = widget.units.formatVolume(widget.goal);
    
    // Определяем цвет текста в зависимости от уровня воды
    final bool useWhiteText = percent > 65;
    final primaryTextColor = useWhiteText 
        ? Colors.white 
        : const Color(0xFF37474F);
    
    return SizedBox(
      width: 220,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Метка цели сверху
          Positioned(
            top: 0,
            child: Text(
              '${widget.l10n.target}: $goalDisplay',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Кастомный круг с волной
          Positioned(
            top: 25,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: _WaterRingPainter(
                    progress: _animatedProgress,
                    wavePhase: _waveController.value,
                    color: color,
                    ringBgColor: Colors.grey.shade300,
                    waterColor: color,
                  ),
                );
              },
            ),
          ),
          
          // Текст в центре
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),
              Text(
                displayVolume,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: useWhiteText 
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percent.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Рисует круг с волной внутри
class _WaterRingPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color color;
  final Color ringBgColor;
  final Color waterColor;
  
  _WaterRingPainter({
    required this.progress,
    required this.wavePhase,
    required this.color,
    required this.ringBgColor,
    required this.waterColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = math.min(w, h) / 2;
    
    // Фоновый круг
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..color = ringBgColor;
    canvas.drawCircle(center, radius - 6, bgPaint);
    
    // Обрезаем по кругу для волны
    canvas.save();
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 12));
    canvas.clipPath(clipPath);
    
    // Рисуем волны
    final waterLevel = (1.0 - progress) * (h - 16) + 8;
    
    // Первая волна
    _drawWave(
      canvas, 
      size, 
      waterLevel, 
      wavePhase, 
      waterColor.withValues(alpha: 0.85), 
      5, 
      1.6
    );
    
    // Вторая волна для глубины
    _drawWave(
      canvas, 
      size, 
      waterLevel + 2, 
      (wavePhase + 0.35) % 1.0, 
      waterColor.withValues(alpha: 0.6), 
      3, 
      2.3
    );
    
    // Блик сверху
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.25), Colors.transparent],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.4), glossPaint);
    
    canvas.restore();
    
    // Тонкая внутренняя граница
    final glassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius - 12, glassPaint);
    
    // Прогресс-дуга поверх
    if (progress > 0.001) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = color;
      
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
      
      // Точка в конце дуги
      final endAngle = -math.pi / 2 + sweepAngle;
      final endPoint = Offset(
        center.dx + (radius - 6) * math.cos(endAngle),
        center.dy + (radius - 6) * math.sin(endAngle),
      );
      
      // Светящаяся точка
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(endPoint, 4, glowPaint);
      
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(endPoint, 3, dotPaint);
    }
  }
  
  void _drawWave(
    Canvas canvas, 
    Size size, 
    double levelY, 
    double t,
    Color color, 
    double amplitude, 
    double frequency
  ) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, levelY);
    
    final width = size.width;
    for (double x = 0; x <= width; x += 2) {
      final y = levelY +
          math.sin((x / width * math.pi * 2 * frequency) + t * math.pi * 2) * amplitude;
      path.lineTo(x, y);
    }
    
    path.lineTo(width, size.height);
    path.close();
    
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant _WaterRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.wavePhase != wavePhase ||
           oldDelegate.color != color ||
           oldDelegate.ringBgColor != ringBgColor ||
           oldDelegate.waterColor != waterColor;
  }
}