import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Результат расчета корректировок жары
class HeatAdjustments {
  final double waterAdjustment;
  final int sodiumAdjustment;
  
  HeatAdjustments(this.waterAdjustment, this.sodiumAdjustment);
}

class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance => _instance ??= RemoteConfigService._();
  
  RemoteConfigService._();
  
  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;
  
  /// Инициализация Remote Config
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Настройки для разработки (частые обновления)
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode 
            ? const Duration(seconds: 10)  // Для разработки
            : const Duration(hours: 1),    // Для продакшна
        ),
      );
      
      // Значения по умолчанию (из ТЗ)
      await _remoteConfig!.setDefaults(_getDefaults());
      
      // Загружаем конфигурацию
      await _remoteConfig!.fetchAndActivate();
      
      _initialized = true;
      
      if (kDebugMode) {
        print('✅ Remote Config инициализирован');
        print('📊 Параметры загружены: ${_remoteConfig!.getAll().length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка инициализации Remote Config: $e');
      }
    }
  }
  
  /// Значения по умолчанию из ТЗ
  Map<String, dynamic> _getDefaults() {
    return {
      // 🔥 Коэффициенты формул воды (мл на кг веса)
      'water_min_per_kg': 22.0,
      'water_opt_per_kg': 30.0,
      'water_max_per_kg': 36.0,
      
      // ⚡ Электролиты базовые цели (мг в день)
      'sodium_normal': 2500,
      'sodium_keto': 3500,
      'potassium_normal': 3000,
      'potassium_keto': 3500,
      'magnesium_normal': 350,
      'magnesium_keto': 400,
      
      // 🌡️ Пороги Heat Index корректировок
      'heat_index_low': 27.0,     // HI < 27°C: без корректировок
      'heat_index_medium': 32.0,  // HI 27-32°C: +5% воды, +500мг натрия
      'heat_index_high': 39.0,    // HI 32-39°C: +8% воды, +1000мг натрия
      // HI > 39°C: +12% воды, +1500мг натрия
      
      'heat_water_adjustment_low': 0.05,    // 5%
      'heat_water_adjustment_medium': 0.08, // 8%  
      'heat_water_adjustment_high': 0.12,   // 12%
      
      'heat_sodium_adjustment_low': 500,    // мг
      'heat_sodium_adjustment_medium': 1000, // мг
      'heat_sodium_adjustment_high': 1500,   // мг
      
      // 📊 HRI - ВЕСА КОМПОНЕНТОВ (сумма = 100)
      'hri_weight_water': 26.0,
      'hri_weight_sodium': 12.0,
      'hri_weight_potassium': 8.0,
      'hri_weight_magnesium': 8.0,
      'hri_weight_heat': 10.0,
      'hri_weight_workout': 12.0,
      'hri_weight_caffeine': 8.0,
      'hri_weight_alcohol': 8.0,
      'hri_weight_time': 4.0,
      'hri_weight_morning': 4.0,
      
      // 📊 HRI - ПАРАМЕТРЫ РАСЧЕТА
      'caffeine_half_life_hours': 6.0,
      'caffeine_scale_factor': 2.0,
      'alcohol_risk_half_life_hours': 4.0,
      'alc_hri_risk_per_sd': 5.0,
      'alc_hri_risk_cap': 15.0,
      'time_since_last_intake_threshold': 3.0,
      'fasting_suppresses_time_component': true,
      'morning_weight_drop_threshold': 1.0, // % от массы тела
      'heat_index_hysteresis': 0.5, // °C для предотвращения дребезга
      
      // 📊 Пороги статусов гидратации
      'hydration_dehydration_threshold': 0.9,  // < 90% от цели воды
      'hydration_dilution_water_threshold': 1.15, // > 115% воды
      'hydration_dilution_sodium_threshold': 0.6, // < 60% натрия
      'hydration_low_salt_threshold': 0.5,     // < 50% натрия
      
      // 🔔 Настройки уведомлений
      'max_free_reminders': 4,            // FREE: до 4 напоминаний в день
      'coffee_reminder_delay_minutes': 45, // После кофе через 45 минут
      'reminder_spam_protection_hours': 1,  // Антиспам: 1 час между контекстными
      'reminder_daily_limit': 8,           // Максимум в день для PRO
      
      // ⏰ Тихие часы по умолчанию
      'quiet_hours_start': 22, // 22:00
      'quiet_hours_end': 7,    // 07:00
      
      // 🍽️ Режим Fasting Aware
      'fasting_aware_enabled': true,
      'fasting_electrolyte_reminder_enabled': true,
      'fasting_refeeding_ladder_enabled': true,
      
      // 💰 НАСТРОЙКИ ПОДПИСКИ И ЦЕН
      'paywall_show_trial': true,
      'trial_duration_days': 7,
      'trial_enabled': true,
      
      // Цены для годовой подписки
      'price_annual': 9.99,
      'price_annual_original': 16.99,
      'price_annual_discount': 41,
      'price_annual_currency': '\$',
      'price_annual_period': 'в год',
      
      // Цены для месячной подписки  
      'price_monthly': 1.99,
      'price_monthly_currency': '\$',
      'price_monthly_period': 'в месяц',
      
      // Цена единоразовой покупки
      'price_lifetime': 24.99,
      'price_lifetime_currency': '\$',
      
      // Тексты пейвола
      'paywall_title': 'FoodCoach PRO',
      'paywall_subtitle': 'Стань героем водного баланса!',
      'paywall_button_text': 'Продолжить',
      'paywall_trial_text': 'Попробуйте 7 дней бесплатно',
      'paywall_cancel_text': 'Отменить можно в любое время',
      'paywall_best_value_text': 'ВЫГОДНО',
      'paywall_lifetime_text': 'Доступ навсегда',
      'paywall_lifetime_subtitle': 'без повторных платежей',
      
      // 🔧 Фич флаги для PRO функций
      'feature_smart_reminders': true,
      'feature_weekly_reports': true,
      'feature_csv_export': true,
      'feature_cloud_sync': true,
      'feature_contextual_reminders': true,
      'feature_heat_protocols': true,
      
      // 📊 SDK паблишера (Релиз 3)
      'publisher_sdk_enabled': false,
      'appsflyer_enabled': false,
      'sanctioned_countries': '["RU", "BY", "CN", "IR", "KP"]', // JSON строка
      
      // 🎯 A/B тестирование
      'ab_paywall_variant': 'default',
      'ab_onboarding_variant': 'standard',
      
      // � АЛКОГОЛЬ параметры
      'std_drink_grams': 10.0,
      'alcohol_drink_bonus_ml': 250.0,
      'na_per_sd_mg': 500.0,
      'mg_per_day_after_alc_mg': 100.0,
      'alc_evening_cutoff_local': 20, // 20:00
      'alc_reminders_max_per_day': 2,
      'sobriety_goals_enabled': true,
      'sober_mode_enabled_default': false,
      
      // 🍬 САХАР параметры (НОВОЕ)
      'max_daily_sugar_grams': 25.0,           // Рекомендация ВОЗ для добавленного сахара
      'sugar_warning_threshold_grams': 50.0,   // Порог для предупреждений в уведомлениях
      
      // Влияние на HRI
      'sugar_hri_threshold_grams': 50.0,       // Порог, после которого начинается влияние на HRI
      'sugar_hri_multiplier': 0.2,             // Множитель для расчета влияния
      'sugar_hri_max_impact': 10.0,            // Максимальное влияние сахара на HRI
      
      // Содержание сахара в напитках (г/100мл)
      'sugar_juice_per_100ml': 12.0,           // Фруктовый сок
      'sugar_soda_per_100ml': 10.0,            // Газировка
      'sugar_energy_per_100ml': 11.0,          // Энергетические напитки
      'sugar_sports_per_100ml': 6.0,           // Спортивные напитки
      'sugar_beer_per_100ml': 1.0,             // Пиво
      'sugar_wine_per_100ml': 2.0,             // Вино
      'sugar_cocktail_per_100ml': 15.0,        // Коктейли
      'sugar_kombucha_per_100ml': 3.0,         // Комбуча
      
      // Содержание сахара в кофе и чае
      'sugar_coffee_milk_base': 5.0,           // Базовый сахар от молока в латте/капучино
      'sugar_coffee_syrup': 10.0,              // Дополнительный сахар от сиропа
      'sugar_sweet_tea': 8.0,                  // Сладкий чай (на порцию)
      
      // Содержание сахара в других продуктах
      'sugar_smoothie_per_250ml': 20.0,        // Смузи (на 250мл)
      'sugar_protein_shake': 5.0,              // Протеиновый коктейль (на порцию)
      'sugar_fruit_serving': 10.0,             // Фрукты (средняя порция)
      'sugar_yogurt_lactose': 5.0,             // Натуральный йогурт (лактоза)
      'sugar_yogurt_flavored': 10.0,           // Ароматизированный йогурт (добавленный)
      
      // Скрытые сахара
      'sugar_sauce_average': 5.0,              // Соусы (средняя порция)
      'sugar_bread_serving': 3.0,              // Хлеб (порция)
      'sugar_dessert_average': 20.0,           // Десерты (средняя порция)
      'sugar_snack_average': 10.0,             // Снеки (средняя порция)
      'sugar_meal_hidden': 5.0,                // Скрытый сахар в обычной еде
      
      // Визуальные пороги для UI
      'sugar_green_threshold': 25.0,           // До этого значения - зеленый цвет
      'sugar_yellow_threshold': 50.0,          // До этого значения - желтый цвет
      'sugar_orange_threshold': 75.0,          // До этого значения - оранжевый цвет
      
      // Корректировки воды при высоком сахаре
      'sugar_water_bonus_25_50': 250,          // Дополнительная вода при 25-50г сахара (мл)
      'sugar_water_bonus_50_75': 500,          // Дополнительная вода при 50-75г сахара (мл)
      'sugar_water_bonus_above_75': 750,       // Дополнительная вода при >75г сахара (мл)
    };
  }
  
  /// Получение значения с проверкой инициализации
  T _getValue<T>(String key, T defaultValue) {
    if (!_initialized || _remoteConfig == null) {
      return defaultValue;
    }
    
    try {
      if (T == String) {
        return _remoteConfig!.getString(key) as T;
      } else if (T == int) {
        return _remoteConfig!.getInt(key) as T;
      } else if (T == double) {
        return _remoteConfig!.getDouble(key) as T;
      } else if (T == bool) {
        return _remoteConfig!.getBool(key) as T;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Ошибка получения параметра $key: $e');
      }
    }
    
    return defaultValue;
  }
  
  // 📊 МЕТОДЫ ДЛЯ HRI СЕРВИСА
  
  // Универсальный метод для получения double значений
  double getDouble(String key) {
    final defaults = _getDefaults();
    final defaultValue = defaults[key] ?? 0.0;
    return _getValue<double>(key, defaultValue is double ? defaultValue : defaultValue.toDouble());
  }
  
  // Универсальный метод для получения int значений
  int getInt(String key) {
    final defaults = _getDefaults();
    final defaultValue = defaults[key] ?? 0;
    return _getValue<int>(key, defaultValue is int ? defaultValue : defaultValue.toInt());
  }
  
  // Универсальный метод для получения bool значений
  bool getBool(String key) {
    final defaults = _getDefaults();
    final defaultValue = defaults[key] ?? false;
    return _getValue<bool>(key, defaultValue is bool ? defaultValue : false);
  }
  
  // Универсальный метод для получения String значений
  String getString(String key) {
    final defaults = _getDefaults();
    final defaultValue = defaults[key] ?? '';
    return _getValue<String>(key, defaultValue.toString());
  }
  
  // Веса компонентов HRI (сумма = 100)
  double getHRIWaterWeight() => _getValue('hri_weight_water', 26.0);
  double getHRISodiumWeight() => _getValue('hri_weight_sodium', 12.0);
  double getHRIPotassiumWeight() => _getValue('hri_weight_potassium', 8.0);
  double getHRIMagnesiumWeight() => _getValue('hri_weight_magnesium', 8.0);
  double getHRIHeatWeight() => _getValue('hri_weight_heat', 10.0);
  double getHRIWorkoutWeight() => _getValue('hri_weight_workout', 12.0);
  double getHRICaffeineWeight() => _getValue('hri_weight_caffeine', 8.0);
  double getHRIAlcoholWeight() => _getValue('hri_weight_alcohol', 8.0);
  double getHRITimeWeight() => _getValue('hri_weight_time', 4.0);
  double getHRIMorningWeight() => _getValue('hri_weight_morning', 4.0);
  
  // Параметры расчета HRI
  double getCaffeineHalfLife() => _getValue('caffeine_half_life_hours', 6.0);
  double getCaffeineScaleFactor() => _getValue('caffeine_scale_factor', 2.0);
  double getAlcoholRiskHalfLife() => _getValue('alcohol_risk_half_life_hours', 4.0);
  double getAlcoholHRIRiskPerSD() => _getValue('alc_hri_risk_per_sd', 5.0);
  double getAlcoholHRIRiskCap() => _getValue('alc_hri_risk_cap', 15.0);
  double getTimeSinceLastIntakeThreshold() => _getValue('time_since_last_intake_threshold', 3.0);
  bool getFastingSuppressesTimeComponent() => _getValue('fasting_suppresses_time_component', true);
  double getMorningWeightDropThreshold() => _getValue('morning_weight_drop_threshold', 1.0);
  double getHeatIndexHysteresis() => _getValue('heat_index_hysteresis', 0.5);
  
  // Пороги Heat Index для HRI
  double getHeatIndexLowThreshold() => _getValue('heat_index_low', 27.0);
  double getHeatIndexMediumThreshold() => _getValue('heat_index_medium', 32.0);
  double getHeatIndexHighThreshold() => _getValue('heat_index_high', 39.0);
  
  // 🔥 ФОРМУЛЫ ВОДЫ
  double get waterMinPerKg => _getValue('water_min_per_kg', 22.0);
  double get waterOptPerKg => _getValue('water_opt_per_kg', 30.0);
  double get waterMaxPerKg => _getValue('water_max_per_kg', 36.0);
  
  // ⚡ ЭЛЕКТРОЛИТЫ
  int get sodiumNormal => _getValue('sodium_normal', 2500);
  int get sodiumKeto => _getValue('sodium_keto', 3500);
  int get potassiumNormal => _getValue('potassium_normal', 3000);
  int get potassiumKeto => _getValue('potassium_keto', 3500);
  int get magnesiumNormal => _getValue('magnesium_normal', 350);
  int get magnesiumKeto => _getValue('magnesium_keto', 400);
  
  // 🌡️ HEAT INDEX ПОРОГИ
  double get heatIndexLow => _getValue('heat_index_low', 27.0);
  double get heatIndexMedium => _getValue('heat_index_medium', 32.0);
  double get heatIndexHigh => _getValue('heat_index_high', 39.0);
  
  double get heatWaterAdjustmentLow => _getValue('heat_water_adjustment_low', 0.05);
  double get heatWaterAdjustmentMedium => _getValue('heat_water_adjustment_medium', 0.08);
  double get heatWaterAdjustmentHigh => _getValue('heat_water_adjustment_high', 0.12);
  
  int get heatSodiumAdjustmentLow => _getValue('heat_sodium_adjustment_low', 500);
  int get heatSodiumAdjustmentMedium => _getValue('heat_sodium_adjustment_medium', 1000);
  int get heatSodiumAdjustmentHigh => _getValue('heat_sodium_adjustment_high', 1500);
  
  // 📊 ПОРОГИ СТАТУСОВ
  double get dehydrationThreshold => _getValue('hydration_dehydration_threshold', 0.9);
  double get dilutionWaterThreshold => _getValue('hydration_dilution_water_threshold', 1.15);
  double get dilutionSodiumThreshold => _getValue('hydration_dilution_sodium_threshold', 0.6);
  double get lowSaltThreshold => _getValue('hydration_low_salt_threshold', 0.5);
  
  // 🔔 УВЕДОМЛЕНИЯ
  int get maxFreeReminders => _getValue('max_free_reminders', 4);
  int get coffeeReminderDelayMinutes => _getValue('coffee_reminder_delay_minutes', 45);
  int get reminderSpamProtectionHours => _getValue('reminder_spam_protection_hours', 1);
  int get reminderDailyLimit => _getValue('reminder_daily_limit', 8);
  
  // ⏰ ТИХИЕ ЧАСЫ
  int get quietHoursStart => _getValue('quiet_hours_start', 22);
  int get quietHoursEnd => _getValue('quiet_hours_end', 7);
  
  // 🍽️ FASTING AWARE
  bool get fastingAwareEnabled => _getValue('fasting_aware_enabled', true);
  bool get fastingElectrolyteReminderEnabled => _getValue('fasting_electrolyte_reminder_enabled', true);
  bool get fastingRefeedingLadderEnabled => _getValue('fasting_refeeding_ladder_enabled', true);
  
  // 💰 ПОДПИСКА И ЦЕНЫ
  bool get paywallShowTrial => _getValue('paywall_show_trial', true);
  bool get trialEnabled => _getValue('trial_enabled', true);
  int get trialDurationDays => _getValue('trial_duration_days', 7);
  
  // Getters для цен (возвращаем базовые значения, форматирование делаем в UI)
  double get priceAnnual => _getValue('price_annual', 9.99);
  double get priceAnnualOriginal => _getValue('price_annual_original', 16.99);
  int get priceAnnualDiscount => _getValue('price_annual_discount', 41);
  String get priceAnnualCurrency => _getValue('price_annual_currency', 'USD');
  String get priceAnnualPeriod => _getValue('price_annual_period', 'year');
  
  double get priceMonthly => _getValue('price_monthly', 1.99);
  String get priceMonthlyCurrency => _getValue('price_monthly_currency', 'USD');
  String get priceMonthlyPeriod => _getValue('price_monthly_period', 'month');
  
  double get priceLifetime => _getValue('price_lifetime', 24.99);
  String get priceLifetimeCurrency => _getValue('price_lifetime_currency', 'USD');
  
  // Тексты пейвола (базовые английские значения)
  String get paywallTitle => _getValue('paywall_title', 'FoodCoach PRO');
  String get paywallSubtitle => _getValue('paywall_subtitle', 'Become a hydration hero!');
  String get paywallButtonText => _getValue('paywall_button_text', 'Continue');
  String get paywallTrialText => _getValue('paywall_trial_text', 'Try 7 days free');
  String get paywallCancelText => _getValue('paywall_cancel_text', 'Cancel anytime');
  String get paywallBestValueText => _getValue('paywall_best_value_text', 'BEST VALUE');
  String get paywallLifetimeText => _getValue('paywall_lifetime_text', 'Lifetime access');
  String get paywallLifetimeSubtitle => _getValue('paywall_lifetime_subtitle', 'no recurring payments');
  
  // 🔧 ФИЧ ФЛАГИ
  bool get featureSmartReminders => _getValue('feature_smart_reminders', true);
  bool get featureWeeklyReports => _getValue('feature_weekly_reports', true);
  bool get featureCsvExport => _getValue('feature_csv_export', true);
  bool get featureCloudSync => _getValue('feature_cloud_sync', true);
  bool get featureContextualReminders => _getValue('feature_contextual_reminders', true);
  bool get featureHeatProtocols => _getValue('feature_heat_protocols', true);
  
  // 📊 SDK ПАБЛИШЕРА
  bool get publisherSdkEnabled => _getValue('publisher_sdk_enabled', false);
  bool get appsflyerEnabled => _getValue('appsflyer_enabled', false);
  
  List<String> get sanctionedCountries {
    try {
      final jsonString = _getValue('sanctioned_countries', '["RU", "BY", "CN", "IR", "KP"]');
      // В реальном приложении здесь должен быть парсинг JSON
      // Для простоты возвращаем статичный список
      return ['RU', 'BY', 'CN', 'IR', 'KP'];
    } catch (e) {
      return ['RU', 'BY', 'CN', 'IR', 'KP'];
    }
  }
  
  // 🎯 A/B ТЕСТИРОВАНИЕ
  String get abPaywallVariant => _getValue('ab_paywall_variant', 'default');
  String get abOnboardingVariant => _getValue('ab_onboarding_variant', 'standard');
  
  /// Принудительное обновление конфигурации
  Future<bool> forceRefresh() async {
    if (!_initialized || _remoteConfig == null) {
      return false;
    }
    
    try {
      await _remoteConfig!.fetchAndActivate();
      
      if (kDebugMode) {
        print('🔄 Remote Config обновлен принудительно');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка принудительного обновления: $e');
      }
      return false;
    }
  }
  
  /// Получение всех параметров (для отладки)
  Map<String, RemoteConfigValue> getAllParameters() {
    if (!_initialized || _remoteConfig == null) {
      return {};
    }
    
    return _remoteConfig!.getAll();
  }
  
  /// Расчет корректировки воды по Heat Index
  HeatAdjustments calculateHeatAdjustments(double heatIndex) {
    if (heatIndex < heatIndexLow) {
      return HeatAdjustments(0.0, 0); // Нет корректировок
    } else if (heatIndex < heatIndexMedium) {
      return HeatAdjustments(heatWaterAdjustmentLow, heatSodiumAdjustmentLow);
    } else if (heatIndex < heatIndexHigh) {
      return HeatAdjustments(heatWaterAdjustmentMedium, heatSodiumAdjustmentMedium);
    } else {
      return HeatAdjustments(heatWaterAdjustmentHigh, heatSodiumAdjustmentHigh);
    }
  }
}