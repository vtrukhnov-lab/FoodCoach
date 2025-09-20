// lib/services/notifications/notification_config.dart

import 'notification_types.dart';

/// Конфигурация уведомлений FoodCoach
class NotificationConfig {
  // Не создаем экземпляры - только статические константы
  NotificationConfig._();

  // ==================== КАНАЛЫ ANDROID ====================
  
  static const String channelPrefix = 'hydracoach';
  
  // Суффиксы каналов (к ним добавляется язык)
  static const String defaultChannelSuffix = 'default';
  static const String urgentChannelSuffix = 'urgent';
  static const String reportChannelSuffix = 'report';
  static const String silentChannelSuffix = 'silent';
  
  // ==================== ВРЕМЕННЫЕ НАСТРОЙКИ ====================
  
  // Тихие часы по умолчанию
  static const String defaultQuietHoursStart = '22:00';
  static const String defaultQuietHoursEnd = '07:00';
  
  // Время вечернего отчета по умолчанию
  static const String defaultEveningReportTime = '21:00';
  
  // Задержки для уведомлений (в минутах)
  static const int postCoffeeDelayMinutes = 45;
  static const int alcoholCounterDelayMinutes = 30;
  static const int postWorkoutDelayMinutes = 30;
  
  // ==================== ЛИМИТЫ ====================
  
  // FREE пользователи
  static const int maxFreeNotificationsDaily = 4;
  static const int freeAntiSpamMinutes = 90;
  
  // PRO пользователи
  static const int proAntiSpamMinutes = 60;
  static const int proDailySoftCap = 6;
  static const int proDailyHardCap = 8;
  
  // ==================== БАЗОВЫЕ ВРЕМЕНА НАПОМИНАНИЙ ====================
  
  static const List<List<int>> baseReminderTimes = [
    [9, 30],   // 09:30
    [12, 30],  // 12:30
    [15, 30],  // 15:30
    [18, 30],  // 18:30
  ];
  
  static const List<List<int>> fastingElectrolyteTimes = [
    [10, 0],   // 10:00
    [14, 0],   // 14:00
    [18, 0],   // 18:00
  ];
  
  // ==================== АЛКОГОЛЬ ====================
  
  static const int standardDrinkGrams = 10;  // Грамм чистого спирта в стандартном дринке
  static const int waterPerStandardDrink = 150;  // мл воды на стандартный дринк
  static const int sodiumPerStandardDrink = 100;  // мг натрия на стандартный дринк
  
  // План восстановления после алкоголя
  static const int lightRecoveryHours = 6;   // Для 1-2 дринков
  static const int heavyRecoveryHours = 12;  // Для 3+ дринков
  static const int recoveryStepInterval = 2; // Часы между напоминаниями
  
  // ==================== УТРЕННИЙ ЧЕК-ИН ====================
  
  static const int morningCheckInHour = 7;
  static const int morningCheckInMinute = 5;
  
  // ==================== КЕШИРОВАНИЕ ====================
  
  static const Duration proStatusCacheDuration = Duration(minutes: 5);
  
  // ==================== SINGLETON ТИПЫ ====================
  
  /// Типы уведомлений, которые должны быть единственными
  static const Set<NotificationType> singletonTypes = {
    NotificationType.dailyReport,
    NotificationType.morningCheckIn,
    NotificationType.heatWarning,
    NotificationType.postCoffee,
  };
  
  // ==================== REMOTE CONFIG KEYS ====================
  
  // Ключи для Remote Config параметров
  static const String rcPostCoffeeDelay = 'post_coffee_delay_minutes';
  static const String rcMaxFreeNotifications = 'max_free_notifications_daily';
  static const String rcAntiSpamInterval = 'anti_spam_interval_minutes';
  static const String rcProDailyCap = 'push_pro_daily_cap';
  static const String rcProHardCap = 'push_pro_hard_cap';
  
  // Алкоголь
  static const String rcStandardDrinkGrams = 'std_drink_grams';
  static const String rcAlcoholDrinkBonus = 'alcohol_drink_bonus_ml';
  static const String rcSodiumPerDrink = 'na_per_sd_mg';
  static const String rcMagnesiumAfterAlc = 'mg_per_day_after_alc_mg';
  static const String rcAlcoholHriRisk = 'alc_hri_risk_per_sd';
  static const String rcAlcoholHriCap = 'alc_hri_risk_cap';
  static const String rcAlcoholEveningCutoff = 'alc_evening_cutoff_local';
  
  // ==================== SHARED PREFERENCES KEYS ====================
  
  // Основные настройки
  static const String prefNotificationsEnabled = 'notificationsEnabled';
  static const String prefIsPro = 'is_pro';
  static const String prefDietMode = 'diet_mode';
  static const String prefUserTimezone = 'user_timezone';
  
  // Тихие часы
  static const String prefQuietHoursEnabled = 'quiet_hours_enabled';
  static const String prefQuietHoursStart = 'quiet_hours_start';
  static const String prefQuietHoursEnd = 'quiet_hours_end';
  
  // Пост
  static const String prefFastingSchedule = 'fasting_schedule';
  static const String prefFastingWindowStart = 'fasting_window_start';
  static const String prefFastingWindowEnd = 'fasting_window_end';
  static const String prefQuietFastingMode = 'quiet_fasting_mode';
  
  // Счетчики
  static const String prefNotificationCountToday = 'notification_count_today';
  static const String prefNotificationLimitReset = 'notification_limit_reset';
  static const String prefProSentToday = 'pro_sent_today';
  static const String prefProCapReset = 'pro_cap_reset';
  static const String prefLastNotificationTime = 'last_notification_time';
  static const String prefLastCoffeeNotificationTime = 'last_coffee_notification_time';
  
  // Антиспам
  static const String prefAntiSpamEnabled = 'anti_spam_enabled';
  
  // Вечерний отчет
  static const String prefEveningReportTime = 'evening_report_time';
  
  // Тренировка
  static const String prefHasWorkoutToday = 'has_workout_today';
  static const String prefWorkoutTime = 'workout_time';
  static const String prefWorkoutDurationMinutes = 'workout_duration_minutes';
  
  // Погода
  static const String prefHeatIndex = 'heat_index';
  
  // FCM
  static const String prefFcmToken = 'fcm_token';
}