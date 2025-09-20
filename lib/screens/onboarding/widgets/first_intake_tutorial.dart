// lib/widgets/first_intake_tutorial.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/hydration_provider.dart';
import '../../../services/units_service.dart';
import '../../../widgets/ion_character.dart';

class FirstIntakeTutorial extends StatefulWidget {
  final VoidCallback onComplete;
  
  const FirstIntakeTutorial({
    super.key,
    required this.onComplete,
  });

  @override
  State<FirstIntakeTutorial> createState() => _FirstIntakeTutorialState();
}

class _FirstIntakeTutorialState extends State<FirstIntakeTutorial> 
    with TickerProviderStateMixin {
  // Текущий шаг туториала
  int _currentStep = 0;
  
  // Симулированный прогресс воды (не влияет на реальные данные)
  int _simulatedWater = 0;
  
  // Флаги для показа текста "TAP"
  bool _showTapText = false;
  
  // Позиция круга прогресса
  Offset? _circlePosition;
  Size? _circleSize;
  
  // Анимационные контроллеры
  late AnimationController _pulseController;
  late AnimationController _fingerTapController;
  late AnimationController _rippleController;
  late AnimationController _textFadeController;
  
  // Анимации
  late Animation<double> _pulseAnimation;
  late Animation<double> _fingerTapAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _textFadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    // Запускаем анимации после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findCirclePosition();
      _startFingerAnimation();
    });
  }
  
  void _initAnimations() {
    // Пульсация подсветки круга
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Анимация нажатия пальца
    _fingerTapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Расходящиеся круги
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    
    // Появление первого текста TAP
    _textFadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    
    // Настройка анимаций
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fingerTapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _fingerTapController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeOut,
    ));
    
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _fingerTapController.dispose();
    _rippleController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }
  
  void _findCirclePosition() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _circlePosition = Offset(size.width * 0.5, size.height * 0.35);
      _circleSize = const Size(200, 200);
    });
  }
  
  void _startFingerAnimation() {
    if (!mounted || _currentStep >= 2) return;
    
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;
      
      // if (_currentStep == 1) {
      //   // Анимация двойного тапа для второго шага
      //   await _animateDoubleTap();
      // } else {
        // Анимация одиночного тапа для первого шага
        await _animateSingleTap();
      // }
      
      // Повторяем цикл
      if (_currentStep < 2 && mounted) {
        _startFingerAnimation();
      }
    });
  }
  
  Future<void> _animateSingleTap() async {
    // Палец опускается
    _fingerTapController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Показываем TAP
    setState(() => _showTapText = true);
    _textFadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Палец поднимается
    _fingerTapController.reverse();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Скрываем TAP
    _textFadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showTapText = false);
  }
  
  
  void _handleSingleTap() {
    if (_currentStep != 0) return;
    
    HapticFeedback.lightImpact();
    
    final unitsService = UnitsService.instance;
    final volumeToAdd = unitsService.getQuickVolumeMl(1); // 250ml или ~8oz
    
    setState(() {
      _simulatedWater += volumeToAdd;
    });
    
    // Показываем мотивационное сообщение с правильными единицами
    final volumeDisplay = unitsService.formatVolume(volumeToAdd, hideUnit: false);
    _showMotivationalMessage('+$volumeDisplay', '💧');
    
    // Переходим сразу к финальному шагу после задержки
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentStep = 2;
        });
        // Останавливаем все анимации
        _fingerTapController.stop();
        _textFadeController.stop();
        _rippleController.stop();
      }
    });
  }
  
  
  void _showMotivationalMessage(String text, String emoji) {
    // Дополнительная вибрация для обратной связи
    HapticFeedback.selectionClick();
    
    // Показываем overlay с анимацией
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _MotivationalOverlay(
        text: text,
        emoji: emoji,
        position: _circlePosition ?? Offset(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.35),
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  void _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialCompleted', true);
    widget.onComplete();
  }
  
  String _getStepText(AppLocalizations l10n, UnitsService unitsService) {
    switch (_currentStep) {
      case 0:
        final volume = unitsService.formatVolume(
          unitsService.getQuickVolumeMl(1),
          hideUnit: false,
        );
        return l10n.tutorialStep1(volume);
      case 2:
        return l10n.tutorialStep3;
      default:
        return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final unitsService = UnitsService.instance;
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    
    final waterGoal = provider.goals.waterOpt;
    final simulatedProgress = waterGoal > 0 
        ? (_simulatedWater / waterGoal * 100).clamp(0.0, 100.0)
        : 0.0;
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Затемнение фона
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
          ),
          
          // Подсветка круга с пульсирующими кольцами
          if (_circlePosition != null && _circleSize != null && _currentStep < 2)
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _rippleAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: _SpotlightPainter(
                    spotlightCenter: _circlePosition!,
                    spotlightRadius: (_circleSize!.width / 2) * _pulseAnimation.value,
                    glowRadius: (_circleSize!.width / 2) * _pulseAnimation.value * 1.5,
                    rippleProgress: _rippleAnimation.value,
                  ),
                );
              },
            ),
          
          // Симулированный круг прогресса
          if (_circlePosition != null && _currentStep < 2)
            Positioned(
              left: _circlePosition!.dx - 100,
              top: _circlePosition!.dy - 100,
              child: GestureDetector(
                onTap: _currentStep == 0 ? _handleSingleTap : null,
                // onDoubleTap: _currentStep == 1 ? _handleDoubleTap : null,
                child: _SimulatedProgressCircle(
                  progress: simulatedProgress,
                  waterConsumed: _simulatedWater,
                  waterGoal: waterGoal,
                  units: unitsService,
                ),
              ),
            ),
          
          // Текст TAP над кругом
          if (_circlePosition != null && _currentStep < 2)
            Positioned(
              left: 0,
              right: 0,
              top: _circlePosition!.dy - 150,
              child: IgnorePointer(
                child: Center(
                  child: Column(
                    children: [
                      // Первый TAP
                      if (_showTapText)
                        AnimatedBuilder(
                          animation: _textFadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textFadeAnimation.value,
                              child: Transform.scale(
                                scale: 0.8 + (_textFadeAnimation.value * 0.4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2EC5FF).withValues(alpha: 0.6),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'TAP',
                                    style: TextStyle(
                                      color: Color(0xFF2EC5FF),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      // Второй TAP (только для двойного тапа)
                      // if (_showSecondTap && _currentStep == 1)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 8),
                      //     child: AnimatedBuilder(
                      //       animation: _secondTextFadeAnimation,
                      //       builder: (context, child) {
                      //         return Opacity(
                      //           opacity: _secondTextFadeAnimation.value,
                      //           child: Transform.scale(
                      //             scale: 0.8 + (_secondTextFadeAnimation.value * 0.4),
                      //             child: Container(
                      //               padding: const EdgeInsets.symmetric(
                      //                 horizontal: 24,
                      //                 vertical: 12,
                      //               ),
                      //               decoration: BoxDecoration(
                      //                 color: Colors.white,
                      //                 borderRadius: BorderRadius.circular(25),
                      //                 boxShadow: [
                      //                   BoxShadow(
                      //                     color: const Color(0xFF2EC5FF).withValues(alpha: 0.6),
                      //                     blurRadius: 20,
                      //                     spreadRadius: 2,
                      //                   ),
                      //                 ],
                      //               ),
                      //               child: const Text(
                      //                 'TAP',
                      //                 style: TextStyle(
                      //                   color: Color(0xFF2EC5FF),
                      //                   fontWeight: FontWeight.w900,
                      //                   fontSize: 32,
                      //                   letterSpacing: 3,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Анимированный палец на круге
          if (_circlePosition != null && _currentStep < 2)
            Positioned(
              left: _circlePosition!.dx - 30,
              top: _circlePosition!.dy - 10,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fingerTapAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fingerTapAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.touch_app,
                          color: Color(0xFF2EC5FF),
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Ion персонаж с инструкциями
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // Ion и текст
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Ion персонаж
                      const IonCharacter(
                        size: 100,
                        mood: IonMood.excited,
                        showGlow: true,
                        showElectrolytes: false,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Речевой пузырь
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getStepText(l10n, unitsService),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: Color(0xFF37474F),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            if (_currentStep == 2) ...[
                              const SizedBox(height: 24),
                              
                              // Кнопка завершения
                              ElevatedButton(
                                onPressed: _completeTutorial,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2EC5FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  l10n.tutorialComplete,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Индикатор шагов (теперь только 2 шага)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    // Маппинг индекса: 0 -> шаг 0, 1 -> шаг 2
                    final stepIndex = index == 0 ? 0 : 2;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: stepIndex == _currentStep ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: stepIndex <= _currentStep
                            ? const Color(0xFF2EC5FF)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Симулированный круг прогресса
class _SimulatedProgressCircle extends StatelessWidget {
  final double progress;
  final int waterConsumed;
  final int waterGoal;
  final UnitsService units;
  
  const _SimulatedProgressCircle({
    required this.progress,
    required this.waterConsumed,
    required this.waterGoal,
    required this.units,
  });
  
  Color _getProgressColor(double percent) {
    if (percent < 30) return Colors.red.shade400;
    if (percent < 60) return Colors.orange.shade400;
    if (percent < 90) return Colors.blue.shade400;
    return Colors.green.shade400;
  }
  
  @override
  Widget build(BuildContext context) {
    final displayVolume = units.formatVolume(waterConsumed);
    final color = _getProgressColor(progress);
    
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EC5FF).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Круговой прогресс
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Текст в центре
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayVolume,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
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

// Painter для эффекта прожектора с пульсирующими кольцами
class _SpotlightPainter extends CustomPainter {
  final Offset spotlightCenter;
  final double spotlightRadius;
  final double glowRadius;
  final double rippleProgress;
  
  _SpotlightPainter({
    required this.spotlightCenter,
    required this.spotlightRadius,
    required this.glowRadius,
    this.rippleProgress = 0.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Создаем путь для всего экрана
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Создаем путь для освещенной области
    final spotlightPath = Path()
      ..addOval(Rect.fromCircle(
        center: spotlightCenter,
        radius: spotlightRadius,
      ));
    
    // Вырезаем освещенную область из затемнения
    final maskPath = Path.combine(
      PathOperation.difference,
      screenPath,
      spotlightPath,
    );
    
    // Рисуем затемнение с вырезом
    canvas.drawPath(
      maskPath,
      Paint()..color = Colors.black87,
    );
    
    // Рисуем пульсирующие кольца
    for (int i = 0; i < 3; i++) {
      final progress = (rippleProgress + i * 0.33) % 1.0;
      final opacity = (1.0 - progress) * 0.3;
      final radius = spotlightRadius + (progress * 50);
      
      canvas.drawCircle(
        spotlightCenter,
        radius,
        Paint()
          ..color = const Color(0xFF2EC5FF).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    
    // Добавляем светящуюся рамку
    canvas.drawCircle(
      spotlightCenter,
      spotlightRadius,
      Paint()
        ..color = const Color(0xFF2EC5FF).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    
    // Внешнее свечение с градиентом
    final gradient = RadialGradient(
      colors: [
        const Color(0xFF2EC5FF).withValues(alpha: 0.3),
        const Color(0xFF2EC5FF).withValues(alpha: 0.1),
        const Color(0xFF2EC5FF).withValues(alpha: 0.0),
      ],
      stops: const [0.3, 0.6, 1.0],
    );
    
    canvas.drawCircle(
      spotlightCenter,
      glowRadius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: spotlightCenter, radius: glowRadius),
        ),
    );
  }
  
  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightCenter != spotlightCenter ||
           oldDelegate.spotlightRadius != spotlightRadius ||
           oldDelegate.glowRadius != glowRadius ||
           oldDelegate.rippleProgress != rippleProgress;
  }
}

// Виджет для мотивационного сообщения
class _MotivationalOverlay extends StatefulWidget {
  final String text;
  final String emoji;
  final Offset position;
  final VoidCallback onComplete;
  
  const _MotivationalOverlay({
    required this.text,
    required this.emoji,
    required this.position,
    required this.onComplete,
  });
  
  @override
  State<_MotivationalOverlay> createState() => _MotivationalOverlayState();
}

class _MotivationalOverlayState extends State<_MotivationalOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
    
    _controller.forward().then((_) {
      widget.onComplete();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 100,
      top: widget.position.dy - 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: ReverseAnimation(CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
              )),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 200,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2EC5FF).withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 24,
                            decoration: TextDecoration.none,
                          ),
                          child: Text(widget.emoji),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.text,
                            style: const TextStyle(
                              color: Color(0xFF2EC5FF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}