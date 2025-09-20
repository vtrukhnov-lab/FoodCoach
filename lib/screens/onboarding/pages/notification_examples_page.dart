// lib/screens/onboarding/pages/notification_examples_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics_service.dart';
import '../../../services/notification_service.dart';

class NotificationExamplesPage extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final ValueChanged<PermissionStatus> onPermissionResult;

  const NotificationExamplesPage({
    Key? key,
    required this.onSkip,
    required this.onBack,
    required this.onPermissionResult,
  }) : super(key: key);

  AnalyticsService get _analytics => AnalyticsService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Text(
                l10n.onboardingNotificationExamplesTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 12),
              
              // Подзаголовок
              Text(
                l10n.onboardingNotificationExamplesSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate()
                .fadeIn(duration: 500.ms, delay: 100.ms),
              
              const SizedBox(height: 32),
              
              // Примеры уведомлений
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildNotificationExample(
                        context: context,
                        icon: Icons.water_drop,
                        iconColor: Colors.blue,
                        time: '09:30',
                        title: l10n.timeToHydrate,
                        body: l10n.maintainWaterBalance,
                        delay: 200.ms,
                        theme: theme,
                        isLight: isLight,
                      ),
                      
                      _buildNotificationExample(
                        context: context,
                        icon: Icons.coffee,
                        iconColor: Colors.brown,
                        time: '10:15',
                        title: l10n.postCoffeeTitle,
                        body: l10n.postCoffeeBody,
                        delay: 300.ms,
                        theme: theme,
                        isLight: isLight,
                      ),
                      
                      _buildNotificationExample(
                        context: context,
                        icon: Icons.sunny,
                        iconColor: Colors.orange,
                        time: '14:00',
                        title: l10n.heatWarningHot,
                        body: l10n.drinkMoreWaterToday,
                        delay: 400.ms,
                        theme: theme,
                        isLight: isLight,
                      ),
                      
                      _buildNotificationExample(
                        context: context,
                        icon: Icons.nightlight_round,
                        iconColor: Colors.indigo,
                        time: '21:00',
                        title: l10n.dailyReportTitle,
                        body: l10n.dailyReportBody,
                        delay: 500.ms,
                        theme: theme,
                        isLight: isLight,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопки действий
              Row(
                children: [
                  // Кнопка "Назад"
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onBack();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        l10n.back,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(width: 16),
                  
                  // Кнопка "Включить уведомления"
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        _analytics.logPermissionPrompt(
                          permission: 'notifications',
                          context: 'onboarding',
                        );
                        final status =
                            await _requestNotificationPermission(context);
                        onPermissionResult(status);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_active, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.onboardingAllowNotifications),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideX(begin: 0.2, end: 0),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Кнопка "Пропустить"
              Center(
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSkip();
                  },
                  child: Text(
                    l10n.onboardingEnableLater,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }

  /// Запрос разрешений на уведомления
  Future<PermissionStatus> _requestNotificationPermission(
    BuildContext context,
  ) async {
    PermissionStatus finalStatus = await Permission.notification.status;
    bool overlayVisible = true;
    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 1. Сначала проверяем и запрашиваем системное разрешение через permission_handler
      debugPrint('📱 Step 1: Checking system notification permission...');
      
      PermissionStatus status = finalStatus;
      debugPrint('Current permission status: $status');

      if (!status.isGranted) {
        debugPrint('🔔 Requesting system notification permission...');
        status = await Permission.notification.request();
        debugPrint('New permission status: $status');

        // Добавляем небольшую задержку после системного запроса
        await Future.delayed(const Duration(milliseconds: 500));
      }

      finalStatus = status;

      // 2. Теперь инициализируем NotificationService если нужно
      debugPrint('📱 Step 2: Initializing NotificationService...');
      final notificationService = NotificationService();

      if (!notificationService.isInitialized) {
        await NotificationService.initialize();
        // Ждем завершения инициализации
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      
      // 3. Если разрешение получено, настраиваем уведомления
      if (status.isGranted) {
        debugPrint('✅ Permission granted, configuring notifications...');

        // Вызываем дополнительную конфигурацию через NotificationService
        // Это настроит каналы и запланирует уведомления
        await notificationService.requestPermissions(exactAlarms: true);

        debugPrint('🎉 Notifications configured successfully!');
      } else if (status.isPermanentlyDenied) {
        debugPrint('⚠️ Permission permanently denied, showing settings dialog...');

        // Закрываем индикатор загрузки
        if (context.mounted && overlayVisible && Navigator.canPop(context)) {
          Navigator.pop(context);
          overlayVisible = false;
        }

        // Показываем диалог для перехода в настройки
        if (context.mounted) {
          await _showSettingsDialog(context);
        }
      } else {
        debugPrint('❌ Permission denied by user');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Error requesting permissions: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      // Закрываем индикатор загрузки
      if (context.mounted && overlayVisible && Navigator.canPop(context)) {
        Navigator.pop(context);
        overlayVisible = false;
      }
    }

    return finalStatus;
  }

  /// Диалог для перехода в настройки
  Future<void> _showSettingsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.onboardingNotificationTitle),
          content: Text(
            'Для получения уведомлений необходимо включить их в настройках устройства.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Позже'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Открыть настройки'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationExample({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String time,
    required String title,
    required String body,
    required Duration delay,
    required ThemeData theme,
    required bool isLight,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight 
            ? Colors.white 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Содержимое уведомления
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms, delay: delay)
      .slideX(begin: 0.1, end: 0);
  }
}