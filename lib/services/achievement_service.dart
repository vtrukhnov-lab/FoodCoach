// lib/services/achievement_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../services/units_service.dart';

/// Глобальный сервис для отображения достижений и мотивационных сообщений
class AchievementService {
  // Singleton pattern
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  // Текущий оверлей и таймер для автоскрытия
  static OverlayEntry? _currentOverlay;
  static Timer? _hideTimer;
  
  // Последний показанный порог для предотвращения дублирования
  static int? _lastShownThreshold;
  static DateTime? _lastShownTime;
  
  // Пороги для достижений
  static const List<int> _thresholds = [25, 50, 75, 100];
  
  /// Проверяет и показывает достижения при изменении прогресса
  static void checkAndShow({
    required BuildContext context,
    required double oldPercent,
    required double newPercent,
    required int addedVolume,
    required String formattedVolume,
  }) {
    // Не показываем при удалении воды (движение назад)
    if (newPercent < oldPercent) {
      return;
    }
    
    // Получаем локализацию
    final l10n = AppLocalizations.of(context);
    
    String? message;
    Color? color;
    
    // Проверяем пересечение порогов
    int? crossedThreshold;
    for (final threshold in _thresholds) {
      if (oldPercent < threshold && newPercent >= threshold) {
        crossedThreshold = threshold;
        break;
      }
    }
    
    if (crossedThreshold != null) {
      // Проверяем, не показывали ли мы это достижение недавно
      final now = DateTime.now();
      if (_lastShownThreshold == crossedThreshold && 
          _lastShownTime != null &&
          now.difference(_lastShownTime!).inSeconds < 2) {
        // Не показываем дважды подряд
        crossedThreshold = null;
      } else {
        _lastShownThreshold = crossedThreshold;
        _lastShownTime = now;
        
        // Получаем сообщение и цвет для порога
        message = _getMotivationalMessage(crossedThreshold.toDouble(), l10n);
        color = _getMotivationalColor(crossedThreshold.toDouble());
        
        // Тактильная обратная связь при достижении
        HapticFeedback.mediumImpact();
      }
    } else if (newPercent < 25) {
      // НОВОЕ: Показываем мотивационное сообщение для прогресса от 0 до 25%
      message = l10n.startDrinking;
      color = Colors.purple.shade500;
      
      // Легкая тактильная обратная связь
      HapticFeedback.lightImpact();
    }
    
    // Показываем оверлей с достижением или просто с объемом
    _showAchievementOverlay(
      context: context,
      message: message,
      color: color,
      addedVolume: formattedVolume,
    );
  }
  
  /// Получает мотивационное сообщение на основе процента
  static String _getMotivationalMessage(double percent, AppLocalizations l10n) {
    if (percent >= 100) return l10n.goalReached;
    if (percent >= 75) return l10n.almostThere;
    if (percent >= 50) return l10n.halfwayThere;
    if (percent >= 25) return l10n.keepGoing;
    return '';
  }
  
  /// Получает цвет для мотивационного сообщения
  static Color _getMotivationalColor(double percent) {
    if (percent >= 100) return Colors.green.shade500;
    if (percent >= 75) return Colors.blue.shade500;
    if (percent >= 50) return Colors.orange.shade500;
    return Colors.purple.shade500;
  }
  
  /// Показывает оверлей с достижением
  static void _showAchievementOverlay({
    required BuildContext context,
    String? message,
    Color? color,
    required String addedVolume,
  }) {
    // Удаляем предыдущий оверлей если есть
    _hideOverlay();
    
    // Создаем новый оверлей
    _currentOverlay = OverlayEntry(
      builder: (context) => _AchievementOverlay(
        message: message,
        color: color,
        addedVolume: addedVolume,
      ),
    );
    
    // Добавляем в оверлей
    final overlay = Overlay.of(context);
    overlay.insert(_currentOverlay!);
      
    // Планируем автоскрытие через 3 секунды
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      _hideOverlay();
    });
  }
  
  /// Скрывает текущий оверлей
  static void _hideOverlay() {
    _hideTimer?.cancel();
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
  
  /// Принудительно скрывает оверлей (например, при dispose)
  static void forceHide() {
    _hideOverlay();
    _lastShownThreshold = null;
    _lastShownTime = null;
  }
}

/// Виджет оверлея для отображения достижений
class _AchievementOverlay extends StatefulWidget {
  final String? message;
  final Color? color;
  final String addedVolume;
  
  const _AchievementOverlay({
    this.message,
    this.color,
    required this.addedVolume,
  });
  
  @override
  State<_AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<_AchievementOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    // Запускаем анимацию появления
    _controller.forward();
    
    // Автоскрытие с анимацией
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final hasMessage = widget.message != null && widget.message!.isNotEmpty;
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Мотивационное сообщение (если есть)
                  if (hasMessage)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: widget.color ?? Colors.purple.shade500,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (widget.color ?? Colors.purple.shade500).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForMessage(widget.message!),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.message!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                      .fadeIn(duration: 300.ms)
                      .shimmer(duration: 1500.ms, delay: 300.ms),
                  
                  // Индикатор добавленного объема (всегда показываем)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+${widget.addedVolume}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms, delay: hasMessage ? 100.ms : 0.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForMessage(String message) {
    // Определяем иконку на основе сообщения
    if (message.toLowerCase().contains('goal') || message.toLowerCase().contains('reached')) {
      return Icons.emoji_events;
    } else if (message.toLowerCase().contains('almost')) {
      return Icons.trending_up;
    } else if (message.toLowerCase().contains('half')) {
      return Icons.water_drop;
    } else {
      return Icons.local_fire_department;
    }
  }
}