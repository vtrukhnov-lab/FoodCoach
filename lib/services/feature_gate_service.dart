import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_service.dart';

/// Enum всех функций приложения согласно ТЗ
enum AppFeature {
  // ===== FREE функции (доступны всем) =====
  // Основной трекинг
  basicWaterTracking,      // 3 кольца (Вода/Na/K) + индикатор Mg
  basicHRI,                 // Базовый HRI индекс
  hydrationStatus,          // Статус гидратации
  quickLog,                 // Быстрый лог воды/электролитов/кофе
  deleteSwipe,              // Удаление записей свайпом
  
  
  // Уведомления FREE
  simpleReminders,          // До 4 временных напоминаний в день
  coffeeReminder,           // 1 пинг после кофе
  
  // Отчёты FREE
  dailyReport,              // Базовый дневной отчёт
  weeklyTrends,             // Базовые недельные тренды
  
  // История FREE
  historyLimited,           // История до 30 дней
  basicCloudSync,           // Базовая синхронизация
  
  // Алкоголь FREE
  alcoholLog,               // Лог SD (тип/объём/ABV)
  alcoholCounterCorrection, // Контр-коррекция воды/Na
  alcoholHarmReductionCard, // Карточка "минимум вреда"
  alcoholMorningCheckin,    // Утренний чек-ин (5 баллов)
  alcoholHRIImpact,         // Влияние на HRI
  
  // ===== PRO функции (требуют подписку) =====
  // Smart Reminders
  smartReminders,           // Контекстные напоминания
  heatReminders,            // Напоминания при жаре
  workoutReminders,         // Напоминания при тренировке
  fastingReminders,         // Напоминания при выходе из поста
  antiSpam,                 // Анти-спам (≤1/час)
  quietHours,               // Тихие часы
  quietFasting,             // "Тихий" режим поста
  
  // Fasting-aware
  fastingSchedules,         // Расписания IF/OMAD/ADF
  refeedLadder,             // "Лестница" рефида
  electrolytesPings,        // Электролитные пинги в пост
  
  // Workout/Heatwave протоколы
  workoutProtocol,          // T-60/30/15 протокол
  heatwaveProfile,          // Профиль "жара/высота"
  
  // Калибровки
  sweatTest,                // Тест потоотделения
  urineColorScale,          // Шкала цвета мочи
  
  // Отчёты PRO
  weeklyProReport,          // Недельный PRO-отчёт с инсайтами
  csvExport,                // Экспорт в CSV
  
  // Синхронизация PRO
  unlimitedHistory,         // Неограниченная история
  multiDevice,              // Мультидевайс синхронизация
  
  // Виджеты
  homeScreenWidgets,        // Виджеты на главном экране
  watchApp,                 // Приложение для часов
  
  // Алкоголь PRO
  alcoholPreDrink,          // Pre-drink протокол (T-60/30/15)
  alcoholRecoveryPlan,      // Recovery план на 6-12 часов
  soberCalendar,            // Трезвый календарь
  soberGoals,               // Цели по трезвым дням
  alcoholFlexibleReminders, // Гибкие напоминания
  alcoholExtendedCheckin,   // Расширенный утренний индекс
  alcoholWeeklyReport,      // Вкладка в недельном отчёте
}

/// Сервис для управления доступом к функциям
class FeatureGateService {
  static FeatureGateService? _instance;
  static FeatureGateService get instance => _instance ??= FeatureGateService._();
  
  FeatureGateService._();
  
  final SubscriptionService _subscriptionService = SubscriptionService.instance;
  
  // Кэш для оффлайн проверок
  bool _cachedProStatus = false;
  DateTime? _cacheExpiry;
  
  /// FREE функции - всегда доступны
  static const Set<AppFeature> _freeFeatures = {
    // Основной трекинг
    AppFeature.basicWaterTracking,
    AppFeature.basicHRI,
    AppFeature.hydrationStatus,
    AppFeature.quickLog,
    AppFeature.deleteSwipe,
    
    
    // Уведомления FREE
    AppFeature.simpleReminders,
    AppFeature.coffeeReminder,
    
    // Отчёты FREE
    AppFeature.dailyReport,
    AppFeature.weeklyTrends,
    
    // История FREE
    AppFeature.historyLimited,
    AppFeature.basicCloudSync,
    
    // Алкоголь FREE
    AppFeature.alcoholLog,
    AppFeature.alcoholCounterCorrection,
    AppFeature.alcoholHarmReductionCard,
    AppFeature.alcoholMorningCheckin,
    AppFeature.alcoholHRIImpact,
  };
  
  /// Проверка доступа к функции
  bool isFeatureAvailable(AppFeature feature) {
    // FREE функции всегда доступны
    if (_freeFeatures.contains(feature)) {
      return true;
    }
    
    // PRO функции требуют подписки
    return hasProAccess();
  }
  
  /// Проверка PRO статуса с кэшированием для оффлайна
  bool hasProAccess() {
    // Если онлайн - используем актуальный статус
    if (_subscriptionService.isInitialized) {
      _cachedProStatus = _subscriptionService.isPro;
      _updateCache(_cachedProStatus);
      return _cachedProStatus;
    }
    
    // Если оффлайн - используем кэш
    if (_cacheExpiry != null && DateTime.now().isBefore(_cacheExpiry!)) {
      return _cachedProStatus;
    }
    
    // Кэш истёк или отсутствует - возвращаем false
    return false;
  }
  
  /// Обновление кэша PRO статуса
  Future<void> _updateCache(bool isPro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cached_pro_status', isPro);
    
    // Кэш на 7 дней для PRO, на 1 день для FREE
    final cacheDuration = isPro ? const Duration(days: 7) : const Duration(days: 1);
    _cacheExpiry = DateTime.now().add(cacheDuration);
    
    await prefs.setString('cache_expiry', _cacheExpiry!.toIso8601String());
  }
  
  /// Загрузка кэша при старте
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedProStatus = prefs.getBool('cached_pro_status') ?? false;
    
    final expiryString = prefs.getString('cache_expiry');
    if (expiryString != null) {
      _cacheExpiry = DateTime.parse(expiryString);
    }
  }
  
  /// Получение лимитов для FREE версии
  Map<String, dynamic> getFreeLimits() {
    return {
      'daily_reminders_max': 4,
      'history_days': 30,
      'coffee_reminders_per_day': 1,
      'alcohol_reminders_per_day': 2, // 1 контр-пинг + 1 перед сном
    };
  }
  
  /// Получение описания PRO функции для UI
  static String getFeatureDescription(AppFeature feature) {
    switch (feature) {
      // Smart Reminders
      case AppFeature.smartReminders:
        return 'Умные контекстные напоминания';
      case AppFeature.heatReminders:
        return 'Напоминания при жаркой погоде';
      case AppFeature.workoutReminders:
        return 'Напоминания для тренировок';
      case AppFeature.fastingReminders:
        return 'Напоминания при выходе из поста';
      case AppFeature.antiSpam:
        return 'Защита от спама (не чаще 1/час)';
      case AppFeature.quietHours:
        return 'Тихие часы без уведомлений';
      case AppFeature.quietFasting:
        return 'Тихий режим во время поста';
      
      // Fasting-aware
      case AppFeature.fastingSchedules:
        return 'Расписания IF/OMAD/ADF';
      case AppFeature.refeedLadder:
        return 'Лестница выхода из голодания';
      case AppFeature.electrolytesPings:
        return 'Напоминания об электролитах в пост';
      
      // Протоколы
      case AppFeature.workoutProtocol:
        return 'Протокол подготовки к тренировке';
      case AppFeature.heatwaveProfile:
        return 'Адаптация к жаре и высоте';
      
      // Калибровки
      case AppFeature.sweatTest:
        return 'Тест уровня потоотделения';
      case AppFeature.urineColorScale:
        return 'Анализ цвета мочи';
      
      // Отчёты PRO
      case AppFeature.weeklyProReport:
        return 'Детальный недельный отчёт';
      case AppFeature.csvExport:
        return 'Экспорт данных в CSV';
      
      // Синхронизация
      case AppFeature.unlimitedHistory:
        return 'Неограниченная история';
      case AppFeature.multiDevice:
        return 'Синхронизация между устройствами';
      
      // Виджеты
      case AppFeature.homeScreenWidgets:
        return 'Виджеты на главном экране';
      case AppFeature.watchApp:
        return 'Приложение для умных часов';
      
      // Алкоголь PRO
      case AppFeature.alcoholPreDrink:
        return 'Протокол подготовки перед алкоголем';
      case AppFeature.alcoholRecoveryPlan:
        return 'План восстановления на 6-12 часов';
      case AppFeature.soberCalendar:
        return 'Календарь трезвости';
      case AppFeature.soberGoals:
        return 'Цели по трезвым дням';
      case AppFeature.alcoholFlexibleReminders:
        return 'Гибкие напоминания для восстановления';
      case AppFeature.alcoholExtendedCheckin:
        return 'Расширенная оценка самочувствия';
      case AppFeature.alcoholWeeklyReport:
        return 'Алкогольная статистика в отчёте';
      
      default:
        return '';
    }
  }
  
  /// Получение иконки для PRO функции
  static IconData getFeatureIcon(AppFeature feature) {
    switch (feature) {
      case AppFeature.smartReminders:
      case AppFeature.heatReminders:
      case AppFeature.workoutReminders:
      case AppFeature.fastingReminders:
      case AppFeature.alcoholFlexibleReminders:
        return Icons.notifications_active;
        
      case AppFeature.antiSpam:
      case AppFeature.quietHours:
      case AppFeature.quietFasting:
        return Icons.do_not_disturb_on;
        
      case AppFeature.fastingSchedules:
      case AppFeature.refeedLadder:
      case AppFeature.electrolytesPings:
        return Icons.schedule;
        
      case AppFeature.workoutProtocol:
        return Icons.fitness_center;
        
      case AppFeature.heatwaveProfile:
        return Icons.wb_sunny;
        
      case AppFeature.sweatTest:
      case AppFeature.urineColorScale:
        return Icons.science;
        
      case AppFeature.weeklyProReport:
        return Icons.assessment;
        
      case AppFeature.csvExport:
        return Icons.file_download;
        
      case AppFeature.unlimitedHistory:
        return Icons.all_inclusive;
        
      case AppFeature.multiDevice:
        return Icons.devices;
        
      case AppFeature.homeScreenWidgets:
        return Icons.widgets;
        
      case AppFeature.watchApp:
        return Icons.watch;
        
      case AppFeature.alcoholPreDrink:
        return Icons.local_bar;
        
      case AppFeature.alcoholRecoveryPlan:
        return Icons.healing;
        
      case AppFeature.soberCalendar:
      case AppFeature.soberGoals:
        return Icons.calendar_today;
        
      case AppFeature.alcoholExtendedCheckin:
        return Icons.fact_check;
        
      case AppFeature.alcoholWeeklyReport:
        return Icons.analytics;
        
      default:
        return Icons.star;
    }
  }
  
  /// Группировка PRO функций для отображения в пейволе
  static Map<String, List<AppFeature>> getProFeatureGroups() {
    return {
      '🔔 Умные напоминания': [
        AppFeature.smartReminders,
        AppFeature.heatReminders,
        AppFeature.workoutReminders,
        AppFeature.antiSpam,
        AppFeature.quietHours,
      ],
      '🥑 Режимы питания': [
        AppFeature.fastingSchedules,
        AppFeature.refeedLadder,
        AppFeature.electrolytesPings,
        AppFeature.quietFasting,
      ],
      '💪 Протоколы активности': [
        AppFeature.workoutProtocol,
        AppFeature.heatwaveProfile,
        AppFeature.sweatTest,
        AppFeature.urineColorScale,
      ],
      '🍺 Алкоголь PRO': [
        AppFeature.alcoholPreDrink,
        AppFeature.alcoholRecoveryPlan,
        AppFeature.soberCalendar,
        AppFeature.alcoholFlexibleReminders,
        AppFeature.alcoholExtendedCheckin,
      ],
      '📊 Аналитика и данные': [
        AppFeature.weeklyProReport,
        AppFeature.csvExport,
        AppFeature.unlimitedHistory,
        AppFeature.multiDevice,
      ],
      '🔗 Расширения': [
        AppFeature.homeScreenWidgets,
        AppFeature.watchApp,
      ],
    };
  }
}