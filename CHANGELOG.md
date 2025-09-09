# Changelog
All notable changes to HydraCoach will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Next Steps
- Activate real purchases via RevenueCat
- Implement restore purchases functionality
- Add subscription management in settings
- Cloud sync via Firestore
- Export data to CSV/PDF
- Dark theme support
- Home screen widgets

## [1.5.0] - 2025-09-09
🎯 Major Update: Notification System Overhaul
## Added

Event Notification Preservation: Event-based notifications (workout, alcohol, coffee) now persist when changing app language
Smart Time Recovery: Improved algorithm for recovering notification times from IDs, especially for notifications scheduled after 4:40 PM
Localized Text Updates: All notification texts properly update to new language while maintaining scheduled times
Dual ID Scheme Support: Backward compatibility for existing notifications with new enhanced ID generation

## Fixed

Critical: Fixed loss of workout and alcohol notifications when changing language
Time Calculation: Fixed incorrect time calculation for notifications with ID overflow (times after 16:40)
Workout Notifications: Fixed workout reminder times being reset to midnight instead of correct time
Alcohol Recovery Hours: Fixed recovery hour parameter showing 2699h instead of correct 2h, 4h, 6h
ID Generation: Improved ID generation scheme to handle full 24-hour range properly
Language Switch: All event notifications now properly reschedule with correct times and localized texts

## Technical Details

Refactored onLocaleChanged method in NotificationService to properly handle event notifications
Added logic to detect and correct ID overflow for notifications scheduled after 4:40 PM (999 minutes)
Implemented dual ID scheme support for backward compatibility
Added comprehensive time extraction logic for different notification types
Improved handling of alcohol recovery hour parameters from notification titles

## Impact

User Experience: Users can now change language without losing their scheduled notifications
Reliability: Notification system is now more robust and handles edge cases properly
Internationalization: Better support for multi-language usage

## [0.6.2] - 2025-09-08
- Добавлен Ion-персонаж в paywall вместо капли воды
- Увеличены размеры Ion-персонажа в onboarding (60->120, 120->140)
- Исправлен overflow на первом экране onboarding
- Добавлены кнопки 'Назад' на экранах диеты и профиля
- Убрана кнопка 'У меня есть аккаунт' с первого экрана
- Расширен список бенефитов в paywall (5 пунктов)
- Добавлены новые локализации: sportRecoveryProtocols, allDrinksAndSupplements
- Обновлен ползунок веса: 50-200 кг, начальное значение 80 кг
- Улучшен экран уведомлений с 6 примерами функций"

## [0.6.1] - 2025-09-08

### Architecture
- Refactored HRI system following established service/screen/model pattern
- Improved separation of concerns between UI and business logic
- Better state management using existing Provider infrastructure

### Added
- Automatic HRI updates when weather data loads
- Weather change listener for real-time heat stress updates
- Workout and CaffeineIntake models within HRI service
- Debug mode checks for production-safe console output

### Changed
- Complete HRI Service rewrite (lib/services/hri_service.dart)
- Home screen rebuilt with better state management (lib/screens/home_screen.dart)
- Optimized performance by removing unnecessary update cycles

### Fixed
- Heat stress not showing on app startup in hot weather
- Alcohol showing +0 impact despite having standard drinks
- Water ring visualization issues on main progress card
- Magnesium text overflow in electrolyte progress bars
- HRI calculation timing issues with weather data


## [0.6.0] - 2025-09-07
### Added
- **Complete Alcohol Tracking Revamp**
  - Redesigned alcohol logging screen with 3x3 grid (3 FREE, 6 PRO types)
  - 9 alcohol types: Beer, Wine, Spirits + 6 PRO variants (Vodka, Whiskey, Rum, Tequila, Gin, Cocktail)
  - Unified icon system: beer mug, wine glass, bottle for spirits, cocktail glass
  - Save to favorites functionality with slot selection
  - Automatic Standard Drinks (SD) calculation

- **Favorites System Enhancement**
  - Full AlcoholService integration for instant logging
  - Dynamic icon selection based on alcohol type
  - Fixed alcohol favorites not logging to history
  - Material Design icons in favorite slots

- **UI/UX Improvements**
  - Increased drink selection icons to 60px for better visibility
  - Updated text format to "Type: X%" in single line (e.g., "Beer: 5%")
  - Improved icon centering in selection grid
  - Renamed Water category to Liquids for future expansion

### Changed
- Optimized code structure: 700→580 lines in alcohol_log_screen.dart
- Removed unused emoji system in favor of Material Design icons
- Gin and Tequila positions swapped in grid layout

### Fixed
- Alcohol favorites now properly log to history via AlcoholService
- Icon centering in alcohol selection grid
- Removed all hardcoded text strings - full localization support

### Technical
- Clean architecture without redundant enums
- Proper state management for alcohol tracking
- Complete localization integration

[0.5.0] - 2025-09-06
Added

Complete Localization System Refactoring

Implemented Flutter ARB-based localization system
Added support for three languages: English (EN), Russian (RU), Spanish (ES)
Created comprehensive app_en.arb with 200+ localized strings
Added Russian translations (app_ru.arb) with proper declensions
Added Spanish translations (app_es.arb) with regional variations
Integrated flutter_localizations for system UI components

Refactored UI Components

All widgets now use context-based localization
Quick-add buttons display in user's language
Settings screen fully localized
Reports generate in selected language


Remote Config Integration

Paywall texts now pulled from Remote Config per locale
A/B test variants support multiple languages
Error messages configured per language



Fixed06

Fixed missing placeholders in hydration status messages
Resolved RTL layout issues for future Arabic support
Fixed date/time formatting for different locales
Corrected number formatting (decimal separators) per region
Fixed notification scheduling with proper timezone handling

Technical

Added flutter_gen for type-safe localization access
Implemented AppLocalizations.delegate in MaterialApp
Created l10n.yaml configuration for ARB processing
Added locale persistence in SharedPreferences
Integrated intl package for date/number formatting
Set up CI/CD checks for missing translations
Added lint rules for hardcoded string detection

Migration Notes

Developers must run flutter gen-l10n after pulling this update
All new features MUST add strings to app_en.arb first
Use AppLocalizations.of(context)!.keyName for all text
Never commit hardcoded strings - will fail CI checks


## [0.4.0] - 2025-09-04
### Added
- **Redesigned Home Screen**
  - Single water ring with percentage display
  - Three horizontal electrolyte bars (Na/K/Mg)
  - Compact weather card with city and Heat Index
  - Smart Advice card with contextual recommendations
  - Integrated alcohol corrections display

- **Improved HRI Algorithm**
  - Water component "mono-clamp" to prevent sudden jumps
  - Alcohol factor from Remote Config (alc_hri_risk_per_sd)
  - Better handling of goal changes
  - Persistent HRI state between app launches

### Changed
- Weather card increased 2x with more details (city, humidity, description)
- Removed duplicate alcohol indicator
- Progress rings replaced with single ring + bars design
- Morning check-in shows only after alcohol consumption
- Improved state management for alcohol service

### Fixed
- HRI sudden jumps when drinking water
- Weather service property names compatibility
- Morning check-in conditional logic
- Alcohol corrections not updating properly

### Technical
- Refactored home_screen.dart with cleaner component structure
- Added _buildCompactWeatherCard, _buildMainProgressCard methods
- Implemented _clampWaterComponent for HRI stability

## [0.3.0] - 2025-09-04
### Added
- **Complete FREE/PRO Subscription System**
  - Full RevenueCat integration for subscription management
  - Modern paywall screen with three pricing tiers
  - PRO feature gating with soft restrictions
  - PRO indicators (stars) on locked features
  - FREE tier limitations (max 4 notifications/day)

- **Subscription Features**
  - Monthly subscription ($2.99/month)
  - Annual subscription ($19.99/year with 44% discount)
  - Lifetime license ($39.99 one-time)
  - Trial period support (configurable via Remote Config)

- **PRO Features Preparation**
  - Weekly and monthly history restricted to PRO
  - Notification counter for FREE users
  - Smart reminders framework (coffee/heat/alcohol) - PRO only
  - UI indicators for premium features

- **UI/UX Improvements**
  - Material animations on quick-add buttons
  - Smooth transitions for PRO gates
  - Beautiful placeholder screens for locked features
  - Compact paywall design with clear value proposition

### Changed
- History screen now shows PRO badges for weekly/monthly tabs
- Notification service tracks usage for FREE tier limits
- Settings screen displays current subscription status
- Quick-add buttons now have ripple and scale animations

### Fixed
- **Critical Fix:** Water addition not working in release builds
- Fixed UI update order (notifyListeners timing)
- Optimized state management for better performance
- Fixed notification counter persistence

### Technical
- Implemented SubscriptionService with RevenueCat
- Added notification usage tracking
- Enhanced Remote Config with subscription parameters
- Prepared architecture for cloud sync

## [0.2.1] - 2025-09-03
### Added
- **Alcohol tracking in reports**
  - Daily report: alcohol intake display with SD calculations
  - Weekly report: alcohol consumption graph and statistics
  - Monthly report: alcohol indicators in calendar view
  - Filter by alcohol type in daily history

### Fixed
- **Daily History Screen**
  - Fixed LocaleDataException when navigating between dates
  - Fixed crash when navigating to dates more than 2 days in the past
  - Added proper locale initialization for date formatting
  - Added date navigation boundaries (max 1 year back)

- **Weekly History Screen**  
  - Fixed alcohol data not loading properly
  - Added alcohol consumption graph
  - Improved data loading performance

- **Monthly History Screen**
  - Removed blue dot indicator for today
  - Removed water percentage from calendar cells
  - Calendar colors now based only on water consumption
  - Removed achievements block (moved to future separate module)
  - Removed SD daily chart
  - Fixed undefined methods compilation errors

### Changed
- Reports refactored for better performance
- Simplified monthly calendar visualization
- Improved error handling in all history screens

### Technical
- Added `initializeDateFormatting` for Russian locale support
- Refactored history screens to prevent async operations in build
- Optimized data caching with `_loadedDateKey`
- Fixed import conflicts and unused imports

## [0.2.0] - 2025-09-03
### Added
- **PRO Subscription Architecture**
  - RevenueCat integration for subscription management
  - Paywall screen with PRO features description
  - PRO badge and indicator in main screen
  - Subscription provider with state management
  
- **Remote Config Service**
  - Firebase Remote Config integration (local mode for now)
  - Dynamic parameter management for formulas and thresholds
  - Configurable water/electrolyte coefficients
  - Heat Index adjustment thresholds
  - Hydration status parameters
  
- **PRO Features Structure** (Ready for implementation)
  - Smart reminders framework
  - Weekly reports placeholder
  - CSV export preparation
  - Cloud sync preparation
  - Fasting aware mode preparation

### Changed
- Main screen now shows PRO button for non-subscribers
- Updated to MultiProvider architecture for subscription state
- Water and electrolyte goals now use Remote Config values
- Hydration status thresholds managed remotely

### Technical
- Added `subscription_service.dart` for RevenueCat integration
- Added `remote_config_service.dart` for parameter management
- Updated main.dart with SubscriptionProvider
- Fixed RevenueCat 9.x API compatibility
- Prepared architecture for future PRO features

### Fixed
- RevenueCat API compatibility with version 9.x
- Firebase Remote Config import issues

## [0.1.3] - 2025-09-03
### Fixed
- **Critical UI Bug:** Fixed monthly achievements panel not displaying properly in APK builds
- **Daily History Crash:** Resolved red screen error when swiping through previous days
- **Infinite Loop:** Fixed build method calling async operations causing infinite rebuilds
- **Performance:** Optimized data loading for historical days to prevent UI freezing

### Changed
- **Achievement Design:** Improved monthly achievements with better purple gradient and progress indicators
- **Date Navigation:** Enhanced daily history navigation with proper error handling
- **Loading States:** Added loading indicators for better user experience when switching dates

### Technical
- Refactored DailyHistoryScreen to use proper state management
- Added `_loadedDateKey` caching to prevent unnecessary data reloading
- Improved error handling for corrupted SharedPreferences data
- Fixed `build()` method calling async operations directly

## [0.1.2] - 2024-09-02
### Fixed
- **Critical notification bug:** Removed LED notification parameters that caused crashes on Android versions before Oreo (API 26)
- All notification types now working correctly (instant, scheduled, delayed)
- Fixed PlatformException "invalid_led_details" error
- Post-coffee reminders (20-minute delay) now functional

### Changed
- Disabled LED lights for notifications to ensure compatibility with all Android versions
- Improved notification channel configuration for better reliability

### Tested
- Successfully tested on physical Android device
- Verified all notification types: instant, 10-second delay, 1-minute delay
- Confirmed scheduled notifications working properly

## [0.1.1] - 2024-09-02
### Changed
- Removed debug UI elements (FCM token button)
- Cleaned up commented debug code
- Production-ready build configuration

### Fixed
- Fixed unclosed comment blocks in main.dart
- Resolved all compiler warnings
- Fixed import conflicts between modules

### Security
- Wrapped all debug prints in kDebugMode for production safety

## [0.1.0] - 2024-09-02
### Added
- **Firebase Integration**
  - Firebase Cloud Messaging (FCM) for push notifications
  - FCM token generation and management
  - Topic subscriptions (all_users, keto_users, fasting_users)
  - Targeted and broadcast push notifications

- **Notification System**
  - Local notifications via flutter_local_notifications
  - Smart reminders based on Hydration Risk Index
  - Context-aware triggers (post-coffee, heat warnings)
  - Customizable reminder frequency and timing
  - Timezone-aware scheduling

- **Settings Enhancements**
  - Notification management UI
  - Reminder frequency controls (2-8 times per day)
  - Custom quiet hours (morning/evening times)
  - Toggle for special reminders (coffee, heat)

### Changed
- Refactored NotificationService with complete functionality
- Updated Firebase dependencies to compatible versions
- Improved settings screen with notification controls

### Fixed
- Import naming conflicts with prefixes
- Firebase package version incompatibilities
- Settings screen integration issues

## [0.0.9] - 2024-09-01
### Added
- **Core Tracking Features**
  - Water intake tracking (ml/oz)
  - Electrolyte monitoring (Na, K, Mg)
  - Quick-add preset buttons
  - Intake history with swipe-to-delete

- **Weather Integration**
  - OpenWeatherMap API integration
  - Automatic location detection
  - Heat Index calculation
  - Dynamic goal adjustments based on temperature

- **Monthly Analytics**
  - Achievement system with 10 unlockable rewards
  - Heatmap calendar showing daily progress
  - Monthly statistics and trends
  - Progress tracking for streaks and consistency

- **Personalization**
  - Onboarding flow (weight, diet mode, activity level)
  - Three diet modes: Normal, Keto, Intermittent Fasting
  - Activity levels: Low, Medium, High
  - Profile settings management

- **Visual Features**
  - Animated progress rings
  - Hydration Risk Index (HRI) indicator
  - Status badges (Normal, Dehydration, Dilution, Low Salt)
  - Weather card with real-time updates
  - Daily report modal (after 9 PM)

### Known Issues (Fixed in 0.1.3)
- Monthly achievements panel display issues in APK builds
- Daily history crashes when navigating to previous days
- Performance issues with historical data loading

## [0.0.5] - 2024-08-28
### Added
- Initial project setup
- Basic Flutter app structure
- Provider state management
- SharedPreferences for local storage

---

## Version Guidelines
### Version Numbers
- **Major (1.0.0):** Breaking changes, major feature releases
- **Minor (0.1.0):** New features, backwards compatible
- **Patch (0.0.1):** Bug fixes, minor improvements

### Categories
- **Added:** New features
- **Changed:** Changes in existing functionality
- **Deprecated:** Soon-to-be removed features
- **Removed:** Removed features
- **Fixed:** Bug fixes
- **Security:** Vulnerability fixes
- **Technical:** Code improvements, refactoring