# Настройка флейворов FoodCoach и FoodMaster Pro

## ✅ Что уже готово:

1. **Конфигурация флейворов** (`lib/config/flavor_config.dart`)
2. **Точки входа:**
   - `lib/main_foodcoach.dart` - для FoodCoach
   - `lib/main_foodcoachsup.dart` - для FoodMaster Pro
3. **Скрипты запуска:**
   - `run_foodcoach.bat` - запуск FoodCoach
   - `run_foodmasterpro.bat` - запуск FoodMaster Pro
4. **Экран home_screen_redesign.dart** скопирован из FoodCoachSUP
5. **SVG иконки** скопированы в assets/icons

## ❗ Что нужно сделать вручную:

### 1. Добавить flutter_svg в pubspec.yaml:
```yaml
dependencies:
  flutter_svg: ^2.2.1
```
Затем выполнить: `flutter pub get`

### 2. Внести изменения в android/app/build.gradle.kts:

После блока `defaultConfig` (строка 39-46) добавить:
```kotlin
flavorDimensions += "app"

productFlavors {
    create("foodcoach") {
        dimension = "app"
        applicationId = "com.playcus.foodcoach"
        manifestPlaceholders["appName"] = "FoodCoach"
    }

    create("foodcoachsup") {
        dimension = "app"
        applicationId = "com.logics7.foodmasterpro"
        manifestPlaceholders["appName"] = "FoodMaster Pro"
    }
}
```

И закомментировать строку 40:
```kotlin
// applicationId = "com.playcus.hydracoach"
```

### 3. Обновить lib/screens/main_shell.dart:

После строки 4 добавить:
```dart
import '../config/flavor_config.dart';
```

После строки 7 добавить:
```dart
import 'home_screen_redesign.dart';
```

В строке 37 заменить:
```dart
const HomeScreen(),
```
на:
```dart
FlavorConfig.useRedesignedHome ? const HomeScreenRedesign() : const HomeScreen(),
```

## 🚀 Как запускать:

### Для разработки:
- **FoodCoach:** `run_foodcoach.bat` или `flutter run --flavor foodcoach -t lib/main_foodcoach.dart`
- **FoodMaster Pro:** `run_foodmasterpro.bat` или `flutter run --flavor foodcoachsup -t lib/main_foodcoachsup.dart`

### Для сборки APK:
- **FoodCoach:** `flutter build apk --flavor foodcoach -t lib/main_foodcoach.dart`
- **FoodMaster Pro:** `flutter build apk --flavor foodcoachsup -t lib/main_foodcoachsup.dart`

### Для сборки AAB (для Google Play):
- **FoodCoach:** `flutter build appbundle --flavor foodcoach -t lib/main_foodcoach.dart`
- **FoodMaster Pro:** `flutter build appbundle --flavor foodcoachsup -t lib/main_foodcoachsup.dart`

## 📱 Различия между версиями:

| Параметр | FoodCoach | FoodMaster Pro |
|----------|-----------|----------------|
| Bundle ID | com.playcus.foodcoach | com.logics7.foodmasterpro |
| Название | FoodCoach | FoodMaster Pro |
| Главный экран | home_screen.dart | home_screen_redesign.dart |

## 🔄 Рабочий процесс:

1. Разрабатывай фичи в единой кодовой базе
2. Тестируй на обоих флейворах
3. Коммить в один репозиторий
4. При необходимости используй условия `FlavorConfig.isFoodCoach` или `FlavorConfig.isFoodCoachSup` для специфичной логики