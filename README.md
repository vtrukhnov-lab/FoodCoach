# HydraCoach 💧

> Умный трекер гидратации и электролитного баланса для кето, интервального голодания и активного образа жизни

[![Version](https://img.shields.io/badge/version-0.3.0-blue.svg)](https://github.com/vtrukhnov-lab/HydraCoach)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🎯 О проекте

HydraCoach — персонализированный трекер баланса воды и электролитов с учётом контекстных факторов: режима питания (кето/пост), погодных условий, физической активности и бытовых триггеров (кофеин/алкоголь).

### Ключевые особенности:
- 📊 **Персональные цели** — вода + Na/K/Mg с учётом вашего профиля
- 🌡️ **Погодная адаптация** — автокоррекция целей по Heat Index
- 🍺 **Alcohol-Aware** — учёт алкоголя и восстановительные протоколы
- 📈 **HRI индекс** — комплексная оценка риска обезвоживания (0-100)
- ⏰ **Умные напоминания** — контекстные уведомления без спама
- 🥑 **Режимы питания** — оптимизация для кето, IF/OMAD/ADF
- 📱 **Подписка PRO** — расширенные функции через RevenueCat

## 📱 Скриншоты

<details>
<summary>Посмотреть интерфейс приложения</summary>

- Главный экран с кольцами прогресса
- Карточка погоды с корректировками
- Лог алкоголя и восстановление  
- История и аналитика
- Настройки и профиль

</details>

## 🏗️ Текущий статус разработки

### ✅ Реализовано (v0.3.0)

#### Основной функционал
- ✅ **Главный экран** — 3 кольца (Вода/Na/K) + индикатор Mg
- ✅ **Онбординг** — настройка профиля (вес, режим питания, активность)
- ✅ **Быстрый лог** — вода, электролиты, кофе
- ✅ **История** — день/неделя/месяц с графиками

#### Сервисы
- ✅ **Погода** — интеграция с API, Heat Index, автокоррекция целей
- ✅ **Уведомления** — базовые временные напоминания
- ✅ **Remote Config** — управление параметрами через Firebase

#### Алкоголь (базовый функционал)
- ✅ **Лог алкоголя** — тип/объём/ABV, пересчёт в стандартные дринки
- ✅ **Контр-коррекция** — автоматическая корректировка воды/Na
- ✅ **Утренний чек-ин** — оценка самочувствия

#### Инфраструктура  
- ✅ **Firebase** — Core, Auth, Firestore, Analytics, Remote Config, Crashlytics
- ✅ **RevenueCat** — интеграция для подписок
- ✅ **Пейвол** — экран монетизации

### 🚧 В разработке

#### Релиз 1 — Стабилизация ядра
- [ ] Полноценный расчёт HRI индекса (0-100)
- [ ] Статусы гидратации (норма/разбавление/недобор/мало соли)
- [ ] Дневные отчёты с инсайтами
- [ ] Экспорт CSV

#### Релиз 2 — PRO подписка
- [ ] Активация PRO-функций через RevenueCat
- [ ] Smart Reminders (жара/тренировка/выход из поста)
- [ ] Fasting-aware режимы (IF/OMAD/ADF)
- [ ] Workout/Heatwave протоколы
- [ ] Недельный PRO-отчёт
- [ ] Безлимитная синхронизация

#### Релиз 3 — Алкоголь PRO
- [ ] Pre-drink протокол (T-60/30/15)
- [ ] Recovery план на 6-12 часов
- [ ] Трезвый календарь и цели
- [ ] Расширенный утренний индекс

#### Релиз 4 — SDK издателя
- [ ] AppsFlyer интеграция
- [ ] Offerwall события
- [ ] ATT/CMP диалоги (iOS)
- [ ] Санкционные ограничения

#### Релиз 5 — Расширения
- [ ] Калибровки (тест потоотделения, цвет мочи)
- [ ] Интеграции Apple Health/Google Fit
- [ ] Виджеты и часы

## 🛠 Технологический стек

### Frontend
- **Framework:** Flutter 3.9.0+
- **State Management:** Provider
- **UI:** Material Design, fl_chart, flutter_animate

### Backend & Services  
- **Firebase:** Auth, Firestore, Remote Config, Analytics, Crashlytics, Messaging
- **Биллинг:** RevenueCat (purchases_flutter)
- **Погода:** External Weather API
- **Уведомления:** flutter_local_notifications

### Хранение данных
- **Локально:** SharedPreferences
- **Облако:** Firestore (структурированные коллекции)
- **Экспорт:** CSV через path_provider

## 📂 Структура проекта

```
hydracoach/
├── lib/
│   ├── main.dart                      # Точка входа
│   ├── firebase_options.dart          # Конфигурация Firebase
│   │
│   ├── models/                        # Модели данных
│   │   └── alcohol_intake.dart        # Модель приёма алкоголя
│   │
│   ├── screens/                       # Экраны приложения
│   │   ├── home_screen.dart          # Главный экран
│   │   ├── onboarding_screen.dart    # Онбординг
│   │   ├── alcohol_log_screen.dart   # Лог алкоголя
│   │   ├── paywall_screen.dart       # Пейвол
│   │   ├── settings_screen.dart      # Настройки
│   │   ├── history_screen.dart       # История (контейнер)
│   │   └── history/                  # Вкладки истории
│   │       ├── daily_history_screen.dart
│   │       ├── weekly_history_screen.dart
│   │       └── monthly_history_screen.dart
│   │
│   ├── services/                      # Бизнес-логика
│   │   ├── alcohol_service.dart      # Сервис алкоголя
│   │   ├── notification_service.dart # Уведомления
│   │   ├── remote_config_service.dart # Remote Config
│   │   ├── subscription_service.dart  # Подписки
│   │   └── weather_service.dart      # Погода
│   │
│   └── widgets/                       # Переиспользуемые компоненты
│       ├── alcohol_card.dart         # Карточка алкоголя
│       ├── alcohol_checkin_dialog.dart # Утренний чек-ин
│       ├── daily_report.dart         # Дневной отчёт
│       └── weather_card.dart         # Карточка погоды
│
├── assets/
│   └── images/                       # Изображения и иконки
│
├── pubspec.yaml                      # Зависимости
├── firebase.json                     # Конфигурация Firebase
└── README.md                         # Документация
```

## 🚀 Установка и запуск

### Требования
- Flutter SDK 3.9.0 или выше
- Dart SDK 3.0 или выше
- iOS/Android development environment
- Firebase проект с активированными сервисами
- RevenueCat аккаунт для подписок

### Установка

1. **Клонирование репозитория:**
```bash
git clone https://github.com/vtrukhnov-lab/HydraCoach.git
cd hydracoach
```

2. **Установка зависимостей:**
```bash
flutter pub get
```

3. **Конфигурация Firebase:**
```bash
flutterfire configure
```

4. **Запуск приложения:**
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web (в разработке)
flutter run -d chrome
```

## 📊 Алгоритмы расчёта

### Базовые цели воды
```
waterMin = 22 мл × вес(кг)
waterOpt = 30 мл × вес(кг)  
waterMax = 36 мл × вес(кг)
```

### Корректировки по Heat Index
- HI < 27°C: без изменений
- HI 27-32°C: +5% воды, +500mg Na
- HI 32-39°C: +8% воды, +1000mg Na
- HI > 39°C: +12% воды, +1500mg Na

### Алкогольная коррекция
```
Δвода = alcohol_drink_bonus_ml × SD
ΔNa = na_per_sd_mg × SD
SD (стандартный дринк) = 10г чистого спирта
```

## 🔐 Приватность и безопасность

- **GDPR совместимость** — согласия на обработку данных
- **iOS ATT** — корректная обработка разрешений
- **Локальное хранение** — чувствительные данные в SharedPreferences
- **Облачная синхронизация** — только с авторизацией пользователя
- **Трезвый режим** — скрытие алкогольных функций с PIN-защитой

## 🧪 Тестирование

```bash
# Запуск тестов
flutter test

# Анализ кода
flutter analyze

# Форматирование
flutter format lib/
```

## 📈 Метрики успеха

- **Удержание:** D1 > 60%, D7 > 40%, D30 > 25%
- **Конверсия в PRO:** Trial → Paid > 15%
- **HRI в зелёной зоне:** > 70% дней
- **Активность:** > 5 записей/день у активных пользователей

## 🤝 Вклад в проект

Приветствуем вклад в развитие HydraCoach!

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменений (`git commit -m 'Add: удивительная функция'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📄 Лицензия

Распространяется под лицензией MIT. См. [LICENSE](LICENSE) для подробностей.

## 👨‍💻 Автор

**Viktor Trukhnov** - [GitHub](https://github.com/vtrukhnov-lab)

## 🙏 Благодарности

- Вдохновлено потребностью в качественном трекинге гидратации для кето/IF диет
- Weather API для данных о погоде
- Firebase & RevenueCat за отличные сервисы
- Flutter community за поддержку

---

<p align="center">Создано с ❤️ используя Flutter</p>
<p align="center">
  <a href="#hydracoach-">↑ Наверх</a>
</p>