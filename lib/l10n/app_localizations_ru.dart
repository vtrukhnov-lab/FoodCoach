// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HydraCoach';

  @override
  String get getPro => 'Получить PRO';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get january => 'Январь';

  @override
  String get february => 'Февраль';

  @override
  String get march => 'Март';

  @override
  String get april => 'Апрель';

  @override
  String get may => 'Май';

  @override
  String get june => 'Июнь';

  @override
  String get july => 'Июль';

  @override
  String get august => 'Август';

  @override
  String get september => 'Сентябрь';

  @override
  String get october => 'Октябрь';

  @override
  String get november => 'Ноябрь';

  @override
  String get december => 'Декабрь';

  @override
  String dateFormat(String weekday, int day, String month) {
    return '$weekday, $day $month';
  }

  @override
  String get loading => 'Загрузка...';

  @override
  String get loadingWeather => 'Загрузка погоды...';

  @override
  String get heatIndex => 'Индекс жары';

  @override
  String humidity(int value) {
    return 'Влажность: $value%';
  }

  @override
  String get water => 'Вода';

  @override
  String get sodium => 'Натрий';

  @override
  String get potassium => 'Калий';

  @override
  String get magnesium => 'Магний';

  @override
  String get electrolyte => 'Электролиты';

  @override
  String get broth => 'Бульон';

  @override
  String get coffee => 'Кофе';

  @override
  String get alcohol => 'Алкоголь';

  @override
  String get drink => 'Напиток';

  @override
  String get ml => 'мл';

  @override
  String get mg => 'мг';

  @override
  String get kg => 'кг';

  @override
  String valueWithUnit(int value, String unit) {
    return '$value $unit';
  }

  @override
  String goalFormat(int current, int goal, String unit) {
    return '$current/$goal $unit';
  }

  @override
  String heatAdjustment(int percent) {
    return 'Жара +$percent%';
  }

  @override
  String alcoholAdjustment(int amount) {
    return 'Алкоголь +$amount мл';
  }

  @override
  String get smartAdviceTitle => 'Совет на сейчас';

  @override
  String get smartAdviceDefault => 'Поддерживайте баланс воды и электролитов.';

  @override
  String get adviceOverhydrationSevere => 'Перегидратация (>200% цели)';

  @override
  String get adviceOverhydrationSevereBody =>
      'Пауза 60-90 минут. Добавьте электролиты: 300-500 мл с 500-1000 мг натрия.';

  @override
  String get adviceOverhydration => 'Перегидратация';

  @override
  String get adviceOverhydrationBody =>
      'Пауза с водой на 30-60 минут и добавьте ~500 мг натрия (электролиты/бульон).';

  @override
  String get adviceAlcoholRecovery => 'Алкоголь: восстановление';

  @override
  String get adviceAlcoholRecoveryBody =>
      'Больше никакого алкоголя сегодня. Пейте 300-500 мл воды маленькими порциями и добавьте натрий.';

  @override
  String get adviceLowSodium => 'Мало натрия';

  @override
  String adviceLowSodiumBody(int amount) {
    return 'Добавьте ~$amount мг натрия. Пейте умеренно.';
  }

  @override
  String get adviceDehydration => 'Недогидратация';

  @override
  String adviceDehydrationBody(String type) {
    return 'Выпейте 300-500 мл $type.';
  }

  @override
  String get adviceHighRisk => 'Высокий риск (HRI)';

  @override
  String get adviceHighRiskBody =>
      'Срочно пейте воду с электролитами (300-500 мл) и снизьте активность.';

  @override
  String get adviceHeat => 'Жара и потери';

  @override
  String get adviceHeatBody =>
      'Увеличьте воду на +5-8% и добавьте 300-500 мг натрия.';

  @override
  String get adviceAllGood => 'Всё идёт по плану';

  @override
  String adviceAllGoodBody(int amount) {
    return 'Держите темп. Цель: ещё ~$amount мл до цели.';
  }

  @override
  String get hydrationStatus => 'Статус гидратации';

  @override
  String get hydrationStatusNormal => 'Норма';

  @override
  String get hydrationStatusDiluted => 'Разбавляете';

  @override
  String get hydrationStatusDehydrated => 'Недогидратация';

  @override
  String get hydrationStatusLowSalt => 'Мало соли';

  @override
  String get hydrationRiskIndex => 'Индекс риска гидратации';

  @override
  String get quickAdd => 'Быстрое добавление';

  @override
  String get add => 'Добавить';

  @override
  String get delete => 'Удалить';

  @override
  String get todaysDrinks => 'Напитки сегодня';

  @override
  String get allRecords => 'Все записи →';

  @override
  String itemDeleted(String item) {
    return '$item удалено';
  }

  @override
  String get undo => 'Отменить';

  @override
  String get dailyReportReady => 'Дневной отчёт готов!';

  @override
  String get viewDayResults => 'Посмотреть результаты дня';

  @override
  String get dailyReportComingSoon =>
      'Дневной отчёт будет доступен в следующей версии';

  @override
  String get home => 'Главная';

  @override
  String get history => 'История';

  @override
  String get settings => 'Настройки';

  @override
  String get cancel => 'Отменить';

  @override
  String get save => 'Сохранить';

  @override
  String get reset => 'Сбросить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageSection => 'Язык';

  @override
  String get languageSettings => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get profileSection => 'Профиль';

  @override
  String get weight => 'Вес';

  @override
  String get dietMode => 'Режим питания';

  @override
  String get activityLevel => 'Уровень активности';

  @override
  String get changeWeight => 'Изменить вес';

  @override
  String get dietModeNormal => 'Обычное питание';

  @override
  String get dietModeKeto => 'Кето / Низкоуглеводная';

  @override
  String get dietModeFasting => 'Интервальное голодание';

  @override
  String get activityLow => 'Низкая активность';

  @override
  String get activityMedium => 'Средняя активность';

  @override
  String get activityHigh => 'Высокая активность';

  @override
  String get activityLowDesc => 'Офисная работа, малое движение';

  @override
  String get activityMediumDesc => '30-60 минут упражнений в день';

  @override
  String get activityHighDesc => 'Тренировки >1 часа';

  @override
  String get notificationsSection => 'Уведомления';

  @override
  String get notificationLimit => 'Лимит уведомлений (FREE)';

  @override
  String notificationUsage(int used, int limit) {
    return 'Использовано: $used из $limit';
  }

  @override
  String get waterReminders => 'Напоминания о воде';

  @override
  String get waterRemindersDesc => 'Регулярные напоминания в течение дня';

  @override
  String get reminderFrequency => 'Частота напоминаний';

  @override
  String timesPerDay(int count) {
    return '$count раз в день';
  }

  @override
  String maxTimesPerDay(int count) {
    return '$count раз в день (макс 4)';
  }

  @override
  String get unlimitedReminders => 'Без ограничений';

  @override
  String get startOfDay => 'Начало дня';

  @override
  String get endOfDay => 'Конец дня';

  @override
  String get postCoffeeReminders => 'Напоминания после кофе';

  @override
  String get postCoffeeRemindersDesc => 'Напомнить пить воду через 20 минут';

  @override
  String get heatWarnings => 'Предупреждения о жаре';

  @override
  String get heatWarningsDesc => 'Уведомления при высокой температуре';

  @override
  String get postAlcoholReminders => 'Напоминания после алкоголя';

  @override
  String get postAlcoholRemindersDesc => 'План восстановления на 6-12 часов';

  @override
  String get proFeaturesSection => 'PRO функции';

  @override
  String get unlockPro => 'Разблокировать PRO';

  @override
  String get unlockProDesc => 'Без ограничений уведомлений и умные напоминания';

  @override
  String get noNotificationLimit => 'Без лимита уведомлений';

  @override
  String get unitsSection => 'Единицы измерения';

  @override
  String get metricSystem => 'Метрическая система';

  @override
  String get metricUnits => 'мл, кг, °C';

  @override
  String get imperialSystem => 'Имперская система';

  @override
  String get imperialUnits => 'унции, фунты, °F';

  @override
  String get aboutSection => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get rateApp => 'Оценить приложение';

  @override
  String get share => 'Поделиться';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get resetAllData => 'Сбросить все данные';

  @override
  String get resetDataTitle => 'Сбросить все данные?';

  @override
  String get resetDataMessage =>
      'Это удалит всю историю и восстановит настройки по умолчанию.';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get start => 'Начать';

  @override
  String get welcomeTitle => 'Добро пожаловать в\nHydraCoach';

  @override
  String get welcomeSubtitle =>
      'Умное отслеживание воды и электролитов\nдля кето, поста и активной жизни';

  @override
  String get weightPageTitle => 'Ваш вес';

  @override
  String get weightPageSubtitle => 'Для расчёта оптимального количества воды';

  @override
  String weightUnit(int weight) {
    return '$weight кг';
  }

  @override
  String recommendedNorm(int min, int max) {
    return 'Рекомендуемая норма: $min-$max мл воды в день';
  }

  @override
  String get dietPageTitle => 'Режим питания';

  @override
  String get dietPageSubtitle => 'Это влияет на потребности в электролитах';

  @override
  String get normalDiet => 'Обычное питание';

  @override
  String get normalDietDesc => 'Стандартные рекомендации';

  @override
  String get ketoDiet => 'Кето / Низкоуглеводная';

  @override
  String get ketoDietDesc => 'Повышенная потребность в соли';

  @override
  String get fastingDiet => 'Интервальное голодание';

  @override
  String get fastingDietDesc => 'Особый режим электролитов';

  @override
  String get fastingSchedule => 'График голодания:';

  @override
  String get fasting16_8 => '16:8';

  @override
  String get fasting16_8Desc => 'Ежедневное 8-часовое окно';

  @override
  String get fastingOMAD => 'OMAD';

  @override
  String get fastingOMADDesc => 'Один приём пищи в день';

  @override
  String get fastingADF => 'ADF';

  @override
  String get fastingADFDesc => 'Голодание через день';

  @override
  String get activityPageTitle => 'Уровень активности';

  @override
  String get activityPageSubtitle => 'Влияет на потребности в воде';

  @override
  String get lowActivity => 'Низкая активность';

  @override
  String get lowActivityDesc => 'Офисная работа, малое движение';

  @override
  String get lowActivityWater => '+0 мл воды';

  @override
  String get mediumActivity => 'Средняя активность';

  @override
  String get mediumActivityDesc => '30-60 минут упражнений в день';

  @override
  String get mediumActivityWater => '+350-700 мл воды';

  @override
  String get highActivity => 'Высокая активность';

  @override
  String get highActivityDesc => 'Тренировки >1 часа или физический труд';

  @override
  String get highActivityWater => '+700-1200 мл воды';

  @override
  String get activityAdjustmentNote =>
      'Мы будем корректировать цели на основе ваших тренировок';

  @override
  String get day => 'День';

  @override
  String get week => 'Неделя';

  @override
  String get month => 'Месяц';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get noData => 'Нет данных';

  @override
  String get noRecordsToday => 'Сегодня записей пока нет';

  @override
  String get noRecordsThisDay => 'В этот день записей нет';

  @override
  String get loadingData => 'Загрузка данных...';

  @override
  String get deleteRecord => 'Удалить запись?';

  @override
  String deleteRecordMessage(String type, int volume) {
    return 'Удалить $type $volume мл?';
  }

  @override
  String get recordDeleted => 'Запись удалена';

  @override
  String get waterConsumption => '💧 Потребление воды';

  @override
  String get alcoholWeek => '🍺 Алкоголь за неделю';

  @override
  String get electrolytes => '⚡ Электролиты';

  @override
  String get weeklyAverages => '📊 Недельные средние';

  @override
  String get monthStatistics => '📊 Статистика месяца';

  @override
  String get alcoholStatistics => '🍺 Статистика алкоголя';

  @override
  String get alcoholStatisticsTitle => 'Статистика алкоголя';

  @override
  String get weeklyInsights => '💡 Недельные инсайты';

  @override
  String get waterPerDay => 'Воды в день';

  @override
  String get sodiumPerDay => 'Натрия в день';

  @override
  String get potassiumPerDay => 'Калия в день';

  @override
  String get magnesiumPerDay => 'Магния в день';

  @override
  String get goal => 'Цель';

  @override
  String get daysWithGoalAchieved => '✅ Дней с достигнутой целью';

  @override
  String get recordsPerDay => '📝 Записей в день';

  @override
  String get insufficientDataForAnalysis => 'Недостаточно данных для анализа';

  @override
  String get totalVolume => 'Общий объём';

  @override
  String averagePerDay(int amount) {
    return 'В среднем $amount мл/день';
  }

  @override
  String get activeDays => 'Активные дни';

  @override
  String perfectDays(int count) {
    return 'Дней с идеальной целью: $count';
  }

  @override
  String currentStreak(int days) {
    return 'Текущая серия: $days дней';
  }

  @override
  String soberDaysRow(int days) {
    return 'Трезвых дней подряд: $days';
  }

  @override
  String get keepItUp => 'Так держать!';

  @override
  String waterAmount(int amount, int percent) {
    return 'Вода: $amount мл ($percent%)';
  }

  @override
  String alcoholAmount(String amount) {
    return 'Алкоголь: $amount SD';
  }

  @override
  String get totalSD => 'Всего SD';

  @override
  String get forMonth => 'за месяц';

  @override
  String get daysWithAlcohol => 'Дней с алкоголем';

  @override
  String fromDays(int days) {
    return 'из $days';
  }

  @override
  String get soberDays => 'Трезвые дни';

  @override
  String get excellent => 'отлично!';

  @override
  String get averageSD => 'Средний SD';

  @override
  String get inDrinkingDays => 'в дни употребления';

  @override
  String get bestDay => '🏆 Лучший день';

  @override
  String bestDayMessage(String day, int percent) {
    return '$day - $percent% от цели';
  }

  @override
  String get weekends => '📅 Выходные';

  @override
  String get weekdays => '📅 Будни';

  @override
  String drinkLessOnWeekends(int percent) {
    return 'В выходные вы пьёте на $percent% меньше';
  }

  @override
  String drinkLessOnWeekdays(int percent) {
    return 'В будни вы пьёте на $percent% меньше';
  }

  @override
  String get positiveTrend => '📈 Позитивная тенденция';

  @override
  String get positiveTrendMessage =>
      'Ваша гидратация улучшается к концу недели';

  @override
  String get decliningActivity => '📉 Снижение активности';

  @override
  String get decliningActivityMessage =>
      'Потребление воды снижается к концу недели';

  @override
  String get lowSalt => '⚠️ Мало соли';

  @override
  String lowSaltMessage(int days) {
    return 'Только $days дней с нормальным уровнем натрия';
  }

  @override
  String get frequentAlcohol => '🍺 Частое употребление';

  @override
  String frequentAlcoholMessage(int days) {
    return 'Алкоголь $days дней из 7 влияет на гидратацию';
  }

  @override
  String get excellentWeek => '✅ Отличная неделя';

  @override
  String get continueMessage => 'Продолжайте в том же духе!';

  @override
  String get all => 'Все';

  @override
  String get addAlcohol => 'Добавить алкоголь';

  @override
  String get minimumHarm => 'Минимум вреда';

  @override
  String additionalWaterNeeded(int amount) {
    return '+$amount мл воды нужно';
  }

  @override
  String additionalSodiumNeeded(int amount) {
    return '+$amount мг натрия добавить';
  }

  @override
  String get goToBedEarly => 'Лечь спать пораньше';

  @override
  String get todayConsumed => 'Сегодня употреблено:';

  @override
  String get alcoholToday => 'Алкоголь сегодня';

  @override
  String get beer => 'Пиво';

  @override
  String get wine => 'Вино';

  @override
  String get spirits => 'Крепкие напитки';

  @override
  String get cocktail => 'Коктейль';

  @override
  String get selectDrinkType => 'Выберите тип напитка:';

  @override
  String get volume => 'Объём (мл):';

  @override
  String get enterVolume => 'Введите объём в мл';

  @override
  String get strength => 'Крепость (%):';

  @override
  String get standardDrinks => 'Стандартные дринки:';

  @override
  String get additionalWater => 'Доп. вода';

  @override
  String get additionalSodium => 'Доп. натрий';

  @override
  String get hriRisk => 'Риск HRI';

  @override
  String get enterValidVolume => 'Пожалуйста, введите корректный объём';

  @override
  String get weeklyHistory => 'Недельная история';

  @override
  String get weeklyHistoryDesc =>
      'Анализ недельных трендов, инсайты и рекомендации';

  @override
  String get monthlyHistory => 'Месячная история';

  @override
  String get monthlyHistoryDesc =>
      'Долгосрочные паттерны, сравнение недель и глубокая аналитика';

  @override
  String get proFunction => 'PRO функция';

  @override
  String get unlockProHistory => 'Разблокировать PRO';

  @override
  String get unlimitedHistory => 'Безлимитная история';

  @override
  String get dataExportCSV => 'Экспорт данных в CSV';

  @override
  String get detailedAnalytics => 'Детальная аналитика';

  @override
  String get periodComparison => 'Сравнение периодов';

  @override
  String get shareResult => 'Поделиться результатом';

  @override
  String get retry => 'Повторить';

  @override
  String get welcomeToPro => 'Добро пожаловать в PRO!';

  @override
  String get allFeaturesUnlocked => 'Все функции разблокированы';

  @override
  String get testMode => 'Тестовый режим: Используется мок-покупка';

  @override
  String get proStatusNote => 'PRO статус сохранится до перезапуска приложения';

  @override
  String get startUsingPro => 'Начать использовать PRO';

  @override
  String get lifetimeAccess => 'Пожизненный доступ';

  @override
  String get bestValueAnnual => 'Лучшая цена — Годовая';

  @override
  String get monthly => 'Месячная';

  @override
  String get oneTime => 'разовый';

  @override
  String get perYear => '/год';

  @override
  String get perMonth => '/мес';

  @override
  String approximatelyPerMonth(String amount) {
    return '≈ $amount/мес';
  }

  @override
  String get startFreeTrial => 'Начать 7-дневную пробную версию';

  @override
  String continueWithPrice(String price) {
    return 'Продолжить — $price';
  }

  @override
  String unlockForPrice(String price) {
    return 'Разблокировать за $price (разовый)';
  }

  @override
  String get enableFreeTrial => 'Включить 7-дневную пробную версию';

  @override
  String get noChargeToday =>
      'Никаких списаний сегодня. Через 7 дней ваша подписка автоматически продлится, если не отменить.';

  @override
  String get cancelAnytime => 'Вы можете отменить в любое время в Настройках.';

  @override
  String get everythingInPro => 'Всё в PRO';

  @override
  String get smartReminders => 'Умные напоминания';

  @override
  String get smartRemindersDesc => 'Жара, тренировки, пост — без спама.';

  @override
  String get weeklyReports => 'Недельные отчёты';

  @override
  String get weeklyReportsDesc => 'Глубокие инсайты + экспорт CSV.';

  @override
  String get healthIntegrations => 'Интеграции здоровья';

  @override
  String get healthIntegrationsDesc => 'Apple Health и Google Fit.';

  @override
  String get alcoholProtocols => 'Алкогольные протоколы';

  @override
  String get alcoholProtocolsDesc => 'Подготовка до и план восстановления.';

  @override
  String get fullSync => 'Полная синхронизация';

  @override
  String get fullSyncDesc => 'Безлимитная история на всех устройствах.';

  @override
  String get personalCalibrations => 'Персональные калибровки';

  @override
  String get personalCalibrationsDesc => 'Тест пота, шкала цвета мочи.';

  @override
  String get showAllFeatures => 'Показать все функции';

  @override
  String get showLess => 'Показать меньше';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get proSubscriptionRestored => 'PRO подписка восстановлена!';

  @override
  String get noPurchasesToRestore => 'Покупок для восстановления не найдено';

  @override
  String get drinkMoreWaterToday => 'Пейте больше воды сегодня (+20%)';

  @override
  String get addElectrolytesToWater =>
      'Добавляйте электролиты в каждый приём воды';

  @override
  String get limitCoffeeOneCup => 'Ограничьте кофе одной чашкой';

  @override
  String get increaseWater10 => 'Увеличьте воду на 10%';

  @override
  String get dontForgetElectrolytes => 'Не забывайте об электролитах';

  @override
  String get startDayWithWater => 'Начните день со стакана воды';

  @override
  String get dontForgetElectrolytesReminder => '⚡ Не забывайте об электролитах';

  @override
  String get startDayWithWaterReminder =>
      'Начните день со стакана воды для хорошего самочувствия';

  @override
  String get takeElectrolytesMorning => 'Принимайте электролиты утром';

  @override
  String purchaseFailed(String error) {
    return 'Покупка не удалась: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Восстановление не удалось: $error';
  }

  @override
  String get trustedByUsers => '⭐️ 4.9 — доверие 12,000 пользователей';

  @override
  String get bestValue => 'Лучшая цена';

  @override
  String percentOff(int percent) {
    return '-$percent% Лучшая цена';
  }

  @override
  String get weatherUnavailable => 'Погода недоступна';

  @override
  String get checkLocationPermissions =>
      'Проверьте разрешения геолокации и интернет';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String get weatherClear => 'ясно';

  @override
  String get weatherCloudy => 'облачно';

  @override
  String get weatherOvercast => 'пасмурно';

  @override
  String get weatherRain => 'дождь';

  @override
  String get weatherSnow => 'снег';

  @override
  String get weatherStorm => 'гроза';

  @override
  String get weatherFog => 'туман';

  @override
  String get weatherDrizzle => 'морось';

  @override
  String get weatherSunny => 'солнечно';

  @override
  String get heatWarningExtreme =>
      '☀️ Экстремальная жара! Максимальная гидратация';

  @override
  String get heatWarningVeryHot => '🌡️ Очень жарко! Риск обезвоживания';

  @override
  String get heatWarningHot => '🔥 Жарко! Пейте больше воды';

  @override
  String get heatWarningElevated => '⚠️ Повышенная температура';

  @override
  String get heatWarningComfortable => 'Комфортная температура';

  @override
  String adjustmentWater(int percent) {
    return '+$percent% воды';
  }

  @override
  String adjustmentSodium(int amount) {
    return '+$amount мг натрия';
  }

  @override
  String get heatWarningCold =>
      '❄️ Холодно! Согревайтесь и пейте тёплые жидкости';

  @override
  String get notificationChannelName => 'Напоминания HydraCoach';

  @override
  String get notificationChannelDescription =>
      'Напоминания о воде и электролитах';

  @override
  String get urgentNotificationChannelName => 'Срочные напоминания';

  @override
  String get urgentNotificationChannelDescription =>
      'Важные уведомления о гидратации';

  @override
  String get goodMorning => '☀️ Доброе утро!';

  @override
  String get timeToHydrate => '💧 Время гидратации';

  @override
  String get eveningHydration => '💧 Вечерняя гидратация';

  @override
  String get dailyReportTitle => '📊 Дневной отчёт готов';

  @override
  String get dailyReportBody => 'Посмотрите, как прошёл ваш день гидратации';

  @override
  String get maintainWaterBalance =>
      'Поддерживайте водный баланс в течение дня';

  @override
  String get electrolytesTime =>
      'Время для электролитов: добавьте щепотку соли в воду';

  @override
  String catchUpHydration(int percent) {
    return 'Вы выпили только $percent% дневной нормы. Время наверстать!';
  }

  @override
  String get excellentProgress => 'Отличный прогресс! Ещё немного до цели';

  @override
  String get postCoffeeTitle => '☕ После кофе';

  @override
  String get postCoffeeBody =>
      'Выпейте 250-300 мл воды для восстановления баланса';

  @override
  String get postWorkoutTitle => '💪 После тренировки';

  @override
  String get postWorkoutBody =>
      'Восстановите электролиты: 500 мл воды + щепотка соли';

  @override
  String get heatWarningPro => '🌡️ PRO Предупреждение о жаре';

  @override
  String get extremeHeatWarning =>
      'Экстремальная жара! Увеличьте потребление воды на 15% и добавьте 1г соли';

  @override
  String get hotWeatherWarning =>
      'Жарко! Пейте на 10% больше воды и не забывайте об электролитах';

  @override
  String get warmWeatherWarning => 'Тёплая погода. Следите за гидратацией';

  @override
  String get alcoholRecoveryTitle => '🍺 Время восстановления';

  @override
  String get alcoholRecoveryBody =>
      'Выпейте 300 мл воды со щепоткой соли для баланса';

  @override
  String get continueHydration => '💧 Продолжайте гидратацию';

  @override
  String get alcoholRecoveryBody2 =>
      'Ещё 500 мл воды помогут вам быстрее восстановиться';

  @override
  String get morningRecoveryTitle => '☀️ Утреннее восстановление';

  @override
  String get morningRecoveryBody => 'Начните день с 500 мл воды и электролитов';

  @override
  String get testNotificationTitle => '🧪 Тестовое уведомление';

  @override
  String get testNotificationBody =>
      'Если вы видите это - мгновенные уведомления работают!';

  @override
  String get scheduledTestTitle => '⏰ Запланированный тест (1 мин)';

  @override
  String get scheduledTestBody =>
      'Это уведомление было запланировано минуту назад. Планирование работает!';

  @override
  String get notificationServiceInitialized =>
      '✅ NotificationService инициализирован';

  @override
  String get localNotificationsInitialized =>
      '✅ Локальные уведомления инициализированы';

  @override
  String get androidChannelsCreated => '📢 Android каналы уведомлений созданы';

  @override
  String notificationsPermissionGranted(String granted) {
    return '📝 Разрешение уведомлений: $granted';
  }

  @override
  String exactAlarmsPermissionGranted(String granted) {
    return '📝 Разрешение точных будильников: $granted';
  }

  @override
  String fcmPermissions(String status) {
    return '📱 FCM разрешения: $status';
  }

  @override
  String get fcmTokenReceived => '🔑 FCM Токен получен';

  @override
  String fcmTokenSaved(String userId) {
    return '✅ FCM Токен сохранён в Firestore для пользователя $userId';
  }

  @override
  String get topicSubscriptionComplete => '✅ Подписка на тему завершена';

  @override
  String foregroundMessage(String title) {
    return '📨 Сообщение на переднем плане: $title';
  }

  @override
  String notificationOpened(String messageId) {
    return '📱 Уведомление открыто: $messageId';
  }

  @override
  String get dailyLimitReached =>
      '⚠️ Достигнут дневной лимит уведомлений (4/день для FREE)';

  @override
  String schedulingError(String error) {
    return '❌ Ошибка планирования уведомления: $error';
  }

  @override
  String get showingImmediatelyAsFallback =>
      'Показываем уведомление немедленно как резервный вариант';

  @override
  String instantNotificationShown(String title) {
    return '📬 Мгновенное уведомление показано: $title';
  }

  @override
  String get smartRemindersScheduled => '🧠 Планирование умных напоминаний...';

  @override
  String smartRemindersComplete(int count) {
    return '✅ Запланировано $count напоминаний';
  }

  @override
  String get proPostCoffeeScheduled =>
      '☕ PRO: Напоминание после кофе запланировано';

  @override
  String get postWorkoutScheduled =>
      '💪 Напоминание после тренировки запланировано';

  @override
  String get proHeatWarningPro => '🌡️ PRO: Предупреждение о жаре отправлено';

  @override
  String get proAlcoholRecoveryPlan =>
      '🍺 PRO: План восстановления после алкоголя запланирован';

  @override
  String eveningReportScheduled(int day, int month) {
    return '📊 Вечерний отчёт запланирован на $day.$month в 21:00';
  }

  @override
  String notificationCancelled(int id) {
    return '🚫 Уведомление $id отменено';
  }

  @override
  String get allNotificationsCancelled => '🗑️ Все уведомления отменены';

  @override
  String get reminderSettingsSaved => '✅ Настройки напоминаний сохранены';

  @override
  String testNotificationScheduledFor(String time) {
    return '⏰ Тестовое уведомление запланировано на $time';
  }

  @override
  String get tomorrowRecommendations => 'Рекомендации на завтра';

  @override
  String get recommendationExcellent =>
      'Отличная работа! Продолжайте в том же духе. Старайтесь начинать день со стакана воды и поддерживать равномерное потребление.';

  @override
  String get recommendationDiluted =>
      'Вы пьете много воды, но мало электролитов. Завтра добавьте больше соли или выпейте электролитный напиток. Попробуйте начать день с соленого бульона.';

  @override
  String get recommendationDehydrated =>
      'Недостаточно воды сегодня. Завтра поставьте напоминания каждые 2 часа. Держите бутылку воды на видном месте.';

  @override
  String get recommendationLowSalt =>
      'Низкий уровень натрия может вызвать усталость. Добавьте щепотку соли в воду или выпейте бульон. Особенно важно на кето или при голодании.';

  @override
  String get recommendationGeneral =>
      'Стремитесь к балансу воды и электролитов. Пейте равномерно в течение дня и не забывайте про соль в жару.';
}
