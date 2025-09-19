// lib/services/analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'devtodev_analytics_service.dart';

/// Сервис для работы с аналитикой (Firebase + DevToDev).
/// Централизует все события и параметры для отслеживания
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _firebase = FirebaseAnalytics.instance;
  final DevToDevAnalyticsService _devToDev = DevToDevAnalyticsService();

  late final List<_AnalyticsBackend> _backends = <_AnalyticsBackend>[
    _FirebaseAnalyticsBackend(_firebase),
    _DevToDevAnalyticsBackend(_devToDev),
  ];

  bool _isInitialized = false;

  Future<void> _setUserId(String? userId) async {
    await _broadcast(
      (backend) => backend.setUserId(userId),
    );
  }

  Future<void> _setUserProperty(String name, String value) async {
    await _broadcast(
      (backend) => backend.setUserProperty(name, value),
    );
  }

  Future<void> _logScreenViewInternal({
    required String screenName,
    String? screenClass,
  }) async {
    final resolvedScreenClass = screenClass ?? screenName;

    await _broadcast(
      (backend) => backend.logScreenView(
        screenName: screenName,
        screenClass: resolvedScreenClass,
      ),
    );
  }

  Future<void> _logEventInternal({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _broadcast(
      (backend) => backend.logEvent(
        name: name,
        parameters: parameters,
      ),
    );
  }

  Future<void> _broadcast(
    Future<void> Function(_AnalyticsBackend backend) action,
  ) async {
    await Future.wait(_backends.map(action));
  }

  /// Получить observer для навигации (если будете использовать)
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _firebase);

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    for (final backend in _backends) {
      await backend.initialize();
    }

    // Устанавливаем базовые свойства пользователя
    await setDefaultUserProperties();

    if (kDebugMode) {
      print('📊 Analytics Service initialized');
    }
  }

  /// Установка базовых свойств пользователя
  Future<void> setDefaultUserProperties() async {
    // Эти свойства помогут сегментировать пользователей
    await _setUserId(null); // Пока не устанавливаем
  }

  // ==================== USER PROPERTIES ====================
  
  /// Установить режим диеты
  Future<void> setDietMode(String mode) async {
    await _setUserProperty('diet_mode', mode);
  }

  /// Установить статус подписки
  Future<void> setProStatus(bool isPro) async {
    await _setUserProperty('is_pro', isPro.toString());
  }

  /// Установить статус уведомлений
  Future<void> setNotificationStatus(bool enabled) async {
    await _setUserProperty('notifications_enabled', enabled.toString());
  }

  /// Установить страну пользователя
  Future<void> setUserCountry(String countryCode) async {
    await _setUserProperty('country', countryCode);
  }

  // ==================== SCREEN VIEW EVENTS ====================
  
  /// Универсальный метод для логирования просмотра экрана
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _logScreenViewInternal(
      screenName: screenName,
      screenClass: screenClass,
    );

    if (kDebugMode) {
      print('📊 Screen view: $screenName');
    }
  }

  /// Общий метод для логирования событий
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _logEventInternal(name: name, parameters: parameters);

    if (kDebugMode) {
      print('📊 Event: $name');
      if (parameters != null) {
        print('   Parameters: $parameters');
      }
    }
  }

  // ==================== NOTIFICATION EVENTS ====================
  
  /// Уведомление запланировано
  Future<void> logNotificationScheduled({
    required String type,
    required DateTime scheduledTime,
    int? delayMinutes,
  }) async {
    await logEvent(
      name: 'notification_scheduled',
      parameters: {
        'notification_type': type,
        'scheduled_hour': scheduledTime.hour,
        'delay_minutes': delayMinutes ?? 0,
        'day_of_week': scheduledTime.weekday,
      },
    );
    
    if (kDebugMode) {
      print('📊 Event: notification_scheduled - $type at ${scheduledTime.hour}:${scheduledTime.minute}');
    }
  }

  /// Уведомление отправлено
  Future<void> logNotificationSent({
    required String type,
    bool isScheduled = false,
  }) async {
    await logEvent(
      name: 'notification_sent',
      parameters: {
        'notification_type': type,
        'is_scheduled': isScheduled,
        'hour': DateTime.now().hour,
      },
    );
    
    if (kDebugMode) {
      print('📊 Event: notification_sent - $type');
    }
  }

  /// Уведомление открыто
  Future<void> logNotificationOpened({
    required String type,
    String? action,
  }) async {
    await logEvent(
      name: 'notification_opened',
      parameters: {
        'notification_type': type,
        'action': action ?? 'none',
      },
    );
  }

  /// Ошибка уведомления
  Future<void> logNotificationError({
    required String type,
    required String error,
  }) async {
    await logEvent(
      name: 'notification_error',
      parameters: {
        'notification_type': type,
        'error_message': error.substring(0, 100), // Ограничиваем длину
      },
    );
  }

  /// Дубль уведомления обнаружен
  Future<void> logNotificationDuplicate({
    required String type,
    required int count,
  }) async {
    await logEvent(
      name: 'notification_duplicate',
      parameters: {
        'notification_type': type,
        'duplicate_count': count,
      },
    );
    
    if (kDebugMode) {
      print('⚠️ Duplicate notification detected: $type x$count');
    }
  }

  // ==================== CORE TRACKING EVENTS ====================
  
  /// Логирование воды
  Future<void> logWaterIntake({
    required int amount,
    required String source,
  }) async {
    await logEvent(
      name: 'water_logged',
      parameters: {
        'amount_ml': amount,
        'source': source, // 'quick', 'manual', 'preset'
        'hour': DateTime.now().hour,
      },
    );
  }

  /// Логирование электролитов
  Future<void> logElectrolyteIntake({
    required String type,
    required int amount,
  }) async {
    await logEvent(
      name: 'electrolyte_logged',
      parameters: {
        'type': type, // 'sodium', 'potassium', 'magnesium'
        'amount_mg': amount,
      },
    );
  }

  /// Логирование кофе
  Future<void> logCoffeeIntake({
    required int cups,
  }) async {
    await logEvent(
      name: 'coffee_logged',
      parameters: {
        'cups': cups,
        'hour': DateTime.now().hour,
      },
    );
  }

  /// Логирование алкоголя
  Future<void> logAlcoholIntake({
    required double standardDrinks,
    required String type,
  }) async {
    await logEvent(
      name: 'alcohol_logged',
      parameters: {
        'standard_drinks': standardDrinks,
        'type': type, // 'beer', 'wine', 'spirits', 'cocktail'
        'hour': DateTime.now().hour,
      },
    );
  }

  // ==================== GOAL & PROGRESS EVENTS ====================
  
  /// Цель достигнута
  Future<void> logGoalReached({
    required String goalType,
    required double percentage,
  }) async {
    await logEvent(
      name: 'daily_goal_reached',
      parameters: {
        'goal_type': goalType, // 'water', 'sodium', 'potassium', 'magnesium'
        'percentage': percentage.round(),
      },
    );
  }

  /// Изменение HRI статуса
  Future<void> logHRIStatusChange({
    required int fromValue,
    required int toValue,
    required String status,
  }) async {
    await logEvent(
      name: 'hri_status_changed',
      parameters: {
        'from_value': fromValue,
        'to_value': toValue,
        'status': status, // 'green', 'yellow', 'red'
        'direction': toValue > fromValue ? 'worse' : 'better',
      },
    );
  }

  /// Статус гидратации
  Future<void> logHydrationStatus({
    required String status,
  }) async {
    await logEvent(
      name: 'hydration_status',
      parameters: {
        'status': status, // 'normal', 'dehydrated', 'diluted', 'low_salt'
        'hour': DateTime.now().hour,
      },
    );
  }

  // ==================== SUBSCRIPTION EVENTS ====================
  
  /// Показ paywall
  Future<void> logPaywallShown({
    required String source,
    String? variant,
  }) async {
    await logEvent(
      name: 'paywall_shown',
      parameters: {
        'source': source, // 'onboarding', 'settings', 'feature_gate'
        'variant': variant ?? 'default',
      },
    );
  }

  /// Выбор плана на paywall
  Future<void> logPaywallPlanSelected({
    required String plan,
    required String source,
    String? variant,
  }) async {
    await logEvent(
      name: 'paywall_plan_selected',
      parameters: {
        'plan': plan,
        'source': source,
        'variant': variant ?? 'default',
      },
    );
  }

  /// Переключение триала на paywall
  Future<void> logPaywallTrialToggle({
    required String source,
    required bool enabled,
  }) async {
    await logEvent(
      name: 'paywall_trial_toggled',
      parameters: {
        'source': source,
        'enabled': enabled,
      },
    );
  }

  /// Закрытие paywall
  Future<void> logPaywallDismissed({
    required String source,
    String? reason,
  }) async {
    await logEvent(
      name: 'paywall_dismissed',
      parameters: {
        'source': source,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Попытка покупки подписки
  Future<void> logSubscriptionPurchaseAttempt({
    required String product,
    required String source,
    bool trialEnabled = false,
  }) async {
    await logEvent(
      name: 'subscription_purchase_attempt',
      parameters: {
        'product': product,
        'source': source,
        'trial_enabled': trialEnabled,
      },
    );
  }

  /// Начало подписки
  Future<void> logSubscriptionStarted({
    required String product,
    required bool isTrial,
  }) async {
    await logEvent(
      name: 'subscription_started',
      parameters: {
        'product': product, // 'monthly', 'annual', 'lifetime'
        'is_trial': isTrial,
      },
    );
  }

  /// Результат покупки подписки
  Future<void> logSubscriptionPurchaseResult({
    required String product,
    required String source,
    required bool success,
    bool trialEnabled = false,
    String? error,
  }) async {
    await logEvent(
      name: 'subscription_purchase_result',
      parameters: {
        'product': product,
        'source': source,
        'success': success,
        'trial_enabled': trialEnabled,
        if (error != null && error.isNotEmpty)
          'error': error.substring(0, 80),
      },
    );
  }

  /// Попытка восстановления подписки
  Future<void> logSubscriptionRestoreAttempt({
    required String source,
  }) async {
    await logEvent(
      name: 'subscription_restore_attempt',
      parameters: {
        'source': source,
      },
    );
  }

  /// Результат восстановления подписки
  Future<void> logSubscriptionRestoreResult({
    required String source,
    required bool success,
  }) async {
    await logEvent(
      name: 'subscription_restore_result',
      parameters: {
        'source': source,
        'success': success,
      },
    );
  }

  /// PRO функция заблокирована
  Future<void> logProFeatureGate({
    required String feature,
  }) async {
    await logEvent(
      name: 'pro_feature_gate_hit',
      parameters: {
        'feature': feature, // 'smart_reminders', 'csv_export', etc
      },
    );
  }

  // ==================== ENGAGEMENT EVENTS ====================
  
  /// Просмотр отчета
  Future<void> logReportViewed({
    required String type,
  }) async {
    await logEvent(
      name: 'report_viewed',
      parameters: {
        'type': type, // 'daily', 'weekly'
      },
    );
  }

  /// Экспорт CSV
  Future<void> logCSVExported() async {
    await logEvent(
      name: 'csv_exported',
      parameters: {
        'date': DateTime.now().toIso8601String().split('T')[0],
      },
    );
  }

  /// Изменение настроек
  Future<void> logSettingsChanged({
    required String setting,
    required dynamic value,
  }) async {
    await logEvent(
      name: 'settings_changed',
      parameters: {
        'setting': setting,
        'value': value.toString(),
      },
    );
  }

  /// Изменение режима диеты
  Future<void> logDietModeChanged({
    required String from,
    required String to,
  }) async {
    await logEvent(
      name: 'diet_mode_changed',
      parameters: {
        'from': from,
        'to': to,
      },
    );
    
    // Также обновляем user property
    await setDietMode(to);
  }

  // ==================== ONBOARDING EVENTS ====================
  
  /// Начало онбординга
  Future<void> logOnboardingStart() async {
    await logEvent(name: 'onboarding_start');
  }

  /// Просмотр шага онбординга
  Future<void> logOnboardingStepViewed({
    required String stepId,
    required int stepIndex,
    String? screenName,
  }) async {
    await logEvent(
      name: 'onboarding_step_viewed',
      parameters: {
        'step_id': stepId,
        'step_index': stepIndex,
        if (screenName != null) 'screen_name': screenName,
      },
    );

    await logScreenView(
      screenName: screenName ?? stepId,
      screenClass: 'Onboarding$stepId',
    );
  }

  /// Завершение шага онбординга
  Future<void> logOnboardingStepCompleted({
    required String stepId,
    required int stepIndex,
  }) async {
    await logEvent(
      name: 'onboarding_step_completed',
      parameters: {
        'step_id': stepId,
        'step_index': stepIndex,
      },
    );
  }

  /// Выбор опции на онбординге
  Future<void> logOnboardingOptionSelected({
    required String stepId,
    required String option,
    required String value,
  }) async {
    await logEvent(
      name: 'onboarding_option_selected',
      parameters: {
        'step_id': stepId,
        'option': option,
        'value': value,
      },
    );
  }

  /// Завершение онбординга
  Future<void> logOnboardingComplete() async {
    await logEvent(name: 'onboarding_complete');
  }

  /// Пропуск онбординга
  Future<void> logOnboardingSkip({
    required int step,
  }) async {
    await logEvent(
      name: 'onboarding_skip',
      parameters: {
        'step': step,
      },
    );
  }

  /// Сохранение профиля пользователя на финальном шаге онбординга
  Future<void> logOnboardingProfileSaved({
    required double weightKg,
    required String units,
    required String dietMode,
    required bool fastingEnabled,
  }) async {
    await logEvent(
      name: 'onboarding_profile_saved',
      parameters: {
        'weight_kg': weightKg,
        'units': units,
        'diet_mode': dietMode,
        'fasting_enabled': fastingEnabled,
      },
    );
  }

  /// Показ системного запроса разрешений
  Future<void> logPermissionPrompt({
    required String permission,
    required String context,
  }) async {
    await logEvent(
      name: 'permission_prompt',
      parameters: {
        'permission': permission,
        'context': context,
      },
    );
  }

  /// Результат запроса разрешений
  Future<void> logPermissionResult({
    required String permission,
    required String status,
    required String context,
  }) async {
    await logEvent(
      name: 'permission_result',
      parameters: {
        'permission': permission,
        'status': status,
        'context': context,
      },
    );
  }

  // ==================== APP LIFECYCLE ====================
  
  /// Открытие приложения
  Future<void> logAppOpen() async {
    await logEvent(name: 'app_open');
  }

  /// Сессия приложения
  Future<void> logSession({
    required int durationSeconds,
  }) async {
    await logEvent(
      name: 'session',
      parameters: {
        'duration_seconds': durationSeconds,
      },
    );
  }

  /// Выбор вкладки нижней навигации
  Future<void> logNavigationTabSelected({
    required String tab,
  }) async {
    await logEvent(
      name: 'navigation_tab_selected',
      parameters: {
        'tab': tab,
      },
    );
  }

  /// Открытие меню быстрого добавления напитков
  Future<void> logQuickAddMenuOpened() async {
    await logEvent(name: 'quick_add_menu_opened');
  }

  // ==================== DEBUG HELPERS ====================
  
  /// Тестовое событие для проверки
  Future<void> logTestEvent() async {
    await logEvent(
      name: 'test_event',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'debug': kDebugMode,
      },
    );
    
    if (kDebugMode) {
      print('📊 Test event sent to Analytics');
    }
  }

  /// Включить/выключить сбор аналитики
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _broadcast(
      (backend) => backend.setAnalyticsCollectionEnabled(enabled),
    );
  }
  
  // ==================== ACHIEVEMENT EVENTS ====================

  /// Достижение разблокировано
  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementName,
    required String category,
    required int rewardPoints,
  }) async {
    await logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'category': category,
        'reward_points': rewardPoints,
      },
    );
    
    if (kDebugMode) {
      print('📊 Achievement unlocked: $achievementName');
    }
  }

  /// Просмотр экрана достижений
  Future<void> logAchievementsScreenView() async {
    await _logScreenViewInternal(
      screenName: 'achievements',
      screenClass: 'AchievementsScreen',
    );

    if (kDebugMode) {
      print('📊 Achievements screen viewed');
    }
  }

  /// Просмотр деталей достижения (упрощенная версия для achievements_screen.dart)
  Future<void> logAchievementViewed({
    required String achievementId,
    required String achievementName,
    required String category,
    required bool isUnlocked,
  }) async {
    await logEvent(
      name: 'achievement_details_viewed',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'category': category,
        'is_unlocked': isUnlocked,
      },
    );
    
    if (kDebugMode) {
      print('📊 Achievement viewed: $achievementName');
    }
  }

  /// Просмотр деталей достижения (полная версия)
  Future<void> logAchievementDetailsViewed({
    required String achievementId,
    required String achievementName,
    required bool isUnlocked,
  }) async {
    await logEvent(
      name: 'achievement_details_viewed',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'is_unlocked': isUnlocked,
      },
    );
  }
} // закрывающая скобка класса AnalyticsService

abstract class _AnalyticsBackend {
  Future<void> initialize();

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty(String name, String value);

  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  });

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  Future<void> setAnalyticsCollectionEnabled(bool enabled);
}

class _FirebaseAnalyticsBackend implements _AnalyticsBackend {
  _FirebaseAnalyticsBackend(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> initialize() async {
    // Firebase не требует дополнительной инициализации здесь
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error setting Firebase userId: $error');
      }
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error setting Firebase user property $name: $error');
      }
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error logging Firebase screen: $screenName ($error)');
      }
    }
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, Object>? firebaseParams = parameters?.map(
      (key, value) => MapEntry(key, value as Object),
    );

    try {
      await _analytics.logEvent(
        name: name,
        parameters: firebaseParams,
      );
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error logging Firebase event $name: $error');
      }
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Error toggling Firebase analytics collection: $error');
      }
    }
  }
}

class _DevToDevAnalyticsBackend implements _AnalyticsBackend {
  _DevToDevAnalyticsBackend(this._devToDev);

  final DevToDevAnalyticsService _devToDev;

  @override
  Future<void> initialize() => _devToDev.initialize();

  @override
  Future<void> setUserId(String? userId) async {
    if (userId == null) {
      await _devToDev.clearUserId();
    } else {
      await _devToDev.setUserId(userId);
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await _devToDev.setUserProperty(name, value);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {
    await _devToDev.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _devToDev.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _devToDev.setTrackingEnabled(enabled);
  }
}
