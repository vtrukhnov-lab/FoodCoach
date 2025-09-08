hydracoach/
├── 📱 lib/
│   ├── main.dart                          # Точка входа приложения
│   ├── firebase_options.dart              # Конфигурация Firebase
│   │
│   ├── 🌍 l10n/                          # Локализация
│   │   ├── app_localizations.dart         # Базовый класс локализации
│   │   ├── app_localizations_en.dart      # Английский
│   │   ├── app_localizations_es.dart      # Испанский
│   │   └── app_localizations_ru.dart      # Русский
│   │
│   ├── 📊 models/                        # Модели данных
│   │   ├── alcohol_intake.dart            # Модель алкогольного напитка
│   │   ├── intake.dart                    # Модель обычного приема ✅
│   │   ├── goals.dart                     # Модель целей ✅
│   │   └── quick_favorites.dart           # Модель избранного
│   │
│   ├── 🎨 screens/                       # Экраны приложения
│   │   ├── home_screen.dart              # Главный экран ✅ ОБНОВЛЕН
│   │   ├── onboarding_screen.dart        # Онбординг
│   │   ├── settings_screen.dart          # Настройки
│   │   ├── paywall_screen.dart           # Экран подписки PRO
│   │   │
│   │   ├── history_screen.dart           # История (главный)
│   │   ├── history/                      # Подэкраны истории
│   │   │   ├── daily_history_screen.dart # Дневная история
│   │   │   ├── weekly_history_screen.dart # Недельная история
│   │   │   └── monthly_history_screen.dart # Месячная история
│   │   │
│   │   └── catalogs/                     # Каталоги напитков/добавок
│   │       ├── alcohol_log_screen.dart   # Алкоголь (красный) ✅
│   │       ├── liquids_catalog_screen.dart # Жидкости (синий) ✅
│   │       ├── hot_drinks_screen.dart    # Горячие напитки (коричневый) ✅
│   │       └── supplements_screen.dart   # Добавки (фиолетовый) ✅
│   │
│   ├── ⚙️ services/                      # Сервисы и бизнес-логика
│   │   ├── alcohol_service.dart          # Логика работы с алкоголем
│   │   ├── subscription_service.dart     # Управление подпиской PRO
│   │   ├── remote_config_service.dart    # Remote Config Firebase
│   │   ├── notification_service.dart     # Уведомления
│   │   ├── weather_service.dart          # Погода и Heat Index
│   │   ├── hri_service.dart             # Расчет HRI индекса ✅ ПЕРЕПИСАН
│   │   ├── locale_service.dart           # Управление языками
│   │   └── feature_gate_service.dart     # Гейтинг PRO функций
│   │
│   ├── 📦 providers/                     # Провайдеры (временно)
│   │   └── hydration_provider.dart       # TODO: → services/hydration_service.dart
│   │
│   └── 🧩 widgets/                       # Переиспользуемые виджеты
│       ├── quick_add_widget.dart         # Быстрое добавление
│       ├── alcohol_card.dart             # Карточка алкоголя
│       ├── alcohol_checkin_dialog.dart   # Диалог утреннего чек-ина
│       └── daily_report.dart             # Виджет дневного отчета
│
├── 🎨 assets/                            # Ресурсы
│   ├── images/                           # Изображения
│   │   └── app_icon.png                  # Иконка приложения
│   └── l10n/                             # Файлы переводов
│       ├── app_en.arb                    # Английский
│       ├── app_es.arb                    # Испанский
│       └── app_ru.arb                    # Русский
│
├── 📋 pubspec.yaml                       # Зависимости проекта
└── 📋 l10n.yaml                          # Конфигурация локализации