@echo off
echo ======================================
echo Настройка флейворов FoodCoach
echo ======================================

echo.
echo 1. Добавляем flutter_svg в pubspec.yaml...
echo   flutter_svg: ^2.2.1 >> pubspec.yaml.tmp
type pubspec.yaml | findstr /v "dev_dependencies:" >> pubspec.yaml.tmp
echo   flutter_svg: ^2.2.1>> pubspec.yaml.tmp
echo.>> pubspec.yaml.tmp
echo dev_dependencies:>> pubspec.yaml.tmp
type pubspec.yaml | findstr /A:100 "dev_dependencies:" >> pubspec.yaml.tmp
echo ВНИМАНИЕ: Добавьте flutter_svg: ^2.2.1 в pubspec.yaml вручную перед dev_dependencies

echo.
echo 2. Запускаем flutter pub get...
flutter pub get

echo.
echo ======================================
echo ВАЖНО! Выполните вручную:
echo ======================================
echo.
echo 1) В pubspec.yaml добавьте перед dev_dependencies:
echo    flutter_svg: ^2.2.1
echo.
echo 2) В android/app/build.gradle.kts после defaultConfig добавьте:
echo.
echo    flavorDimensions += "app"
echo.
echo    productFlavors {
echo        create("foodcoach") {
echo            dimension = "app"
echo            applicationId = "com.playcus.foodcoach"
echo            manifestPlaceholders["appName"] = "FoodCoach"
echo        }
echo.
echo        create("foodcoachsup") {
echo            dimension = "app"
echo            applicationId = "com.logics7.foodmasterpro"
echo            manifestPlaceholders["appName"] = "FoodMaster Pro"
echo        }
echo    }
echo.
echo 3) В lib/screens/main_shell.dart добавьте:
echo    - После строки 4: import '../config/flavor_config.dart';
echo    - После строки 7: import 'home_screen_redesign.dart';
echo    - В строке 37 замените HomeScreen() на:
echo      FlavorConfig.useRedesignedHome ? const HomeScreenRedesign() : const HomeScreen(),
echo.
echo После внесения изменений:
echo - Запустите run_foodcoach.bat для FoodCoach
echo - Запустите run_foodmasterpro.bat для FoodMaster Pro
echo.
pause